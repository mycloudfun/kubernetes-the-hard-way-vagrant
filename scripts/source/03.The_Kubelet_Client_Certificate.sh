#!/bin/bash

declare -A workers=( ["worker1"]="10.0.0.30" ["worker2"]="10.0.0.31" )

for instance in "${!workers[@]}"; do
cat > $instance-csr.json <<EOF
{
  "CN": "system:node:$instance.k8s.local",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

EXTERNAL_IP=${workers[$instance]}

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${instance}.k8s.local,${EXTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done
