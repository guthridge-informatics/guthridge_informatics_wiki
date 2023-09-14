.. _Processing 10X Genomics scRNA-seq Runs:

Processing 10X Genomics scRNA-seq Runs
======================================

Processing the data entails the following steps:

* Demultiplexing with **bcl2fastq**
* Aligning sequences and producing count matrices using **cellranger count**
* Analyzing the data using the R package **Seurat** or the Python module **Scanpy**
** These are not the only two packages available for analysis and you may need
to find others to handle tasks such as RNA velocity or trajectory analysis

Setting up
----------
First, use `Cookiecutter <https://cookiecutter.readthedocs.io/en/latest/>`_ to
setup the directories for the project.  Cookiecutter itself can be installed
on the commandline with::

    pip install cookiecutter

Change directory to where you would like to place the project and run the
following command::

    cookiecutter gl:guthridge_informatics/scrna-processor

This will ask a couple of questions to setup a few configuration variables and
leave a folder with the following structure:

.. code-block:: bash

    .
    ├── AUTHORS.md
    ├── LICENSE
    ├── README.md
    ├── code                <- Analysis code required for this project
    ├── config              <- Configuration files, e.g., for doxygen or for your model if needed
    ├── data
    │   ├── bcls            <- Raw data from sequencers.
    │   ├── fastqs          <- Intermediate data prior to alignment and counting.
    │   ├── processed       <- Count matrices and molecule information files. Cell Ranger output.
    │   └── r_data          <- Data object files created by the Drake analysis.
    ├── metadata            <- Information about the sample sources
    ├── reports             <- Report prepared by Drake
    └── scripts             <- Script code created to process sample data from raw to count matrices

Demultiplexing
--------------
For more on demultiplexing, see the :ref:`Demultiplexing` section in :ref:`Processing Novaseq Runs`.

However, unlike with libraries from other kits you will want to use `cellranger mkfastq`
for demultiplexing.  This Cellranger-specific version generates additional
information specific to 10X runs.

If you look in the `./scripts <https://gitlab.com/guthridge_informatics/scrna-processor/-/tree/master/%7B%7Bcookiecutter.project_slug%7D%7D/scripts>`_
directory, you will find a file named `cellranger_mkfastq.sbatch <https://gitlab.com/guthridge_informatics/scrna-processor/-/blob/master/%7B%7Bcookiecutter.project_slug%7D%7D/scripts/cellranger_mkfastq.sbatch>`_
that serves as an example for running cellranger mkfastq.  You should only need
to change the lines corresponding to '--mail-user=<your-email-address>' and
'export BASE_DIR="<project-root>"'.

Additionally, in the `./metadata <https://gitlab.com/guthridge_informatics/scrna-processor/-/tree/master/%7B%7Bcookiecutter.project_slug%7D%7D/metadata>`_
there is an `example samplesheet <https://gitlab.com/guthridge_informatics/scrna-processor/-/blob/master/%7B%7Bcookiecutter.project_slug%7D%7D/metadata/mkfastq_samplesheet.csv>`_.
When filling out the samplesheet, make sure to note the 'Sample_Name' and 
'Sample_Project' as you may need to refer back to these when completeing the
'libraries.csv' file below.

Aligning and counting
---------------------
There are two ways for running cellranger count, one in which you supply *all*
parameters as command line arguments and another in which you create a library
file describing the type and location of sequence files that should be processed.
If you have an expression library paired with either an antibody (like CITEseq
or hashing) or CRISPRr library (collectively refered to as "feature libraries"),
you will need to use the second method.

For the first method, you will need:

1. The full path to an appropriate STAR index.  Typically, you can and should use one of the prebuild indices available on 10X Genomics `support website <https://support.10xgenomics.com/single-cell-gene-expression/software/downloads/latest>`_.
However, if you have reason to build your own, instructions on how to do so can be found `here <https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/tutorial_mr>`_

  * I keep a collection of our own reference indices at /Volumes/guth_aci_informatics/references/genomic/.  Additionally, the Clinical Genomics Core has a number of indices at /Volumes/hts_core/Shared

2. The full path to the demultiplexed FASTQ files.

Count can then be run with::

  cellranger count --id <UNIQUE-DIRECTORY-NAME-FOR-OUTPUT> --transcriptome <PATH-TO-REFERNCE-INDEX> --fastqs <PATH-TO-FASTQS-FROM-BCL2FASTQ>

Additionally, you will probably want to supply values to the options `--localcores` and `--localmem`

For the second method, you will need:

1. The full path to the STAR index.

2. A `Feature Reference CSV File <https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/feature-bc-analysis>`_ spreadsheet describing the format of the feature libraries.

3. A `libraries CSV file <https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/feature-bc-analysis>`_ describing the location, name, and type of demultiplexed libries.

Monitoring the pipeline
~~~~~~~~~~~~~~~~~~~~~~~

Cellranger includes a `user interface <https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/advanced/ui>`_
that allows one to monitor the progress of
the run via web browser.  However, walnut has a firewall that prevents
connecting to the necessary ports.  We can get around this by opening an
`ssh tunnel <https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding>`_.

1. Start the cellranger run.  Pass the `--jobmode=slurm` argument and ensure that you are not passing `--disable-ui`.

2. Near the beginning of the run, there will be a line like::

    "ui running at http://node065:45861?auth=Bupdsa02GOu-YVpqhyeYM46gPQArh38bt_VjVWDNMDw"

  Note the node name and port.

3. Run::

    srun --partition=serial --cpus-per-task=1 --mem=8 --nodelist=$NODENAME ifconfig

  where `$NODENAME` is the value noted in step 2.

  In the block labeled `bond0`, there should be a field like `inet addr:10.84.142.135`  Note the IP address.

4. On your local computer, run::

    ssh -L $LOCALPORT:$NODEIP:$CELLRANGERPORT $USERNAME@walnut.rc.lan.omrf.org -N -v -v

  Where `$NODEIP` and `$CELLRANGERPORT` are the values from step 3 and `$LOCALPORT` is
  something between `1000-9999` other than `8080` or `8888`.

5. Use your usual ssh password to log in unless you have an ssh key setup.

6. (Optional) If you are running the ssh tunnel from a Windows Subsystem for Linux, you will need to run ifconfig and find the ip address for the WSL partition

7. Open `http://$LOCALIP:$LOCALPORT?auth=$KEY`, where `$KEY` is the value after the port in step 2.
