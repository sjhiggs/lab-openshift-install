#!/bin/bash

SNAPSHOT_NAME=$1

virsh snapshot-create-as --domain master --name "$SNAPSHOT_NAME"
virsh snapshot-create-as --domain node1 --name "$SNAPSHOT_NAME"
virsh snapshot-create-as --domain node2 --name "$SNAPSHOT_NAME"
