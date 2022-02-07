---
title: "Contract beeple"
draft: true
---
Deployer: SP1JSH2FPE8BWNTP228YZ1AZZ0HE0064PS6RXRAY4

SIP-009: false

SIP-010: false

Functions:
{"name":"transfer","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":{"tuple":[{"name":"code","type":"uint128"},{"name":"kind","type":{"string-ascii":{"length":19}}}]}}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-meta","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"tuple":[{"name":"mime-type","type":{"string-ascii":{"length":10}}},{"name":"name","type":{"string-ascii":{"length":30}}},{"name":"uri","type":{"string-ascii":{"length":87}}}]}},"error":"none"}}}}, {"name":"get-nft-meta","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"optional":{"tuple":[{"name":"mime-type","type":{"string-ascii":{"length":10}}},{"name":"name","type":{"string-ascii":{"length":6}}},{"name":"uri","type":{"string-ascii":{"length":87}}}]}},"error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":58}}},"error":"none"}}}}
