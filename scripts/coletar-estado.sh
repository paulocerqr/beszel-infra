#!/usr/bin/env bash
set -euo pipefail

date -u '+UTC %Y-%m-%dT%H:%M:%SZ'
free -h
df -h

if ! command -v docker >/dev/null 2>&1; then
  echo 'Docker ausente; coleta de containers indisponível.' >&2
  exit 1
fi
if ! containers=$(docker ps --filter name=beszel --format '{{.Names}}'); then
  echo 'Não foi possível consultar Docker; verifique serviço e permissões.' >&2
  exit 1
fi
if [[ -z "$containers" ]]; then
  echo 'Nenhum container em execução com nome contendo beszel.' >&2
  exit 1
fi
docker ps --filter name=beszel --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
mapfile -t names <<< "$containers"
docker stats --no-stream "${names[@]}"
