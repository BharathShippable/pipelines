#!/bin/bash -e

main() {
  echo "=== GETting $subscriptionId's default cluster ==="
  defaultClusterId=$(curl -H "Authorization: apiToken $apiToken" $apiUrl/subscriptions/$subscriptionId | jq '.defaultClusterId')
  echo "$subscriptionId's default cluster is $defaultClusterId"
  echo "=== Checking $subscriptionId's default cluster is dynamic ==="
  is_dynamic=$(curl -H "Authorization: apiToken $apiToken" $apiUrl/clusters?subscriptionIds=$subscriptionId | jq '.[] | select(.id=='$defaultClusterId' and .clusterTypeCode=='$dynamicClusterType')')
  if [ -z "$is_dynamic" ]; then
    echo "Default cluster is not dynamic"
    exit 1
  fi
  smi=$(shipctl get_resource_version_key smi_state "smi")
  echo "=== GETting $smi's runtimeTemplateId ==="
  runtimeTemplateId=$(curl -H "Authorization: apiToken $apiToken" $apiUrl/systemMachineImages | jq '.[] | select(.name=="'$smi'") | .runtimeTemplateId')
  echo "$smi's runtimeTemplateId $runtimeTemplateId"
  echo "=== PUTting $subscriptionId's default cluster $defaultClusterId's runtimeTemplateId = $runtimeTemplateId ==="
  update=$(curl -X PUT $apiUrl/clusters/$defaultClusterId -H "Authorization: apiToken $apiToken" -H 'content-type: application/json' -d "{\"runtimeTemplateId\": $runtimeTemplateId}")
  echo "Updated $clusterId: $(echo $update | jq '.')"
}

main
