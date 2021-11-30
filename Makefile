RAM = 1024
DISK_SIZE = 200G
BIOS_ROM = /usr/share/qemu/ovmf-x86_64-code.bin
ISO_BASE_URL = https://cdimage.ubuntu.com/ubuntu-server/focal/daily-live/current
ISO_BASE_IMAGE = focal-live-server-amd64.iso
ISO_PREP_IMAGE = osism-manager-installer.iso
KVM_COMMAND = qemu-kvm

PYTHON = python3
HTTP_PORT = 8050
DATA_SOURCE_URL = http://_gateway:8050/

USER_DATA = user-data
ISO_BASE_TMP_DIR = base_image

.PHONY: help clean install boot boot-prep http create-image

.DEFAULT_GOAL := help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

$(ISO_BASE_IMAGE): ## Download base iso image
	curl -LO $(ISO_BASE_URL)/$(ISO_BASE_IMAGE)

$(ISO_BASE_TMP_DIR): $(ISO_BASE_IMAGE)
	7z -y x $(ISO_BASE_IMAGE) -o$(ISO_BASE_TMP_DIR) >/dev/null

disk0.raw: ## create disk0 image
	truncate -s $(DISK_SIZE) $@

clean: ## remove iso and disk images
	rm -rf disk0.raw $(ISO_BASE_TMP_DIR)

http: ## run http server for meta-data service
	$(PYTHON) -m http.server $(HTTP_PORT)

install: $(ISO_BASE_TMP_DIR) disk0.raw ## install server via autoinstall
	$(KVM_COMMAND) -no-reboot -m $(RAM) \
	  -bios $(BIOS_ROM) \
	  -cdrom $(ISO_BASE_IMAGE) \
	  -drive file=disk0.raw,format=raw,cache=none,if=none,id=d0 \
	  -device virtio-scsi-pci,id=scsi \
	  -device scsi-hd,drive=d0,serial=01 \
	  -kernel $(ISO_BASE_TMP_DIR)/casper/vmlinuz \
	  -initrd $(ISO_BASE_TMP_DIR)/casper/initrd \
	  -append 'autoinstall ds=nocloud-net;s=$(DATA_SOURCE_URL)'

boot: disk0.raw ## boot the installed server
	$(KVM_COMMAND) -no-reboot -m $(RAM) \
	  -bios $(BIOS_ROM) \
	  -drive file=disk0.raw,format=raw,cache=none,if=none,id=d0 \
	  -device virtio-scsi-pci,id=scsi \
	  -device scsi-hd,drive=d0,serial=01

boot-prep: $(ISO_PREP_IMAGE) disk0.raw ## boot from prepared iso image
	$(KVM_COMMAND) -no-reboot -m $(RAM) \
	  -bios $(BIOS_ROM) \
	  -cdrom $(ISO_PREP_IMAGE) \
	  -drive file=disk0.raw,format=raw,cache=none,if=none,id=d0 \
	  -device virtio-scsi-pci,id=scsi \
	  -device scsi-hd,drive=d0,serial=01 \
	  -device nvme,drive=n0,serial=03

create-image: ## create prepared iso image
	bash ubuntu-autoinstall-generator.sh \
	  --no-verify \
	  --all-in-one \
	  --user-data $(USER_DATA) \
	  --destination $(ISO_PREP_IMAGE)
