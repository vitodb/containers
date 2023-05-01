# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# GWMS Workspace
FROM fermilab/gwms-workspace
MAINTAINER Marco Mambelli "marcom@fnal.gov"
LABEL name="Workspace with EL9, OSG 3.6 and the GlideinWMS VO Frontend"

# See gwms-workspace for the repos setup and base packages

RUN yum -y install --enablerepo=osg-development glideinwms-vofrontend

# Clone glideinwms repo in /home/abc/repos
# links, ... to work from git

# Frontend configuration
# Setup with standard environment


# Default entry point
CMD ["/bin/bash"]

#################################
# Cleaning caches to reduce size of image
RUN yum clean all

# build info
RUN echo "Source: fermilab/frontend-workspace" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt
