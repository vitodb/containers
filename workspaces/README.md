<!--
SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
SPDX-License-Identifier: Apache-2.0
-->

# workspaces

Workspaces in containers designed for interactive use, inspired by [Alnoda](https://alnoda.org/) and similar projects.
These are RHEL based containers to provide a consistent development environment for GlideinWMS and Decision Engine.
They are not separating or isolating the different services to improve performance and security, so they are meant only
for a protected development environment, not for production.
For production use instead the frontend and factory off the containers root folder.

The current development environment is based on EL9 and Python 3.9.

Some notable tools used in these containers:

-   [Supervisor](http://supervisord.org/) since [systemd and similars don't work so well in containers](https://docs.docker.com/config/containers/multi-service_container/)
-   [Docker systemctl replacement](https://github.com/gdraheim/docker-systemctl-replacement) that allows to run most systemctl commands also without systemd
