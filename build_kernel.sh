apt-get update
apt-get install -y libacl1-dev libaio-dev libattr1-dev libcap-ng-dev libcurl4-gnutls-dev libepoxy-dev libfdt-dev libgbm-dev libgnutls28-dev libiscsi-dev libjpeg-dev libnuma-dev libpci-dev libpixman-1-dev libproxmox-backup-qemu0-dev librbd-dev libsdl1.2-dev libseccomp-dev libslirp-dev libspice-protocol-dev libspice-server-dev libsystemd-dev liburing-dev libusb-1.0-0-dev libusbredirparser-dev libvirglrenderer-dev meson python3-sphinx python3-sphinx-rtd-theme quilt xfslibs-dev
apt install -y dh-python asciidoc-base bison dwarves flex libdw-dev libelf-dev libiberty-dev libslang2-dev lz4 python3-dev xmlto rsync gawk rust-src rustfmt rust-clippy bindgen
ls
df -h
git clone git://git.proxmox.com/git/pve-kernel.git
cd pve-kernel
git reset --hard 3ed8dd29ffd238c80b6d873907c47e55a4df0d10 # bump version to 7.0.6-2-pve
apt install devscripts -y
mk-build-deps --install
git submodule update --init --recursive --force
cd submodules/zfsonlinux/
mk-build-deps --install
make
