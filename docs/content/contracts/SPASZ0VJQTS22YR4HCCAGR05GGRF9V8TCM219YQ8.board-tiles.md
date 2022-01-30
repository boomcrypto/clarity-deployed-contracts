---
title: "Contract board-tiles"
draft: true
---
Deployer: SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8

SIP-009: true

SIP-010: false

Functions:
{"name":"add-token-to-user-list","access":"private","args":[{"name":"user","type":"principal"},{"name":"token-id","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"remove-token-from-user-list","access":"private","args":[{"name":"user","type":"principal"},{"name":"token-id","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"remove-transfered-token","access":"private","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"main-burn","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"main-mint","access":"public","args":[{"name":"new-owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-contract-owner","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-token-uri","access":"public","args":[{"name":"new-uri","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"user-burn","access":"public","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":256}}},"error":"none"}}}}, {"name":"get-user-tokens","access":"read_only","args":[{"name":"user","type":"principal"}],"outputs":{"type":{"tuple":[{"name":"token-ids","type":{"list":{"type":"uint128","length":5000}}}]}}}
