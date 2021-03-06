# Kubernetes the hard way with Vagrant and Ansible

This is a port of Kelsey Hightower project called [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way), originally created for GCP. The aim of this project is to build a similar setup, but based on well-known product Vagrant. It allows you to build your own Kubernetes cluster for learning purposes without access to any public cloud provides. The only limit is your PC Hardware :)

## Introduction

The setup describes here is not fully automated, because the original idea was to create the Kubernetes cluster with the hardest possible way. In opposite to the original project, some of the tasks described here automate the work. But the original idea has been kept. 

Simply follow the steps described below to build your own Kubernetes cluster. If you are interested in how it works, feel free to read the scripts / ansible playbooks (requires minimal knowledge about BASH and Ansible).

### Differences with the Kelsey version

* Uses Vagrant instead of GCP as an infrastructure
* Uses CentOS 7 Linux images
* Creates 3 masters and 2 worker nodes

## Prerequisites

* Installed Vagrant (tested on v2.2.4)
* Installed Ansible (tested on v2.7.8)
* Installed Virtualbox (tested on v.6.0.6_Ubuntu)
* Entries in your local PC /etc/hosts

```bash
10.0.0.10 api.k8s.local
10.0.0.20 master1.k8s.local
10.0.0.21 master2.k8s.local
10.0.0.22 master3.k8s.local
10.0.0.30 worker1.k8s.local
10.0.0.31 worker2.k8s.local
```
* Private and public keys used later for ansible

```bash
./ssh_keys.sh

#it will produce keys in main directory:
key
key.pub
```

## How to setup the cluster

Steps described here are based on original ones from tutorial of Kelsey Hightower.

### Steps 01-02

Follow the original ones from:

[1. Prerequisites](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md)

[2. Installing the Client Tools](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-client-tools.md)

### Step 03 - Provisioning Compute Resources

In order to provision the required resources, clone this repository and run below command in main directory:

```bash
vagrant up
```

This will provision 6 VM's on your Virtualbox: 3 Masters, 2 Workers and 1 Nginx Load Balander.

### Step 04 - Provisioning a CA and Generating TLS Certificates

Run the **setup_certs.sh** script in **scripts** folder to create all the required certificates. Make sure you run this script from the certs folder.

```bash
cd scripts/
./setup_certs.sh
```

Next copy produced certificates to master's and worker's nodes. I suggest you use vagrant-scp plugin.

```bash
vagrant plugin install vagrant-scp
```

Worker instances:

```bash
for instance in worker1 worker2; do
  vagrant scp ca.pem ${instance}:~/
  vagrant scp ${instance}-key.pem ${instance}:~/
  vagrant scp ${instance}.pem ${instance}:~/
done
```

Master instances:

```bash
for instance in master1 master2 master3; do
  vagrant scp ca.pem ${instance}:~/
  vagrant scp ca-key.pem ${instance}:~/
  vagrant scp kubernetes-key.pem ${instance}:~/
  vagrant scp kubernetes.pem ${instance}:~/
  vagrant scp service-account-key.pem ${instance}:~/
  vagrant scp service-account.pem ${instance}:~/
done
```

### Step 05 - Generating Kubernetes Configuration Files for Authentication

Run the **setup_kubeconfigs.sh** script in **scripts** folder to create all the required configuration files.

```bash
./setup_kubeconfigs.sh
```

Next copy produced files to worker instances:

```bash
for instance in worker1 worker2; do
  vagrant scp ${instance}.kubeconfig ${instance}:~/
  vagrant scp kube-proxy.kubeconfig ${instance}:~/
done
```

and master instances:

```bash
for instance in master1 master2 master3; do
  vagrant scp admin.kubeconfig ${instance}:~/
  vagrant scp kube-controller-manager.kubeconfig ${instance}:~/
  vagrant scp kube-scheduler.kubeconfig ${instance}:~/
done
```

### Step 6 Generating the Data Encryption Config and Key

Run the **setup_encryption.sh** script in **scripts** folder to create the encryption key and configuration.

```bash
./setup_encryption.sh
```

Next copy produced files to Master instances:

```bash
for instance in master1 master2 master3; do
  vagrant scp encryption-config.yaml ${instance}:~/
done
```

### Step 7 Bootstrapping the etcd Cluster

> **IMPORTANT!** Ansible playbook expects that desired files and certificates created in previous steps are available under /home/vagrant folder in nodes. Make sure you successfully completed it, otherwise, the setup will fail.

Start the ansible playbook to configure the ETCD cluster:

```bash
ansible-playbook ansible/etcd-cluster.yml -i ansible/inventory --key-file key
```

Above command will create ETCD cluster and start it. You can validate the status, by executing below command on one of the master nodes:

```bash
vagrant ssh master1 -c "
sudo ETCDCTL_API=3 /usr/local/bin/etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem"
```

It should produce the output similar to one below:

```bash
33d87194523dae28, started, master3, https://10.0.0.22:2380, https://10.0.0.22:2379
49c039455b52a82e, started, master1, https://10.0.0.20:2380, https://10.0.0.20:2379
d39138844daf67cb, started, master2, https://10.0.0.21:2380, https://10.0.0.21:2379
```

### Step 8 Bootstrapping the Kubernetes Control Plane

> **IMPORTANT!** Ansible playbook expects that desired files and certificates created in previous steps are available under /home/vagrant folder in nodes. Make sure you successfully completed it.otherwise the setup will fail.

Start the Ansible playbook to configure control plane of Kubernetes cluster:

```bash
ansible-playbook ansible/control-plane.yml -i ansible/inventory --key-file key
```

After few moments, check if the control plane is operational by typping below command:

```bash
vagrant ssh master1 -c "kubectl get componentstatuses --kubeconfig admin.kubeconfig"
```

You should get the output similar to one below:

```bash
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
etcd-2               Healthy   {"health":"true"}
etcd-1               Healthy   {"health":"true"}
etcd-0               Healthy   {"health":"true"}
```

You can use another test to validate if nginx load balancer is operational:

```bash
curl -k --cacert scripts/ca.pem  https://api.k8s.local:6443/version
{
  "major": "1",
  "minor": "12",
  "gitVersion": "v1.12.0",
  "gitCommit": "0ed33881dc4355495f623c6f22e7dd0b7632b7c0",
  "gitTreeState": "clean",
  "buildDate": "2018-09-27T16:55:41Z",
  "goVersion": "go1.10.4",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

**RBAC for Kubelet**

In order to allow Kubernetes API Server to access the Kubelet API, you need to create the ClusterRole and ClusterRoleBinding. Simply run below commands to configure it:

```bash
vagrant scp scripts/kubelet-rbac-authorization.sh master1:~/
vagrant ssh master1 -c "~/kubelet-rbac-authorization.sh"
```

You will get such output:

```bash
clusterrole.rbac.authorization.k8s.io/system:kube-apiserver-to-kubelet created
clusterrolebinding.rbac.authorization.k8s.io/system:kube-apiserver created
```

### Step 9 Bootstrapping the Kubernetes Worker Nodes

> **IMPORTANT!** Ansible playbook expects that desired files and certificates created in previous steps are available under /home/vagrant folder in nodes. Make sure you successfully completed it.otherwise the setup will fail.

Start the Ansible playbook to configure worker nodes of Kubernetes cluster:

```bash
ansible-playbook ansible/worker-nodes.yml -i ansible/inventory --key-file key
```

Once finished, run below commands to validate the status of worker nodes:

```bash
vagrant ssh master1 -c "kubectl get nodes --kubeconfig admin.kubeconfig"
```

You should get the output similar to the one below:

```bash
NAME      STATUS   ROLES    AGE    VERSION
worker1   Ready    <none>   12m    v1.12.0
worker2   Ready    <none>   107s   v1.12.0
```

### Step 10 Configuring kubectl for Remote Access

Run below script to generate kubectl for access the Kubernetes API:

```bash
cd scripts/
./setup_kubectl.sh
```

Once completed, your kubectl is ready to connect to the API. Run below set of commands to verify it:

```bash
kubectl get componentstatuses
kubectl get nodes
```

### Step 11 Provision Pod network routes

To configure POD network routes accros the nodes, run below ansible script:

```bash
ansible-playbook ansible/pod_network.yml -i ansible/inventory --key-file key
```

It will install and configure necessary routes.

### Step 12 Deploying the DNS Cluster Add-on

Finally, deploy the DNS Cluster Add-on to the cluster:

```bash
kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml
```

Now you can run a small tests to check if the service is operational:

```bash
# Create a busybox deployment:
kubectl run busybox --image=busybox:1.28 --command -- sleep 3600

# List the pod created by the busybox deployment:
kubectl get pods -l run=busybox

# Retrive the full name of the busybox pod:
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")

# Execute a DNS lookup for the kubernetes service inside the busybox pod:
kubectl exec -ti $POD_NAME -- nslookup kubernetes

# Expected output:
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local
```

## Lab cleanup

This command will destroy all the resources created during this lab:

```bash
vagrant destroy
```
