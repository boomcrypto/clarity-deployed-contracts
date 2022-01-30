---
title: "Contract burn-skaters"
draft: true
---
Deployer: SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG

SIP-009: false

SIP-010: false

Functions:
{"name":"burn-bulk","access":"public","args":[{"name":"ids","type":{"list":{"type":"uint128","length":200}}}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"burn-skater","access":"public","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
