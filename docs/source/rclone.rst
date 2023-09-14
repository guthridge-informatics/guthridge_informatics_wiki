Using Rclone
============

Rclone is program for retrieving and uploading data from a variety of services, including 
object (``o3://``) 
and bucket storage. 
To access the object storage files, first install
`rclone <https://rclone.org/downloads/>`__.

If you are running this from Walnut, instead load the module:

::

   module load rclone

and make sure that you run rclone as an interactive job with something
like

::

   srun --partition interactive --mem=16G --cpus-per-task=4 --pty rclone ...

Using without a config file
---------------------------

If you will be accessing the object storage often, I would suggest
creating a config file.

If you will be using this only very infrequently, you can access any of
the object storage “tenants” with the following, replacing the bracketed
variables with their respective values:

.. code-block:: bash

   rclone \
     --swift-tenant "{{TENANT}}" \
     --swift-auth "https://o3.omrf.org/auth/v2.0" \
     --swift-user "{{OMRF_USER_NAME}}" \
     --swift-key "{{OMRF_PASSWORD}}" \
     {{COMMAND}} \
     :swift:

Note that the ``:swift:`` in this case is both the name of the remote
and the remote type. To reference files and folders in this tenant,
place their name directly after the colon,
i.e. ``:swift:PrecisionMed/analysis/rnaseq/blast``

For the possible commands, see `the
website <https://rclone.org/commands/>`__, but likely you will use one
of the following: 

- ``lsf`` - list files
- ``lsd`` - list directories
- ``copy`` - copy from ``SOURCE`` to ``DESTINATION``. This will overwrite files in ``DESTINATION`` *if* there is a 
  newer version in ``SOURCE``
- ``move`` - same 
- ``delete`` - **WARNING** Do *NOT* use this unless you are absolutely sure. You *cannot* recover the files.
- ``sync`` - synchronize the contents in ``DESTINATION`` with those in ``SOURCE``. Unlike copy, this will overwrite any existing files in ``DESTINATION`` *and delete any that are not present* in ``SOURCE``

Tenants on OMRF Object Storage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The James/Guthridge labs tenants of which I am aware (as of 2023-07-26)

* LDAP_o3-guthridge-james - this is where a majority of all data is located
* LDAP_ss-prj-guthridge-scrnaseq - Any single cell transcriptomics/genomics data is stored here 
* LDAP_ss_prj_gaffney_guthridge_bold
* LDAP_ss-prj-james-ordc

.. important::
  NOTE that rclone is a little odd in that it will copy all of the
  contents of a directory, *but not the directory itself*! This means
  that if you run the command

  .. code-block:: bash

     rclone copy -P source:home/pictures/ destination:home/

  all of the files in the source picures subdirectory would be copied
  into home itself. You need to include the destination directory as
  well:

  .. code-block:: bash
    rclone copy -P source:home/pictures/ destination:home/pictures

Creating a config file
----------------------

If you are going to be using rclone much, it is worthwhile to create a
config file. You can either run the command ``rclone config`` and answer
the prompts (most of which can be left at their default values), or you
can directly create the file with whatever text editor you choose
(though, the config file must be saved as a plain text
`TOML <https://toml.io/en/>`__ file.

rclone.conf should be placed in: \* Windows 10/11:
``c:\users\USERNAME\.config\rclone\rclone.conf`` \* Linux variants:
``/home/USERNAME/.config/rclone/rclone.conf`` \* MacOS:
``/Users/USERNAME/.rclone.conf``

An example of a config file would be:

::

   [{{TENANT_NICKNAME}}]
   type = swift
   env_auth = false
   user = {{OMRF_USERNAME}}
   key = {{OMRF_PASSWORD}}
   auth = https://o3.omrf.org/auth/v2.0
   tenant = {{TENANT_NAME}}
   endpoint_type = public

   [amazon]
   type = s3
   provider = AWS
   env_auth = true
   region = us-east-1

   [gcloud]
   type = google cloud storage
   project_number = {{GCLOUD_PROJECT}}
   service_account_file = {{GCLOUD_STORAGE_KEY}}
   location = {{GCLOUD_STORAGE_REGION}}
   object_acl = bucketOwnerFullControl
   bucket_acl = authenticatedRead
   bucket_policy_only = true

Where TENANT_NICKNAME can be anything, but whatever it is set to is the
remote name you would use in the commands above. For example,

::

   rclone copy -P TENANT_NICKNAME:home/pictures OTHER_DEST_NICKNAME:home/pictures

The same is true for ``amazon`` and ``gcloud`` above. To retreive the
storage key for google, see
`here <https://cloud.google.com/storage/docs/authentication>`__;
currently, there is one placed in
``/Volumes/guth_aci_informatics/software/guthridge-nih-strides-projects-storage-key.json``
on Walnut.

Useful Parameters
-----------------

There are several command arguments that can be very useful.

-  ``-P``: print live progress
-  ``--include="PATTERN"``: this will restrict copying/moving/deleting
   to a subset of files that match the glob pattern. Include the pattern
   inside of quotes. For example, to only copy bam files:
   ``rclone copy -P source:directory/ dest:directory --include="*.bam"``
   Look up “glob pattern” for more info.
-  ``--exclude="PATTERN"``: copy/move/delete everything EXCEPT files
   that match the pattern.
