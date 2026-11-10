#!/usr/bin/env bash
set -u

if [[ $# -ne 1 || -z ${1:-} ]]; then
  printf 'Использование: %s <URL>\n' "$0" >&2
  exit 1
fi

url=$1
if [[ ! $url =~ ^https?://[^[:space:]]+$ ]]; then
  printf 'API недоступен, код ответа: 000 (некорректный URL)\n' >&2
  exit 1
fi

if ! status=$(curl --silent --show-error --location --output /dev/null \
  --connect-timeout 5 --max-time 15 --write-out '%{http_code}' "$url"); then
  printf 'API недоступен, код ответа: %s\n' "${status:-000}"
  exit 1
fi

if [[ $status == 200 ]]; then
  printf 'API доступен\n'
  exit 0
fi

printf 'API недоступен, код ответа: %s\n' "$status"
exit 1
