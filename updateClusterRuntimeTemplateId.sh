#!/bin/bash -e

main() {
  echo "=== GETting $nodePoolName's cluster ==="
  cluster=$(curl -H "Authorization: apiToken $apiToken" $apiUrl/clusters?subscriptionIds=$subscriptionId | jq '.[] | select(.name="'$nodePoolName'" and .clusterTypeCode=='$dynamicClusterType')')
  echo "node pool $nodePoolName's cluster is $clusterId"
  if [ -z "$cluster" ]; then
    echo "cluster is not on-demand"
    exit 1
  fi
  clusterId=$(echo cluster | jq '.id')
  smi=$(shipctl get_resource_version_key $smiStateResource "smi")
  echo "=== GETting $smi's runtimeTemplateId ==="
  runtimeTemplateId=$(curl -H "Authorization: apiToken $apiToken" $apiUrl/systemMachineImages | jq '.[] | select(.name=="'$smi'") | .runtimeTemplateId')
  echo "$smi's runtimeTemplateId $runtimeTemplateId"
  echo "=== PUTting cluster $clusterId's runtimeTemplateId = $runtimeTemplateId ==="
  update=$(curl -X PUT $apiUrl/clusters/$clusterId -H "Authorization: apiToken $apiToken" -H 'content-type: application/json' -d "{\"runtimeTemplateId\": $runtimeTemplateId}")
  echo "Updated $clusterId: $(echo $update | jq '.')"
}

main
