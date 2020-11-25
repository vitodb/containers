FROM opensciencegrid/software-base:fresh
LABEL maintainer OSG Software <help@opensciencegrid.org>

# ddavila 20201125:
# temporarily installing from osg-upcoming to get 3.7, this needs to be changed
# once we can get 3.7 out of osg-release
RUN yum -y --enablerepo=osg-upcoming install glideinwms-vofrontend-standalone

RUN yum -y install vo-client \
    git

ADD image-config.d/*    /etc/osg/image-config.d/
ADD cron.d/*            /etc/cron.d/
ADD supervisor.d/*      /etc/supervisord.d/
ADD condor.d/*          /etc/condor/config.d/
