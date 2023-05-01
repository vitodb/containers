# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Selecting AlmaLinux 9 as the base OS
FROM almalinux:9
MAINTAINER Marco Mambelli "marcom@fnal.gov"
LABEL name="Base workspace with EL9, OSG 3.6 and base packages required by GlideinWMS and HEPCloud"

# Installing some base packages, the CRB repo, needed by swig, and the EPEL (epel-release) and OSG repos
# Not installing epel-next-release, consider it for the future
# Not installing the HTCondor Madison repo (getting condor from OSG). In case needed (x509 is in HTCSS 9.0.x from HTCondor)
#    /usr/bin/wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel9.repo -O /etc/yum.repos.d/condor.repo ;\
#    /usr/bin/wget http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor -O /etc/pki/rpm-gpg/RPM-GPG-KEY-HTCondor ;\
#    echo "priority=90" >> /etc/yum.repos.d/condor.repo ;\
#    echo "exclude=*.i686" >> /etc/yum.repos.d/condor.repo ;\
#    echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-HTCondor" >> /etc/yum.repos.d/condor.repo
#    echo "exclude=*condor*" >> /etc/yum.repos.d/osg.repo
# Installing some system management RPMs/sw needed for containers
# Installing some base RPMs (gettext is needed by RELEASE, swig and many devel by jsonnet)  
# Setting up the HTCondor Madison repository
# Technically, HTCondor isn't installed but this has been done
# to keep in sync with other Docker file and keep the source of
# the packages consistent
# Assigning the repo yum prio of 90
# Installing wget to help with repo setup
RUN yum install -y wget sed git yum-utils ;\
    dnf config-manager --set-enabled crb ;\
    dnf install -y epel-release ;\
    /bin/sed -i '/^enabled=1/a priority=99' /etc/yum.repos.d/epel.repo ;\
    yum install -y https://repo.opensciencegrid.org/osg/3.6/osg-3.6-el9-release-latest.rpm ;\
    yum install -y cronie supervisor ;\
    /usr/bin/wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /usr/local/bin/systemctl
    /usr/bin/chmod +x /usr/local/bin/systemctl
    yum install -y python3 python3-devel python3-cryptography python3-wheel make openssl-devel gcc gcc-c++ rpm-build gettext swig ;\
    

# Packages useful for development and administration
# Common packages for all GlideinWMS/HEPCloud software
RUN yum -y install jq apptainer ;\
    yum -y install htgettoken ;\
    /usr/bin/curl -L -o ~/.bash_aliases https://raw.githubusercontent.com/glideinWMS/dev-tools/master/.bash_aliases 2>/dev/null && . ~/.bash_aliases && aliases-update ;\
    yum -y install python3-rrdtool osg-ca-certs ;\
    yum -y install condor
    
# Adding unprivileged user
RUN adduser abc ;\
    mkdir /home/abc/repos
    chown abc: /home/abc/repos
    mkdir /opt/abc ;\
    chown abc: /opt/abc


# Should ssh be enabled/installed?
# SSH config needs to be added
#ADD shared/ssh_config /etc/ssh/ssh_config

# Postponing yum clean all to later, after the git installation
# Skipping additional FermiGrid specific tests:
# - adding /home/interactive
# - adding the tests

# Default entry point
CMD ["/bin/bash"]


#######################
# Parts added

# osg-wn-client already installed and osg-ca-certs is a dependency. Should CRLs (.r0) be removed?
#RUN yum -y install osg-ca-certs osg-wn-client \
#    && rm -f /etc/grid-security/certificates/*.r0

#################################
# Cleaning caches to reduce size of image
RUN yum clean all

# OSG suggested mount points
RUN for MNTPOINT in \
        /cvmfs \
        /hadoop \
        /hdfs \
        /lizard \
        /mnt/hadoop \
        /mnt/hdfs \
        /xenon \
        /scratch \
        /spt \
        /stash2 \
    ; do \
        mkdir -p $MNTPOINT ; \
    done

# build info
RUN echo "Source: fermilab/gwms-workspace" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt
