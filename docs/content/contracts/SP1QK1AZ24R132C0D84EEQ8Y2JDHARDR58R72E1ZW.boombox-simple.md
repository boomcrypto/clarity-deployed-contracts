---
title: "Contract boombox-simple"
draft: true
---
Deployer: SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW

SIP-009: false

SIP-010: false

Functions:
{"name":"mint","access":"public","args":[{"name":"bb-id","type":"uint128"},{"name":"stacker","type":"principal"},{"name":"amount-ustx","type":"uint128"},{"name":"pox-addr","type":{"tuple":[{"name":"hashbytes","type":{"buffer":{"length":20}}},{"name":"version","type":{"buffer":{"length":1}}}]}},{"name":"locking-period","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"set-boombox-id","access":"public","args":[{"name":"bb-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-owner-at-block","access":"read_only","args":[{"name":"id","type":"uint128"},{"name":"stacks-tip","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"uint128"}}}}
