#!/bin/bash

echo "Generate private and public ssh keys"

mkdir -p keys

ssh-keygen -t rsa -f ./key -N ''
