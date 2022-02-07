---
title: "Contract stackerdao-treasury"
draft: true
---
Deployer: SP2BSV94A650WGZ2YZ5Y8HM93W01NGT4GY0W2BN3P

SIP-009: false

SIP-010: false

Functions:
{"name":"is-from-dao","access":"private","args":[],"outputs":{"type":"bool"}}, {"name":"deposit-ft","access":"public","args":[{"name":"ft","type":"trait_reference"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"deposit-nft","access":"public","args":[{"name":"nft","type":"trait_reference"},{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"deposit-stx","access":"public","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"move-ft","access":"public","args":[{"name":"ft","type":"trait_reference"},{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"move-nft","access":"public","args":[{"name":"nft","type":"trait_reference"},{"name":"id","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"move-stx","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
