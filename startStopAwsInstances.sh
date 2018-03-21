#!/bin/bash -e
export ACTION="$1"
export PEM_KEY_LOCATION="/tmp/ssh-key.pem"

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

  aws ec2 run-instances --image-id "$AMI_ID" --count "$COUNT" --instance-type "$INSTANCE_TYPE" --key-name "$KEY_NAME"

  echo "Completed running instance"
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
    else
      echo "Unknown ACTION: $ACTION"
    fi
  else
    echo "no ACTION specfied"
  fi
}

main
