#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Using IMAGE_NAMESPACE and MY_LABEL
[[ -z "${IMAGE_NAMESPACE}" ]] && IMAGE_NAMESPACE=glideinwms || true
[[ "$IMAGE_NAMESPACE" = NONE ]] && IMAGE_NAMESPACE= || true
MY_NAMESPACE=
MY_LABEL=
[[ -n "$IMAGE_NAMESPACE" ]] && MY_NAMESPACE="${IMAGE_NAMESPACE%/}/" || true
[[ -n "$IMAGE_LABEL" ]] && MY_LABEL=":${IMAGE_LABEL#:}" || true
# Exporting IMAGE_NAMESPACE for Dockerfiles
#export IMAGE_NAMESPACE

help_msg() {
    cat << EOF
$0 [options] 
Pull ITB images (ce, factory, and frontend) and optionally re-tag them and the gwms base
  -h       print this message
  -v       verbose mode
  -t       re-tag images and push to docker hub (login before running this) 
  -s SRC_LABEL image label (default: env IMAGE_LABEL)
  -d DST_LABEL new label for re-tagging
  -n NAMESPACE image namespace (default: env IMAGE_NAMESPACE)
EOF
}

VERBOSE=
DO_RETAG=
DST_LABEL=
while getopts "hvts:d:n:" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    t) DO_RETAG=yes;;
    s) IMAGE_LABEL=$OPTARG;;
    d) DST_LABEL=":${OPTARG#:}";;
    n) IMAGE_NAMESPACE=$OPTARG;;
    *) echo "ERROR: Invalid option"; help_msg; exit 1;;
  esac
done

MY_NAMESPACE=
MY_LABEL=
[[ -n "$IMAGE_NAMESPACE" ]] && MY_NAMESPACE="${IMAGE_NAMESPACE%/}/" || true
[[ -n "$IMAGE_LABEL" ]] && MY_LABEL=":${IMAGE_LABEL#:}" || true


# Building for the local architecture
#podman pull "$MY_NAMESPACE"gwms-workspace"$MY_LABEL"
#podman pull "$MY_NAMESPACE"ce-workspace"$MY_LABEL"
#podman pull "$MY_NAMESPACE"factory-workspace"$MY_LABEL"
#podman pull "$MY_NAMESPACE"frontend-workspace"$MY_LABEL"
do_gwms=
if [[ -n "$DO_RETAG" ]]; then
    do_gwms=gwms-workspace
fi
for i in ${do_gwms} ce-workspace factory-workspace frontend-workspace; do
    to_pull="${MY_NAMESPACE}${i}${MY_LABEL}"
    [[ -n "$VERBOSE" ]] && echo "Pulling $to_pull" || true
    podman pull "${to_pull}"
    if [[ -n "$DO_RETAG" ]]; then
        [[ -n "$VERBOSE" ]] && echo "Re-tagging to ${MY_NAMESPACE}${i}${DST_LABEL} and pushing" || true
        podman tag "$to_pull" "${MY_NAMESPACE}${i}${DST_LABEL}"
        podman push "${MY_NAMESPACE}${i}${DST_LABEL}"
    fi
done
