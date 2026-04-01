package com.skala.springbootsample.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * HPA 테스트를 위한 CPU / Memory 부하 생성 컨트롤러
 *
 * CPU 부하  (스레드 1개 고정)
 *   GET /api/load-cpu                      → 기본값: 30초
 *   GET /api/load-cpu?duration-sec=60      → 지정 시간(초)
 *
 * Memory 부하  (단계적 할당 – HPA ScaleOut 유도)
 *   GET /api/load-memory
 *   GET /api/load-memory?duration-sec=180&size-mb=160&step-mb=10&step-interval-sec=5
 *
 *   파라미터 설명
 *     duration-sec       : 메모리를 유지할 총 시간 (기본 180초)
 *                          HPA 감지(~15s) + 스케일 결정 + Pod 기동(~60s) = 최소 120s 이상 권장
 *     size-mb            : 최종 목표 메모리 (기본 160 MB)
 *                          request=256Mi, HPA 50% 기준 → 128Mi 초과해야 ScaleOut 발동
 *                          limit=512Mi 이하로 유지해야 OOMKill 방지
 *     step-mb            : 1회 증가량 (기본 10 MB) – 작을수록 HPA 반응 전 OOM 위험 감소
 *     step-interval-sec  : 증가 주기 (기본 5초) – HPA scrape interval 고려해 5s 이상 권장
 *
 * ※ 권장 HPA 시나리오 (request=256Mi / limit=512Mi / averageUtilization=50)
 *   curl ".../load-memory?duration-sec=180&size-mb=160&step-mb=10&step-interval-sec=5"
 *   → 5초마다 10MB씩 증가 → 약 80초에 160MB 도달 → HPA ScaleOut → 180초 후 해제
 */
@RestController
@RequestMapping("/api")
public class LoadController {

    private static final int DEFAULT_CPU_DURATION_SEC    = 30;

    // Memory 기본값 – request=256Mi / limit=512Mi / HPA 50% 환경 기준
    private static final int DEFAULT_MEM_DURATION_SEC    = 180;  // HPA 반응 + Pod 기동 여유 시간
    private static final int DEFAULT_MEM_SIZE_MB         = 160;  // 128Mi(=HPA 임계) 초과, 512Mi 이하
    private static final int DEFAULT_MEM_STEP_MB         = 10;   // 1회 증가량
    private static final int DEFAULT_MEM_STEP_INTERVAL   = 5;    // 증가 주기(초)

    // ── CPU 부하 ─────────────────────────────────────────────────────────────

    @GetMapping("/load-cpu")
    public ResponseEntity<Map<String, Object>> loadCpu(
            @RequestParam(name = "duration-sec", defaultValue = "" + DEFAULT_CPU_DURATION_SEC) int durationSec) {

        int safeDuration = clamp(durationSec, 1, 300);
        long endTime = System.currentTimeMillis() + safeDuration * 1000L;

        while (System.currentTimeMillis() < endTime) {
            Math.pow(Math.random(), Math.random());
        }

        return ResponseEntity.ok(Map.of(
                "type",        "cpu",
                "durationSec", safeDuration,
                "threads",     1,
                "status",      "completed"
        ));
    }

    // ── Memory 부하 (단계적 할당 – HPA ScaleOut 유도) ─────────────────────────

    /**
     * 메모리를 step-mb 단위로 step-interval-sec 마다 증가시켜
     * HPA가 메트릭을 감지하고 ScaleOut 할 시간을 확보한다.
     *
     * OOMKill 방지 원칙
     *  1. size-mb 상한을 limit의 70%(≈358MB) 이하로 제한
     *  2. OOM 발생 시 즉시 할당 중단하고 보유 메모리를 유지한 채 대기
     *  3. 전체 청크를 Arrays.fill로 채워 GC가 수거하지 못하게 함
     */
    @GetMapping("/load-memory")
    public ResponseEntity<Map<String, Object>> loadMemory(
            @RequestParam(name = "duration-sec",       defaultValue = "" + DEFAULT_MEM_DURATION_SEC)  int durationSec,
            @RequestParam(name = "size-mb",            defaultValue = "" + DEFAULT_MEM_SIZE_MB)        int sizeMb,
            @RequestParam(name = "step-mb",            defaultValue = "" + DEFAULT_MEM_STEP_MB)        int stepMb,
            @RequestParam(name = "step-interval-sec",  defaultValue = "" + DEFAULT_MEM_STEP_INTERVAL)  int stepIntervalSec) {

        int safeDuration = clamp(durationSec,      10,  600);
        int safeSize     = clamp(sizeMb,            1,  358);  // limit 512Mi * 0.7 ≈ 358MB 상한
        int safeStep     = clamp(stepMb,            1,   50);
        int safeInterval = clamp(stepIntervalSec,   1,   30);

        List<byte[]> blocks   = new ArrayList<>();
        int  allocatedMb      = 0;
        boolean oomOccurred   = false;
        long startTime        = System.currentTimeMillis();
        long allocationEnd    = startTime + safeDuration * 1000L;

        // ── 1단계: 단계적 메모리 할당 ───────────────────────────────────────
        while (allocatedMb < safeSize
                && System.currentTimeMillis() < allocationEnd
                && !Thread.currentThread().isInterrupted()) {

            int chunkMb = Math.min(safeStep, safeSize - allocatedMb);
            try {
                byte[] chunk = new byte[chunkMb * 1024 * 1024];
                Arrays.fill(chunk, (byte) 1);   // GC 수거 방지
                blocks.add(chunk);
                allocatedMb += chunkMb;
            } catch (OutOfMemoryError e) {
                oomOccurred = true;
                break;  // 할당 중단 지금까지 확보한 메모리는 유지
            }

            // 목표에 도달하지 않았으면 다음 증가까지 대기
            if (allocatedMb < safeSize && !oomOccurred) {
                try {
                    Thread.sleep(safeInterval * 1000L);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        }

        // ── 2단계: 잔여 duration 동안 메모리 유지 (HPA Scale 대기) ───────────
        long remainMs = allocationEnd - System.currentTimeMillis();
        if (remainMs > 0 && !Thread.currentThread().isInterrupted()) {
            try {
                Thread.sleep(remainMs);
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
            }
        }

        long elapsedSec = (System.currentTimeMillis() - startTime) / 1000;

        // ── 3단계: 참조 해제 → GC 수거 가능 ────────────────────────────────
        blocks.clear();

        // ── 응답 ─────────────────────────────────────────────────────────────
        if (oomOccurred && allocatedMb == 0) {
            return ResponseEntity.status(HttpStatus.INSUFFICIENT_STORAGE).body(Map.of(
                    "type",    "memory",
                    "status",  "failed",
                    "error",   "OutOfMemoryError: 첫 번째 청크(" + safeStep + " MB) 할당 실패. size-mb / step-mb를 줄여주세요."
            ));
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("type",                "memory");
        result.put("status",              oomOccurred ? "partial" : "completed");
        result.put("requestedSizeMb",     safeSize);
        result.put("allocatedMb",         allocatedMb);
        result.put("stepMb",              safeStep);
        result.put("stepIntervalSec",     safeInterval);
        result.put("durationSec",         safeDuration);
        result.put("elapsedSec",          elapsedSec);
        if (oomOccurred) {
            result.put("warn", "목표 크기 도달 전 OOM 발생 – " + allocatedMb + " MB 까지만 할당됨");
        }
        return ResponseEntity.ok(result);
    }

    // ── 공통 유틸 ─────────────────────────────────────────────────────────────

    private int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(max, value));
    }
}

