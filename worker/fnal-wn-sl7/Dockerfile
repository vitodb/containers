# Selecting SL7 as the base OS 
FROM scientificlinux/sl:7 
MAINTAINER Marco Mambelli "marcom@fnal.gov"

# Setting up the HTCondor Madison repository
# Technically, HTCondor isn't installed but this has been done
# to keep in sync with other Docker file and keep the source of
# the packages consistent
# Assigning the repo yum prio of 90
# Installing wget to help with repo setup
RUN yum install -y wget sed ;\
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
    yum install -y https://repo.opensciencegrid.org/osg/3.5/osg-3.5-el7-release-latest.rpm ;\
    # /bin/sed -i '/^enabled=1/a priority=99' /etc/yum.repos.d/epel.repo ;\
    # echo "priority=80" >> /etc/yum.repos.d/osg.repo ;\
    echo "exclude=*condor*" >> /etc/yum.repos.d/osg.repo

# Installing packages
# Singularity version has been explicitly specified to control upgrades
# xrootd packages have been version locked as well to control upgrades
# Updated xrootd and Singularity versions, out of sync w/ GCO: RUN yum install -y gcc-c++ libstdc++ xrootd-client-libs-4.11.1-1.osg35.el7.x86_64 xrootd-libs-4.11.1-1.osg35.el7.x86_64 xrootd-client-4.11.1-1.osg35.el7.x86_64 osg-wn-client krb5-workstation strace redhat-lsb-core mesa-libGLU mesa-libGLU-devel libXmu cvmfs gstreamer-plugins-base libXScrnSaver libSM-devel libXpm-devel libgfortran glibc.i686 libXmu libXmu-devel expat-devel libxml2-devel mysql-libs libtiff libjpeg-turbo openssh-clients openssl-devel tzdata glibc-headers glibc-devel singularity-3.5.3-1.1.el7.x86_64 ;\
# Added libraries from FNAL requests are labeled with "LIBRARIES (optional comment) [VO, requestor, SNOW req. number]
#  mpich mpich-devel numactl numactl-devel (MPI libraries) [, M.Paterno, ] libffi libffi-devel [DES, M, Paterno, RITM1038430]
#  pcre2 xxhash-libs libzstd libzstd-devel [Art v3_06, R.Kutschke, RITM1002405]
#  libcurl-devel [Minerva, K.Herner, RITM1036665]
#  ftgl gl2ps libGLEW giflib libAfterImage [LArSoft v09_16_00, V. Di Benedetto, RITM1085514]
#  perl libraries: perl perl-autodie ...  perl-Scalar-List-Utils [Mu2e S.Soleti R.Kutschke, INC000001118312] 
#  jq [SBND Mateus F. Carneiro, RITM1235906]
# OSG has only: osg-wn-client redhat-lsb-core singularity
# removed:  gfal2-plugin-xrootd-2.18.1-2.el7.x86_64, verify why it was added, now also in OSG, it is a dependency of osg-wn-client
# TODO: temporary using osg-development, should be removed after 11/5
#  removed --enablerepo=osg-testing 2020-07-09
RUN yum install -y \
    osg-ca-certs \
    gcc-c++ libstdc++ xrootd-client-libs xrootd-libs xrootd-client osg-wn-client krb5-workstation strace redhat-lsb-core mesa-libGLU mesa-libGLU-devel libXmu cvmfs gstreamer-plugins-base libXScrnSaver libSM-devel libXpm-devel libgfortran glibc.i686 libXmu libXmu-devel expat-devel libxml2-devel mysql-libs libtiff libjpeg-turbo openssh-clients openssl-devel tzdata glibc-headers glibc-devel singularity \
    pcre2 xxhash-libs libzstd libzstd-devel mpich mpich-devel numactl numactl-devel libffi libffi-devel libcurl-devel \
    ftgl gl2ps libGLEW giflib libAfterImage \
    perl perl-autodie perl-Carp perl-constant perl-Data-Dumper perl-Digest perl-Digest-SHA perl-Exporter perl-File-Path perl-File-Temp perl-Getopt-Long perl-libs perl-PathTools perl-Scalar-List-Utils \
    jq

# Overriding the default singularity configuration
ADD shared/singularity.conf /etc/singularity/singularity.conf

# SSH config needs to be added
ADD fnal-wn-sl7/ssh_config.sl7 /etc/ssh/ssh_config

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
# Temporary fix - Manually add Singularity files
# repo done on 8/29 by UNL sysadmin
# Files content from: https://github.com/sylabs/singularity/blob/master/internal/pkg/build/sources/base_environment.go

RUN yum install -y git && \
    git clone https://github.com/jthiltges/singularity-environment.git /usr/singularity-environment/ && \
    cp -r /usr/singularity-environment/{environment,.exec,.run,.shell,singularity,.singularity.d,.test} / && \
    mkdir /.singularity.d/libs

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
RUN echo "Source: fermilab/fnal-wn-sl7" > /image-source-info.txt
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt
