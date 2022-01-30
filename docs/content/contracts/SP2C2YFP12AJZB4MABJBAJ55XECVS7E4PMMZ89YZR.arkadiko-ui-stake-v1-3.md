---
title: "Contract arkadiko-ui-stake-v1-3"
draft: true
---
Deployer: SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR

SIP-009: false

SIP-010: false

Functions:
{"name":"get-stake-amounts","access":"public","args":[{"name":"user","type":"principal"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"stake-amount-diko-usda","type":"uint128"},{"name":"stake-amount-wstx-diko","type":"uint128"},{"name":"stake-amount-wstx-usda","type":"uint128"}]},"error":"none"}}}}, {"name":"get-stake-totals","access":"public","args":[],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"stake-total-diko","type":"uint128"},{"name":"stake-total-diko-usda","type":"uint128"},{"name":"stake-total-wstx-diko","type":"uint128"},{"name":"stake-total-wstx-usda","type":"uint128"}]},"error":"none"}}}}
