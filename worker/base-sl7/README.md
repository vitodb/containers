<!--
SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
SPDX-License-Identifier: Apache-2.0
-->

Image of ScientificLinux 7 with SL and Fermilab yum repositories updated to point to the
obsolete location (http://ftp.scientificlinux.org/linux/scientific/obsolete/...)
EPEL, HTCondor 9.0 LTS (supporting tokens and last version supporting GSI), 
and OSG 3.6 repositories are also set up and available.
OSG is configured to ignore the condor* and htcondor* packages so they are picked from the HTCondor repository.

This image is used as base for fnal-wn-sl7, fnal-dev-sl7 and the SL7 version of the GlideinWMS workspaces.

Maintained and built by Marco Mambelli.
