# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# DE Workspace
ARG IMAGE_NAMESPACE=glideinwms
FROM $IMAGE_NAMESPACE/gwms-workspace
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG BUILD_VERSION=dev
ARG BUILD_REF
ARG BUILD_HASH
ARG BUILD_SHA
ARG BUILD_DATE
# MAINTAINER is deprecated but it is needed to set Author in the image attributes
MAINTAINER GlideinWMS Team <glideinwms@fnal.gov>
LABEL name="Devcontainer for the HEPCloud Decision Engine on EL9" \
      org.opencontainers.image.authors="GlideinWMS Team glideinwms@fnal.gov" \
      org.opencontainers.image.title="HEPCloud Decision Engine Workspace" \
      org.opencontainers.image.description="Devcontainer for the HEPCloud Decision Engine on EL9" \
      org.opencontainers.image.url="https://hepcloud.github.io/" \
      org.opencontainers.image.documentation="https://hepcloud.github.io/" \
      org.opencontainers.image.source="https://github.com/glideinWMS/containers/tree/main/workspaces" \
      org.opencontainers.image.vendor="The GlideinWMS Team" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.revision="$BUILD_HASH" \
      org.opencontainers.image.ref.name="$BUILD_REF" \
      org.opencontainers.image.created="$BUILD_DATE"
# Declaring ports: webserver, htcondor(shared port)
EXPOSE 80 443 9618

RUN echo "Building DE dev image ($BUILD_SHA/$BUILD_DATE) on $BUILDPLATFORM, for $TARGETPLATFORM"

# See gwms-workspace for the repos setup and base packages

# RUN dnf install -y postgresql postgresql-server postgresql-devel && systemctl enable postgresql && \
# postgresql-setup --initdb -k ; \
# yum -y install --enablerepo=osg-development decisionengine-deps decisionengine-modules-deps
RUN dnf install -y --enablerepo=osg-development decisionengine-onenode; \
    decisionengine-install-python 
# links, ... to work from git

# This must be after all dnf/yum and pip commands
# Cleaning YUM and DNF all caches (including disabled repos) and pip caches to reduce size of image
RUN rm -rf /var/cache/yum/* /var/cache/dnf/* /root/.cache/pip/*

RUN postgresql-setup --initdb
ADD pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
# RUN sed -e '/^local   all             all/s/peer/trust/' -e '/^host    all             all/s/ident/trust/' -i /var/lib/pgsql/data/pg_hba.conf

# Without this the systemctl start was failing and the error was in /var/lib/pgsql/data/log/postgresql-*.log
RUN mkdir -p /var/run/postgresql; \
    chown postgres: /var/run/postgresql

# DE configuration
# Setup with standard environment

# Deploy utility scripts
COPY shared/scripts /opt/scripts
COPY frontend-workspace/scripts/run-test.sh /opt/scripts/
COPY decisionengine-workspace/scripts/* /opt/scripts/
RUN ln -s /opt/scripts/* /usr/local/bin

# Deploy DE, httpd, and HTCondor configuration
COPY frontend-workspace/config/frontend.xml /etc/gwms-frontend/frontend.xml
RUN chown decisionengine: /etc/gwms-frontend/frontend.xml
COPY shared/config/99-debug.conf /etc/condor/config.d/99-debug.conf
COPY shared/config/httpd_sec.conf /etc/httpd/conf.d/httpd_sec.conf
COPY decisionengine-workspace/config/ /etc/decisionengine/

# Fix Frontend install 
# TODO: to improve in packaging - remove when not needed
RUN chown -R decisionengine: /etc/gwms-frontend

# Add HTCondor files to test user for test jobs submission
RUN useradd testuser
COPY --chown=testuser:testuser frontend-workspace/testuser-home/* /home/testuser/

# Default entry point
CMD ["/bin/bash"]

# build info
RUN echo "Source: $IMAGE_NAMESPACE/decisonengine-workspace" > /image-source-info.txt
RUN echo "Timestamp: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee /image-build-info.txt
