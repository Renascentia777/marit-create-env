#!/bin/bash

aws ec2 run-instances --image-id ami-06b94666 --count 3 --key-name Johannes --security-group-id sg-1c50d065 --instance-type t2.micro --region us-west-2 --client-token TicTacToken

aws elb create-load-balancer --load-balancer-name Saul --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones us-west-2b --security-groups sg-1c50d065

sleep 10m

INSTANCEIDS=`aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,ClientToken]' | grep TicTacToken | awk '{print $1}'`

aws elb register-instances-with-load-balancer --load-balancer-name Saul --instances $INSTANCEIDS

aws autoscaling create-launch-configuration --launch-configuration-name Filippos --image-id ami-06b94666 --instance-type t2.micro --security-groups sg-1c50d065

aws autoscaling create-auto-scaling-group --auto-scaling-group-name Moses --launch-configuration-name Filippos --min-size 0 --max-size 7 --desired-capacity 1 --health-check-type ELB --health-check-grace-period 300 --availability-zones us-west-2b
aws autoscaling attach-instances --instance-ids $INSTANCEIDS --auto-scaling-group-name Moses

aws autoscaling attach-load-balancers --auto-scaling-group-name Moses --load-balancer-names Saul


