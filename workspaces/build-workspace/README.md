<!--
SPDX-FileCopyrightText: 2020 Fermi Research Alliance, LLC
SPDX-License-Identifier: Apache-2.0
-->

# Build Workspace

Image for containers to build GlideinWMS releases.
Contains all the necessary components for a build environment:
Kerberos and kx509 for the authentication, Git, SVN, rpm-build, and osg-build.

Pull the container image, run it:
```commandline
 podman pull docker.io/glideinwms/build-workspace:latest
 podman image list
 # Check the ID of the build-workspace
 # Add --privileged if you plan to build locally the RPMs with mock
 podman run -it <image_ID> /bin/bash
```
And in the container switch to the unprivileged user `abc` and run all the commands:
```commandline
su - abc
cd /opt/
ls -l
```

In `/opt` there are a couple directories ready for use and owned by `abc`:
- `/opt/osg` contains a clone of osg-build in `osg-build`, in case you want to use that instead of the installed one,
and a checkout of the OSG SVN repositories for glideinwms in `svnrepo`, so you can use `svn update` to get the latest
version and then use them to build.
- `/opt/abc` ready to be used as work directory (e.g. to clone the glideinwms repository) if you prefer
this to the home directory.

The `/opt/scripts/startup.sh` creates a host certificate and starts the http server.
There are two YUM repod in `/opt/repo/` served as `gwms-build` (enabled by default) and `gwms-build-alt` (disabled by default).
Other hosts can set up the exported YUM repos using (we assume the build container host name to
be `build-workspace.glideinwms.org`): 
```commandline
wget http://build-workspace.glideinwms.org/repo/build.repo -O /etc/yum.repos.d/build.repo
```

Here the commands to build new RPMs and update the YUM repos:
```commandline
su - abc
# As abc user
cd /opt/abc
# Choose the repo you'd like to use for the build
git clone https://github.com/mambelli/glideinwms.git
cd glideinwms/
# Choose the branch for the build
git checkout release_v3_10_9_rc1
cd ../
# Add --no-mock to use only rpmbuild
# To use mock you must run the build container as privileged (podman run --privileged ...)
./glideinwms/build/ReleaseManager/release.py --release-version=v3_10_9 --source-dir=`pwd`/glideinwms --release-dir=`pwd`/distro --rc=1 --python=python39 --verbose
# The RPMS are in distro/v3_10_9_rc1/rpmbuild/RPMS/ (where v3_10_9_rc1 is the release/RC)
# Copy the RPMs (choose if you want to use the main ot alt repo) and update the YUM repos
cp distro/v3_10_9_rc1/rpmbuild/RPMS/*rpm /opt/repo/main/
cd /opt/repo/
createrepo main/
createrepo alt/
```
