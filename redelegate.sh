#!/bin/bash

source $(dirname $(readlink -e $0))/config

#REWARDS=$($CLI query distribution rewards $ADDR $OPER --node $NODE --output json | jq -r ".rewards[] | select (.denom == (\"$DENOM\").amount")
#REWARDS=$($CLI query distribution rewards $ADDR --node $NODE --output json | jq -r ".rewards[] | select (.validator_address == \"$OPER\").reward[] | select (contains (\"$DENOM\"))" | cut -d'.' -f1)
REWARDS=$($CLI query distribution rewards $ADDR --node $NODE --output json | jq -r ".rewards[] | select (.validator_address == \"$OPER\").reward[] | select (.denom | index (\"$DENOM\")).amount" | cut -d'.' -f1)
#COMMISSION=$($CLI query distribution commission $OPER --node $NODE --output json | jq -r ".commission[] | select (.denom == \"$DENOM\").amount")
#COMMISSION=$($CLI query distribution commission $OPER --node $NODE --output json | jq -r ".commission.commission[] | select (contains(\"$DENOM\"))" | cut -d'.' -f1)
COMMISSION=$($CLI query distribution commission $OPER --node $NODE --output json | jq -r ".commission.commission[] | select (.denom | index(\"$DENOM\")).amount" | cut -d'.' -f1)

AMOUNT=$((${REWARDS%.*}+${COMMISSION%.*}))

if (($AMOUNT > $CLAIM_THR)); then
    echo -e $PASS | $($CLI tx distribution withdraw-rewards $OPER --commission --from $KEY_NAME --chain-id $CHAIN --gas auto --fees $FEES$DENOM --yes --node $NODE)
    sleep 10
fi

BAL=$($CLI query bank balances $ADDR --node $NODE --output json | jq -r ".balances[] | select (.denom == \"$DENOM\").amount")
BALANCE=${BAL%.*}

if (($BALANCE > $DELEGATE_THR)); then
    SUM=$((BALANCE-REMAINDER))
    echo -e $PASS | $($CLI tx staking delegate $OPER $SUM$DENOM --chain-id=$CHAIN --from $KEY_NAME --gas auto --fees $FEES$DENOM --yes --node $NODE)
fi
