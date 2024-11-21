# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Parameter to allow builds for EL7/9
ARG GWMS_VERSION=latest
ARG IMAGE_NAMESPACE=glideinwms
FROM $IMAGE_NAMESPACE/gwms-workspace:$GWMS_VERSION
# NOTE: if you need GWMS_VERSION after FROM, you need to repeat it
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG BUILD_VERSION=dev
ARG BUILD_REF
ARG BUILD_HASH
ARG BUILD_SHA
ARG BUILD_DATE
# MAINTAINER is deprecated but it is needed to set Author in the image attributes
MAINTAINER GlideinWMS Team <glideinwms@fnal.gov>
LABEL name="Devcontainer to build the GlideinWMS packages on EL7/9" \
      org.opencontainers.image.authors="GlideinWMS Team glideinwms@fnal.gov" \
      org.opencontainers.image.title="GWMS Factory Workspace" \
      org.opencontainers.image.description="Devcontainer to build the GlideinWMS packages on EL7/9" \
      org.opencontainers.image.url="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.documentation="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.source="https://github.com/glideinWMS/containers/tree/main/workspaces" \
      org.opencontainers.image.vendor="The GlideinWMS Team" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.revision="$BUILD_HASH" \
      org.opencontainers.image.ref.name="$BUILD_REF" \
      org.opencontainers.image.created="$BUILD_DATE"\
      org.glideinwms.image.version="$GWMS_VERSION"
# Declaring ports: webserver, htcondor(shared port)
EXPOSE 80 443 9618

RUN echo "Building the release building dev image ($BUILD_SHA/$BUILD_DATE) on $BUILDPLATFORM, for $TARGETPLATFORM"

# See gwms-workspace for the repos setup and base packages

# Install Fermilab repo and packages, RPM and OSG dev packages
RUN yum -y install https://linux-mirrors.fnal.gov/linux/fermilab/almalinux/9/yum-conf-fermilab.rpm
RUN yum -y fermilab-util_kx509 install svn rpmbuild koji osg-build

# This must be after all dnf/yum and pip commands
# Cleaning YUM and DNF all caches (including disabled repos) and pip caches to reduce size of image
RUN rm -rf /var/cache/yum/* /var/cache/dnf/* /root/.cache/pip/*

RUN mkdir -p /opt/osg/svnrepo && \
    cd /opt/osg && git clone https://github.com/opensciencegrid/osg-build.git ; \
    cd /opt/osg/svnrepo && \
    for i in osg-3.6_glideinwms 23-main_glideinwms 23-upcoming_glideinwms 24-main_glideinwms 24-upcoming_glideinwms; \
    do mkdir "$i"; pushd "$i"; \ 
    svn co https://vdt.cs.wisc.edu/svn/native/redhat/branches/${i%_glideinwms}/glideinwms; \
    popd; done && \
    chown -R abc: /opt/osg
    
# Default entry point
CMD ["/bin/bash"]

# build info
RUN echo "Source: fermilab/build-workspace" > /image-source-info.txt
RUN echo "Timestamp: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee /image-build-info.txt
