hosts = {
  'master1' => '10.0.0.20',
  'master2' => '10.0.0.21',
  'master3' => '10.0.0.22',
  'worker1' => '10.0.0.30',
  'worker2' => '10.0.0.31'
}

Vagrant.configure(2) do |config|

  config.vm.box = "centos/7"
  total_hosts = hosts.length

  hosts.each_with_index do |(name, ip), index|

    config.vm.define name do |nodes|
      nodes.vm.hostname = "#{name}.k8s.local"
      nodes.vm.network :private_network, ip: ip
      nodes.vm.provider "virtualbox" do |v|
        # VM configuration
        v.memory = 1024
        v.cpus = 2
      end

      # if index == total_hosts - 1
      #   nodes.vm.provision "ansible" do |ansible|
      #     # Ansible config
      #   end
      # end
    end
  end

  config.vm.define "load_balancer" do |lb|
    lb.vm.hostname = "lb.k8s.local"
    lb.vm.network :private_network, ip: "10.0.0.10"
    lb.vm.provider "virtualbox" do |v|
      # VM configuration
      v.memory = 512
      v.cpus = 2
    end
  end
end
