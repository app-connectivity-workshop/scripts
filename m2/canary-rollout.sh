#!/bin/bash

WEIGHT_V1=100
WEIGHT_V2=0
SLEEP=20

echo "Begin Canary Rollout..."
echo "${WEIGHT_V1}% traffic routed to v1, ${WEIGHT_V2}% to v2"

for WEIGHT_V2 in 10 25 50 75 100
do
    sleep $SLEEP

    # Calculate the weight for v1
    NEW_WEIGHT_V1=$((WEIGHT_V1 - WEIGHT_V2))

    # Apply the patch
    oc -n travel-agency patch virtualservice discounts --type=json -p="[
      {\"op\": \"replace\", \"path\": \"/spec/http/0/route/0/weight\", \"value\": $NEW_WEIGHT_V1},
      {\"op\": \"replace\", \"path\": \"/spec/http/0/route/1/weight\", \"value\": $WEIGHT_V2}
    ]"

    # Friendly output
    echo "${NEW_WEIGHT_V1}% traffic routed to v1, ${WEIGHT_V2}% to v2"
done
