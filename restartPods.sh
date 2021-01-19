#!/bin/bash

ns=$2

start() {
    oc project $ns
    replica="dcReplica-${ns}.txt"
    while read line;do
        dcName=$(echo ${line}|awk '{print $1}')
        replica=$(echo ${line}|awk '{print $2}')
        (oc scale dc $dcName --replicas=$replica)&
    done < "${replica}"
    wait
}
stop() {
    oc project $ns
    oc get dc |awk '{print $1,$3}' > dcReplica-${ns}.txt
    for i in $(oc get dc | awk '{printf "%s",$1; printf ";%s",$3; print ""}' );do
        dc_name=$(echo $i | awk -F';' '{print $1}')
        dc_repl=$(echo $i | awk -F';' '{print $2}')
        (oc scale dc $dc_name --replicas=0)&
    done
    wait
}
case $1 in
        start|stop|stop_all) $1;;
        restart) stop; start;;
        *) echo "Usage: $0 <start|stop|restart>"; exit 1;;
esac
