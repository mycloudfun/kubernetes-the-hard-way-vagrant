#!/bin/bash

KUBERNETES_PUBLIC_ADDRESS="10.0.0.10"
KUBERNETES_API_DOMAIN="api.k8s.local"
MASTER1="10.0.0.20"
MASTER2="10.0.0.21"
MASTER3="10.0.0.22"

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${KUBERNETES_API_DOMAIN},${MASTER1},${MASTER2},${MASTER3},${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,10.32.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
