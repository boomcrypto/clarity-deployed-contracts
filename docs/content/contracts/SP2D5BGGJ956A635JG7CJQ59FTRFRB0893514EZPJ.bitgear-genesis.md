---
title: "Contract bitgear-genesis"
draft: true
---
Deployer: SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ

SIP-009: true

SIP-010: false

Functions:
{"name":"is-owner","access":"private","args":[{"name":"index","type":"uint128"},{"name":"user","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"mint","access":"private","args":[{"name":"index","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"bestow","access":"public","args":[{"name":"new-dm","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim","access":"public","args":[{"name":"index","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"freeze-metadata","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"grant","access":"public","args":[{"name":"index","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"lock-mint","access":"public","args":[{"name":"locked","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"reward","access":"public","args":[{"name":"index","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-base-uri","access":"public","args":[{"name":"new-base-uri","type":{"string-ascii":{"length":90}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"index","type":"uint128"},{"name":"owner","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-gear-remaining","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"index","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":99}}},"error":"none"}}}}
