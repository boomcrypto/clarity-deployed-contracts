---
title: "Contract board-main-manager"
draft: true
---
Deployer: SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8

SIP-009: false

SIP-010: false

Functions:
{"name":"change-contract","access":"public","args":[{"name":"name","type":{"string-ascii":{"length":256}}},{"name":"address","type":"principal"},{"name":"qualified-name","type":"principal"},{"name":"can-mint","type":"bool"},{"name":"can-burn","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-contract-owner","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
