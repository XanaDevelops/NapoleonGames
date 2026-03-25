#!/usr/bin/env bash
set -euo pipefail

TARGET_SHA="$1"
BASE_BRANCH="$2"

git fetch origin "${BASE_BRANCH}:refs/remotes/origin/${BASE_BRANCH}"

if git merge-base --is-ancestor "$TARGET_SHA" "origin/${BASE_BRANCH}"; then
  echo "OK: ${TARGET_SHA} ja està validat a ${BASE_BRANCH}"
else
  echo "ERROR: ${TARGET_SHA} NO està validat a ${BASE_BRANCH}"
  exit 1
fi