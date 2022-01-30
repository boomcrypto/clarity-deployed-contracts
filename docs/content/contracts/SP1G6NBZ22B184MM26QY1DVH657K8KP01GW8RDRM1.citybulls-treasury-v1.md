---
title: "Contract citybulls-treasury-v1"
draft: true
---
Deployer: SP1G6NBZ22B184MM26QY1DVH657K8KP01GW8RDRM1

SIP-009: false

SIP-010: false

Functions:
{"name":"deposit-ft","access":"public","args":[{"name":"ft","type":"trait_reference"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"deposit-nft","access":"public","args":[{"name":"nft","type":"trait_reference"},{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"deposit-stx","access":"public","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"move-ft","access":"public","args":[{"name":"ft","type":"trait_reference"},{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"move-nft","access":"public","args":[{"name":"nft","type":"trait_reference"},{"name":"id","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"move-stx","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
