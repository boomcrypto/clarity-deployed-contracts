---
title: "Contract megapont-robot-expansion-mint"
draft: true
---
Deployer: SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335

SIP-009: false

SIP-010: false

Functions:
{"name":"freebie-mint","access":"private","args":[{"name":"new-owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint-component","access":"private","args":[{"name":"new-owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint-freebie-component","access":"private","args":[{"name":"new-owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint-robot","access":"private","args":[{"name":"new-owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-freebie","access":"public","args":[{"name":"ape","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"ape-has-claimed","access":"read_only","args":[{"name":"ape","type":"uint128"}],"outputs":{"type":"bool"}}
