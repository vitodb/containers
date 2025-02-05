#!/bin/bash

# SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
# SPDX-License-Identifier: Apache-2.0

# Remove unused files to reduce the image size

# In /var are /var/lib/dnf, /var/lib/rpm and /var/lib/selinux
# In /etc are /etc/grid-security/certificates /etc/pki/ca-trust /etc/selinux/targeted/contexts /etc/selinux/targeted/policy
# CE in /opt has /opt/containers/apptainer (>100MB, remove it after pulling the image)?
# /usr is big all over (~1GB in CE) mostly bin and lib directories (bin sbin lib lib64 libexec /usr/local/lib64 /usr/local/lib)
# /usr/include/ is 29MB, mostly /usr/include/c++ and /usr/include/linux
# /usr/share/doc /usr/share/groff /usr/share/info /usr/share/man are about 60MB
# /usr/share/licenses is 5.5MB, needed for redistribution

empty_dir() {
    [[ -d "$1" ]] && rm -rf "${1:?}"/*
}


for i in /usr/share/doc /usr/share/groff /usr/share/info /usr/share/man ; do
    empty_dir "$i"
done
