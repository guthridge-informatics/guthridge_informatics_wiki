.. _Processing 10X Genomics scRNA-seq Runs:

Processing 10X Genomics scRNA-seq Runs
======================================

Processing the data entails the following steps:

* Demultiplexing with ``bcl-convert``
* Aligning sequences and producing count matrices using ``cellranger count`` or ``cellranger multi``
* Analyzing the data using the R package ``{seurat}`` or the Python module ``scanpy``
  
  .. note::
    These are not the only two packages available for analysis and you may need to find others to handle tasks such as 
    RNA velocity or trajectory analysis

.. Setting up
.. ----------
.. First, use `Cookiecutter <https://cookiecutter.readthedocs.io/en/latest/>`_ to
.. setup the directories for the project.  Cookiecutter itself can be installed
.. on the commandline with::

..     pip install cookiecutter

.. Change directory to where you would like to place the project and run the
.. following command::

..     cookiecutter gl:guthridge_informatics/scrna-processor

.. This will ask a couple of questions to setup a few configuration variables and
.. leave a folder with the following structure:

.. .. code-block:: bash

..     .
..     ├── AUTHORS.md
..     ├── LICENSE
..     ├── README.md
..     ├── code                <- Analysis code required for this project
..     ├── config              <- Configuration files, e.g., for doxygen or for your model if needed
..     ├── data
..     │   ├── bcls            <- Raw data from sequencers.
..     │   ├── fastqs          <- Intermediate data prior to alignment and counting.
..     │   ├── processed       <- Count matrices and molecule information files. Cell Ranger output.
..     │   └── r_data          <- Data object files created by the Drake analysis.
..     ├── metadata            <- Information about the sample sources
..     ├── reports             <- Report prepared by Drake
..     └── scripts             <- Script code created to process sample data from raw to count matrices


Demultiplexing (BCL -> FASTQ)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. tip::
  For additional information on demultiplexing, see the :ref:`Demultiplexing` section in :ref:`Processing Novaseq Runs`.

The reads from the Clinical Genomics Core are delivered in one of two *raw* formats: BCL or FASTQs. The files will 
likely be delivered in a cryptically named folder (the name is derived from some combination of the run date and 
flowcell id) located on the :ref:`scratch <scratch>` drive. If the data is in bcl format, it will need to be converted
to FASTQ before mapping and counting by CellRanger.

.. warning::
  Before doing anything else, rename the folder to something meaningful and make a backup by uploading it to 
  :ref:`object storage <Local computing object storage>`. This should be somehwere on ``LDAP_ss-prj-guthridge-scrnaseq``
  under ``${PROJECT}/data/raw/bcls``

Sample Sheet
^^^^^^^^^^^^

Start by preparing the sample sheet. Likely, you have already prepared
this for submitting samples to sequencing. The samplesheet should be in
comma delimited format (i.e. .csv) and it its most basic form, should
have three sections - Header, Reads, and Data - like so:

::

   [Header],,,,
   EMFileVersion,4,,,
   ,,,,
   [Reads],,,,
   26,,,,
   90,,,,
   ,,,,
   [Data],,,,
   Sample_ID,Sample_Name,index,index2,Sample_Project

Additionally, if the sequencing run was divided into two or more lanes,
a “lane” column can be added to the [Data] section.

.. note::
   If editing using a text editor, you need to ensure that all
   lines have the same number of columns (i.e. has the same number of
   commas)

The information in the sample sheet is used to separate reads belonging
to each sample and to name the resulting FASTQs:

* Sample_ID: this will be prepended to the name of the resulting files matching the two indices below 
* Sample_Name: not used 
* index: the i7 index sequence
* index2: the i5 index sequence
  
  * If this data was generated using a Novaseq 6000 or Novaseq X, use sequence in the ``index2_workflow_b(i5)`` column,
    otherwise, use the sequence in the ``index2_workflow_a(i5)`` column
* Sample_Project: this will be used to group output files into folders
  
  .. note::
    If the flowcell was divided into lanes, another column titled ``lane`` can be added to indicate the lane in which
    the library was run.

bcl-convert
^^^^^^^^^^^

Illumina makes it difficult to install bcl-convert, so it is necessary to run it from within a container using 
either Singularity or `Apptainer <https://apptainer.org/>`_. At current (2023-09-11), there is a Singularity container 
with bcl-convert version 4.1.7 in ``/Volumes/guth_aci_informatics/software``.
To run bcl-convert:

::

   apptainer run \
       --bind /s/guth-aci/var:/var \
       --bind /s/guth-aci:/s/guth-aci \
       /Volumes/guth_aci_informatics/software/bclconvert-4.1.7.sif \
       bcl-convert \
           --output-directory /s/guth-aci/${PROJECT}/data/fastqs/${RUN_NAME} \
           --bcl-input-directory /s/guth-aci/${PROJECT}/data/bcls/${RUN_NAME} \
           --sample-sheet /s/guth-aci/${PROJECT}/metadata/${RUN_NAME}/samplesheet.csv \
           --force \
           --no-lane-splitting true \
           --bcl-sampleproject-subdirectories true

substituting any ``${VARIABLE}`` with the appropriate values.

The first two lines that start with ``--bind`` map a directory outside to a location inside the container. You will 
need to adjust the ``--output-directory``, ``--bcl-input-directory``, and ``--sample-sheet`` arguments to match the
desired destination for the fastqs, the location of the bcls, and location of the sample sheet,
respectively. If your data was split by lane, set ``--no-lane-splitting`` to ``false``.

  .. warning::
    ``bcl-convert`` needs to run as a :ref:`slurm batch job<_Batch jobs>` if it is run on :ref:`walnut <_Local Cluster>`.
    So, for example add the above in a ``sbatch`` file so that you have:

    .. literalinclude:: example_10x_demux_job.sbatch
      :language: bash

    Save it to your projects scripts folder, and run using::

      sbatch demux_job.sbatch
    
    Where ``demux_job.sbatch`` is the name you gave the batch file.

  .. warning::
    Make sure that the ``/s/guth-aci/var`` directory exists.


Cellranger mkfastq
^^^^^^^^^^^^^^^^^^
In addition to `bcl-convert`, there is a subcommand of `cellranger` named
`mkfastq <https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/mkfastq>`_ that 
is capable of demultiplexing 10x data. `cellranger mkfastq` is essentially a wrapper around the older `bcl2fastq`
program but lets you use a simplified samplesheet that is *suppose* to allow for the use of just the index plate
sample well names instead of the index sequence; in my experience, however, it is no easier to use than `bcl-convert` but is
instead slower, less capable if you need to use any of the advanced options (such as masking reads or allowing for
short index sequences), and more difficult to troubleshoot.


Aligning and counting
---------------------

To use ``cellranger multi``, you will need:

1. The full path to the STAR index.

2. A `Feature Reference CSV File <https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/feature-bc-analysis>`_ spreadsheet describing the format of the feature libraries.

3. A `libraries CSV file <https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/feature-bc-analysis>`_ describing the location, name, and type of demultiplexed libries.

Monitoring the pipeline
~~~~~~~~~~~~~~~~~~~~~~~

Cellranger includes a `user interface <https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/advanced/ui>`_
that allows one to monitor the progress of the run via web browser.  However, walnut has a firewall that prevents
connecting to the necessary ports.  We can get around this by opening an 
`ssh tunnel <https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding>`_.

1. Start the cellranger run.  Pass the ``--jobmode=slurm`` argument and ensure that you are not passing ``--disable-ui``.

2. Near the beginning of the run, there will be a line like

  .. code:: bash
    "ui running at http://node065:45861?auth=Bupdsa02GOu-YVpqhyeYM46gPQArh38bt_VjVWDNMDw"

  Note the node name and port.

3. Run
  
  .. code:: bash
    srun --partition=serial --cpus-per-task=1 --mem=8 --nodelist=${NODENAME} ifconfig

  where ``${NODENAME}`` is the value noted in step 2.

  In the block labeled ``bond0``, there should be a field like ``inet addr:10.84.142.135``.
  Note the IP address.

4. On your local computer, run

  .. code:: bash
    ssh -L ${LOCALPORT}:${NODEIP}:${CELLRANGERPORT} ${USERNAME}@walnut.rc.lan.omrf.org -N -v -v

  Where ``NODEIP`` and ``CELLRANGERPORT`` are the values from step 3 and ``LOCALPORT`` is
  something between ``1000-9999`` other than ``8080`` or ``8888``.

5. Use your usual ssh password to log in unless you have an ssh key setup.

6. (Optional) If you are running the ssh tunnel from a Windows Subsystem for Linux, you will need to run ifconfig and find the ip address for the WSL partition

7. Open ``http://${LOCALIP}:${LOCALPORT}?auth=${KEY}``, where ``KEY`` is the value after the port in step 2.
