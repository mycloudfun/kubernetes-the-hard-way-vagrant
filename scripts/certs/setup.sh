#!/bin/bash

echo "Starting creating certificates"

./01.Certificate_Authority.sh*
./02.The_Admin_Client_Certificate.sh*
./03.The_Kubelet_Client_Certificate.sh*
./04.The_Controller_Manager_Client_Certificate.sh*
./05.The_Kube_Proxy_Client_Certificate.sh*
./06.The_Scheduler_Client_Certificate.sh
./07.The_Kubernetes_Api_Server_Certificate.sh
./08.The_Service_Account_Key_Pair.sh

echo "Certificates created..."
