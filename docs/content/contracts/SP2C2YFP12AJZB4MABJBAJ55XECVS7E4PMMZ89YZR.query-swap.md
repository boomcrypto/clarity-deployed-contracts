---
title: "Contract query-swap"
draft: true
---
Deployer: SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR

SIP-009: false

SIP-010: false

Functions:
{"name":"get-pair-details-at-block","access":"read_only","args":[{"name":"block","type":"uint128"},{"name":"token-x","type":"principal"},{"name":"token-y","type":"principal"}],"outputs":{"type":{"response":{"ok":{"optional":{"tuple":[{"name":"balance-x","type":"uint128"},{"name":"balance-y","type":"uint128"},{"name":"fee-balance-x","type":"uint128"},{"name":"fee-balance-y","type":"uint128"},{"name":"fee-to-address","type":{"optional":"principal"}},{"name":"name","type":{"string-ascii":{"length":32}}},{"name":"shares-total","type":"uint128"},{"name":"swap-token","type":"principal"}]}},"error":{"response":{"ok":"none","error":"uint128"}}}}}}
