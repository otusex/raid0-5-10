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
                # RAID5 
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
   
    config.vm.provision "shell", path: "create.raid-0.5.10.sh"

    end
  end
end


