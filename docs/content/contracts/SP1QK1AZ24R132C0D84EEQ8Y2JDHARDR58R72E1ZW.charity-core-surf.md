---
title: "Contract charity-core-surf"
draft: true
---
Deployer: SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW

SIP-009: true

SIP-010: false

Functions:
{"name":"is-approved-with-owner","access":"private","args":[{"name":"id","type":"uint128"},{"name":"operator","type":"principal"},{"name":"owner","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"mint","access":"public","args":[{"name":"bb-id","type":"uint128"},{"name":"stacker","type":"principal"},{"name":"amount-ustx","type":"uint128"},{"name":"pox-addr","type":{"tuple":[{"name":"hashbytes","type":{"buffer":{"length":20}}},{"name":"version","type":{"buffer":{"length":1}}}]}},{"name":"locking-period","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"set-approved","access":"public","args":[{"name":"id","type":"uint128"},{"name":"operator","type":"principal"},{"name":"approved","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"set-approved-all","access":"public","args":[{"name":"operator","type":"principal"},{"name":"approved","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"set-boombox-admin","access":"public","args":[{"name":"admin","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-boombox-id","access":"public","args":[{"name":"bb-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer-memo","access":"public","args":[{"name":"id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"},{"name":"memo","type":{"buffer":{"length":34}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-owner-at-block","access":"read_only","args":[{"name":"id","type":"uint128"},{"name":"stacks-tip","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"uint128"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":72}}},"error":"none"}}}}, {"name":"is-approved","access":"read_only","args":[{"name":"id","type":"uint128"},{"name":"operator","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}