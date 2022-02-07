---
title: "Contract doge-punks-v1"
draft: true
---
Deployer: SP1FV3SN48RVHHQF7456N62G5NW768B8YM44M3AV1

SIP-009: false

SIP-010: false

Functions:
{"name":"mint","access":"private","args":[{"name":"new-owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-base-uri","access":"public","args":[{"name":"new-uri","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-token-uri","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"new-uri","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"toggle","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-contract-active-status","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":2048}}},"error":"none"}}}}, {"name":"uint-to-string","access":"read_only","args":[{"name":"value","type":"uint128"}],"outputs":{"type":{"string-ascii":{"length":40}}}}, {"name":"uint-to-string-clojure","access":"read_only","args":[{"name":"i","type":"bool"},{"name":"data","type":{"tuple":[{"name":"return","type":{"string-ascii":{"length":40}}},{"name":"value","type":"uint128"}]}}],"outputs":{"type":{"tuple":[{"name":"return","type":{"string-ascii":{"length":40}}},{"name":"value","type":"uint128"}]}}}
