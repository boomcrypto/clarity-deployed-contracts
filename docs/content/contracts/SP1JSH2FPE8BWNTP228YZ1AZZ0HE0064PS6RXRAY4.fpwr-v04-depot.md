---
title: "Contract fpwr-v04-depot"
draft: true
---
Deployer: SP1JSH2FPE8BWNTP228YZ1AZZ0HE0064PS6RXRAY4

SIP-009: false

SIP-010: false

Functions:
{"name":"add-reward","access":"private","args":[{"name":"details","type":{"tuple":[{"name":"amount","type":"uint128"},{"name":"user","type":"principal"}]}}],"outputs":{"type":"bool"}}, {"name":"add-rewards","access":"public","args":[{"name":"rewards","type":{"list":{"type":{"tuple":[{"name":"amount","type":"uint128"},{"name":"user","type":"principal"}]},"length":200}}}],"outputs":{"type":{"response":{"ok":{"list":{"type":"bool","length":200}},"error":"uint128"}}}}, {"name":"claim","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"update-reward-admin","access":"public","args":[{"name":"new-admin","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-balance","access":"read_only","args":[{"name":"user","type":"principal"}],"outputs":{"type":{"response":{"ok":{"optional":"uint128"},"error":"none"}}}}, {"name":"get-depot-info","access":"read_only","args":[],"outputs":{"type":{"tuple":[{"name":"tokens","type":{"response":{"ok":"uint128","error":"none"}}},{"name":"total-claimed","type":"uint128"},{"name":"total-rewards","type":"uint128"}]}}}
