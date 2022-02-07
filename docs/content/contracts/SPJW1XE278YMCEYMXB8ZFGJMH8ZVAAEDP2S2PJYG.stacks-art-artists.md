---
title: "Contract stacks-art-artists"
draft: true
---
Deployer: SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG

SIP-009: false

SIP-010: false

Functions:
{"name":"register","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"set-contract-owner","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"verify-artist","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-artist","access":"read_only","args":[{"name":"artist","type":"principal"}],"outputs":{"type":{"tuple":[{"name":"id","type":"uint128"},{"name":"verified","type":"bool"}]}}}, {"name":"is-verified-artist","access":"read_only","args":[{"name":"address","type":"principal"}],"outputs":{"type":"bool"}}
