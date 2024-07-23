# Node Images

| :zap: When booting from one of these images, all data on the hard disks will be destroyed without confirmation. :zap: |
|-----------------------------------------------------------------------------------------------------------------------|

## Usage of the node images

* Copy image to USB stick or place the image on your network provisioning environment (Redfish, BMC mount, ....)
* Mount the image in the BMC in another way
* Boot from the device
* Installation is performed, system shuts down afterwards
* Unmount the device or remove it and start system again
* After the first boot the system shuts down once more
* System is ready for use, by default DHCP is tried on all available interfaces
* Perform a SSH-login
  * user: `osism` (alternatively use `dragon` after the 2nd deployment run)
  * password: `password`

## Creation of specific images

If the node images created in the release process are not sufficient or variants are required
that need specific parameters (e.g. for the setup of layer 3 underlay nodes), variants of the images can be created.

### The build process

[Jinja2](https://jinja.palletsprojects.com) is used here as a templating mechanism. By adding new templates or
specific logic, operators of osism cloud environments can use their own flavor of node images.

Node images are created using the [`create-image.sh`](./create-image.sh) tool, which uses
templates from the [`templates`](./templates)` folder.

Values used in the templates are obtained from the following sources and in the following hierarchy:

1. from the `vars` section of the respective node image in `.zuul.yaml`.
2. from parameters that are passed via the `--arg <key>=<value>` parameter.
3. via a YAML file that is passed with `--config <filename>`.

Last values are effective / winning.

```bash
usage: create-image.sh [-h] (--show | --build BUILD [BUILD ...] | --env | --clean) [--arg KEY=VALUE [KEY=VALUE ...]]
                       [--config CONFIG] [--template-only] [--layer3-underlay]

options:
  -h, --help            Show this help message and exit
  --show, -s            Show possible images
  --build BUILD [BUILD ...], -b BUILD [BUILD ...]
                        Build images
  --env, -e             Create build environment
  --clean, -r           Drop cached build data
  --arg KEY=VALUE [KEY=VALUE ...], -a KEY=VALUE [KEY=VALUE ...]
                        Extra values, see template
  --config CONFIG, -c CONFIG
                        A config as yaml file
  --template-only, -t   Do only templating
  --layer3-underlay, -l
                        Use layer 3 underlay
```

### Build an image with adapted/new values

In order to just test the templating and show the effective values
(templated files are created in the [`./build`](./build) folder):

```bash
$ ./create-image.sh --build node-image-build-osism-1 --layer3-underlay --template
Created context (yaml):
---
asn_node_base: '42100210'
description: Two mirrored NVME disks with a enhanced set of predefined logical volumes
  (/dev/nvme3n1 and /dev/nvme4n1)
interface1_asn: '65405'
interface1_name: enp2s0f0np0
interface2_asn: '65404'
interface2_name: enp2s0f1np1
ipv4_base: 10.10.21.
ipv6_base: 'fd0c:cc24:75a0:1:10:10:21:'
layer3_underlay: 'true'
variant: osism-1
....
```

Build the image:
````bash
$ ./create-image.sh \
    --build node-image-build-osism-1 \
    --layer3-underlay \
    --config Supermicro_A2SDV-8C-LN8F.yml \
    --arg "ipv6_base=fd0c:cc24:75a0:1:10:10:21:"
````

## Published images

### Generic Node Images

#### Variant 1

[Standard Image](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-1.iso) - 
  [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-1.iso.CHECKSUM)

![Disk layout](assets/disklayout-1.drawio.png "Disk layout")

#### Variant 2

* [Standard Image](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-2.iso) - 
  [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-2.iso.CHECKSUM)
* Regio Cloud Images<BR>
  used for the REGIO.cloud environment, variants of the used devices.
  * [OSISM 1](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-1.iso) -
    [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-1.iso.CHECKSUM)<BR>
    Like `Variant 2`, with `/dev/nvme3n1` and `/dev/nvme4n1`<BR>
  * [OSISM 2](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-2.iso) - 
    [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-2.iso.CHECKSUM)<BR>
    Like `Variant 2`, with `/dev/nvme4n1` and `/dev/nvme5n1`<BR>
  * [OSISM 3](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-3.iso) - 
    [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-3.iso.CHECKSUM)<BR>
    Like `Variant 2`, with `/dev/nvme2n1` and `/dev/nvme3n1`<BR>
  * [OSISM 4](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-4.iso) - 
    [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-osism-4.iso.CHECKSUM)<BR>
    Like `Variant 2`, with `/dev/nvme0n1` and `/dev/nvme1n1`<BR>

![Disk layout](assets/disklayout-2.drawio.png "Disk layout")

#### Variant 3

[Standard Image](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-3.iso) - 
  [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-3.iso.CHECKSUM)

![Disk layout](assets/disklayout-3.drawio.png "Disk layout")

#### Variant 4

[Standard Images](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-4.iso) - 
  [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-4.iso.CHECKSUM)

![Disk layout](assets/disklayout-4.drawio.png "Disk layout")

## Cloud-in-a-box images

The [cloud in a box](https://osism.tech/docs/guides/other-guides/cloud-in-a-box) documentation provides more details about this.

### Variant 1 - SCSI images

* [Sandbox Image](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-1.iso) - 
  [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-1.iso.CHECKSUM)
* [Kubernetes Image](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-kubernetes-1.iso) - 
  [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-kubernetes-1.iso.CHECKSUM)<BR>
  Like Sandbox `Variant 1`, with `CLOUD_IN_A_BOX_TYPE=kubernetes` boot parameter.
* [Ironic Image](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-ironic-1.iso) - 
  [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-ironic-1.iso.CHECKSUM)<BR>
  Like Sandbox `Variant 1`, with `CLOUD_IN_A_BOX_TYPE=ironic` boot parameter.

![Disk layout](assets/disklayout-cloud-in-a-box-1.drawio.png "Disk layout")

### Variant 2 - NVMe images

 * [Sandbox Image](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-2.iso) - 
   [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-2.iso.CHECKSUM)
 * [Edge Image](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-edge-2.iso) - 
   [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-edge-2.iso.CHECKSUM)<BR>
   Like Sandbox `Variant 2`, with `CLOUD_IN_A_BOX_TYPE=edge` boot parameter.
 * [Kubernetes Image](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-kubernetes-2.iso) - 
   [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-kubernetes-2.iso.CHECKSUM)<BR>
   Like Sandbox `Variant 2`, with `CLOUD_IN_A_BOX_TYPE=kubernetes` boot parameter.
 * [Ironic Image](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-ironic-2.iso) - 
   [[SHA256]](https://swift.services.a.regiocloud.tech/swift/v1/AUTH_b182637428444b9aa302bb8d5a5a418c/osism-node-image/ubuntu-autoinstall-cloud-in-a-box-ironic-2.iso.CHECKSUM)<BR>
   Like Sandbox `Variant 2`, with `CLOUD_IN_A_BOX_TYPE=ironic` boot parameter.

![Disk layout](assets/disklayout-cloud-in-a-box-2.drawio.png "Disk layout")

## Frequently asked Questions / Known Issues

### Download and verify images

```bash
osism_image(){
  local url="${1?image url}"
  wget -c "${url}" && \
  wget -c "${url}.CHECKSUM" && \
  sha256sum -c "$(basename ${url})" < "${url}"
}

osism_image <image url>
```

### Efficent adapting, developing and testing

In order for images to be adapted or further developed, they must be tested or checked on the respective hardware.
It has proven to be advantageous to develop these on a system close to the installation hardware
and then mount the images via the SMB protocol in the DVD emulation of the BMC.

To shorten roundtrip times, you can publish created images a Samba server on your workstation as follows:
```
contrib/samba-local/samba_quick.sh
```
After initial installation of the image (system is in shutdown), you can just stop this samba instance by hitting `CTRL+c`
to ensure that the next boot is performed from the local disk.

This saves you having to create a USB stick, go to the system and often also manually select the boot device.

### Disk initialization fails

Disk initialization may fail if the devices have been in use before.
In particular having a MSDOS-type partition table will cause the
installation to break. In this case boot some Ubuntu live image and
erase all data from your disks.

In that case it is a good idea to erase the disk:
```bash
dd if=/dev/zero of=/dev/<device> bs=1M count=1024
```
(you can use that from the shell prompt available from the installation image or with a live systems)

## References

* https://curtin.readthedocs.io/en/latest/topics/storage.html
* https://github.com/cloudymax/pxeless
* https://jimangel.io/posts/automate-ubuntu-22-04-lts-bare-metal/
* https://ubuntu.com/server/docs/install/autoinstall-reference
