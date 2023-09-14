.. _Cloud:

Cloud computing resources
=========================

Google Cloud Platform offers a provides virtual machines, pipelines, and
storage, among others, that overlaps somewhat with the local OMRF cluster but
allows us to customize and scale to our own needs.

Virtual machines
----------------

The Google Cloud Compute provides the ability to run virtual machines, which can function nearly the same as a desktop workstation.
Unlike a local workstation, however, the VMs can be reconfigured to provide more than 1 TB of RAM and > 100 CPUs.

To improve reproducability and promote agility, the VMs use Docker_ images.
The current set of images are found at in the `control docker <https://gitlab.com/guthridge_informatics/control>`
repository on Gitlab.



