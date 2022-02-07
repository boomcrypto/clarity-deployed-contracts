---
title: "Contract hiro-hackathon-winner-2021"
draft: true
---
Deployer: SP1NSRCVAP49EFH0G3D2VXV36G09Y01KSHYW173CV

SIP-009: true

SIP-010: false

Functions:
{"name":"is-owner","access":"private","args":[{"name":"token-id","type":"uint128"},{"name":"user","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"mint","access":"private","args":[{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":{"tuple":[{"name":"code","type":"uint128"}]}}}}}, {"name":"transfer","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-nft-meta","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"hash","type":{"string-ascii":{"length":64}}},{"name":"mime-type","type":{"string-ascii":{"length":10}}},{"name":"name","type":{"string-ascii":{"length":32}}},{"name":"uri","type":{"string-ascii":{"length":93}}}]},"error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":54}}},"error":"none"}}}}
