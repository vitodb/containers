# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

FROM localhost/frontend-workspace
LABEL org.opencontainers.image.authors="coimbra@fnal.gov"
LABEL name="Devcontainer for the GlideinWMS Frontend"

# Install development tools
RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo ;\
    dnf install -y gh vim zsh sudo psmisc bind-utils mlocate ;\
    pip3 install debugpy ;\
    echo 'PROMPT="%F{204}%n%f %F{86}%m%f %F{39}%d%f » "' > /root/.zshrc

# Clone glideinwms repo and link to RPM installed files
COPY scripts/link-git.sh /opt/GlideinWMS/link-git.sh
RUN /opt/GlideinWMS/link-git.sh

# Patch glideinwms repo
# TODO: Remove this patch once the PR is merged
RUN curl https://github.com/glideinWMS/glideinwms/compare/master...namrathaurs:glideinwms:i299/getchildren_deprecation.diff > /tmp/getchildren_deprecation.patch ;\
    patch /opt/GlideinWMS/glideinwms/creation/lib/check_python3_expr.py < /tmp/getchildren_deprecation.patch

# Copy GlideinWMS Frontend configuration
COPY config/frontend.xml /etc/gwms-frontend/frontend.xml
RUN chown frontend:frontend /etc/gwms-frontend/frontend.xml

# Default entry point
CMD ["/bin/bash"]
