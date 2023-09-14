.. _RStudio:

RStudio
=======

Using RStudio on Walnut
-----------------------

If for some reason you do not or cannot use RStudio Server on a GCP instance,
RStudio can be started up as a job on the cluster, allowing for a lot more
resources than your desktop will allow.  There are, however, a couple of
complicating factors

1. RStudio Server acts as an http server, which is how it delivers RStudio to you, the user.

2. The version of RStudio and R available as environment modules may not be the latest or even versions that work with the software you need them to.

These can be worked around, though, by running RStudio from a :ref:`Singularity <singularity>`
container and setting up an `ssh tunnel <https://ssh.com/ssh/tunneling/>`_ to
the RStudio server. There are many prebuilt containers available from Dockerhub,
though those from the `Rocker Project <https://www.rocker-project.org/>`_, or
building off that, `Bioconductor <https://hub.docker.com/r/bioconductor/bioconductor_docker>`_
are a good place to start (and on which to base your own containers).

Pre-written RStudio job script
..............................

Currently, in the `/Volumes/guth_aci_informatics/software/containers/` folder,
there is a `bioconductor-3.11.sif` that is built from from the bioconductor/bioconductor_docker:RELEASE_3_11 and in the `/Volumes/guth_aci_informatics/software/`
directory, there is an `rstudio-server.job` that will start and configure the
server.  

To run it ::

1. Submit the script to slurm with :

    .. code-block:: bash

        (base) smithm@walnut:~/$ sbatch /Volumes/guth_aci_informatics/software/rstudio-server.job

2. After submitting the script, examine the file `rstudio-server.job.log` in your home directory:

    .. code-block:: bash

        (base) smithm@walnut:~/$ cat ~/rstudio-server.job.log

3. That log will have directions on how to setup a tunnel on your local desktop and how to log into the server.

4. In a web browser, go to the address `http://127.0.0.1:8787` and login using the credentials as detailed in the above log .

The script is a modified from of that from the `Rocker Project's guide to Singularity <https://www.rocker-project.org/use/singularity/>`_

.. code-block:: bash

    #!/bin/sh
    #SBATCH --time=08:00:00
    #SBATCH --signal=USR2
    #SBATCH --ntasks=1
    #SBATCH --cpus-per-task=4
    #SBATCH --mem=64
    #SBATCH --partition=highmem
    #SBATCH --output=/home/%u/rstudio-server.job.log

    export PASSWORD=$(openssl rand -base64 15)
    # get unused socket per https://unix.stackexchange.com/a/132524
    # tiny race condition between the python & singularity commands
    readonly PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
    readonly HOSTNAME=$(hostname -I)
    cat 1>&2 <<END
    1. SSH tunnel from your workstation using the following command:

    ssh -N -L 8787:${HOSTNAME}:${PORT} ${USER}@walnut.rc.lan.omrf.org

    and point your web browser to http://localhost:8787

    2. log in to RStudio Server using the following credentials:

    user: ${USER}
    password: ${PASSWORD}

    When done using RStudio Server, terminate the job by:

    1. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
    2. Issue the following command on the login node:

        scancel -f ${SLURM_JOB_ID}
    END

    # User-installed R packages go into their home directory
    if [ ! -e ${HOME}/.Renviron ]
    then
    printf '\nNOTE: creating ~/.Renviron file\n\n'
    echo 'R_LIBS_USER=~/R/%p-library/%v' >> ${HOME}/.Renviron
    fi

    # This example bind mounts the /project directory on the host into the Singularity container.
    # By default the only host file systems mounted within the container are $HOME, /tmp, /proc, /sys, and /dev.
    singularity exec --bind=/s/guth-aci --bind=/Volumes/guth_aci_informatics/ /Volumes/guth_aci_informatics/software/rstudio.sif \
        rserver --www-port ${PORT} --auth-none=0 --auth-pam-helper-path=pam-helper
    printf 'rserver exited' 1>&2