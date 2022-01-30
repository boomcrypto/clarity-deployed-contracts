---
title: "Contract plaid-thing-token-v0a"
draft: true
---
Deployer: SP23DAB333A5CPFXNK13E5YMX1DZJ07112QNZEBCF

SIP-009: false

SIP-010: false

Functions:
{"name":"burn","access":"public","args":[{"name":"recipient","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint","access":"public","args":[{"name":"recipient","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-balance-of","access":"read_only","args":[{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-data","access":"read_only","args":[{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"balance","type":"uint128"},{"name":"decimals","type":"uint128"},{"name":"name","type":{"string-ascii":{"length":17}}},{"name":"supply","type":"uint128"},{"name":"symbol","type":{"string-ascii":{"length":17}}},{"name":"uri","type":{"optional":{"string-utf8":{"length":51}}}}]},"error":"none"}}}}, {"name":"get-decimals","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-name","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":17}},"error":"none"}}}}, {"name":"get-symbol","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":17}},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"optional":{"string-utf8":{"length":51}}},"error":"none"}}}}, {"name":"get-total-supply","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}
