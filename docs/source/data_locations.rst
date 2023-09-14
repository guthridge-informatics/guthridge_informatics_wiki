.. _local data:

Local data sources
==================

.. _cluster data:

Cluster
-------
Data specific to our lab should be located in one of those places: 
the group folder at `/Volumes/guth_aci_informatics` or in the scratch drive at
`/s/guth-aci`.  See the :ref:`folders section <Data storage>` of the 
:ref:`Local computing resources <Local Cluster>` page for more information about
cluster data storage and access.

.. warning::
    Do not use the scratch drive for long term storage - it is *not* backed 
    up **AND** files not used for 30 days are purged.

.. _adi data:

ADI
---
All files belonging to you and analyses should be kept in the appropriate
subdirectories of ADI - unlike the local storage on the desktops, ADI is 
frequently backed up.

Each group has their own directory, with subdirectories for personel, prior
personel, and projects.  Within the directory of the group in which you are
working (i.e. Phenotyping Core, Informatics, Lab, etc...), you should have a
personal folder.  As for project and instrument data... that can differ widely
and be located seemingly somewhat random.  Most often, there should be a
"[group]_Data" folder with subdirectories in the form of "01_Active_Projects",
"02_Completed_Projects", etc...

.. _o3:

o3
--

Larger files, such as raw sequencing data, will most likely be located in
:ref:`object storage <Object Storage>`.  Because object storage is explictly
designed for archival storage, completed analyses may be placed here as well.

.. _cloud data:

Online data sources
===================

.. _google buckets:

Google cloud
------------

To bolster local desktop computing resources, we make use of Google Cloud
Platform (GCP), which enables us to spin up virtual machines that can satisfy the
enormous amounts of RAM required to work with some of our datasets.

GCP has its own form of object storage termed "buckets".  These buckets serve as
intermediaries for transferring data between local storage and GCP, as archival
storage of data on GCP, and as a backup of local object storage.  There several
classes of buckets, which determines the price for storage and retrieval of data.
Unless otherwise necessary, keep to the Standard and Multi-regional class
buckets.

.. warning::
    Unless you need to and really know what you are doing, **do not** mess
    around with data in Coldline or Archive buckets.  Storage in these classes
    is cheap, but accessing, deleting, moving, renaming, etc... can quickly
    become *very* expensive.

The currently (as of 2020-05-22) existing buckets are:

* artifacts.scrna-196615.appspot.com: stores Docker containers either built with `Google Cloud Build <https://console.cloud.google.com/cloud-build/builds?project=scrna-196615>`_ or uploaded to the `Container Registry <https://console.cloud.google.com/gcr/images/scrna-196615?project=scrna-196615>`_
* botany_bay: Coldline storage of processed data
* genomic_references: Archive of references used in processing data (e.g. FASTA/GTF files used to build alignment references)
* memory-beta: Main working bucket.  Data that needs to be accessed and updated frequently is and should be stored here.
* rura-penthe: Archive storage of raw data.  Things like FASTQ or BCL files that are enormous but do not need to be accessed but once or twice a year, if that.
* scrna-196615_cloudbuild: stores Docker build cache

The buckets can be accessed one of three ways:

* :ref:`rclone <rclone_local_cluster>` - preferred.  As fast or faster than gsutil and using it means learning only one tool.

* Google's tool, gsutil - Unlike `rclone`, this may actually be preinstalled on your VM (unless you are working on a deployed container).  However, this may still have a bug where deleting a `boto.cfg` in `/etc` is required for it to work.  Also, the Python 2 version of gsutil required one to do some work to enable multipart file transfers.

   * One advantage of gsutil is that its usage syntax will be familiar if you know basic Unix commands.  Practically, the `gsutil` command works as a prefix placed in front of the common `cp`, `mv`, `rm`, etc... and addressing bucket storage works like a network address (i.e. `gs://memory-beta/analysis`)

* Google's web interface - good for visually exploring the bucket structure; not so great for moving or transferring multiple files at once


Extant datasets
===============
