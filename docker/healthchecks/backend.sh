#!/bin/sh

# Verifica se a API respondeu no endpoint de saúde.
set -eu

PORT="${PORT:-8787}"

curl --fail --silent --show-error "http://127.0.0.1:${PORT}/health" >/dev/null