# manager-installer

Create iso image for automatic server installation using *autoinstall*.

A ready-to-use image can be [downloaded from our file server](https://minio.services.osism.tech/manager-installer/osism-manager-installer.iso).

The login it possible with the user ``install`` and the password ``install``.

The automated creation of the ISO image in this repository is documented in the
[OSISM documentation](https://docs.osism.tech/deployment/provisioning.html#preseed-installation).

## Custom user-data

Clone this repository and copy your user-data file into it.

```shell
git clone https://github.com/osism/manager-installer.git
cd manager-installer
cp /path/to/your/user-data ./
```

## ``cloud-init`` syntax check

```shell
cloud-init devel shema --config-file ./user-data
```

## Create ISO image

```shell
make create-image BIOS_ROM=/usr/share/OVMF/OVMF_CODE.fd
```

### Boot the image for testing purposes via kvm

Boot the *autoinstall* iso image that has been created with `make create-image`:

```shell
make boot-prep
```

## Testing the configuration

### Run http server to serve meta-data for *autoinstall*

```shell
make http
```

### Run installation

```shell
make install
```

### Boot the system configured by *autoinstall*

```shell
make boot
```

## Notes

The ``ubuntu-autoinstall-generator.sh`` script is from
[covertsh/ubuntu-autoinstall-generator](https://github.com/covertsh/ubuntu-autoinstall-generator)
and is licensed under the MIT License.
