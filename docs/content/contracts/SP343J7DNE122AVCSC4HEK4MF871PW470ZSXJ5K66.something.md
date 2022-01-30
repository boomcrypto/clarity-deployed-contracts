---
title: "Contract something"
draft: true
---
Deployer: SP343J7DNE122AVCSC4HEK4MF871PW470ZSXJ5K66

SIP-009: false

SIP-010: false

Functions:
{"name":"mint!","access":"private","args":[{"name":"account","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"to","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-total-supply","access":"read_only","args":[],"outputs":{"type":"uint128"}}
