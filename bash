#!/bin/bash
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod u+x ec2-metadata
INSTANCE_ID=$(./ec2-metadata | grep instance-id | awk 'NR==1{print $2}')
AG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids ${INSTANCE_ID} --region us-east-2 --query AutoScalingInstances[].AutoScalingGroupName --output text)
for ID in $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${AG_NAME} --region us-east-2 --query AutoScalingGroups[].Instances[].InstanceId --output text);
do
    if [ "${ID}" == ${INSTANCE_ID} ] ; then
        continue;
    fi
    IP=$(aws ec2 describe-instances --instance-ids $ID --region us-east-2 --query Reservations[].Instances[].PrivateIpAddress --output text)
    rm ~/workspace/pushtogit.jenkins.opsroute/id_rsa
    rm ~/workspace/pushtogit.jenkins.opsroute/id_rsa.pub
    ssh-keygen -f ~/workspace/pushtogit.jenkins.opsroute/id_rsa -t rsa -N ''
    cat ~/workspace/pushtogit.jenkins.opsroute/id_rsa.pub|ssh -i ~/workspace/pushtogit.jenkins.opsroute/key.pem ubuntu@${IP} 'cat >> .ssh/authorized_keys'
    rm ec2-metadata
    echo "try -- ssh ubuntu@"${IP}
done
