#!/bin/bash

VM_NAME=$1
virsh destroy $VM_NAME
virsh undefine --remove-all-storage --snapshots-metadata --managed-save $VM_NAME
