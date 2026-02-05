#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="${SCRIPT_DIR}/ctrlplane"

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required but not installed or not on PATH." >&2
  exit 1
fi

if ! helm plugin list 2>/dev/null | awk '{print $1}' | grep -qx "unittest"; then
  echo "helm-unittest plugin is required. Install with:" >&2
  echo "  helm plugin install https://github.com/helm-unittest/helm-unittest" >&2
  exit 1
fi

echo "Running helm-unittest for ${CHART_DIR}"
helm unittest "${CHART_DIR}"
