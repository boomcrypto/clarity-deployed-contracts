---
title: "Contract MillieCoin"
draft: true
---
Deployer: SPF1S6WJHKPB873EET97946B24G78NNDXQ22PYJ4

SIP-009: false

SIP-010: false

Functions:
{"name":"nft-transfer-err","access":"private","args":[{"name":"code","type":"uint128"}],"outputs":{"type":{"response":{"ok":"none","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"from","type":"principal"},{"name":"to","type":"principal"},{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":67}}},"error":"none"}}}}
