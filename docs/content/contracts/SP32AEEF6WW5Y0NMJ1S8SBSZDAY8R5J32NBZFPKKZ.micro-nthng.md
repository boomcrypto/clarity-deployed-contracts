---
title: "Contract micro-nthng"
draft: true
---
Deployer: SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ

SIP-009: false

SIP-010: false

Functions:
{"name":"mint!","access":"private","args":[{"name":"account","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"to","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-total-supply","access":"read_only","args":[],"outputs":{"type":"uint128"}}
