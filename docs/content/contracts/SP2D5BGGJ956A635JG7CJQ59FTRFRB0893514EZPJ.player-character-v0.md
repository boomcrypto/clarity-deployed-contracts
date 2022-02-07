---
title: "Contract player-character-v0"
draft: true
---
Deployer: SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ

SIP-009: false

SIP-010: false

Functions:
{"name":"is-owner","access":"private","args":[{"name":"collection","type":"trait_reference"},{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"add-collection","access":"public","args":[{"name":"collection","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"bestow","access":"public","args":[{"name":"new-dm","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"remove-collection","access":"public","args":[{"name":"collection","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"roll-character","access":"public","args":[{"name":"character-name","type":{"string-utf8":{"length":16}}},{"name":"collection","type":"trait_reference"},{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-character","access":"read_only","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"avatar","type":"uint128"},{"name":"collection","type":"principal"},{"name":"name","type":{"string-utf8":{"length":16}}}]},"error":"uint128"}}}}, {"name":"get-player-list","access":"read_only","args":[{"name":"collection","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":{"list":{"type":"principal","length":1000}},"error":"uint128"}}}}
