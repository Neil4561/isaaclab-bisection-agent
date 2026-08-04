#!/usr/bin/env bash
# Copyright (c) 2022-2026, The Isaac Lab Project Developers (https://github.com/isaac-sim/IsaacLab/blob/main/CONTRIBUTORS.md).
# All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Entrypoint for the bisection agent's docker-reconstruct mode.
#
# The container is the isolation boundary; the *reconstruction* is still
# per-commit and is delegated to the same runner we use on the host, invoked in
# ``local-reconstruct`` mode. That runner clones the candidate commit into
# /candidate, builds a fresh uv venv, pip-installs the commit's pinned Isaac Sim
# and modular stack, runs the benchmark, and writes the artifact contract
# (perf_smoke_test_result.json + bisect_env.json) into /artifacts.
#
# Expected mounts (provided by isaaclab_bisection.runner --mode docker-reconstruct):
#   /target-repo  the target IsaacLab repository and git history (ro)
#   /candidate  writable dir the runner clones the candidate commit into
#   /artifacts  writable dir for this candidate's artifacts
#   /env-cache  writable, run-scoped uv env cache shared across candidates
#   /cache/jit-root  writable run cache root; inner runner selects the stack subdir
#   /cache/kit-root  writable run cache root; inner runner selects the stack subdir
#
# Required environment variables:
#   COMMIT_SHA, TASK_ID, BACKEND
# Optional:
#   EXTRA_RUNNER_ARGS  extra flags forwarded verbatim to the runner (word-split)

set -euo pipefail
set -f  # keep bracketed install selectors like ov[ovrtx] from glob-expanding

: "${COMMIT_SHA:?COMMIT_SHA is required}"
: "${TASK_ID:?TASK_ID is required}"
: "${BACKEND:?BACKEND is required}"

mkdir -p /artifacts

# The bind-mounted /target-repo (and freshly-cloned /candidate) can appear owned by a
# different UID than the container's root, depending on the host's Docker setup
# (rootless Docker, UID-remapping daemons, etc.). Without this, git's "dubious
# ownership" safety check refuses every git operation the runner performs.
git config --global --add safe.directory /target-repo
git config --global --add safe.directory /target-repo/.git
git config --global --add safe.directory /candidate
git config --global --add safe.directory /candidate/.git

# When /target-repo is itself a Git worktree, /target-repo/.git is a file pointing at the
# parent repo's .git/worktrees/<name> directory. The outer runner bind-mounts that
# parent .git metadata at the same absolute path, but Git still requires the actual
# gitdir path to be marked safe before clone/fetch/rev-parse operations will read it.
if [[ -f /target-repo/.git ]]; then
    gitdir="$(python3 - <<'PY'
from pathlib import Path

git_file = Path("/target-repo/.git")
text = git_file.read_text(encoding="utf-8").strip()
if text.startswith("gitdir:"):
    path = Path(text.split(":", 1)[1].strip())
    if not path.is_absolute():
        path = (git_file.parent / path).resolve()
    print(path)
PY
)"
    if [[ -n "${gitdir}" ]]; then
        git config --global --add safe.directory "${gitdir}"
        common_gitdir="$(dirname "$(dirname "${gitdir}")")"
        git config --global --add safe.directory "${common_gitdir}"
    fi
fi

# EXTRA_RUNNER_ARGS is a shell-quoted argv string built by the runner. Re-parse
# it with ``eval set --`` so quoted tokens (e.g. a GPU model like "NVIDIA L40S")
# reconstruct as single arguments instead of being word-split into fragments.
# ``set -f`` above keeps any glob-like tokens (e.g. install selectors) literal.
eval "set -- ${EXTRA_RUNNER_ARGS:-}"

# Release images bake the package under /opt. A caller may explicitly mount a
# development checkout at /agent to override that code without rebuilding.
if [[ -d /agent/src ]]; then
    export PYTHONPATH="/agent/src${PYTHONPATH:+:$PYTHONPATH}"
fi
exec python3 -m isaaclab_bisection.runner \
    --mode local-reconstruct \
    --repo_root /target-repo \
    --commit "${COMMIT_SHA}" \
    --task_id "${TASK_ID}" \
    --backend_key "${BACKEND}" \
    --artifact_dir /artifacts \
    --source_dir /candidate \
    --env_cache_dir /env-cache \
    --jit_cache /cache/jit-root \
    --kit_cache /cache/kit-root \
    "$@"
