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
 # check the ID of the build-workspace
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
