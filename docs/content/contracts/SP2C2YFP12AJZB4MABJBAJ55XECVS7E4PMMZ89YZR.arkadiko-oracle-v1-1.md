---
title: "Contract arkadiko-oracle-v1-1"
draft: true
---
Deployer: SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR

SIP-009: false

SIP-010: false

Functions:
{"name":"fetch-price","access":"public","args":[{"name":"token","type":{"string-ascii":{"length":12}}}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"decimals","type":"uint128"},{"name":"last-block","type":"uint128"},{"name":"last-price","type":"uint128"}]},"error":"none"}}}}, {"name":"set-oracle-owner","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"update-price","access":"public","args":[{"name":"token","type":{"string-ascii":{"length":12}}},{"name":"price","type":"uint128"},{"name":"decimals","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"get-price","access":"read_only","args":[{"name":"token","type":{"string-ascii":{"length":12}}}],"outputs":{"type":{"tuple":[{"name":"decimals","type":"uint128"},{"name":"last-block","type":"uint128"},{"name":"last-price","type":"uint128"}]}}}
