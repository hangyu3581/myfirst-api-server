/**
 * User API
 *
 * - 로컬 개발 (npm run dev): Vite proxy가 /api → http://localhost:8080 으로 중계
 * - K8s 배포 후: 동일 도메인에서 /api 로 직접 요청 (Ingress가 Spring Boot로 라우팅)
 */
const API_BASE = '/api'

/**
 * 전체 사용자 목록 조회
 * @returns {Promise<Array<{id: number, name: string, email: string, region: {id: number, name: string}}>>}
 */
export async function getUsers() {
  const response = await fetch(`${API_BASE}/users`)
  if (!response.ok) {
    throw new Error(`사용자 조회 실패: ${response.status} ${response.statusText}`)
  }
  return response.json()
}
