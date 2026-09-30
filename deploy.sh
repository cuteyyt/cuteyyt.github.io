#!/usr/bin/env bash
# Build locally and publish generated output to the existing gh-pages branch.
# Usage: ./deploy.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
case "${1:-}" in
  "") ;;
  --help|-h) echo "Usage: $0"; exit 0 ;;
  *) echo "ERROR: unknown argument: $1" >&2; exit 1 ;;
esac
if [[ $# -gt 1 ]]; then
  echo "ERROR: expected at most one argument." >&2
  exit 1
fi

cd "$REPO_DIR"

# Verify source ownership and state before writing any publishing files.
GIT_ROOT="$(git rev-parse --show-toplevel)"
GIT_ROOT="$(cd "$GIT_ROOT" && pwd -P)"
if [[ "$GIT_ROOT" != "$REPO_DIR" ]]; then
  echo "ERROR: deploy.sh must be in the source repository root." >&2
  exit 1
fi
current_branch="$(git symbolic-ref --short HEAD)"
if [[ "$current_branch" != "main" ]]; then
  echo "ERROR: must be on 'main' branch to deploy (currently on '$current_branch')" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: working tree not clean. Commit or stash source changes first." >&2
  git status --short
  exit 1
fi
MAIN_SHA="$(git rev-parse HEAD)"
SHORT_SHA="$(git rev-parse --short HEAD)"

# A failed fetch must stop publication; never fall back to a source branch.
git fetch origin gh-pages
git rev-parse --verify origin/gh-pages >/dev/null
echo "==> Building site..."
bundle exec jekyll build
if [[ ! -f "$REPO_DIR/_site/index.html" ]]; then
  echo "ERROR: build did not produce _site/index.html." >&2
  exit 1
fi
if [[ "$(git rev-parse HEAD)" != "$MAIN_SHA" || -n "$(git status --porcelain)" ]]; then
  echo "ERROR: source changed during the build. Review it before deploying." >&2
  exit 1
fi

# Create a new directory inside this repository; leave existing worktrees alone.
mkdir -p "$REPO_DIR/output/deploy"
OUTPUT_DIR="$(cd "$REPO_DIR/output/deploy" && pwd -P)"
if [[ "$OUTPUT_DIR" != "$REPO_DIR/output/deploy" ]]; then
  echo "ERROR: publishing output resolves outside the expected directory." >&2
  exit 1
fi
WORKTREE_DIR="$(mktemp -d "$OUTPUT_DIR/site-${SHORT_SHA}-XXXXXX")"
case "$WORKTREE_DIR" in
  "$OUTPUT_DIR"/site-*) ;;
  *) echo "ERROR: unexpected worktree path." >&2; exit 1 ;;
esac
WORKTREE_ADDED=false

cleanup() {
  exit_status=$?
  trap - EXIT
  cd "$REPO_DIR"
  if [[ "$WORKTREE_ADDED" == true ]]; then
    if [[ "$exit_status" -eq 0 ]]; then
      # A successful commit leaves a clean tree. Never force-delete a dirty tree.
      if ! git worktree remove "$WORKTREE_DIR"; then
        echo "ERROR: cleanup failed; worktree retained at $WORKTREE_DIR" >&2
        exit_status=1
      fi
    else
      echo "==> Deployment worktree retained at $WORKTREE_DIR"
    fi
  else
    # worktree add failed: remove only the empty directory created by mktemp.
    if ! rmdir "$WORKTREE_DIR"; then
      echo "ERROR: could not remove empty temporary directory $WORKTREE_DIR" >&2
      exit_status=1
    fi
  fi
  exit "$exit_status"
}
trap cleanup EXIT

echo "==> Preparing gh-pages worktree..."
git worktree add --detach "$WORKTREE_DIR" origin/gh-pages
WORKTREE_ADDED=true

cd "$WORKTREE_DIR"
if [[ "$(pwd -P)" != "$WORKTREE_DIR" || -n "$(git status --porcelain)" ]]; then
  echo "ERROR: generated worktree is not the expected clean directory." >&2
  exit 1
fi
git rm -r --ignore-unmatch -- .
cp -r "$REPO_DIR/_site/." .
touch .nojekyll
git add -A

if git diff --cached --quiet; then
  echo "==> Site content is identical to the published branch."
else
  git commit -m "Deploy site (built from main@${SHORT_SHA})"
  git push origin HEAD:gh-pages
  echo "==> Published to gh-pages."
fi
