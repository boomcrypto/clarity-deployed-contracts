---
title: "Contract age002-emergency-proposals"
draft: true
---
Deployer: SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9

SIP-009: false

SIP-010: false

Functions:
{"name":"callback","access":"public","args":[{"name":"sender","type":"principal"},{"name":"memo","type":{"buffer":{"length":34}}}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"emergency-propose","access":"public","args":[{"name":"proposal","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"is-dao-or-extension","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-emergency-proposal-duration","access":"public","args":[{"name":"duration","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-emergency-team-member","access":"public","args":[{"name":"who","type":"principal"},{"name":"member","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-emergency-team-sunset-height","access":"public","args":[{"name":"height","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"is-emergency-team-member","access":"read_only","args":[{"name":"who","type":"principal"}],"outputs":{"type":"bool"}}
