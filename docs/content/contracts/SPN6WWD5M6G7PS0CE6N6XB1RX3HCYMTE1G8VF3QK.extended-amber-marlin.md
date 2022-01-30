---
title: "Contract extended-amber-marlin"
draft: true
---
Deployer: SPN6WWD5M6G7PS0CE6N6XB1RX3HCYMTE1G8VF3QK

SIP-009: false

SIP-010: false

Functions:
{"name":"get-balances","access":"private","args":[{"name":"a","type":"trait_reference"},{"name":"b","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":{"list":{"type":"uint128","length":2}},"error":"uint128"}}}}, {"name":"get-sell-amount","access":"private","args":[{"name":"new-diko","type":"uint128"},{"name":"diko-balance","type":"uint128"},{"name":"max-sell","type":{"optional":"uint128"}}],"outputs":{"type":"uint128"}}, {"name":"decrement-one","access":"public","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"increment","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"increment-n","access":"public","args":[{"name":"max-sell","type":{"optional":"uint128"}}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"staked","type":"uint128"}]},"error":"uint128"}}}}, {"name":"increment-one","access":"public","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"calculate-swap-in","access":"read_only","args":[{"name":"reserves","type":"uint128"},{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}
