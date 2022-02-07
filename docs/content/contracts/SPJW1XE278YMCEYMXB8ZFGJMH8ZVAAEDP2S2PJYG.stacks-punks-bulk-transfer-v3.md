---
title: "Contract stacks-punks-bulk-transfer-v3"
draft: true
---
Deployer: SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG

SIP-009: false

SIP-010: false

Functions:
{"name":"transfer","access":"private","args":[{"name":"punk-id","type":"uint128"},{"name":"data","type":{"tuple":[{"name":"address","type":"principal"},{"name":"count","type":"uint128"}]}}],"outputs":{"type":{"tuple":[{"name":"address","type":"principal"},{"name":"count","type":"uint128"}]}}}, {"name":"bulk-transfer","access":"public","args":[{"name":"punk-ids","type":{"list":{"type":"uint128","length":10}}},{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"address","type":"principal"},{"name":"count","type":"uint128"}]},"error":"none"}}}}
