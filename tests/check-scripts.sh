#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT

cat > "$scratch/curl" <<'MOCK'
#!/usr/bin/env bash
printf '%s' "${TEST_HTTP:-200}"
exit "${TEST_CURL_EXIT:-0}"
MOCK
cat > "$scratch/docker" <<'MOCK'
#!/usr/bin/env bash
if [[ ${TEST_DOCKER_EXIT:-0} != 0 ]]; then exit 1; fi
case "$1" in
  ps) printf '%s' "${TEST_CONTAINERS-beszel-agent}" ;;
  stats) [[ "$*" == 'stats --no-stream beszel-agent' ]] ;;
  *) exit 1 ;;
esac
MOCK
chmod +x "$scratch/curl" "$scratch/docker"
export PATH="$scratch:$PATH"

expect_failure() {
  if "$@" > "$scratch/output" 2>&1; then
    echo "FALHA: comando deveria falhar: $*" >&2
    exit 1
  fi
}

for script in scripts/*.sh tests/check-scripts.sh; do
  bash -n "$script"
done
bash scripts/verificar-hub.sh https://hub.example.ts.net > "$scratch/output"
expect_failure bash scripts/verificar-hub.sh
expect_failure bash scripts/verificar-hub.sh http://hub.example.ts.net
expect_failure bash scripts/verificar-hub.sh https://user:secret@hub.example.ts.net
expect_failure bash scripts/verificar-hub.sh 'https://hub.example.ts.net/?token=secret'
expect_failure bash scripts/verificar-hub.sh 'https://hub.example.ts.net/#secret'
expect_failure env TEST_HTTP=503 bash scripts/verificar-hub.sh https://hub.example.ts.net
expect_failure env TEST_CURL_EXIT=6 bash scripts/verificar-hub.sh https://hub.example.ts.net
bash scripts/coletar-estado.sh > "$scratch/output"
expect_failure env TEST_DOCKER_EXIT=1 bash scripts/coletar-estado.sh
expect_failure env TEST_CONTAINERS= bash scripts/coletar-estado.sh
printf 'OK: sintaxe, HTTPS, rejeição de URLs com credenciais e falhas de DNS/HTTP/Docker.\n'
