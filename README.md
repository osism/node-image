# node-image

| :zap: When booting from this image, all data on the hard disks will be destroyed without confirmation. |
|--------------------------------------------------------------------------------------------------------|

## Download

* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-1.iso
* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-1.iso.CHECKSUM

* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-2.iso
* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-2.iso.CHECKSUM

* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-3.iso
* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-3.iso.CHECKSUM

### Cloud-in-a-box images

* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-1.iso
* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-1.iso.CHECKSUM

* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-2.iso
* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-2.iso.CHECKSUM

### Other

* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-1.iso
* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-1.iso.CHECKSUM

* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-2.iso
* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-2.iso.CHECKSUM

* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-3.iso
* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-3.iso.CHECKSUM

* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-4.iso
* https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-4.iso.CHECKSUM

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

### OSISM 2

Like ``Variant 2``, with ``/dev/nvme4n1`` and ``/dev/nvme5n1``

### OSISM 3

Like ``Variant 2``, with ``/dev/nvme2n1`` and ``/dev/nvme3n1``

### OSISM 4

Like ``Variant 2``, with ``/dev/nvme0n1`` and ``/dev/nvme1n1``

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
