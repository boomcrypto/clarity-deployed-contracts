---
title: "Contract arkadiko-stake-lp-rewards-2"
draft: true
---
Deployer: SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR

SIP-009: false

SIP-010: false

Functions:
{"name":"claim-rewards-v1","access":"private","args":[],"outputs":{"type":"uint128"}}, {"name":"stake-rewards-v1","access":"private","args":[],"outputs":{"type":"uint128"}}, {"name":"claim-rewards","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"stake-rewards","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"toggle-claim-shutdown","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-diko-by-wallet","access":"read_only","args":[{"name":"wallet","type":"principal"}],"outputs":{"type":"uint128"}}, {"name":"get-total-diko-by-wallet","access":"read_only","args":[{"name":"wallet","type":"principal"}],"outputs":{"type":"uint128"}}
