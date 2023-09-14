.. _jupyter:

Jupyter
=======

Using Jupyter notebooks on Walnut
-----------------------

If for whatever reason you wish to run a jupyter notebook locally,
it is possible to start a job on the OMRF HPC, allowing for a lot more
resources than your desktop will allow.

To start jupyter ::

1. Submit the script to slurm with :

    .. code-block:: bash

        (base) smithm@walnut:~/$ sbatch /Volumes/guth_aci_informatics/software/start_jupyter_lab.job

2. After submitting the script, you *should* receive an email with instructions on accessing the server.  If you do not,
   examine the file `rstudio-server.job.log` in your home directory:

    .. code-block:: bash

        (base) smithm@walnut:~/$ cat ~/jupyterlab.log

3. That log will have directions on how to setup a tunnel on your local desktop and how to log into the server.

4. In a web browser, go to the address `http://127.0.0.1:${PORT}` and login using the credentials as detailed in the above log .

.. code-block:: bash

    #!/bin/bash -l

    #SBATCH --nodes=1
    #SBATCH --cpus-per-task=4
    #SBATCH --mem=64G
    #SBATCH --partition=interactive
    #SBATCH --time 0-12:0:0
    #SBATCH --job-name jupyter-notebook
    #SBATCH --dependency=singleton
    #SBATCH -o jupyterlab.log
    #SBATCH -e jupyterlab.log
    #SBATCH --output %x.%A.%a.log
    #SBATCH --mail-type END,FAIL,TIME_LIMIT_80


    # check if in slurm first
    if [ -z "${SLURM_JOB_ID}" ]; then
    module load slurm
    exec sbatch --mail-user ${USER}@omrf.org ${@} \
        ${0}
    fi

    set -e

    #export J_PASSWORD=$(openssl rand -base64 12)
    export XDG_RUNTIME_DIR=""

    PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')

    command -v jupyter lab >/dev/null 2>&1 || module load python jupyter matplotlib seaborn

    #exec \
    jupyter lab --no-browser \
    --port=${PORT}  --ip=0.0.0.0 \
    --NotebookApp.allow_password_change=False \
    --notebook-dir=/s/guth-aci/ &
    #--NotebookApp.token="${J_PASSWORD}"
    pid=$!

    sleep 5

    tok=$(jupyter-lab list|grep -o "token=[a-z0-9]*" | sed -n 1p|sed 's/token=//')

    # inform user of URI & password
    (cat <<END | tee /dev/stderr | mail -s "Jupyter Notebook Instance ${SLURM_JOB_ID}" ${USER}@omrf.org
    The Jupyter Notebook session has started.

    It will by default last for about 12 hours

    Access the session at:

    http://$(hostname -f):${PORT}/?token=${tok}

    Login with the token: ${tok} (or check the job log file)

    When finished with the session, terminate the job by:
    1. Select Quit from the notebook website
    2. Run the following command on the login node:

    scancel -f ${SLURM_JOB_ID}

    END
    ) 2>&1

    wait $pid