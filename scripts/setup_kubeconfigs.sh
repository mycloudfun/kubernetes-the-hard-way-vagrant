#!/bin/bash

echo "Generate kubernetes configuration files"

source/09.The_Kubelet_Kubernetes_Configuration_Files.sh*
source/10.The_Kube-proxy_Kubernetes_Configuration_Files.sh*
source/11.The_Kube-controller-manager_Kubernetes_Configuration_File.sh
source/12.The_Kube-scheduler_Kubernetes_Configuration_File.sh
source/13.The_Admin_Kubernetes_Configuration_File.sh

echo "Kubernetes configuration files created..."
