Rclone
======

Rclone is a program for retrieving and uploading data from a variety of services. It is most useful 
for interacting with object (``o3://``) and amazon or google bucket (``s3://`` or ``gs://``) 
storage. It is, however, capable of downloading/uploading from a wide variety of sources, including
``http``, ``ftp``, ``dropbox``.

Setup
-----

Installation
............

Rclone can be installed

* from `the rclone website <https://rclone.org/downloads/>`__.
* using the `conda <https://docs.conda.io/en/latest/>`__ or `mamba <https://mamba.readthedocs.io/en/latest/index.html>`__ package managers
* using `apt <https://ubuntu.com/server/docs/package-management>`__, `brew <https://brew.sh/>`__, `dnf <https://rpm-software-management.github.io/>`__, or whatever software manager comes with your operating system

If you are looking to run rclone on Walnut, instead load the module using:

.. code-block:: bash

   module load rclone

Configuration
.............
If you are going to be using rclone much, it is worthwhile to create a config file.  You can either run the command
``rclone config`` and answer the prompts (most of which can be left at their default values), or you can directly
create the file with whatever text editor you choose (though, the config file must be saved as a plain 
text `TOML <https://toml.io/en/>`__ file. However, if you will just be accessing our Google bucket and OMRF object
storage, a configuration file with the appropriate values can be found at
``/Volumes/guth_aci_informatics/software/rclone.conf``.

The ``rclone.conf`` file should be placed in:

* Windows 10/11: ``%homepath%\.config\rclone\rclone.conf``
* Linux variants: ``$HOME/.config/rclone/rclone.conf``
* MacOS: ``$HOME/.rclone.conf``

If you wish to directly create the config file, it should look like:

.. code-block:: TOML
   :linenos:
   :caption: example rclone.conf
   :emphasize-lines: 1,4-5,7

   [{{NICKNAME}}]
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


The value for ``NICKNAME`` does not need to match anything in particular, it is just a name that *you*
assign to that source and use whenever accessing it in the commands. For example, 

.. code-block:: bash
   :caption: example rclone command

   rclone copy -P NICKNAME:home/pictures OTHER_DEST_NICKNAME:home/pictures

The same is true for ``amazon`` and ``gcloud`` above.

Object storage
~~~~~~~~~~~~~~

See the :ref:`Object storage <Local computing object storage>` section in the
 :ref:`Local computing resources <local_cluster>` page for more information.

Google cloud
~~~~~~~~~~~~

To setup Google cloud storage, you will need a few pieces of information.  Namely:

* project_id: At the moment, we just make use of one project, Guthridge-NIH-STRIDES-Projects
  This is also often used in its lowercase form, mostly in commandline instances such as in the Rclone config.
* `storage access key <https://cloud.google.com/storage/docs/authentication>`__: Follow the link for instructions
  on how to retreive a storage access key. Currently, there is one placed in 
  ``/Volumes/guth_aci_informatics/software/guthridge-nih-strides-projects-storage-key.json`` on Walnut
  (or ``\\qlotsam\guth_aci_informaticssoftware/guthridge-nih-strides-projects-storage-key.json`` in Windows)
* bucket region: see the documentation for `Regions and zone <https://cloud.google.com/compute/docs/regions-zones>`__.
  All of our resources should be located in ``us-central1`` (i.e. located in Iowa)


Using without a config file
...........................

If you will be using a particular source only very infrequently, you can access any of
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

Simlarly, one can use rclone to access an http source without configuration instead of using 
something like :ref:`curl or wget <curl_wget>`. For example:

.. code-block:: bash

   rclone copy -P --http-url https://stuff.online/files :http: ./

will download ``files`` to the present directory.


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

.. important::
  NOTE that rclone is a little odd in that it will copy all of the
  contents of a directory, *but not the directory itself*! This means
  that if you run the command

  .. code-block:: bash

   rclone copy -P source:home/pictures/ destination:home/

  all of the files in the source ``picures`` subdirectory would be copied
  into ``home`` itself. You need to include the destination directory as
  well:

  .. code-block:: bash
   
   rclone copy -P source:home/pictures/ destination:home/pictures

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
