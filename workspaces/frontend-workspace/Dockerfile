# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Parameter to allow builds for EL7/9
ARG GWMS_VERSION=latest
ARG IMAGE_NAMESPACE=glideinwms
FROM $IMAGE_NAMESPACE/gwms-workspace:$GWMS_VERSION
# NOTE: if you need GWMS_VERSION after FROM, you need to repeat it
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG BUILD_SHA
ARG BUILD_DATE
LABEL name="Devcontainer for the GlideinWMS Frontend on EL7/9"
LABEL org.opencontainers.image.authors="GlideinWMS Team glideinwms@fnal.gov" \
      org.opencontainers.image.url="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.documentation="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.source="https://github.com/glideinWMS/containers/tree/main/workspaces" \
      org.opencontainers.image.vendor="The GlideinWMS Team" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.licenses="$BUILD_SHA" \
      org.opencontainers.image.created="$BUILD_DATE"

RUN echo "Building Frontend dev image ($BUILD_SHA/$BUILD_DATE) on $BUILDPLATFORM, for $TARGETPLATFORM"

# See gwms-workspace for the repos setup and base packages

# Install GlideinWMS Frontend
RUN yum -y install --enablerepo=osg-development glideinwms-vofrontend
RUN rm -f /etc/condor/config.d/00-minicondor

#################################
# Cleaning caches to reduce size of image
RUN yum clean all

# Deploy utility scripts
COPY shared/scripts /root/scripts
COPY frontend-workspace/scripts/* /root/scripts/
RUN ln -s /root/scripts/* /usr/local/bin

# Deploy GlideinWMS Frontend and HTCondor configuration
COPY frontend-workspace/config/frontend.xml /etc/gwms-frontend/frontend.xml
RUN chown frontend:frontend /etc/gwms-frontend/frontend.xml
COPY shared/config/99-debug.conf /etc/condor/config.d/99-debug.conf

# Add HTCondor files to test user abc
RUN useradd testuser
COPY --chown=testuser:testuser frontend-workspace/testuser-home/* /home/testuser/

# Default entry point
CMD ["/bin/bash"]

# build info
RUN echo "Source: fermilab/frontend-workspace" > /image-source-info.txt
RUN echo "Timestamp: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee /image-build-info.txt
