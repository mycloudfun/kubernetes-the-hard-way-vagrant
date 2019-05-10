#!/bin/bash

echo "Starting creating certificates"

source/01.Certificate_Authority.sh*
source/02.The_Admin_Client_Certificate.sh*
source/03.The_Kubelet_Client_Certificate.sh*
source/04.The_Controller_Manager_Client_Certificate.sh*
source/05.The_Kube_Proxy_Client_Certificate.sh*
source/06.The_Scheduler_Client_Certificate.sh
source/07.The_Kubernetes_Api_Server_Certificate.sh
source/08.The_Service_Account_Key_Pair.sh

echo "Certificates created..."
