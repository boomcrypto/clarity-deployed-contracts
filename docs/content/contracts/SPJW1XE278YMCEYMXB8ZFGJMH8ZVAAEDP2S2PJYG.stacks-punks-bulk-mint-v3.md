---
title: "Contract stacks-punks-bulk-mint-v3"
draft: true
---
Deployer: SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG

SIP-009: false

SIP-010: false

Functions:
{"name":"mint","access":"private","args":[{"name":"punk-id","type":"uint128"},{"name":"data","type":{"tuple":[{"name":"count","type":"uint128"}]}}],"outputs":{"type":{"tuple":[{"name":"count","type":"uint128"}]}}}, {"name":"bulk-mint","access":"public","args":[{"name":"punk-ids","type":{"list":{"type":"uint128","length":20}}}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"count","type":"uint128"}]},"error":"none"}}}}
