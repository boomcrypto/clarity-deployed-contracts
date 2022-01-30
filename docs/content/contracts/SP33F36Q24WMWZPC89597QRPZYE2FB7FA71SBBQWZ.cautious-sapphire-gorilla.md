---
title: "Contract cautious-sapphire-gorilla"
draft: true
---
Deployer: SP33F36Q24WMWZPC89597QRPZYE2FB7FA71SBBQWZ

SIP-009: true

SIP-010: false

Functions:
{"name":"err-nft-mint","access":"private","args":[{"name":"code","type":"uint128"}],"outputs":{"type":{"response":{"ok":"none","error":"uint128"}}}}, {"name":"err-nft-transfer","access":"private","args":[{"name":"code","type":"uint128"}],"outputs":{"type":{"response":{"ok":"none","error":"uint128"}}}}, {"name":"get-time","access":"private","args":[],"outputs":{"type":"uint128"}}, {"name":"create-hai","access":"public","args":[{"name":"name","type":{"string-ascii":{"length":20}}},{"name":"target-aip","type":{"string-ascii":{"length":20}}},{"name":"num-timeblocks","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"hai-id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-errstr","access":"read_only","args":[{"name":"code","type":"uint128"}],"outputs":{"type":{"string-ascii":{"length":32}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-meta-data","access":"read_only","args":[{"name":"hai-id","type":"uint128"}],"outputs":{"type":{"optional":{"tuple":[{"name":"date-of-birth","type":"uint128"},{"name":"name","type":{"string-ascii":{"length":20}}},{"name":"num-timeblocks","type":"uint128"},{"name":"target-aip","type":{"string-ascii":{"length":20}}}]}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"hai-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"hai-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"none"},"error":"none"}}}}
