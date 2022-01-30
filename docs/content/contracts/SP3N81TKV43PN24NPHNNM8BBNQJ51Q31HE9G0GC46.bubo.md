---
title: "Contract bubo"
draft: true
---
Deployer: SP3N81TKV43PN24NPHNNM8BBNQJ51Q31HE9G0GC46

SIP-009: true

SIP-010: false

Functions:
{"name":"cycle-random-id","access":"private","args":[{"name":"remaining-ids","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"is-owner","access":"private","args":[{"name":"id","type":"uint128"},{"name":"user","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"rand","access":"private","args":[{"name":"byte-idx","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"set-vrf","access":"private","args":[],"outputs":{"type":"bool"}}, {"name":"swap-container","access":"private","args":[{"name":"id","type":"uint128"},{"name":"idx","type":"uint128"},{"name":"ids-remaining","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"burn","access":"public","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint-five","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint-ten","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":53}}},"error":"none"}}}}
