---
title: "Contract Obelisk"
draft: true
---
Deployer: SP1TA84JTP4YRFWBK7PYKBA33H3YB60XP654RAR7M

SIP-009: false

SIP-010: false

Functions:
{"name":"get-balance-of","access":"public","args":[{"name":"user","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-decimals","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-name","access":"public","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":7}},"error":"none"}}}}, {"name":"get-symbol","access":"public","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":3}},"error":"none"}}}}, {"name":"get-token-uri","access":"public","args":[],"outputs":{"type":{"response":{"ok":{"optional":"none"},"error":"none"}}}}, {"name":"transfer","access":"public","args":[{"name":"to","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
