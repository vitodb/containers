#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

GWMS_DIR=/opt/gwms
GWMS_SRC_DIR="$GWMS_DIR"/glideinwms
GWMS_REPO=https://github.com/glideinWMS/glideinwms.git
GWMS_REPO_REMOTE=origin
# Leaving unchanged. Default branch after cloning is master
GWMS_REPO_REF=
# auto or 
PYVER="auto"
# v... format, e.g. v3_10_9
B_RELEASE=
# empty (no RC) or number, e.g. 2
B_RC=
# main or alt
B_REPO=main

help_msg() {
    cat << EOF
$0 [options] 
Build a GlideinWMS release from a Git repository and publish it in the build-server YUM repository.
Future versions will be generalized for multiple software packages.
  -h       print this message.
  -v       verbose mode.
  -c REF   Checkout REF in the GlideinWMS Git repository (Default: no checkout, leave the default/existing reference).
           Setting a REF will reset the content of the repository loosing eventual changes.
  -u URL   Git repository URL (Default: $GWMS_REPO).
  -d DIR   GlideinWMS directory (GWMS_DIR, Default: $GWMS_DIR). The repository will be in its ./glideinwms subdirectory.
  -p PYVER Python version e.g. 39, 3.9, 36, 3.6, auto (Default: auto. Detect the highest version installed in /usr/lib/python*).
  -r REL   Release string, e.g. v3_10_9. Mandatory (will be auto detected in the future).
  -n RCN   Release candidate number, e.g. 2. Defaults to empty, no RC (full release).
  -y REPO  YUM repository ('alt' or 'main' - Default: $B_REPO).
EOF
}

while getopts "hc:u:d:p:r:n:y:v" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    c) GWMS_REPO_REF=${OPTARG};;
    u) GWMS_REPO=${OPTARG};;
    d) GWMS_DIR=${OPTARG%/};;
    p) PYVER=$OPTARG;;
    r) B_RELEASE=${OPTARG};;
    n) B_RC=${OPTARG};;
    y) B_REPO=${OPTARG};;
    *) echo "ERROR: Invalid option"; help_msg; exit 1;;
  esac
done

if [[ ! -d "$GWMS_SRC_DIR" ]]; then
    cd "$GWMS_DIR"
    git clone "$GWMS_REPO"
else
    cd "$GWMS_SRC_DIR"
fi

if ! git status 1>/dev/null 2>&1; then
    echo "GWMS_SRC_DIR ($GWMS_SRC_DIR) exists but is not a valid git repository. Aborting."
    exit 1
fi

if [[ -n "$GWMS_REPO_REF" ]]; then
    git fetch "$GWMS_REPO_REMOTE"
    # git checkout "$GWMS_REPO_REF"
    # This is more robust if there were changes in the source tree
    git reset -hard "$GWMS_REPO_REMOTE/$GWMS_REPO_REF"
fi

if [[ "${PYVER}" = auto ]]; then
    PYVER="$(ls -d /usr/lib/python3* | tail -n1)"
    PYVER=${PYVER#/usr/lib/python}
    [[ -n "$VERBOSE" ]] && echo "PYVER auto. Detected and using Python $PYVER."
fi
PYVER="${PYVER/./}"

if [[ -z "$B_RELEASE" ]]; then
    # TODO: implement autodetect: current (from spec file changelog) + 1
    echo "Unable to set the release version. Aborting."
    exit 1
fi

B_DIR="$$B_RELEASE"

if [[ -n "$B_RC" ]]; then
    B_RC="--rc=$B_RC"
    B_DIR="${B_DIR}_rc$B_RC"
fi

# Make the release    
cd ..
# ./glideinwms/build/ReleaseManager/release.py --release-version="$B_RELEASE" --source-dir=`pwd`/glideinwms --release-dir=`pwd`/distro --rc=3 --python=python39 --verbose
if ! ./glideinwms/build/ReleaseManager/release.py --release-version="$B_RELEASE" --source-dir="$GWMS_SRC_DIR" --release-dir=`pwd`/distro "$B_RC" --python="python$PYVER" --verbose; then
    echo "GlideinWMS release building failed."
    exit 1
fi

# Update the YUM repository 
if ! cp distro/"$B_DIR"/rpmbuild/RPMS/*rpm /opt/repo/"$B_REPO"/; then
    echo "Copy of the packages to the repository failed."
    exit 1
fi
pushd /opt/repo/ && createrepo main/ && createrepo alt/ && popd

echo "YUM repository $B_REPO updated with $B_DIR"
