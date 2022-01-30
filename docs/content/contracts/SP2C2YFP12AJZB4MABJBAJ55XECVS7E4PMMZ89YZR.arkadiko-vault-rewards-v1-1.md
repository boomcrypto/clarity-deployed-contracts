---
title: "Contract arkadiko-vault-rewards-v1-1"
draft: true
---
Deployer: SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR

SIP-009: false

SIP-010: false

Functions:
{"name":"claim-pending-rewards-for","access":"private","args":[{"name":"user","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"get-rewards-per-block","access":"private","args":[],"outputs":{"type":"uint128"}}, {"name":"add-collateral","access":"public","args":[{"name":"collateral","type":"uint128"},{"name":"user","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-pending-rewards","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"claim-pending-rewards-liquidated-vault","access":"public","args":[{"name":"user","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"increase-cumm-reward-per-collateral","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"remove-collateral","access":"public","args":[{"name":"collateral","type":"uint128"},{"name":"user","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"toggle-vault-rewards-shutdown","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"calculate-cumm-reward-per-collateral","access":"read_only","args":[],"outputs":{"type":"uint128"}}, {"name":"get-collateral-amount-of","access":"read_only","args":[{"name":"user","type":"principal"}],"outputs":{"type":"uint128"}}, {"name":"get-collateral-of","access":"read_only","args":[{"name":"user","type":"principal"}],"outputs":{"type":{"tuple":[{"name":"collateral","type":"uint128"},{"name":"cumm-reward-per-collateral","type":"uint128"}]}}}, {"name":"get-cumm-reward-per-collateral-of","access":"read_only","args":[{"name":"user","type":"principal"}],"outputs":{"type":"uint128"}}, {"name":"get-pending-rewards","access":"read_only","args":[{"name":"user","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}
