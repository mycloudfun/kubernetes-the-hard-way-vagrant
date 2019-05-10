# Variables

hosts = {
  'master1' => '10.0.0.20',
  'master2' => '10.0.0.21',
  'master3' => '10.0.0.22',
  'worker1' => '10.0.0.30',
  'worker2' => '10.0.0.31'
}

loadbalancer = { 'lb' => '10.0.0.10' }

hostsMemory = "1024"
hostsCpu = "2"

lbMemory = "512"
lbCpu = "2"

# Configuration
Vagrant.configure(2) do |config|

  config.vm.box = "centos/7"
  total_hosts = hosts.length

  hosts.each_with_index do |(name, ip), index|

    config.vm.define name do |nodes|
      nodes.vm.hostname = "#{name}.k8s.local"
      nodes.vm.network :private_network, ip: ip
      nodes.vm.provider "virtualbox" do |v|
        # VM configuration
        v.memory = hostsMemory
        v.cpus = hostsCpu
      end

      nodes.vm.provision "ansible" do |ansible|
        ansible.playbook = "providers/ansible/hosts_playbook.yml"
      end
    end
  end
  
  loadbalancer.each_with_index do |(name, ip), index|

    config.vm.define name do |lb|
      lb.vm.hostname = "#{name}.k8s.local"
      lb.vm.network :private_network, ip: ip
      lb.vm.provider "virtualbox" do |v|
        # VM configuration
        v.memory = lbMemory
        v.cpus = lbCpu
      end

      lb.vm.provision "ansible" do |ansible|
        ansible.playbook = "providers/ansible/lb_playbook.yaml"
      end
    end
  end
end
