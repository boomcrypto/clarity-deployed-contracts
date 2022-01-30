---
title: "Contract bitcowboys"
draft: true
---
Deployer: SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG

SIP-009: true

SIP-010: false

Functions:
{"name":"is-owner","access":"private","args":[{"name":"index","type":"uint128"},{"name":"user","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"mint-next","access":"private","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"burn","access":"public","args":[{"name":"index","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"freeze-metadata","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint-three","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-cost-per-mint","access":"public","args":[{"name":"value","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-creator-address","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-token-uri","access":"public","args":[{"name":"value","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"index","type":"uint128"},{"name":"owner","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer-stx","access":"public","args":[{"name":"address","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-balance","access":"read_only","args":[{"name":"account","type":"principal"}],"outputs":{"type":"uint128"}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"index","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":256}}},"error":"none"}}}}
