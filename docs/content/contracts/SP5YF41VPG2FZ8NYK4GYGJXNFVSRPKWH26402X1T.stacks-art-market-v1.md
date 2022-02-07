---
title: "Contract stacks-art-market-v1"
draft: true
---
Deployer: SP5YF41VPG2FZ8NYK4GYGJXNFVSRPKWH26402X1T

SIP-009: false

SIP-010: false

Functions:
{"name":"bid","access":"public","args":[{"name":"item-id","type":"uint128"},{"name":"price","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"reset","access":"public","args":[{"name":"item-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"unlist-item","access":"public","args":[{"name":"item-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"withdraw","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
