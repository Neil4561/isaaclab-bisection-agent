<!--
Copyright (c) 2026, The Isaac Lab Project Developers (https://github.com/isaac-sim/IsaacLab/blob/main/CONTRIBUTORS.md).
All rights reserved.

SPDX-License-Identifier: BSD-3-Clause
-->

# Security

Report suspected vulnerabilities privately to the repository maintainers rather
than opening a public issue.

The agent checks out and installs historical source code, invokes package
installers, and runs candidate workloads. Treat every target repository and
commit as trusted code. Use `docker-reconstruct` on a dedicated host for
investigations that require stronger isolation; the container is not a security
sandbox against hostile kernel or GPU workloads.

Do not place API keys in plans, command-line arguments, logs, or artifacts. LLM
credentials are read from environment variables and LLM modes are disabled
unless explicitly selected.

Review generated relaunch commands before running them on another host. Runner
extra arguments and custom command templates are operator-controlled code
execution surfaces.
