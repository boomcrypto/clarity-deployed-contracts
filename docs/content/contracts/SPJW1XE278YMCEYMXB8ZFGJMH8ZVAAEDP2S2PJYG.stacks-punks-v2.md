---
title: "Contract stacks-punks-v2"
draft: true
---
Deployer: SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG

SIP-009: true

SIP-010: false

Functions:
{"name":"is-owner","access":"private","args":[{"name":"index","type":"uint128"},{"name":"user","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"migrate-v1","access":"private","args":[{"name":"random-punk-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"mint-with-id","access":"private","args":[{"name":"random-punk-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"remove-punk","access":"private","args":[{"name":"owner","type":"principal"},{"name":"punk-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"remove-transferred-punk","access":"private","args":[{"name":"punk-id","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"set-next-rotation","access":"private","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"burn","access":"public","args":[{"name":"index","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-v1-punks","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-owner","access":"public","args":[{"name":"index","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-punks-by-owner","access":"public","args":[{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":{"list":{"type":"uint128","length":2500}},"error":"none"}}}}, {"name":"mint","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-cost-per-mint","access":"public","args":[{"name":"value","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-token-punk-uri","access":"public","args":[{"name":"value","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-token-uri","access":"public","args":[{"name":"value","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"index","type":"uint128"},{"name":"owner","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer-stx","access":"public","args":[{"name":"address","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-punks-entry-by-owner","access":"read_only","args":[{"name":"owner","type":"principal"}],"outputs":{"type":{"tuple":[{"name":"ids","type":{"list":{"type":"uint128","length":2500}}}]}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":256}}},"error":"none"}}}}, {"name":"stx-balance","access":"read_only","args":[],"outputs":{"type":"uint128"}}, {"name":"stx-balance-of","access":"read_only","args":[{"name":"address","type":"principal"}],"outputs":{"type":"uint128"}}