#!/usr/bin/env bash
set -euo pipefail

log_file=${1:-access.log}

# Generate reproducible 360-line sample when no external log file is supplied.
if [[ $# -eq 0 ]]; then
  : > "$log_file"
  for ((i = 0; i < 360; i++)); do
    case $((i % 6)) in
      0|1|2) ip=192.168.1.10 ;;
      3|4) ip=10.0.0.5 ;;
      5) ip=172.16.0.8 ;;
    esac
    case $((i % 10)) in
      0) method=POST; endpoint=/api/login; code=401 ;;
      1) method=GET; endpoint=/api/missing; code=404 ;;
      2) method=GET; endpoint=/api/error; code=500 ;;
      3) method=GET; endpoint=/api/error; code=503 ;;
      *) method=GET; endpoint=/api/users; code=200 ;;
    esac
    printf '%s - - [15/Aug/2026:10:%02d:%02d] "%s %s HTTP/1.1" %s\n' \
      "$ip" "$(((i / 60) % 60))" "$((i % 60))" "$method" "$endpoint" "$code" >> "$log_file"
  done
fi

if [[ ! -f $log_file || ! -r $log_file ]]; then
  printf 'Не удалось прочитать файл: %s\n' "$log_file" >&2
  exit 1
fi

# Match the IPv4 field at the beginning of each access-log line.
ip_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}[[:space:]]'
printf 'Файл: %s\n' "$log_file"
printf 'Общее количество запросов: %s\n' "$(wc -l < "$log_file" | tr -d ' ')"
printf 'Топ-3 IP-адресов:\n'
grep -E "$ip_regex" "$log_file" | awk '{print $1}' | sort | uniq -c | sort -k1,1nr -k2,2 | head -n 3 || true
awk '/" (4[0-9][0-9])([[:space:]]|$)/ {n++} END {print "Количество 4xx:", n+0}' "$log_file"
awk '/" (5[0-9][0-9])([[:space:]]|$)/ {n++} END {print "Количество 5xx:", n+0}' "$log_file"
