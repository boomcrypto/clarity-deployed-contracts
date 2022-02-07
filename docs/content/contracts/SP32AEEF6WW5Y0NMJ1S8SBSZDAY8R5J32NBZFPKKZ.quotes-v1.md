---
title: "Contract quotes-v1"
draft: true
---
Deployer: SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ

SIP-009: true

SIP-010: false

Functions:
{"name":"add-quote","access":"public","args":[{"name":"quote-text","type":{"string-utf8":{"length":2048}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-quote-by-id","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-utf8":{"length":2048}}},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"none"},"error":"none"}}}}
