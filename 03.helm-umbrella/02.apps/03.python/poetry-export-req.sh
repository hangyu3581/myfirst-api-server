#!/bin/bash

# poetry export --format requirements.txt --output requirements.txt --without-hashes --only main
#
poetry export -f requirements.txt -o requirements.txt --without-hashes

