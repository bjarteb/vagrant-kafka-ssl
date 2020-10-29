# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"
  config.vm.provision "shell", inline: <<-SHELL
       which python || (apt-get update; apt-get install -y python)
  SHELL

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true

  (1..3).each do |i|
    config.vm.define "k#{i}" do |node|
      node.vm.hostname = "k#{i}"
      node.vm.network :private_network, ip: "10.0.21.1#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", 2048]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        # set timesync parameters to keep the clocks better in sync
        # sync time every 10 seconds
        vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-interval", 10000 ]
        # adjustments if drift > 100 ms
        vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-min-adjust", 100 ]
        # sync time on restore
        vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-on-restore", 1 ]
        # sync time on start
        vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-start", 1 ]
        # at 1 second drift, the time will be set and not "smoothly" adjusted
        vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]
      end
      node.vm.provision "ansible" do |ansible|
        ansible.extra_vars = { ansible_python_interpreter:"/usr/bin/python3" }
        ansible.become = true
        ansible.playbook = "provisioning/base.yml"
      end
    end
  end

  config.vm.define :a do |node|
    node.vm.hostname = "a"
    node.vm.network "private_network", ip: "10.0.21.10"
    node.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 512]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
    node.vm.provision "ansible" do |ansible|
      ansible.extra_vars = { ansible_python_interpreter:"/usr/bin/python3" }
      ansible.playbook = 'provisioning/controller.yml'
      ansible.become = true
    end
  end

end
