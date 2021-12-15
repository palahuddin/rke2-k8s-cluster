#!/bin/bash

function choice {
    echo "Task Choice, Select Task:";
    echo "--------------------------";
    echo "1. Create New k8s RKE Cluster + 2 Workers";
    echo "2. Create New k8s RKE Cluster + 1 Worker";
    echo "3. Add Worker Nodes to Existing Master";
    read -p "Your Choice eq [1-3] :" pick;
        if [ $pick = 1 ];then
            echo "-----------------------------";
            echo "Create New k8s RKE Cluster + 2 Workers"
            echo "-----------------------------";
            newCluster
        elif [ $pick = 3 ];then
            echo "-----------------------------------";
            echo "Add Worker Nodes to Existing Master"
            echo "-----------------------------------";        
            addWorker
        elif [ $pick = 2 ];then
            echo "-----------------------------------";
            echo "Create New k8s RKE Cluster + 1 Workers"
            echo "-----------------------------------";        
            masterSingleWorker        
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

    " > inventory

    ansible-playbook -i inventory rke2.yml
    rm -rf inventory tmp/*
}

function masterSingleWorker {
    read -p "Set Master Nodes IP Address:" ip
    read -p "Set Worker Nodes 1 IP Address :" worker_ip1
    echo $ip > tmp/master-ip
    echo $worker_ip1 > tmp/worker-ip1
    echo "
    [master]
    master-$(cat tmp/master-ip) ansible_host=$(cat tmp/master-ip) ansible_user=root

    [worker]
    worker1-$(cat tmp/worker-ip1) ansible_host=$(cat tmp/worker-ip1) ansible_user=root

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