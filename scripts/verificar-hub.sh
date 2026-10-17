#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]] || [[ ! "$1" =~ ^https://[a-zA-Z0-9.-]+(:[0-9]+)?(/[^[:space:]\?\#\@]*)?$ ]]; then
  echo "Uso: bash $0 https://seu-hub.seu-tailnet.ts.net (sem credenciais, query ou fragmento)" >&2
  exit 2
fi
if ! code=$(curl --proto '=https' --connect-timeout 10 --max-time 20 \
  --silent --show-error --output /dev/null --write-out '%{http_code}' "$1"); then
  echo 'Falha ao acessar HTTPS; confira DNS, rede e certificado.' >&2
  exit 1
fi
printf 'HTTP %s\n' "$code"
if [[ "$code" != 200 ]]; then
  echo 'Resposta diferente de HTTP 200; confira a URL e o Hub.' >&2
  exit 1
fi
echo 'HTTPS acessível pelo host; WebSocket e autenticação do Agent não foram testados.'
