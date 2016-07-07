sudo chown stack:stack /opt/stack/
sudo chown stack:stack /opt/stack/.ssh/
sudo chown stack:stack /opt/stack/.ssh/*
chmod 700 /opt/stack/.ssh/
chmod 600 /opt/stack/.ssh/authorized_keys

sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl stop iptables
sudo systemctl disable iptables

ovs-vsctl --may-exist add-port br-enp8s0f1 enp8s0f1
