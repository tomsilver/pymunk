#!/usr/bin/env bash
set -euo pipefail

rm -rf dist
mkdir dist

echo "Downloading artifacts from latest master CI run..."
gh run download "$(gh run list --branch master --workflow Build --status completed --limit 1 --json databaseId --jq '.[0].databaseId')" --dir dist

# gh creates a subdirectory per artifact; flatten all wheels and sdists into dist/
find dist -mindepth 2 \( -name '*.whl' -o -name '*.tar.gz' \) -exec mv {} dist/ \;
find dist -mindepth 1 -type d -empty -delete

echo "Contents of dist/:"
ls dist/

echo ""
read -p "Publish to PyPI? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    uv publish dist/*
else
    echo "Aborted."
fi
