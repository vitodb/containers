# worker

This folder holds various Dockerfiles for worker nodes images

fnal-wn-sl6, fnal-wn-sl7 and fnal-wn-el8 are containers that provide an environment similar to the one on FermiGrid (actual FermiGrid nodes have only SL7).
It includes a base Scientific Linux with the xrootd client from OSG and a few other commonly used packages.

These three continers are made available on DockerHub and as expanded Singularity images on OSG's CVMFS.
To add a container to the OSG images it shold be added to the docker_images.txt file in the [OSG CVMFS Singularly Image Repository](https://github.com/opensciencegrid/cvmfs-singularity-sync). 

[Here](https://support.opensciencegrid.org/support/solutions/articles/12000024676-docker-and-singularity-containers) are more information about adding your image to CVMFS and on using Singularity images on CVMFS.


## How to use the workers and other images

You can run containers using these images on your workstation via [Docker](https://www.docker.com/) or [Podman](https://podman.io/):
```shell
# Docker
docker run -it --name my-fancy-name fermilab/fnal-wn-sl7:latest /bin/bash
# Podman
podman pull docker.io/fermilab/fnal-wn-sl7
podman run -it fnal-wn-sl7 /bin/bash
```

You may base your containers on the Fermilab worker nodes by including it inside your `Dockerfile` (pick your desired worker):
```
FROM fermilab/fnal-wn-sl7:latest
```

On the distributed computing resources (Grid, Cloud, HPC, ...) you can use the same images via [Apptainer/Singularity](https://apptainer.org/). This is an alternative virtualization product that by default runs in user space, exposes more of the OS, and mounts some local disks, making it more suitable for running unprivileged on shared computing resources.  
Apptainer/Singularity can access the images out of Docker Hub or CVMFS:
```shell
# From Docker
apptainer shell docker://fermilab/fnal-wn-sl7:latest
# CVMFS
apptainer run -B/cvmfs -B/mu2e/data /cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest df -h
```

You can make the request by sending mail to support@osgconnect.net or
For OSG-connect read more about how it works [here](https://support.opensciencegrid.org/support/solutions/articles/12000024676-docker-and-singularity-containers). When you submit your job, add these options:
```shell
--lines='+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"'
--append_condor_requirements='(TARGET.HAS_SINGULARITY==true)'
```

When using GlidienWMS the worker images are normally selected by your experiment and you don't have to worry. You may anyway choose your own, e.g. by adding to your HTCondor submit file:
```
+SingularityImage="/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest"
# And possibly append to the requirements '&& (TARGET.HAS_SINGULARITY==true)'
```

HSF, the HEP Software Foundation, has some Carpentry-style training on how to use Docker and Apptainer/Singularity:
- [Docker](https://hsf-training.github.io/hsf-training-docker/)
- [Apptainer](https://hsf-training.github.io/hsf-training-singularity-webpage/)
