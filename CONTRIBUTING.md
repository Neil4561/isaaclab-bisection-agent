<!--
Copyright (c) 2026, The Isaac Lab Project Developers (https://github.com/isaac-sim/IsaacLab/blob/main/CONTRIBUTORS.md).
All rights reserved.

SPDX-License-Identifier: BSD-3-Clause
-->

# Contributing

Install the development environment and run:

```bash
ruff check .
ruff format --check .
pytest -q
```

Keep pull requests focused. Bug fixes must include a regression test that fails
without the fix and passes with it.

Public API changes must be additive or go through a deprecation period. Preserve
the JSON artifact contracts and structured failure categories unless the change
includes explicit migration guidance.

Do not add LLM behavior to deterministic measurement, threshold, or search-path
decisions. LLM policies must remain optional, bounded, and auditable.

GPU or environment-compatibility changes should include the corresponding
`probe_range.json`, host configuration, and tooling SHA in the pull-request
description.
