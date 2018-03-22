#!/bin/bash -e
export ACTION="$1"
export AMI_STATE="ami_state"

set_defaults() {
  if [ -z "$AMI_ID" ]; then
    export AMI_ID="ami-06b6797b"
  fi
  if [ -z "$COUNT" ]; then
    export COUNT=1
  fi
  if [ -z "$INSTANCE_TYPE" ]; then
    export INSTANCE_TYPE="t2.medium"
  fi
  if [ -z "$KEY_NAME" ]; then
    export KEY_NAME="bharath-us-east-1"
  fi
}

run_instance() {
  echo "Running instance"
  echo "-----------------------------------"

  local aws_run_instances_result=$(aws ec2 run-instances --image-id "$AMI_ID" --count "$COUNT" --instance-type "$INSTANCE_TYPE" --key-name "$KEY_NAME")
  local aws_instance_id=$(echo $aws_run_instances_result | jq -r '.Instances | .[0] | .InstanceId')

  shipctl put_resource_state $AMI_STATE aws_instance_id $aws_instance_id

  echo "Completed running instance: $aws_instance_id"
  echo "-----------------------------------"
}

terminate_instance() {
  local aws_instance_id="$1"
  echo "Terminating instance: $aws_instance_id"
  echo "-----------------------------------"

  aws ec2 terminate-instances --instance-ids $aws_instance_id

  echo "Terminated instance: $aws_instance_id"
  echo "-----------------------------------"
}

start_instance() {
  local aws_instance_id="$1"
  echo "Starting instance: $aws_instance_id"
  echo "-----------------------------------"

  aws ec2 start-instances --instance-ids $aws_instance_id

  echo "Started instance: $aws_instance_id"
  echo "-----------------------------------"
}

stop_instance() {
  local aws_instance_id="$1"
  echo "Stopping instance: $aws_instance_id"
  echo "-----------------------------------"

  aws ec2 stop-instances --instance-ids $aws_instance_id

  echo "Stopped instance: $aws_instance_id"
  echo "-----------------------------------"
}

main() {
  if [ ! -z "$ACTION" ]; then
    set_defaults
    echo "----- AWS CLI version -----"
    aws --version
    echo "---------------------------"
    if [ "$ACTION" == "run" ]; then
      run_instance
    elif [ "$ACTION" == "terminate" ]; then
      local aws_instance_id=$(shipctl get_resource_version_key $AMI_STATE "aws_instance_id")
      terminate_instance $aws_instance_id
    elif [ "$ACTION" == "start" ]; then
      local aws_instance_id=$(shipctl get_resource_version_key $AMI_STATE "aws_instance_id")
      start_instance $aws_instance_id
    elif [ "$ACTION" == "stop" ]; then
      local aws_instance_id=$(shipctl get_resource_version_key $AMI_STATE "aws_instance_id")
      stop_instance $aws_instance_id
    else
      echo "Unknown ACTION: $ACTION"
    fi
  else
    echo "no ACTION specfied"
  fi
}

main
