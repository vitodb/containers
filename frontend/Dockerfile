FROM opensciencegrid/software-base:fresh
LABEL maintainer OSG Software <help@opensciencegrid.org>

RUN yum -y install glideinwms-vofrontend-standalone \
    yum -y update vo-client \
    yum -y install git

ADD image-config.d/*    /etc/osg/image-config.d/
ADD cron.d/*            /etc/cron.d/
ADD supervisor.d/*      /etc/supervisord.d/
ADD condor.d/*          /etc/condor/config.d/
