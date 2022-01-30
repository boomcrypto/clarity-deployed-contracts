---
title: "Contract fari-token-mn"
draft: true
---
Deployer: SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA

SIP-009: false

SIP-010: true

Functions:
{"name":"execute-mint","access":"private","args":[{"name":"amount","type":"uint128"},{"name":"account","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"validate-mint","access":"private","args":[{"name":"amount","type":"uint128"},{"name":"account","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-token-uri","access":"public","args":[],"outputs":{"type":{"response":{"ok":{"optional":{"string-utf8":{"length":26}}},"error":"none"}}}}, {"name":"mint","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"account","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"},{"name":"memo","type":{"optional":{"buffer":{"length":34}}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-balance","access":"read_only","args":[{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-decimals","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-name","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":4}},"error":"none"}}}}, {"name":"get-symbol","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":4}},"error":"none"}}}}, {"name":"get-total-supply","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}
