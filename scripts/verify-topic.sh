#!/usr/bin/env bash
set -euo pipefail

TOPIC="${1:-x0x.commons.agent-conventions.v1}"
TIMEOUT_SECONDS="${VERIFY_TIMEOUT_SECONDS:-30}"

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

need curl
need jq
need awk
need base64
need grep
need tail

api_address="${X0X_API_ADDRESS:-}"
api_token="${X0X_API_TOKEN:-}"

if [[ -z "$api_address" || -z "$api_token" ]]; then
  for data_dir in "$HOME/Library/Application Support/x0x" "$HOME/.local/share/x0x"; do
    if [[ -z "$api_address" && -f "$data_dir/api.port" ]]; then
      api_address="$(<"$data_dir/api.port")"
    fi

    if [[ -z "$api_token" && -f "$data_dir/api-token" ]]; then
      api_token="$(<"$data_dir/api-token")"
    fi
  done
fi

if [[ -z "$api_address" ]]; then
  api_address="127.0.0.1:12700"
fi

base_url="$api_address"
if [[ "$base_url" != http://* && "$base_url" != https://* ]]; then
  base_url="http://$base_url"
fi

auth_args=()
if [[ -n "$api_token" ]]; then
  auth_args=(-H "Authorization: Bearer $api_token")
fi

printf 'Subscribing to %s via %s\n' "$TOPIC" "$base_url"

curl -fsS \
  -X POST \
  "${base_url%/}/subscribe" \
  "${auth_args[@]}" \
  -H 'Content-Type: application/json' \
  -d "$(jq -nc --arg topic "$TOPIC" '{topic: $topic}')" \
  >/dev/null

tmp_events="$(mktemp)"
trap 'rm -f "$tmp_events"' EXIT

set +e
curl -fsS -N --max-time "$TIMEOUT_SECONDS" \
  "${base_url%/}/events" \
  "${auth_args[@]}" \
  >"$tmp_events"
curl_status=$?
set -e

if [[ $curl_status -ne 0 && $curl_status -ne 28 ]]; then
  printf 'failed to read x0x events stream, curl exit status %s\n' "$curl_status" >&2
  exit "$curl_status"
fi

event_json="$(awk '/^data: / { sub(/^data: /, ""); print; next } /^[[:space:]]*{/ { print }' "$tmp_events" | jq -c --arg topic "$TOPIC" 'select((.topic // .message.topic // "") == $topic)' | tail -n 1)"

if [[ -z "$event_json" ]]; then
  printf 'no messages observed on %s within %s seconds\n' "$TOPIC" "$TIMEOUT_SECONDS" >&2
  exit 1
fi

payload="$(jq -r '.payload // .message.payload // empty' <<<"$event_json")"
if [[ -z "$payload" ]]; then
  printf 'observed topic message did not contain a payload\n' >&2
  exit 1
fi

if base64 --help 2>&1 | grep -q -- '--decode'; then
  decoded="$(printf '%s' "$payload" | base64 --decode)"
else
  decoded="$(printf '%s' "$payload" | base64 -D)"
fi

jq -e --arg topic "$TOPIC" '
  .schemaVersion == 1 and
  (.version | type == "number") and
  .topic == $topic and
  (.publisher | type == "object") and
  (.signature | type == "object") and
  (.manifest.schemaVersion == 1) and
  (.manifest.version | type == "number") and
  (.manifest.agents | type == "array")
' <<<"$decoded" >/dev/null

printf 'observed valid envelope-shaped snapshot on %s\n' "$TOPIC"
printf 'version: %s\n' "$(jq -r '.manifest.version' <<<"$decoded")"
printf 'agents: %s\n' "$(jq -r '.manifest.agents | length' <<<"$decoded")"
