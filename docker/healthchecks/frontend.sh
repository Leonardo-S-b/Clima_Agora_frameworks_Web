#!/bin/sh

# Verifica se o servidor web está respondendo a requisições HTTP.
set -eu

PORT="${PORT:-8080}"

curl --fail --silent --show-error "http://127.0.0.1:${PORT}/" >/dev/null