# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Selecting SL7 as the base OS
FROM scientificlinux/sl:7
MAINTAINER Marco Mambelli "marcom@fnal.gov"
LABEL name="Base SL7 and fermilab repos with updated obsolete path, and EPEL and OSG3.6, to use in FNAL and GWMS images"

# Correcting yum repos tp point to the obsolete repos (assuming sed is available!)
# Setting up the HTCondor Madison repository
# Technically, HTCondor isn't installed but this has been done
# to keep in sync with other Docker file and keep the source of
# the packages consistent
# Assigning the repo yum prio of 90
# Installing wget to help with repo setup
RUN sed -i -E '/scientificlinux.org\/linux\/scientific\/obsolete\//!s;scientificlinux.org/linux/scientific/;&obsolete/;' /etc/yum.repos.d/*.repo ;\
    yum install -y wget ;\
    /usr/bin/wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel7.repo -O /etc/yum.repos.d/condor.repo ;\
    /usr/bin/wget http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor -O /etc/pki/rpm-gpg/RPM-GPG-KEY-HTCondor ;\
    echo "priority=60" >> /etc/yum.repos.d/condor.repo ;\
    echo "exclude=*.i686" >> /etc/yum.repos.d/condor.repo ;\
    echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-HTCondor" >> /etc/yum.repos.d/condor.repo

# Next setting up EPEL and OSG repositories
# OSG by default has a YUM  prio of 98
# Assigning EPEL YUM prio of 99
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm ;\
    yum install -y yum-priorities ;\
    yum install -y https://repo.opensciencegrid.org/osg/3.6/osg-3.6-el7-release-latest.rpm ;\
    # /bin/sed -i '/^enabled=1/a priority=99' /etc/yum.repos.d/epel.repo ;\
    # echo "priority=80" >> /etc/yum.repos.d/osg.repo ;\
    echo "exclude=*condor*" >> /etc/yum.repos.d/osg.repo

# install yum-conf-extras to enable sl-extras repo and fix the obsolete link
# And cleaning caches to reduce size of image

RUN yum install -y yum-conf-extras yum-conf-context-fermilab ;\
    sed -i -E '/scientificlinux.org\/linux\/scientific\/obsolete\//!s;scientificlinux.org/linux/scientific/;&obsolete/;' /etc/yum.repos.d/sl-extras.repo ;\
    sed -i -E '/scientificlinux.org\/linux\/scientific\/obsolete\//!s;scientificlinux.org/linux/scientific/;&obsolete/;' /etc/yum.repos.d/fermilab*.repo ;\
    yum clean all

# Default entry point
CMD ["/bin/bash"]

# build info
RUN echo "Source: fermilab/base-sl7" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt
