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
  local aws_instance_id=$(jq -r '.Instances | .[0] | .InstanceId')

  shipctl put_resource_state $AMI_STATE aws_instance_id $aws_instance_id

  echo "Completed running instance: $aws_instance_id"
  echo "-----------------------------------"
}

terminate_instance() {
  echo "Terminating instance"
  echo "-----------------------------------"

  local aws_run_instances_result=$(aws ec2 terminate-instances --instance-ids $aws_instance_id)

  echo "Terminated instance: $aws_instance_id"
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
      terminate_instance
    else
      echo "Unknown ACTION: $ACTION"
    fi
  else
    echo "no ACTION specfied"
  fi
}

main
