#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Using IMAGE_NAMESPACE and MY_LABEL
[[ -z "${IMAGE_NAMESPACE}" ]] && IMAGE_NAMESPACE=glideinwms || true
[[ "$IMAGE_NAMESPACE" = NONE ]] && IMAGE_NAMESPACE= || true
IMG_LIST_DEFAULT="ce,factory,frontend"
IMG_LIST_ALL="gwms,ce,factory,frontend,testbed,build"

help_msg() {
    cat << EOF
$0 [options] 
Pull ITB images (ce, factory, and frontend) and optionally re-tag them and the gwms base
  -h       print this message
  -v       verbose mode
  -t       re-tag images and push to docker hub (login before running this)
  -a       pull all images ($IMG_LIST_ALL)
  -s SRC_LABEL image label (default: env IMAGE_LABEL)
  -d DST_LABEL new label for re-tagging
  -n NAMESPACE image namespace (e.g. docker.io/glideinwms, default: env IMAGE_NAMESPACE)
  -i IMG_LIST comma separated list (no spaces) of images to pull or re-tag (default: $IMG_LIST_DEFAULT all when re-tagging)
              possible images keywords: $IMG_LIST_ALL
EOF
}

VERBOSE=
DO_RETAG=
DST_LABEL=
IMG_LIST=
while getopts "vtas:d:n:i:h" option
do
  case "${option}"
    in
    h) help_msg; exit 0;;
    v) VERBOSE=yes;;
    t) DO_RETAG=yes;;
    a) IMG_LIST="$IMG_LIST_ALL";;
    s) IMAGE_LABEL=$OPTARG;;
    d) DST_LABEL=":${OPTARG#:}";;
    n) IMAGE_NAMESPACE=$OPTARG;;
    i) IMG_LIST="$OPTARG";;
    *) echo "ERROR: Invalid option"; help_msg; exit 1;;
  esac
done

MY_NAMESPACE=
MY_LABEL=
[[ -n "$IMAGE_NAMESPACE" ]] && MY_NAMESPACE="${IMAGE_NAMESPACE%/}/" || true
[[ -n "$IMAGE_LABEL" ]] && MY_LABEL=":${IMAGE_LABEL#:}" || true
if [[ -z "$IMG_LIST" ]]; then
    [[ -n "$DO_RETAG" ]] && IMG_LIST="$IMG_LIST_ALL" || IMG_LIST="$IMG_LIST_DEFAULT"
fi

# Pulling for the local architecture
#podman pull "$MY_NAMESPACE"gwms-workspace"$MY_LABEL"
#podman pull "$MY_NAMESPACE"ce-workspace"$MY_LABEL"
#podman pull "$MY_NAMESPACE"factory-workspace"$MY_LABEL"
#podman pull "$MY_NAMESPACE"frontend-workspace"$MY_LABEL"

image_list=
if [[ -n "$IMG_LIST" ]]; then
    for i in gwms ce factory frontend testbed build ; do
        [[ ",${IMG_LIST}," = *,${i},* ]] && image_list="${image_list} ${i}-workspace" || true
    done
fi

for i in ${image_list} ; do
    to_pull="${MY_NAMESPACE}${i}${MY_LABEL}"
    [[ -n "$VERBOSE" ]] && echo "Pulling $to_pull" || true
    podman pull "${to_pull}"
    if [[ -n "$DO_RETAG" ]]; then
        [[ -n "$VERBOSE" ]] && echo "Re-tagging to ${MY_NAMESPACE}${i}${DST_LABEL} and pushing" || true
        podman tag "$to_pull" "${MY_NAMESPACE}${i}${DST_LABEL}"
        podman push "${MY_NAMESPACE}${i}${DST_LABEL}"
    fi
done
