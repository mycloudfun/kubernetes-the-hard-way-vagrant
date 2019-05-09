# Kubernetes the hard way with vagrant

This is a port of Kelsey Hightower project called [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way), originally created for GCP. The aim of this project is to build a similar setup, but based on well-known product Vagrant. It allows you to build your own Kubernetes cluster for learning purposes without access to any public cloud provides. The only limit is your PC Hardware :)

### Differences with the Kelsey version

* Uses Vagrant instead of GCP as an infrastructure
* Uses CentOS7 images
* Creates 3 masters and 2 worker nodes

## Prerequisites

* Installed Vagrant (validated on v2.2.4)
* Installed Ansible
* Installed Virtualbox
* Entries in your /etc/hosts

```bash
10.0.0.10 api.k8s.local
10.0.0.20 master1.k8s.local
10.0.0.21 master2.k8s.local
10.0.0.22 master3.k8s.local
10.0.0.30 worker1.k8s.local
10.0.0.31 worker2.k8s.local
```

## How to setup the cluster

Steps described here are based on original ones from tutorial of Kelsey Hightower.

### Steps 01-02

Follow the original ones from:
[1. Prerequisites](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md)
[2. Installing the Client Tools](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-client-tools.md)

### Steps 03

In order to provision the required resources, clone this repository and run below command in main directory:

```bash
vagrant up
```

This will provision 6 VM's on your Virtualbox. 3 Masters, 2 Workers and 1 Nginx Load Balander.
