---
title: "Contract age003-emergency-execute"
draft: true
---
Deployer: SP1YK770QXSJY7G1SJD664CQKQGWM2N25DBFTMBMB

SIP-009: false

SIP-010: false

Functions:
{"name":"callback","access":"public","args":[{"name":"sender","type":"principal"},{"name":"memo","type":{"buffer":{"length":34}}}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"executive-action","access":"public","args":[{"name":"proposal","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"is-dao-or-extension","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-executive-team-member","access":"public","args":[{"name":"who","type":"principal"},{"name":"member","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-executive-team-sunset-height","access":"public","args":[{"name":"height","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-signals-required","access":"public","args":[{"name":"new-requirement","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-signals","access":"read_only","args":[{"name":"proposal","type":"principal"}],"outputs":{"type":"uint128"}}, {"name":"get-signals-required","access":"read_only","args":[],"outputs":{"type":"uint128"}}, {"name":"has-signalled","access":"read_only","args":[{"name":"proposal","type":"principal"},{"name":"who","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"is-executive-team-member","access":"read_only","args":[{"name":"who","type":"principal"}],"outputs":{"type":"bool"}}
