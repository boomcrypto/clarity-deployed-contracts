---
title: "Contract stacks-art-bulk-remove-bid"
draft: true
---
Deployer: SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG

SIP-009: false

SIP-010: false

Functions:
{"name":"admin-remove-bid","access":"public","args":[{"name":"bid","type":{"tuple":[{"name":"collection-id","type":"uint128"},{"name":"item-id","type":"uint128"}]}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"bulk-remove-bid","access":"public","args":[{"name":"ids","type":{"list":{"type":{"tuple":[{"name":"collection-id","type":"uint128"},{"name":"item-id","type":"uint128"}]},"length":100}}}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}
