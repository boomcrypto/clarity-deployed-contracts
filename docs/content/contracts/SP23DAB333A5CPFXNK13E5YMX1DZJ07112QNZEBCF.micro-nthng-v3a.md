---
title: "Contract micro-nthng-v3a"
draft: true
---
Deployer: SP23DAB333A5CPFXNK13E5YMX1DZJ07112QNZEBCF

SIP-009: false

SIP-010: false

Functions:
{"name":"mint!","access":"private","args":[{"name":"account","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"to","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-total-supply","access":"read_only","args":[],"outputs":{"type":"uint128"}}
