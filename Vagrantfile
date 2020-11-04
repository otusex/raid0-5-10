MACHINES = {
 :otusc7 => {
    :box_name => "centos/7",
    :ip_addr  => '10.10.0.2',
    :disks    => {
               # RAID0 
               :sata1 => {
                 :dfile => './sata1.vdi',
                 :size  => '20', #Mb
                 :port  => 1 
                },
               :sata2 => {
                 :dfile => './sata2.vdi',
                 :size  => '20',
                 :port  => 2
                },
                # RAID5 /var
                :sata3 => {
                 :dfile => './sata3.vdi',
                 :size  => '20',
                 :port  => 3
                },
                 :sata4 => {
                 :dfile => './sata4.vdi',
                 :size  => '20',
                 :port  => 4
                },
                 :sata5 => {
                 :dfile => './sata5.vdi',
                 :size  => '20',
                 :port  => 5
                },
                 :sata6 => {
                 :dfile => './sata6.vdi',
                 :size  => '20',
                 :port  => 6
                },
                # RAID10 
                :sata7 => {
                 :dfile => './sata7.vdi',
                 :size  => '20',
                 :port  => 7
                },
                 :sata8 => {
                 :dfile => './sata8.vdi',
                 :size  => '20',
                 :port  => 8
                },
                 :sata9 => {
                 :dfile => './sata9.vdi',
                 :size  => '20',
                 :port  => 9
                },
                 :sata10 => {
                 :dfile => './sata10.vdi',
                 :size  => '20',
                 :port  => 10
                },
                # создать GPT раздел и 5 партиций
                :sata11 => {
                 :dfile => './sata11.vdi',
                 :size  => '20',
                 :port  => 11
                }
    }
  },
}


Vagrant.configure("2") do |config|

 MACHINES.each do |boxname, boxconfig|
   config.vm.synced_folder ".", "/vagrant", disabled: true
   config.vm.define boxname do |box|

      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxname.to_s

      #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset

      box.vm.network "private_network", ip: boxconfig[:ip_addr]

      box.vm.provider :virtualbox do |vb|

           vb.customize ["modifyvm", :id, "--memory", "1024"]
           needsController = false

           boxconfig[:disks].each do |dname, dconf|
             unless File.exist?(dconf[:dfile])
                    vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size] ]
                    needsController = true
             end
           end
           if needsController == true
              vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata"]
              boxconfig[:disks].each do |dname, dconf|
                vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
              end
           end 
      end
   
   box.vm.provision "shell", inline: <<-SHELL
   
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

   SHELL


    end
  end
end


