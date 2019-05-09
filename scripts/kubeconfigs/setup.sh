#!/bin/bash

echo "Generate kubernetes configuration files"

./01.The_Kubelet_Kubernetes_Configuration_Files.sh*
./02.The_Kube-proxy_Kubernetes_Configuration_Files.sh*
./03.The_Kube-controller-manager_Kubernetes_Configuration_File.sh
./04.The_Kube-scheduler_Kubernetes_Configuration_File.sh
./05.The_Admin_Kubernetes_Configuration_File.sh

echo "Kubernetes configuration files created..."
