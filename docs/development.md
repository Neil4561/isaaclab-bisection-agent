<!--
Copyright (c) 2026, The Isaac Lab Project Developers (https://github.com/isaac-sim/IsaacLab/blob/main/CONTRIBUTORS.md).
All rights reserved.

SPDX-License-Identifier: BSD-3-Clause
-->

# Development

## Local setup

Create an environment with Python 3.11 or newer, then install the package:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --editable ".[test]"
```

Run the CPU-only validation:

```bash
ruff check .
ruff format --check .
pytest -q
isaaclab-bisect --help
```

Unit and synthetic tests must not require Isaac Sim, a GPU, or Docker.

## Container

Build the reconstruction image from the repository root:

```bash
docker build --file docker/Dockerfile --tag isaaclab-bisection-agent:dev .
```

The image intentionally contains no Isaac Sim installation. Each candidate's
pinned runtime is reconstructed into a run-scoped cache.

## GPU validation

GPU validation is intentionally separate from pull-request CI. Use
`probe-range` first because it records every per-commit compatibility result and
continues after setup failures:

```bash
isaaclab-bisect probe-range \
    --repo_root /path/to/IsaacLab \
    --work_dir /tmp/isaaclab-probe \
    --runner_mode docker-reconstruct \
    --image isaaclab-bisection-agent:dev \
    --good_ref <OLDER_SHA> \
    --bad_ref <NEWER_SHA> \
    --tooling_ref <TOOLING_SHA> \
    --task_id Isaac-Cartpole-Direct \
    --backend_key physx \
    --num_envs 4096 \
    --cleanup_probe_envs
```

Do not use a probe report as regression evidence. After compatibility is
established, run `bisect-range` with the normal reference and candidate sampling
policy.

## Contribution requirements

- Keep deterministic verdict logic independent from LLM recovery and diagnosis.
- Add regression tests for every newly supported setup failure.
- Verify a bug regression test fails without its fix.
- Preserve structured skip categories instead of collapsing failures into
  benchmark regressions.
- Update `docs/compatibility.md` when extending the validated matrix.
