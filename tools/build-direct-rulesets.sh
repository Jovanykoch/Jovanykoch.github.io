#!/usr/bin/env bash
set -euo pipefail

# Build 2 Surge-ready rulesets from rules/direct.txt
#
# Input:
#   rules/direct.txt
#
# Outputs:
#   rules/direct-domain-set.list      (domain list, one per line)
#   rules/direct-domain-suffix.list   (domain suffix list, one per line, WITHOUT leading dot)
#
# Notes:
# - Lines like ".010.cc" are treated as suffix intent and moved into suffix output as "010.cc".
# - Regular domains like "apple.com" stay in domain-set output.
# - We remove comments/blank lines, normalize to lowercase, validate characters, dedup + sort.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IN="${REPO_ROOT}/rules/direct.txt"

OUT_DOMAIN="${REPO_ROOT}/rules/direct-domain-set.list"
OUT_SUFFIX="${REPO_ROOT}/rules/direct-domain-suffix.list"

TMPD="$(mktemp -d)"
trap 'rm -rf "$TMPD"' EXIT

if [[ ! -f "$IN" ]]; then
  echo "ERROR: input not found: $IN" >&2
  exit 1
fi

normalize_stream() {
  # - strip CRLF
  # - trim
  # - drop empty
  # - drop comment-ish lines
  # - lowercase
  tr -d '\r' \
    | sed -e 's/^[[:space:]]\+//g' -e 's/[[:space:]]\+$//g' \
    | awk 'NF>0' \
    | awk '{
        line=$0
        if (line ~ /^#/) next
        if (line ~ /^\/\//) next
        if (line ~ /^;/) next
        print line
      }' \
    | tr '[:upper:]' '[:lower:]'
}

is_domainish_awk='
  {
    line=$0
    # allowed chars only
    if (line ~ /[^a-z0-9\.\-]/) next
    # must contain at least one dot
    if (line !~ /\./) next
    # basic guards against weird leading/trailing dots/hyphens
    if (line ~ /^\./) next
    if (line ~ /\.$/) next
    if (line ~ /^\-/) next
    if (line ~ /\-$/) next
    print line
  }
'

# Split into:
#  - suffix candidates: lines that start with '.' + domainish after removing leading dot
#  - domain candidates: lines that do not start with '.'
cat "$IN" | normalize_stream > "${TMPD}/normalized.txt"

# Suffix lines: ".example.com" -> "example.com"
awk '
  {
    line=$0
    if (line ~ /^\./) {
      sub(/^\./, "", line)
      print line
    }
  }
' "${TMPD}/normalized.txt" | awk "$is_domainish_awk" > "${TMPD}/suffix.raw"

# Domain lines: "example.com"
awk '
  {
    line=$0
    if (line !~ /^\./) print line
  }
' "${TMPD}/normalized.txt" | awk "$is_domainish_awk" > "${TMPD}/domain.raw"

# Dedup + sort (stable, reproducible)
LC_ALL=C sort -u "${TMPD}/domain.raw" > "${TMPD}/domain.sorted"
LC_ALL=C sort -u "${TMPD}/suffix.raw" > "${TMPD}/suffix.sorted"

write_header() {
  local kind="$1"
  local out="$2"
  local lines="$3"
  {
    echo "# Surge ${kind}"
    echo "# Source: rules/direct.txt"
    echo "# Generated at (UTC): $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "# Lines: ${lines}"
    echo "#"
  } > "$out"
}

write_header "DOMAIN-SET (exact domains, one per line)" "$OUT_DOMAIN" "$(wc -l < "${TMPD}/domain.sorted")"
cat "${TMPD}/domain.sorted" >> "$OUT_DOMAIN"

write_header "DOMAIN-SUFFIX-SET (suffix domains, one per line, no leading dot)" "$OUT_SUFFIX" "$(wc -l < "${TMPD}/suffix.sorted")"
cat "${TMPD}/suffix.sorted" >> "$OUT_SUFFIX"

echo "OK:"
echo "  input                    : $IN ($(wc -l < "$IN") lines)"
echo "  domain-set output         : $OUT_DOMAIN ($(grep -vc '^[#]' "$OUT_DOMAIN") rules)"
echo "  domain-suffix-set output  : $OUT_SUFFIX ($(grep -vc '^[#]' "$OUT_SUFFIX") rules)"
