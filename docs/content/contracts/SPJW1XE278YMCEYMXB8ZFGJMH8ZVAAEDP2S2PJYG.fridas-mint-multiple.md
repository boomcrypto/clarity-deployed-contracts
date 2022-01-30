---
title: "Contract fridas-mint-multiple"
draft: true
---
Deployer: SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG

SIP-009: false

SIP-010: false

Functions:
{"name":"burn-frida","access":"public","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"burn-fridas","access":"public","args":[{"name":"ids","type":{"list":{"type":"uint128","length":200}}}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"mint-five","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint-three","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
