#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

TEMPLATE_FILE="${1:-museum.yaml}"
OUTPUT_FILE="${2:-museum.rendered.yaml}"
ENV_FILE="${ENV_FILE:-./.env}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing env file: $ENV_FILE" >&2
  exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Missing template file: $TEMPLATE_FILE" >&2
  exit 1
fi

set -a
# shellcheck source=.env
. "$ENV_FILE"
set +a

awk '
{
  line = $0
  while (match(line, /\$\{[A-Za-z_][A-Za-z0-9_]*\}/)) {
    var = substr(line, RSTART + 2, RLENGTH - 3)
    if (!(var in ENVIRON)) {
      printf("Missing environment variable: %s\n", var) > "/dev/stderr"
      exit 1
    }
    val = ENVIRON[var]
    line = substr(line, 1, RSTART - 1) val substr(line, RSTART + RLENGTH)
  }
  print line
}
' "$TEMPLATE_FILE" > "$OUTPUT_FILE"

if grep -Eq '\$\{[A-Za-z_][A-Za-z0-9_]*\}' "$OUTPUT_FILE"; then
  echo "Unresolved placeholders found in $OUTPUT_FILE" >&2
  exit 1
fi

echo "Rendered $OUTPUT_FILE from $TEMPLATE_FILE using $ENV_FILE"
