---
title: "Contract duv"
draft: true
---
Deployer: SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M

SIP-009: false

SIP-010: true

Functions:
{"name":"transfer","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"},{"name":"memo","type":{"optional":{"buffer":{"length":34}}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-balance","access":"read_only","args":[{"name":"account","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-decimals","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-name","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":3}},"error":"none"}}}}, {"name":"get-symbol","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":3}},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"optional":{"string-utf8":{"length":38}}},"error":"none"}}}}, {"name":"get-total-supply","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}