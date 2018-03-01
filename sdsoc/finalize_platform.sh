#!/bin/bash

PLATFORM_NAME=zybo_z7_20
PETALINUX_PROJECT=Zybo-Z7-20
SDX_VERSION=2017.4

PLATFORM_DIR=./${PLATFORM_NAME}/export/${PLATFORM_NAME}
REPO_DIR=..
RELEASE_NAME=reVISION-${PLATFORM_NAME}-${SDX_VERSION}-

## Script is run as root, so "sudo -u $real_user" must be in front of all 
## non-sudo commands.
#ref: https://askubuntu.com/a/30157/8698
if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

# Change to script directory
cd "$(dirname "$0")"

sudo -u $real_user cp -f -v ./README.txt ${PLATFORM_DIR}/../

sudo -u $real_user mkdir -p ${PLATFORM_DIR}/sd_image
sudo -u $real_user mkdir -p ${PLATFORM_DIR}/sw/sysroot
sudo -u $real_user cp -f -v ${REPO_DIR}/linux/${PETALINUX_PROJECT}/images/linux/rootfs.ext4 ${PLATFORM_DIR}/sd_image/
sudo -u $real_user mkdir -p ./mnt
mount -t ext4 -o loop ${PLATFORM_DIR}/sd_image/rootfs.ext4 ./mnt
sudo -u $real_user cp -RLp ./mnt/. ${PLATFORM_DIR}/sw/sysroot >/dev/null 2>/dev/null
umount ./mnt
rm -rf ./mnt

#Create 2GB image file
sudo -u $real_user dd if=/dev/zero of=${PLATFORM_DIR}/sd_image/rootfs.img bs=512 count=3906250

#Create partition table (this may break with user input)
fdisk -u ${PLATFORM_DIR}/sd_image/rootfs.img <<EOF
o
n
p
1
2048
+500M
n
p
2


t
1
c
w
EOF

#Create filesystems
losetup -P /dev/loop0 ${PLATFORM_DIR}/sd_image/rootfs.img
mkfs.msdos -F 32 -n ZYNQBOOT /dev/loop0p1

#Unmount partitions in case OS automounts them
sleep 3
umount /dev/loop0p1 
umount /dev/loop0p2 

#Write root fs to second partition of image and label it
dd if=${PLATFORM_DIR}/sd_image/rootfs.ext4 of=/dev/loop0p2
e2label /dev/loop0p2 ROOTFS
sync

#unmount the loop devices 
losetup -d /dev/loop0

#Remove the unneeded single partition image
rm -rf ${PLATFORM_DIR}/sd_image/rootfs.ext4

#Compress image 
rm -rf ${PLATFORM_DIR}/sd_image/rootfs.zip
sudo -u $real_user zip -j ${PLATFORM_DIR}/sd_image/rootfs.zip ${PLATFORM_DIR}/sd_image/rootfs.img
rm -rf ${PLATFORM_DIR}/sd_image/rootfs.img

#Create release package
if [ ! -z "$1" ]; then
   cd ${PLATFORM_DIR}/.. 
   rm -rf ${RELEASE_NAME}${1}.zip
   sudo -u $real_user zip -r -9 ${RELEASE_NAME}${1}.zip ./${PLATFORM_NAME} ./README.txt > /dev/null 
fi



