---
title: "Contract multi-swap"
draft: true
---
Deployer: SPCAQ4RCYJ30BYKJ9Z6BRGS3169PWZNN89NH4MCS

SIP-009: false

SIP-010: false

Functions:
{"name":"arkadiko-diko-usda-x-y","access":"private","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"arkadiko-diko-usda-y-x","access":"private","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"arkadiko-stx-diko-x-y","access":"private","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"arkadiko-stx-diko-y-x","access":"private","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"arkadiko-stx-usda-x-y","access":"private","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"arkadiko-stx-usda-y-x","access":"private","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"magic","access":"private","args":[{"name":"swapId","type":"uint128"},{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"stackswap-stx-diko-x-y","access":"private","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"stackswap-stx-diko-y-x","access":"private","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"stackswap-stx-usda-x-y","access":"private","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"stackswap-stx-usda-y-x","access":"private","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"swap-x-y","access":"private","args":[{"name":"input","type":{"response":{"ok":{"list":{"type":"uint128","length":2}},"error":"uint128"}}}],"outputs":{"type":"uint128"}}, {"name":"swap-y-x","access":"private","args":[{"name":"input","type":{"response":{"ok":{"list":{"type":"uint128","length":2}},"error":"uint128"}}}],"outputs":{"type":"uint128"}}, {"name":"test","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"swaps","type":{"list":{"type":"uint128","length":30}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
