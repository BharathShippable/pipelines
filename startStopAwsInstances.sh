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
}

configure_creds() {
  local pem_resource="bharath-us-east-1"
  local pem_resource_upper_case=$(echo $pem_resource | awk '{print toupper($0)}')
  local pem_resource_meta=$(eval echo "$"$pem_resource_upper_case"_META")
  echo "Extracting AWS PEM"
  echo "-----------------------------------"
  pushd $pem_resource_meta
  if [ ! -f "integration.json" ]; then
    echo "No credentials file found at location: $RES_PEM_META"
    return 1
  fi

  cat integration.json | jq -r '.key' > "$PEM_KEY_LOCATION"
  chmod 600 "$PEM_KEY_LOCATION"

  echo "Completed Extracting AWS PEM"
  echo "-----------------------------------"

  popd
}

run_instance() {
  aws ec2 run-instances --image-id "$AMI_ID" --count "$COUNT" --instance-type "$INSTANCE_TYPE" --key-name "$PEM_KEY_LOCATION"
}

main() {
  if [ ! -z "$ACTION" ]; then
    set_defaults
    echo "----- AWS CLI version -----"
    aws --version
    echo "---------------------------"
    if [ "$ACTION" == "run" ]; then
      configure_creds
      run_instance
    else
      echo "Unknown ACTION: $ACTION"
    fi
  else
    echo "no ACTION specfied"
  fi
}

main
