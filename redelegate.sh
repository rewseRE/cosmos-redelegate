#!/bin/bash

CLI=""
CHAIN=""
CLAIM_THR=""
DELEGATE_THR=""
REMAINDER=""
DENOM=""
NODE='http://localhost:26657'
KEY_NAME=""
ADDR=""
OPER=""
PASS=""

REWARDS=$($CLI query distribution rewards $ADDR $OPER --node $NODE --output json | jq -r '.rewards[0].amount')
COMMISSION=$($CLI query distribution commission $OPER --node $NODE --output json | jq -r '.commission[0].amount')

AMOUNT=$((${REWARDS%.*}+${COMMISSION%.*}))

if (($AMOUNT > $CLAIM_THR)); then
    echo -e $PASS | $($CLI tx distribution withdraw-rewards $OPER --commission --from $KEY_NAME --chain-id $CHAIN --fees 200$DENOM --yes --node $NODE)
    sleep 10
fi

BAL=$($CLI query bank balances $ADDR --node $NODE --output json | jq -r '.balances[0].amount')
BALANCE=${BAL%.*}

if (($BALANCE > $DELEGATE_THR)); then
    SUM=$((BALANCE-REMAINDER))$DENOM
    echo -e $PASS | $($CLI tx staking delegate $OPER $SUM --chain-id=$CHAIN --from $KEY_NAME --fees 200$DENOM --yes --node $NODE)
fi
