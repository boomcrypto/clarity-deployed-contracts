---
title: "Contract shitty-coin"
draft: true
---
Deployer: SP113MYNN52BC76GWP8P9PYFEP7XWJP6S5Y7ZE549

SIP-009: false

SIP-010: false

Functions:
{"name":"mint!","access":"private","args":[{"name":"account","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"balance-of","access":"public","args":[{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"transfer","access":"public","args":[{"name":"to","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-decimals","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-name","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":6}},"error":"none"}}}}, {"name":"get-symbol","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":4}},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":28}},"error":"none"}}}}, {"name":"get-total-supply","access":"read_only","args":[],"outputs":{"type":"uint128"}}
