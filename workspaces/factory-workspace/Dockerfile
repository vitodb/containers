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
LABEL name="Devcontainer for the GlideinWMS Factory on EL7/9"
LABEL org.opencontainers.image.authors="GlideinWMS Team glideinwms@fnal.gov" \
      org.opencontainers.image.url="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.documentation="https://glideinwms.fnal.gov/" \
      org.opencontainers.image.source="https://github.com/glideinWMS/containers/tree/main/workspaces" \
      org.opencontainers.image.vendor="The GlideinWMS Team" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.licenses="$BUILD_SHA" \
      org.opencontainers.image.created="$BUILD_DATE"

RUN echo "Building Factory dev image ($BUILD_SHA/$BUILD_DATE) on $BUILDPLATFORM, for $TARGETPLATFORM"

# See gwms-workspace for the repos setup and base packages

# Install GlideinWMS Factory
RUN yum -y install --enablerepo=osg-development glideinwms-factory
RUN rm -f /etc/condor/config.d/00-minicondor

#################################
# Cleaning caches to reduce size of image
RUN yum clean all

# Deploy utility scripts
COPY shared/scripts /root/scripts
COPY factory-workspace/scripts/* /root/scripts
RUN ln -s /root/scripts/* /usr/local/bin

# Dowload HTCondor tarballs
# HTCondor 10.6.0 to test a more recent version on Alma9
# HTCondor 9.0.18 to test alsp hybrid configurations on EL7 (x86_64 only)
RUN pushd /var/lib/gwms-factory/condor ;\
    wget https://research.cs.wisc.edu/htcondor/tarball/10/10.x/10.6.0/release/condor-10.6.0-$(arch)_AlmaLinux9-stripped.tar.gz ;\
    tar -xf condor-10.6.0-$(arch)_AlmaLinux9-stripped.tar.gz ;\
    rm -f condor-10.6.0-$(arch)_AlmaLinux9-stripped.tar.gz ;\
    wget https://research.cs.wisc.edu/htcondor/tarball/9.0/9.0.18/release/condor-9.0.18-x86_64_CentOS7-stripped.tar.gz ;\
    tar -xf condor-9.0.18-x86_64_CentOS7-stripped.tar.gz ;\
    rm -f condor-9.0.18-x86_64_CentOS7-stripped.tar.gz ;\
    popd

# Deploy GlideinWMS Factory and HTCondor configuration
COPY factory-workspace/config/glideinWMS.xml /etc/gwms-factory/glideinWMS.xml
RUN sed -i "s/\[ARCH\]/$(arch)/g" /etc/gwms-factory/glideinWMS.xml
RUN chown gfactory:gfactory /etc/gwms-factory/glideinWMS.xml
COPY shared/config/99-debug.conf /etc/condor/config.d/99-debug.conf
COPY shared/config/99-cafile.conf /etc/condor/config.d/99-cafile.conf

# Default entry point
CMD ["/bin/bash"]

# build info
RUN echo "Source: fermilab/factory-workspace" > /image-source-info.txt
RUN echo "Timestamp: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee /image-build-info.txt
