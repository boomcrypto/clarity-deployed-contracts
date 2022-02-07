---
title: "Contract shit"
draft: true
---
Deployer: SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ

SIP-009: false

SIP-010: false

Functions:
{"name":"burn","access":"private","args":[{"name":"stx-to-burn","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"increase-supply","access":"private","args":[{"name":"increment","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"is-creator","access":"private","args":[],"outputs":{"type":"bool"}}, {"name":"mint-shit","access":"private","args":[{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"give-a-shit","access":"public","args":[{"name":"shits-to-give","type":"uint128"},{"name":"shits-given-to","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-token-uri","access":"public","args":[{"name":"uri","type":{"string-utf8":{"length":265}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"take-a-shit","access":"public","args":[{"name":"how-big-a-shit","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"from","type":"principal"},{"name":"to","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-balance-of","access":"read_only","args":[{"name":"user","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-decimals","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-name","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":4}},"error":"none"}}}}, {"name":"get-symbol","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":3}},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-utf8":{"length":265}},"error":"none"}}}}, {"name":"get-total-supply","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}
