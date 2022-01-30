---
title: "Contract megapont-ape-club-mint"
draft: true
---
Deployer: SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335

SIP-009: false

SIP-010: false

Functions:
{"name":"mintpass-mint","access":"private","args":[{"name":"new-owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"public-mint","access":"private","args":[{"name":"new-owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-five","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-four","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-three","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-two","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"flip-mintpass-sale","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"flip-sale","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-presale-balance","access":"read_only","args":[{"name":"account","type":"principal"}],"outputs":{"type":"uint128"}}
