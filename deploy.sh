#!/usr/bin/env bash
# deploy.sh — Build al-folio site locally and push to gh-pages branch
# Usage: ./deploy.sh (run from repo root)
#
# Deployment strategy: main branch holds al-folio source (this file lives here);
# gh-pages branch holds the built static _site (what GitHub Pages actually serves).
# This script builds + pushes gh-pages in one command.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKTREE_DIR="${REPO_DIR}/../cuteyyt-ghpages"

cd "$REPO_DIR"

# 1. Verify on main branch
current_branch="$(git symbolic-ref --short HEAD)"
if [[ "$current_branch" != "main" ]]; then
  echo "ERROR: must be on 'main' branch to deploy (currently on '$current_branch')" >&2
  exit 1
fi

# 2. Verify working tree is clean (no uncommitted source changes)
if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: working tree not clean. Commit or stash source changes first." >&2
  git status --short
  exit 1
fi

# 3. Fresh build
echo "==> Building site..."
rm -rf _site .jekyll-cache
bundle exec jekyll build

# 4. Get short SHA for commit message
MAIN_SHA="$(git rev-parse --short main)"

# 5. Prep gh-pages worktree
echo "==> Preparing gh-pages worktree..."
if [[ -d "$WORKTREE_DIR" ]]; then
  rm -rf "$WORKTREE_DIR"
fi
git fetch origin gh-pages 2>/dev/null || true
git worktree add -B gh-pages "$WORKTREE_DIR" origin/gh-pages 2>/dev/null || \
  git worktree add -B gh-pages "$WORKTREE_DIR" main

# 6. Clear worktree and copy fresh _site contents
cd "$WORKTREE_DIR"
git rm -rf . >/dev/null 2>&1 || true
cp -r "$REPO_DIR/_site/." .
touch .nojekyll

# 7. Commit and push
git add -A
if [[ -z "$(git status --porcelain)" ]]; then
  echo "==> No changes to deploy (site content identical to previous)."
else
  git commit -m "Deploy site (built from main@${MAIN_SHA})"
  echo "==> Pushing gh-pages..."
  git push origin gh-pages
fi

# 8. Cleanup
cd "$REPO_DIR"
git worktree remove "$WORKTREE_DIR" --force 2>/dev/null || rm -rf "$WORKTREE_DIR"

echo ""
echo "==> Done. Site will be live at https://cuteyyt.github.io/ within ~1 minute."
echo "==> Check status: https://github.com/cuteyyt/cuteyyt.github.io/actions"
