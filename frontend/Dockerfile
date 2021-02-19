FROM opensciencegrid/software-base:fresh
LABEL maintainer OSG Software <help@opensciencegrid.org>

# Create the frontend user with a fixed GID/UID
# This is important so that we can use the same IDs in the persistent volume used for
# the web-area
RUN groupadd -o -g 993 frontend
RUN useradd -o -u 996 -g 993 -s /bin/sh frontend

# ddavila 20201125:
# temporarily installing from osg-upcoming to get 3.7, this needs to be changed
# once we can get 3.7 out of osg-release
RUN yum -y --enablerepo=osg-upcoming-testing install glideinwms-vofrontend-standalone

RUN yum -y install vo-client \
    git

ADD image-config.d/*    /etc/osg/image-config.d/
ADD cron.d/*            /etc/cron.d/
ADD supervisor.d/*      /etc/supervisord.d/
ADD condor.d/*          /etc/condor/config.d/
