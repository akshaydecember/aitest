#!/usr/bin/env bash
set -euo pipefail
echo "Initializing repository branches (dev, stage, main)..."
git branch -M main || true
git checkout -b dev || git checkout dev
git checkout -b stage || git checkout stage
git checkout main
echo "Branches created: dev, stage, main"
