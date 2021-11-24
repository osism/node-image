# manager-installer

Create iso image for automatic server installation using *autoinstall*.

## Image Download

* manager: https://minio.services.osism.tech/manager-installer/osism-manager-installer.iso

## Documentation

The automated creation of the ISO image in this repository is documented in
<https://docs.osism.tech/deployment/provisioning.html#preseed-installation>.

### Create *autoinstall* iso image

```shell
make create-image BIOS_ROM=/usr/share/OVMF/OVMF_CODE.fd
```

### Boot the image for testing purposes via kvm

Boot the *autoinstall* iso image that has been created with `make create-image`:

```shell
make boot-prep
```

### Testing the *autoinstall* configuration

#### Run http server to serve meta-data for *autoinstall*

```shell
make http
```

#### Run installation

```shell
make install
```

#### Boot the system configured by *autoinstall*

```shell
make boot
```
