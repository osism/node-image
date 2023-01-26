# node-image

| :zap: When booting from this image, all data on the hard disks will be destroyed without confirmation. |
|--------------------------------------------------------------------------------------------------------|

## Download

* https://minio.services.osism.tech/node-image/ubuntu-autoinstall-1.iso
* https://minio.services.osism.tech/node-image/ubuntu-autoinstall-2.iso
* https://minio.services.osism.tech/node-image/ubuntu-autoinstall-3.iso

### Cloud-in-a-box images

* https://minio.services.osism.tech/node-image/ubuntu-autoinstall-cloud-in-a-box-1.iso
* https://minio.services.osism.tech/node-image/ubuntu-autoinstall-cloud-in-a-box-2.iso

### Other

* https://minio.services.osism.tech/node-image/ubuntu-autoinstall-osism-1.iso
* https://minio.services.osism.tech/node-image/ubuntu-autoinstall-osism-2.iso

## Usage

* Copy image to USB stick
* Boot from USB stick
* Installation is performed, system shuts down afterwards
* Remove USB stick and start system
* After the first boot the system shuts down again
* System is ready for use, by default DHCP is tried on all available
  devices (login via ``osism`` and ``password``)

## Variants

### Variant 1

![Disk layout](/assets/disklayout-1.drawio.png "Disk layout")

### Variant 2

![Disk layout](/assets/disklayout-2.drawio.png "Disk layout")

### Variant 3

![Disk layout](/assets/disklayout-3.drawio.png "Disk layout")

## Cloud-in-a-box variants

### Variant 1

![Disk layout](/assets/disklayout-cloud-in-a-box-1.drawio.png "Disk layout")

### Variant 2

![Disk layout](/assets/disklayout-cloud-in-a-box-2.drawio.png "Disk layout")

## Other variants

### OSISM 1

Like ``Variant 2``, with ``/dev/nvme3n1`` and ``/dev/nvme4n1``

## Known issues

- Disk initialization may fail if the devices have been in use before.
  In particular having a MSDOS-type partition table will cause the
  installation to break. In this case boot some Ubuntu live image and
  erase all data from your disks.

## References

* https://curtin.readthedocs.io/en/latest/topics/storage.html
* https://github.com/cloudymax/pxeless
* https://jimangel.io/posts/automate-ubuntu-22-04-lts-bare-metal/
* https://ubuntu.com/server/docs/install/autoinstall-reference
