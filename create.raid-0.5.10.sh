#!/bin/bash

yum install -y nano vim wget mdadm gdisk
# создать GPT раздел и 5 партиций
echo -e "o \ny \nn \n1 \n \n+3M \n8300\nn \n2 \n \n+4M \n8300 \nn\n3 \n \n+4M \n8300 \nn\n4 \n \n+4M \n8300 \nn\n5 \n \n \n8300 \nw\ny\n" | gdisk /dev/sdl

# GPT partition
echo -e "o \ny \nn \n1 \n \n \nfd00 \nw\ny\n" | gdisk /dev/sdh
echo -e "o \ny \nn \n1 \n \n \nfd00 \nw\ny\n" | gdisk /dev/sdi
echo -e "o \ny \nn \n1 \n \n \nfd00 \nw\ny\n" | gdisk /dev/sdj
echo -e "o \ny \nn \n1 \n \n \nfd00 \nw\ny\n" | gdisk /dev/sdk

# GPT partition
echo -e "o \ny \nn \n1 \n \n \nfd00 \nw\ny\n" | gdisk /dev/sdb
echo -e "o \ny \nn \n1 \n \n \nfd00 \nw\ny\n" | gdisk /dev/sdc

# GPT partition
echo -e "o \ny \nn \n1 \n \n \nfd00 \nw\ny\n" | gdisk /dev/sdd
echo -e "o \ny \nn \n1 \n \n \nfd00 \nw\ny\n" | gdisk /dev/sde
echo -e "o \ny \nn \n1 \n \n \nfd00 \nw\ny\n" | gdisk /dev/sdf
echo -e "o \ny \nn \n1 \n \n \nfd00 \nw\ny\n" | gdisk /dev/sdg

# create RAID 0/5/10
mdadm --create /dev/md0 --level 0 -n 2 /dev/sd{b,c}1
mdadm --create /dev/md1 --level 5 -n 4 /dev/sd{d,e,f,g}1
mdadm --create /dev/md2 --level 10 -n 4 /dev/sd{h,i,j,k}1
   
# create filesystem XFS
mkfs.xfs /dev/md0
mkfs.xfs /dev/md1
mkfs.xfs /dev/md2
   
#mount point
mkdir -p /mnt/{r1,r2,r3}

# add to fstab
blkid /dev/md{0,1,2} | awk '{x+=1}{print  $2 " /mnt/r"x" xfs defaults 0 0" }' >> /etc/fstab
mdadm --verbose --detail --scan > /etc/mdadm.conf
cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bak
/sbin/dracut --mdadmconf --add="mdraid" --force -v
reboot

