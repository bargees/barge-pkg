# A dummy plugin for Barge to set hostname and network correctly at the very first `vagrant up`
module VagrantPlugins
  module GuestLinux
    class Plugin < Vagrant.plugin("2")
      guest_capability("linux", "change_host_name") { Cap::ChangeHostName }
      guest_capability("linux", "configure_networks") { Cap::ConfigureNetworks }
    end
  end
end

Vagrant.configure(2) do |config|
  config.vm.define "barge-pkg", primary: true
  config.vm.define "barge-pkg-armhf", autostart: false

  config.vm.box = "ailispaw/barge"

  config.vm.provider :virtualbox do |vb|
    vb.memory = 2048
  end

  config.vm.hostname = "barge-pkg"

  config.vm.synced_folder ".", "/vagrant", id: "vagrant"
end
