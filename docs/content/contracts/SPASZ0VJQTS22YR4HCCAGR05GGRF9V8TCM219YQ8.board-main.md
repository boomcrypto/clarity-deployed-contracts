---
title: "Contract board-main"
draft: true
---
Deployer: SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8

SIP-009: false

SIP-010: false

Functions:
{"name":"burn-ft-token","access":"public","args":[{"name":"token","type":"trait_reference"},{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"burn-nft-token","access":"public","args":[{"name":"token","type":"trait_reference"},{"name":"token-id","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"change-contract","access":"public","args":[{"name":"name","type":{"string-ascii":{"length":256}}},{"name":"address","type":"principal"},{"name":"qualified-name","type":"principal"},{"name":"can-mint","type":"bool"},{"name":"can-burn","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint-ft-token","access":"public","args":[{"name":"token","type":"trait_reference"},{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint-nft-token","access":"public","args":[{"name":"token","type":"trait_reference"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-contract-address-by-name","access":"read_only","args":[{"name":"name","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"optional":"principal"}}}, {"name":"get-contract-can-burn-by-qualified-name","access":"read_only","args":[{"name":"qualified-name","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"get-contract-can-mint-by-qualified-name","access":"read_only","args":[{"name":"qualified-name","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"get-qualified-name-by-name","access":"read_only","args":[{"name":"name","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"optional":"principal"}}}