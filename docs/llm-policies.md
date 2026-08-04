<!--
Copyright (c) 2026, The Isaac Lab Project Developers (https://github.com/isaac-sim/IsaacLab/blob/main/CONTRIBUTORS.md).
All rights reserved.

SPDX-License-Identifier: BSD-3-Clause
-->

# Optional LLM policies

LLM recovery and container probing are disabled unless explicitly selected.
They use an OpenAI-compatible chat endpoint and never participate in metric
classification or binary-search decisions.

Set the credential in an environment variable:

```bash
export OPENAI_API_KEY=<secret>
```

Verify recovery connectivity before a GPU run:

```bash
isaaclab-bisect recovery-selftest \
    --recovery llm \
    --model <MODEL> \
    --base_url <OPENAI_COMPATIBLE_BASE_URL>
```

Verify the bounded setup probe:

```bash
isaaclab-bisect probe-selftest \
    --model <MODEL> \
    --base_url <OPENAI_COMPATIBLE_BASE_URL>
```

Use `--api_key_env` when credentials are stored under another environment
variable. Do not put keys in plans, command lines, or artifacts.

Recovery is limited to the action vocabulary and retry budget enforced in
Python. Invalid responses fall back to deterministic behavior. Probe actions
are similarly bounded and cannot emit `GOOD`, `BAD`, or `UNCLEAR`.
