#!/bin/bash

set -e

MODULE_NAME=$(basename "$(pwd)")
MEDIA_DIR="$(git rev-parse --show-toplevel)/media"
GRAPH_FILE="${MODULE_NAME}_graph.svg"

echo "Generating documentation for: $MODULE_NAME"

mkdir -p "$MEDIA_DIR"

docker run --rm \
  --volume "$(pwd):/terraform-docs" \
  -u "$(id -u)" \
  quay.io/terraform-docs/terraform-docs \
  markdown /terraform-docs > README.md

terraform graph | dot -Tsvg > "$MEDIA_DIR/$GRAPH_FILE"

RELATIVE_PATH=$(realpath --relative-to="$(pwd)" "$MEDIA_DIR")

cat >> README.md << EOF

## Diagram

![Terraform Graph](${RELATIVE_PATH}/${GRAPH_FILE})
EOF

echo "Done! README.md updated with diagram."