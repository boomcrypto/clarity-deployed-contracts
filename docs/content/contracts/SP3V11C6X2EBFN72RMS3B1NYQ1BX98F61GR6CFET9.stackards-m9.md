---
title: "Contract stackards-m9"
draft: true
---
Deployer: SP3V11C6X2EBFN72RMS3B1NYQ1BX98F61GR6CFET9

SIP-009: true

SIP-010: false

Functions:
{"name":"mint","access":"public","args":[{"name":"new-owner","type":"principal"},{"name":"seed","type":{"string-ascii":{"length":64}}}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-caller","access":"read_only","args":[],"outputs":{"type":"principal"}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-mint-price","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-seed","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":64}}},"error":"none"}}}}, {"name":"get-sender","access":"read_only","args":[],"outputs":{"type":"principal"}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":49}}},"error":"none"}}}}, {"name":"mint-check","access":"read_only","args":[],"outputs":{"type":{"tuple":[{"name":"amount","type":"uint128"},{"name":"evt","type":{"string-ascii":{"length":10}}},{"name":"last","type":"uint128"},{"name":"owner","type":"principal"}]}}}
