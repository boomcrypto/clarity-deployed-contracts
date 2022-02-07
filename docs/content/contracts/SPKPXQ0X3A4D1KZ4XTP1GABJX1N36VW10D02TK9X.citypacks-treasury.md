---
title: "Contract citypacks-treasury"
draft: true
---
Deployer: SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X

SIP-009: false

SIP-010: false

Functions:
{"name":"is-from-dao","access":"private","args":[],"outputs":{"type":"bool"}}, {"name":"deposit-ft","access":"public","args":[{"name":"ft","type":"trait_reference"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"deposit-nft","access":"public","args":[{"name":"nft","type":"trait_reference"},{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"deposit-stx","access":"public","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"move-ft","access":"public","args":[{"name":"ft","type":"trait_reference"},{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"move-nft","access":"public","args":[{"name":"nft","type":"trait_reference"},{"name":"id","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"move-stx","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
