#!/bin/bash
# bash script by Amr Osman to check the health of your AWS instances every 2 minutes and if it was down then it will try to relaunch it 

Instances=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --output text | xargs)

# loop to check the instances 
for (( ; ; )) ;do 
	for Instance in $Instances
		do
			if [[ $(aws ec2 describe-instance-status --instance-ids $Instance | grep -q running) || $? -eq 0 ]]
			then 
				echo $(date +"%D %T") ": OK"
				echo $Instance is running
				echo ---------------------------------------------------------------------
			else 
				echo $(date +"%D %T") ": FAILURE" 
				echo $Instance is not running
				echo I will try to launch instance $Instance again for you, Please hold on.
				aws ec2 start-instances --instance-ids $Instance 1> /dev/null
				echo  waiting for instance and check again in 3 minutes
				sleep 60
				echo ---------------------------------------------------------------------
			fi
		done 
sleep 120;
done
