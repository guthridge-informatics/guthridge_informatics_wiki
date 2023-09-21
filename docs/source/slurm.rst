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
