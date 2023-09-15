.. note::
  Any values below that are in brackets indicate where you should substitute
  values that are appropriate for you (such as a username).  Unless indicated,
  the brackets should be removed.

.. _Local Cluster:

Local computing resources
=========================

.. _walnut:

Walnut
------

ssh
~~~
OMRFs high performance compute (HPC) cluster, Walnut (walnut.rc.lan.omrf.org),
is accessable via remote terminal.  One must connected to the OMRF intranet (by
either local connection or VPN via Pulse) or to access Walnut.  Logging in is
easy on \*nix systems where `ssh` is built in; on versions of Windows prior to
10 you will need to install the program PuTTY while on Windows 10 `ssh` is
available at least in Powershell.  To log in simply run:

.. code-block:: console

    ssh {OMRF USERNAME}@walnut.rc.lan.omrf.org.

If you will be accessing Walnut often and from the same computer, logging in
(and use of Visual Studio Code) can be made easier by setting up an ssh-key_.

ssh-key
~~~~~~~
To generate a key on an \*nix system, run the following in a terminal:

.. code-block:: console

    ssh-keygen -t ed25519 -o -C "{some identifier like an email address}" -f ~/.ssh/walnut

On Windows10, run from either the command prompt or powershell:

.. code-block:: console

    ssh-keygen -t ed25519 -o -C "{some identifier like an email address}" -f C:\Users\{USERNAME}\.ssh\walnut

Create (or open if it already exists) the file at `~/.ssh/config` or
`C:\\Users\\{USERNAME}\\.ssh\\config` and add the following:

.. code-block:: sh

    Host walnut.rc.lan.omrf.org
      HostName walnut.rc.lan.omrf.org
      IdentityFile ~/.ssh/walnut
      User {OMRF USERNAME}

Open the walnut.pub file in the .ssh directory and copy the contents.
Log into Walnut and run the following:

.. code-block:: console

    echo {PASTE walnut.pub CONTENTS} >> ~/.ssh/authorized_keys

.. _Software:

Software
--------

Modules
~~~~~~~
By default, the software available upon login to Walnut is generally limited
to standard Unix commands. Additional software is provided through
`environment modules <http://modules.sourceforge.net/>`_. You can see what
modules are available modules by running:

.. code-block:: console

    user@walnut:~$ module avail

or you can search for particular software with:

.. code-block:: console

    user@walnut:~$ module spider

To load/unload a particular module:

.. code-block:: console

    user@walnut:~$ module load {MODULE NAME}
    user@walnut:~$ module unload {MODULE NAME}

Conda
~~~~~
Not all software is available as an environment module and without superuser
access, it is impossible to install additional software (though compiling from
source is sometimes possible). While it should be possible to have software
installed by the administrator, it is more expedient (and somewhat cleaner) to
sidestep these issues by using the Python package manager Anaconda.  While
originally designed for managing Python packages, many bioinformatics software
are available though it (especially when the bioconda channel is added).

Anaconda makes use of user environments where programs and libraries are put in
a discrete container belonging to a user where they do not interfer with the
external system libraries or with other environments.
To create an environment:

.. code-block:: console

    user@walnut:~$ conda create -n {ENVIRONMENT NAME}

Software can be installed at environment creation by passing the names at the
end of the above statement or at anytime after creation. An environment can be
also created from a YAML file defining the environment:

.. code-block:: console

    user@walnut:~$ conda create -f environment.yml

Addtional software channels can be added by:

.. code-block:: console

    user@walnut:~$ conda config --add channels {CHANNEL NAME}

Two particularly useful channels are ``conda-forge`` and ``bioconda``.  Once
created, the environment can be activated with:

.. code-block:: console

    user@walnut:~$ source activate {ENVIRONMENT NAME}

.. important::
    Use ``source activate``, not the newer ``conda activate``. The latter form
    disagrees with something in the current Bash setup on Walnut and fails to
    work unless you invoke `bash` after logging in (at which point you lose
    any command line highlighting).

Once activated, programs can be run as if they had been installed by the
system itself.  New software is installed by:

.. code-block:: console

    user@walnut:~$ conda install {PROGRAM NAME}

And particular software versions can be installed by:

.. code-block:: console

    user@walnut:~$ conda install {PROGRAM NAME}=={VERSION NUMBER}=={CHANNEL}

vscode
~~~~~~
It can be quite handy to run Visual Studio Code remotely on Walnut, especially
for debugging purposes; however, there are a couple of issues with simply
using the remotes plugin and connecting via ssh.  For one, doing so runs
a server on the head node, and running anything other than minimal applications
on the head node is generally frowned on.  Trying to spin up a job for the 
server on a a compute node and then connect to it remotely is currently
non-trivial.  Probably the easiest solution is to run the code-server docker
container as a job.

1. Create the configuration file. 

.. code-block:: console

    ~/.config/code-server/config.yaml

2. Build the container.

3. Run the server container.

.. code-block:: console

    srun --partition interactive --pty --mem=64G --cpus-per-task=4 hostname && singularity run --bind=/s/guth-aci --bind=/Volumes/guth_aci_informatics ~/code_server_3_9_2.sif

4. Setup ssh port forwarding. 

.. code-block:: console

    ssh -L 8080:cb000:8080 smithm@walnut.rc.lan.omrf.org -N

.. _Data storage:

Folders
-------
While not an exhaustive list, the primary folders that are available are:

* `/flotsam/h` - `home`_ directory
* `/Volumes/guthridge-aci-informatics` - `Group <Share_>`_ directory
* `/scratch/guth-aci` - Scratch_ directory
* `/Volumes/hts_core/Shared` - `Shared References`_ directory

Home
~~~~
Each user has their own home directory hosted on the Flotsam file server.
As each individual's home directory has a 5/10GiB quota, it is mostly useful
for storing setting files and analysis script files. Backup snapshots are taken
at the top of the hour in addition to a nightly replication snapshot that is
stored for 3-4 weeks on a secondary system.

Share
~~~~~
The lab has a shared folder on Flotsam named `guth_aci_informatics`. This
is generally used for our own reference files, software, and working copies of
data in folder. While it is not automatically backed up, hourly snapshots are
taken and kept for a maximum of ~72, though these may be purged earlier if
space on the server becomes constrained.

.. important::
  The directory has a 10.0TiB soft and 12.0TiB hard quota. Meaning you can
  write up to 12.0TiB of data, but not past that. If you go over 10.0TiB,
  the system will allow more data to be written for 7 days, up to the 12.0TiB
  limit. After 7 days it will block writes until you drop below 10.0TiB.

.. _scratch:

Scratch
~~~~~~~
The scratch drive offers virtually unlimited storage with the caveat that there
are absolutely no backups and all files are purged after 30 days of inactivity.
It is especially useful for analysis and data processing pipelines where
large intermediate files are generated but are of otherwise no interest and do
not need to be caught up in potentially expensive backup routines.

Shared References
~~~~~~~~~~~~~~~~~
There are many common reference datasets & genomes available in
`/Volumes/hts_core/Shared`. However, in my experience, many of these are out of
date.

.. _Local computing object storage:

Object Storage
~~~~~~~~~~~~~~
Most of the large files (especially those from sequencing runs) are not kept
in a typical files system but are instead placed in object storage. A
discussion of what is object storage and why it is used is beyond the scope of
this guide. What is important here is how to access and manipulate the files in
object storage.

.. note::
    See this `article from Western Digital <https://blog.westerndigital.com/why-object-storage/>`_ for a good explanation or read about it on `Wikipedia <https://en.wikipedia.org/wiki/Object_storage>`_.

Object storage can only be accessed from within the OMRF network (or when connected via VPN) and requires
special software to interact with it, such as :ref:`o3-utils <o3-utils>` or :ref:`rclone <Rclone>`

o3-utils
........
OMRFs object storage is built on OpenStack.  Accessing it can be somewhat less
than straightforward. There are a few settings that one typically need to be
aware of (and some differences in terminology) but are instead transparently
taken care of by a couple of scripts made available through the `o3-utils`
module.

OpenStack uses the terms *tenants*, *container*, and *prefix* to roughly mean
*drive*, *root folder*, and *sub-folder* (or, at least for our purposes right
now.). Differing from how one typically accesses files, you will need to use a
client to log into a particular tenant

For instance, the Novaseq runs are stored at
`LDAP_o3-guthridge-james/PrecisionMed/S4`
In this case, `LDAP_o3-guthridge-james` is the tenant, `PrecisionMed` is the
container, and `S4` is the prefix.

Before accessing any of the files in object storage, you will need to login to
the tenant you wish to access by running:

.. code-block:: console

    o3-login -t {TENANT}

Afterward, you can manipulate files in the container using `swift` or the more
straightforward tool, `rclone`_

.. note::
  The command `o3-tenants` can be used to see what tenants you are part of.

Tenants
.......

The James/Guthridge labs tenants of which I am aware (as of 2023-07-26)

* LDAP_o3-guthridge-james - this is where a majority of all data is located
* LDAP_ss-prj-guthridge-scrnaseq - Any single cell transcriptomics/genomics data is stored here 
* LDAP_ss_prj_gaffney_guthridge_bold
* LDAP_ss-prj-james-ordc

.. _rclone_local_cluster:

rclone
......

`rclone <rclone.org>`_ is a utility capable of interacting with numerous types
of object and cloud storage systems, including both OpenStack and Google
Cloud Storage. See the :ref:`section on using rclone <Rclone>`for more.

.. _Batch jobs:

slurm
-----
To execute resource intensive commands, submit the commands as jobs to the
`slurm workload manager <https://slurm.schedmd.com/documentation.html>`_

.. note::
  The login nodes are limited to a single CPU core and 2 GB of of RAM and are
  not suited to running many bioinformatics tools.  Also, attempting to run
  anything beyond a text editor will likely result in receiving a curt email
  telling you to cut it out.

On Walnut, quick, simple jobs can be submitted using the ``srun`` command while
longer and more complex jobs should be written as batch scripts and submitted
using ``sbatch``.  Additionally, use the command ``squeue`` to list the
current job queue and use ``scancel`` to terminate one or more jobs.

srun
~~~~
Most terminal commands can be prefixed with `srun` to offload them to the.
cluster.  Specify the necessary resources by passing arguments to srun:

    --mem=GBMEMORY         memory to request for the job
    --cpus-per-task=CPUS   number of CPUs to request for the job
    --partition=NAME       hardware partition type to run job on

.. warning::
  ``srun`` functions like a typical command line program in that disconnecting
  from the terminal session will result in the command exiting early. If you
  plan to use ``srun`` for a command that will take some time or there is the
  possibility of the terminal disconnecting, start a ``tmux`` session first. Or,
  just use ``sbatch``.

sbatch
~~~~~~
Batch scripts have the following format:

  .. code-block:: bash

    #! /bin/bash -l

    #SBATCH --account {ACCOUNT}
    #SBATCH --job-name {JOBNAME}
    #SBATCH --output bcl2fastq_demux.log
    #SBATCH --mail-user={YOUR EMAIL ADDRESS}
    #SBATCH --mail-type=END,FAIL
    #SBATCH --mem={GB MEMORY}
    #SBATCH --partition={PARTITON}
    #SBATCH --nodes=1
    #SBATCH --cpus-per-task={# CPU CORES}
    #SBATCH -t 1:6:15

    module load {NECESSARY MODULES}
    {LIST OF COMMANDS...}

..

    --account  Account names for tracking usage
    --output  Output file name to redirect STDOUT into
    --mail-user  Address to email updates
    --mail-type  Types to updates to email about
    --job-name  Job a name
    --mem  Amount of memory to request
    --partition  Hardware node type to request. Options include serial, debug,
      highmem, and gpu. Unless otherwise necessary, use serial.
    --nodes  Number of compute nodes to request for job
    --cpus-per-task  Number of cpu cores on that node to request
    --time  Maximum amount of time a job can run before being killed.
      In {days}:{hours}:{minutes} format.

Submit the job by:

.. code-block:: console

    user@walnut:/Volumes/guth_aci_informatics/$ sbatch job_script.sh
