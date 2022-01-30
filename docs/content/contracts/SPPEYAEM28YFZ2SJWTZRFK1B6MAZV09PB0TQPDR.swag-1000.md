---
title: "Contract swag-1000"
draft: true
---
Deployer: SPPEYAEM28YFZ2SJWTZRFK1B6MAZV09PB0TQPDR

SIP-009: true

SIP-010: false

Functions:
{"name":"balance-of","access":"private","args":[{"name":"account","type":"principal"}],"outputs":{"type":"uint128"}}, {"name":"mint","access":"private","args":[{"name":"new-owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"nft-mint-err","access":"private","args":[{"name":"code","type":"uint128"}],"outputs":{"type":{"response":{"ok":"none","error":"uint128"}}}}, {"name":"nft-transfer-err","access":"private","args":[{"name":"code","type":"uint128"}],"outputs":{"type":{"response":{"ok":"none","error":"uint128"}}}}, {"name":"claim-swag","access":"public","args":[],"outputs":{"type":{"response":{"ok":{"response":{"ok":"bool","error":"uint128"}},"error":{"response":{"ok":"none","error":"uint128"}}}}}}, {"name":"transfer","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-meta","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"tuple":[{"name":"mime-type","type":{"string-ascii":{"length":10}}},{"name":"name","type":{"string-ascii":{"length":20}}},{"name":"uri","type":{"string-ascii":{"length":83}}}]}},"error":"none"}}}}, {"name":"get-nft-meta","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"optional":{"tuple":[{"name":"mime-type","type":{"string-ascii":{"length":10}}},{"name":"name","type":{"string-ascii":{"length":20}}},{"name":"uri","type":{"string-ascii":{"length":83}}}]}},"error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":23}}},"error":"none"}}}}
