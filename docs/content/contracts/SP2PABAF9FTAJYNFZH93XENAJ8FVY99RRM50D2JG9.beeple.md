---
title: "Contract beeple"
draft: true
---
Deployer: SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9

SIP-009: true

SIP-010: false

Functions:
{"name":"nft-transfer-err","access":"private","args":[{"name":"code","type":"uint128"}],"outputs":{"type":{"response":{"ok":"none","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-errstr","access":"read_only","args":[{"name":"code","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":23}},"error":"none"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-meta","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"tuple":[{"name":"mime-type","type":{"string-ascii":{"length":10}}},{"name":"name","type":{"string-ascii":{"length":30}}},{"name":"uri","type":{"string-ascii":{"length":87}}}]}},"error":"none"}}}}, {"name":"get-nft-meta","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"optional":{"tuple":[{"name":"mime-type","type":{"string-ascii":{"length":10}}},{"name":"name","type":{"string-ascii":{"length":6}}},{"name":"uri","type":{"string-ascii":{"length":87}}}]}},"error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":58}}},"error":"none"}}}}
