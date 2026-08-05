<!--
Copyright (c) 2026, The Isaac Lab Project Developers (https://github.com/isaac-sim/IsaacLab/blob/main/CONTRIBUTORS.md).
All rights reserved.

SPDX-License-Identifier: BSD-3-Clause
-->

# Agent Skills

These playbooks expose the bisection package to coding agents and automation:

- `isaaclab-perf-bisection` selects the appropriate workflow.
- `isaaclab-perf-benchmark-commit` measures one commit.
- `isaaclab-perf-threshold-check` classifies existing measurements.
- `isaaclab-perf-bisect-range` qualifies endpoints and searches a range.

Each atomic Skill includes versioned JSON input and output schemas. Invoke the
automation adapter with:

```bash
isaaclab-bisect-skill --input request.json --output response.json
```

The Skills are orchestration guidance. Deterministic Python code remains the
source of truth for metric extraction, thresholds, and bisection verdicts.

The `isaaclab-perf-bisection` router can also hand off host onboarding, setup
troubleshooting, backend selection, and post-bisection profiling to a small set
of [pinned official Skills](../docs/upstream-skills.md). Those Skills remain
optional and outside the candidate execution and verdict paths.
