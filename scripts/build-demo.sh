#!/bin/sh
# Copies the prototype into the website as a standalone page (website/demo.html).
# Run after changing prototype/index.html, then republish the website.
set -e
cd "$(dirname "$0")/.."
{
  printf '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"><style>body{margin:0}</style></head><body>\n'
  cat prototype/index.html
  printf '\n</body></html>\n'
} > website/demo.html
echo "Built website/demo.html"
