#!/bin/bash

function choice {
    echo "Task Choice, Select Task:";
    echo "--------------------------";
    echo "1. Create New k8s RKE Cluster";
    echo "2. Add Worker Nodes to Existing Master";
    read -p "Your Choice eq [1-2] :" pick;
        if [ $pick = 1 ];then
            echo "-----------------------------";
            echo "Create New k8s RKE Cluster"
            echo "-----------------------------";
            newCluster
        elif [ $pick = 2 ];then
            echo "-----------------------------------";
            echo "Add Worker Nodes to Existing Master"
            echo "-----------------------------------";        
            addWorker
        else
            echo "Please Select From List..."
            choice
        fi
}

function newCluster {
    read -p "Set Master Nodes IP Address:" ip
    read -p "Set Worker Nodes 1 IP Address :" worker_ip1
    read -p "Set Worker Nodes 2 IP Address :" worker_ip2
    echo $ip > tmp/master-ip
    echo $worker_ip1 > tmp/worker-ip1
    echo $worker_ip2 > tmp/worker-ip2
    echo "
    [master]
    master-$(cat tmp/master-ip) ansible_host=$(cat tmp/master-ip) ansible_user=root

    [worker]
    worker1-$(cat tmp/worker-ip1) ansible_host=$(cat tmp/worker-ip1) ansible_user=root
    worker2-$(cat tmp/worker-ip2) ansible_host=$(cat tmp/worker-ip2) ansible_user=root

    [master:vars]
    ansible_ssh_common_args=' -J ovh1,prox.proxmox'

    [worker:vars]
    ansible_ssh_common_args=' -J ovh1,prox.proxmox'
    " > inventory

    ansible-playbook -i inventory rke2.yml
    rm -rf inventory tmp/*
}

function addWorker {
    read -p "Set Existing Master Nodes IP Address:" ip
    read -p "Set Worker Nodes IP Address || \"separate [space] multiple IP Address\" : " worker_ip
    echo $ip > tmp/master-ip
    echo "
[master]
master-$(cat tmp/master-ip) ansible_host=$(cat tmp/master-ip) ansible_user=root
[master:vars]
ansible_ssh_common_args=' -J ovh1,prox.proxmox'

[worker:vars]
ansible_ssh_common_args=' -J ovh1,prox.proxmox'

## WORKER-NODES ## " > inventory-addworker

    list=( $worker_ip )
    for worker in ${list[@]}
    do 
echo $worker > tmp/worker-ip
echo "worker-$(cat tmp/worker-ip) ansible_host=$(cat tmp/worker-ip) ansible_user=root" >> inventory-addworker
    done 
sed -i '/WORKER-NODES/a [worker]' inventory-addworker
ansible-playbook -i inventory-addworker add-worker-nodes.yml
rm -rf inventory-addworker
    
}

choice