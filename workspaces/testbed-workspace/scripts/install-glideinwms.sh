#!/usr/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Install on EL9 the GlideinWMS software from a specific repository


### INTRO ###

# Environment
OSG_VERSION=24
DE_REPO=
OSG_REPO=
GWMS_REPO=osg-development
GWMS_SW=
GWMS_LOGSERVER=false
CHECK_ONLY=false
GWMS_USE_BUILD=false
GWMS_USE_CUSTOM_REPO=
# Outside mounted directory with shared files
GWMS_DIR=/opt/gwms

help(){
    cat <<EOF 
$0 [options]
Install the EL9 version of the specified GlideinWMS software
--help                      Print this
--osg-repo OSG_REPO         Set the repository for the OSG osg-ca-certs, e.g. osg-development, osg (defaults to GWMS_REPO)
--gwms-repo GWMS_REPO       Set the GlideinWMS repository, e.g. osg-development (default), osg, upcoming-development
--de-repo GWMS_REPO         Set the Decision Engine repository, e.g. osg-development, osg, upcoming-development (defaults to GWMS_REPO)
--osg-version OSG_VERSION   Set the OSG version, e.g. 24 (default), 23
--de                        Install Decision Engine
--factory                   Install the Factory
--frontend                  Install the Frontend
--logserver                 Add a Log server to the Factory (only if installing the Factory)
--check-only                Only print the available RPMs (no install and set up)
--use-build                 Use the build-workspace container as YUM repo for GlideinWMS and Decision Engine (can use only one --use-... option)
--use-ssi-dev               Use the ssi-dev YUM repo for GlideinWMS and Decision Engine (can use only one --use-... option)
--use-ssi                   Use the ssi YUM repo for GlideinWMS and Decision Engine (can use only one --use-... option)
You cannot set both --factory and --frontend. If none is set the script tries to guess from the hostname
EOF
}

# Argument parser
use_option_ctr=0
[[ "$* " = *"--use-build "* ]] && ((use_option_ctr++)) || true
[[ "$* " = *"--use-ssi-dev "* ]] && ((use_option_ctr++)) || true
[[ "$* " = *"--use-ssi "* ]] && ((use_option_ctr++)) || true
if [[ "$use_option_ctr" -gt 0 ]]; then
    echo "Error. Cannot enable both --use-build and --use-ssi."
    help
    exit 1
fi

while [ -n "$1" ];do
    case "$1" in
        --de-repo)
            DE_REPO="$2"
            shift
            ;;
        --osg-repo)
            OSG_REPO="$2"
            shift
            ;;
        --gwms-repo)
            GWMS_REPO="$2"
            shift
            ;;
        --osg-version)
            OSG_VERSION="$2"
            shift
            ;;
        --use-build)
            GWMS_USE_BUILD=true
            GWMS_USE_CUSTOM_REPO=build
            ;;
        --use-ssi)
            GWMS_USE_CUSTOM_REPO=ssi
            ;;
        --use-ssi-dev)
            GWMS_USE_CUSTOM_REPO=ssidev
            ;;
        --check-only)
            CHECK_ONLY=true
            ;;
        --de)
            GWMS_SW=decisionengine
            ;;
        --factory)
            GWMS_SW=factory
            ;;
        --frontend)
            GWMS_SW=vofrontend
            ;;
        --logserver)
            GWMS_LOGSERVER=true
            ;;
        --help)
            help
            exit 0
            ;;
        *)
            echo "Error. Parameter '$1' is not supported."
            help
            exit 1
    esac
    shift
done

if [[ -z "$GWMS_SW" ]]; then
    myhost=$(hostname)
    if [[ "$myhost" = *factory* ]]; then
        GWMS_SW=factory
    elif [[ "$myhost" = *frontend* ]]; then
        GWMS_SW=vofrontend
    elif [[ "$myhost" = *decisionengine* ]]; then
        GWMS_SW=decisionengine
    else
        echo "Error. Unable to determine what to install."
        help
        exit 1
    fi
fi

# Set the OSG repo now if not set via option. Before setting the custom GWMS repos
# You don't want to want to use them for OSG
if [[ -z "$OSG_REPO" ]]; then
    OSG_REPO="$GWMS_REPO"
fi

if [[ -n "$GWMS_USE_CUSTOM_REPO" ]]; then
    if [[ "$GWMS_USE_CUSTOM_REPO" = build ]];then
        # Install and setup the build server YUM repo (if missing or empty)
        if [[ ! -s /etc/yum.repos.d/build.repo ]]; then
            wget http://build-workspace.glideinwms.org/repo/build.repo -O /etc/yum.repos.d/build.repo
        fi
        GWMS_REPO="gwms-build"
    elif [[ "$GWMS_USE_CUSTOM_REPO" = ssidev ]];then
        # Install and setup the ssi-hepcloud YUM repo (if missing or empty)
        if [[ ! -s /etc/yum.repos.d/ssi-hepcloud.repo ]]; then
            wget -O /etc/yum.repos.d/ssi-hepcloud.repo http://ssi-rpm.fnal.gov/hep/ssi-hepcloud.repo
        fi
        GWMS_REPO="ssi-hepcloud-dev"
    elif [[ "$GWMS_USE_CUSTOM_REPO" = ssi ]];then
        # Install and setup the ssi-hepcloud-dev YUM repo (if missing or empty)
        if [[ ! -s /etc/yum.repos.d/ssi-hepcloud.repo ]]; then
            wget -O /etc/yum.repos.d/ssi-hepcloud.repo http://ssi-rpm.fnal.gov/hep/ssi-hepcloud.repo
        fi
        GWMS_REPO="ssi-hepcloud"
    fi
fi

# Set the DE repo only if not set via option
if [[ -z "$DE_REPO" ]]; then
    DE_REPO="$GWMS_REPO"
fi

### INSTALLATION ###

install_pre(){
    # Install the OSG repository
    
    # OSG Repo
    dnf -y install "https://repo.osg-htc.org/osg/$OSG_VERSION-main/osg-$OSG_VERSION-main-el9-release-latest.rpm"
}

install_sw(){    
    # Install common OSG packages, and the GlideinWMS software

    # OSG packages
    dnf install -y --enablerepo="$OSG_REPO" osg-ca-certs htgettoken  

    if [[ "$GWMS_SW" = decisionengine ]]; then
        dnf install -y --enablerepo="$OSG_REPO" --enablerepo="$DE_REPO" decisionengine-onenode
        # Git is in the package dependencies
        # pip install git+https://github.com/HEPCloud/decisionengine.git@2.0.3
        su -s /bin/bash -c 'pip install git+https://github.com/HEPCloud/decisionengine.git' - decisionengine
        su -s /bin/bash -c 'pip install git+https://github.com/HEPCloud/decisionengine_modules.git' - decisionengine
    else
        # Install the GlideinWMS Factory/Frontend
        dnf install -y --enablerepo="$OSG_REPO" --enablerepo="$GWMS_REPO" glideinwms-$GWMS_SW
    fi
    if [[ "$GWMS_SW" = vofrontend ]]; then
        # sudo is required by the run-test script
        dnf install -y sudo
    fi
    # For now the example logserver is supported only on the Factory
    if "$GWMS_LOGSERVER" && [[ "$GWMS_SW" = factory ]]; then
        dnf install -y --enablerepo="$OSG_REPO" --enablerepo="$GWMS_REPO" glideinwms-logserver
    fi
}


### CONFIGURATION ###

configure_common(){
    # HTCondor configuration
    cp /opt/config/99-debug.conf /etc/condor/config.d
    cp /opt/config/99-cafile.conf /etc/condor/config.d
}

configure_factory(){
    # GlideinWMS Factory configuration
    GWMS_CONFIG=/etc/gwms-factory/glideinWMS.xml
    cp /opt/config/factory/glideinWMS.xml $GWMS_CONFIG
    chown gfactory.gfactory $GWMS_CONFIG
    echo Updated Factory configuration
        
    # Condor tarball
    CONDOR_TARBALL_URLS="
    https://research.cs.wisc.edu/htcondor/tarball/24.0/24.0.3/release/condor-24.0.3-$(arch)_AlmaLinux9-stripped.tar.gz
    https://research.cs.wisc.edu/htcondor/tarball/10/10.x/10.6.0/release/condor-10.6.0-$(arch)_AlmaLinux9-stripped.tar.gz
    https://research.cs.wisc.edu/htcondor/tarball/9.0/9.0.18/release/condor-9.0.18-x86_64_CentOS7-stripped.tar.gz
    "
    CONDOR_TARBALL_PATH=/var/lib/gwms-factory/condor
    [ ! -d $CONDOR_TARBALL_PATH ] && mkdir -p $CONDOR_TARBALL_PATH
    pushd $CONDOR_TARBALL_PATH || exit 3
    for CONDOR_TARBALL_URL in $CONDOR_TARBALL_URLS; do
        wget "$CONDOR_TARBALL_URL"
        CONDOR_TARBALL=$(echo "$CONDOR_TARBALL_URL" | awk -F'/' '{print $NF}')
        tar -xf "$CONDOR_TARBALL"
    done
    popd || exit 4
}

configure_frontend(){
    # GlideinWMS Frontend configuration
    GWMS_CONFIG=/etc/gwms-frontend/frontend.xml
    cp /opt/config/frontend/frontend.xml $GWMS_CONFIG
    chown frontend.frontend $GWMS_CONFIG
    echo Updated Frontend configuration
}

configure_de(){
    postgresql-setup --initdb
    sed -e '/^local   all             all/s/peer/trust/' -e '/^host    all             all/s/ident/trust/' -i /var/lib/pgsql/data/pg_hba.conf
    # Without this the systemctl start was failing and the error was in /var/lib/pgsql/data/log/postgresql-*.log
    mkdir -p /var/run/postgresql
    chown postgres: /var/run/postgresql
}

### STARTUP ###

start_common(){
    bash /opt/scripts/create-host-certificate.sh -d "$GWMS_DIR"/secrets
    systemctl start httpd
    systemctl start condor    
}

start_logserver(){
    # Will start only if installed
    if [[ -f /etc/php-fpm.conf ]]; then
        echo "systemd_interval = 0" >> /etc/php-fpm.conf
        systemctl start php-fpm
        if [[ -f /var/lib/gwms-logserver/composer.json ]]; then
            pushd /var/lib/gwms-logserver/
            if ! composer install; then
                # running a second time because the first frequently times out
                composer install
            fi
            popd
        fi
    fi
}

start_factory(){
    bash /opt/scripts/create-idtokens.sh -a
    gwms-factory upgrade
    systemctl start gwms-factory
}

start_frontend(){
    bash /opt/scripts/create-idtokens.sh -r
    bash /opt/scripts/create-scitoken.sh -r
    gwms-frontend upgrade
    systemctl start gwms-frontend
}

start_de(){
    bash /opt/scripts/create-idtokens.sh -d
    bash /opt/scripts/create-scitoken.sh -d
    systemctl enable postgresql
    systemctl start postgresql
    createdb -U postgres decisionengine
    # Start Redis
    # yum rm iptables-legacy
    # yum install iptables-nft
    # podman run --name decisionengine-redis -p 127.0.0.1:6379:6379 -d redis:6 --loglevel warning
}

### MAIN ###
# Install
install_pre
if $CHECK_ONLY; then
    echo "Listing available GlideinWMS packages and aborting"
    dnf list --enablerepo="$GWMS_REPO" glideinwms\* decision\*
    exit 0
fi
install_sw
# Set up
configure_common
if [[ "$GWMS_SW" = factory ]]; then
    configure_factory
elif [[ "$GWMS_SW" = frontend ]]; then
    configure_frontend
elif [[ "$GWMS_SW" = decisionengine ]]; then
    configure_de
else
    echo "Error. Unexpected server type: $GWMS_SW"
    exit 1
fi
# Start
start_common
start_logserver
if [[ "$GWMS_SW" = factory ]]; then
    start_factory
elif [[ "$GWMS_SW" = frontend ]]; then
    start_frontend
elif [[ "$GWMS_SW" = decisionengine ]]; then
    start_de
else
    echo "Error. Unexpected server type: $GWMS_SW"
    exit 1
fi
