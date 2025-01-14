# Core Installation

In order to have end-to-end connectivity a core network is required.
If no core network is available, Open5GS can be installed in a virtual machine on the installation machine.
If you already have a core you can skip this chapter.

## Create a Network Bridge

In order to be able to assign a public IP address to the Virtual Machine, the network connection of the installation machine has to be bridged.
This allows to add the virtual machine to the created bridge.
To create a bridge, replace the network configuration of the installation machine which is assumed to be located in `/etc/netplan/00-installer-config.yaml` with the configuration below.
You might have to edit this configuration to match your set-up.

``` bash
sudo tee /etc/netplan/00-installer-config.yaml <<EOF
network:
  ethernets:
    $NODE_INT:
      dhcp4: no
  bridges:
    br0:
      addresses:
      - $NODE_IP/24
      gateway4: $GATEWAY_IP
      nameservers:
        addresses:
        - $GATEWAY_IP
        search:
        - $GATEWAY_IP
      interfaces:
        - $NODE_INT
  version: 2
EOF
```

Next run the following command to test and apply the new configuration:

``` bash
sudo netplan try
```

Make sure to use `br0` as the `$NODE_INT` from now on:

``` bash
export NODE_INT=br0
```

## Create a Virtual Machine

Next you can install the virtual machine that hosts the core.
The installation process is outside the scope of this document.
Make sure to create a bridged network for the virtual machine and assign a fixed IP address (`$CORE_IP`) in the same subnet as `$NODE_IP` to it.
Note that if you SSH into the virtual machine the `$CORE_IP` and related variables might not be set.

## Install Open5GS

Please refer to [the Open5GS website](https://open5gs.org/open5gs/docs/guide/01-quickstart/) for information on how to install and configure the Open5GS core network on the virtual machine.

## Configure Open5GS

The default configuration of Open5GS can mostly be used as-is.
There are a couple of modifications that have to be made to its configuration:

Edit `/etc/open5gs/amf.yaml` and set the NGAP listen address to the public address of the virtual machine:

``` yaml
amf:
    ngap:
      - addr: $CORE_IP
```

Edit `/etc/open5gs/upf.yaml` and set the GTP-U listen address to the public address of the virtual machine:

``` yaml
upf:
    gtpu:
      - addr: $CORE_IP
```

Restart the AMF and UPF:

``` bash
sudo systemctl restart open5gs-amfd
sudo systemctl restart open5gs-upfd
```
