---
title: "Contract deliberate-turquoise-marmoset"
draft: true
---
Deployer: SP333V744Y42P93B8W6154VNQ9RDPM9MWCC2QN11J

SIP-009: false

SIP-010: false

Functions:
{"name":"get-balance","access":"private","args":[{"name":"user","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"is-auth-pool","access":"private","args":[],"outputs":{"type":"bool"}}, {"name":"transfer-mia","access":"private","args":[{"name":"amount","type":"uint128"},{"name":"from","type":"principal"},{"name":"to","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"buy-nyc","access":"public","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"change-price","access":"public","args":[{"name":"newPrice","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"exit-nyc","access":"public","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"sell-nyc","access":"public","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-contract-stx-balance","access":"read_only","args":[],"outputs":{"type":"uint128"}}, {"name":"get-pool-mia-balance","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-pool-stx-balance","access":"read_only","args":[],"outputs":{"type":"uint128"}}, {"name":"get-price","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-remaining","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"response":{"ok":"uint128","error":"none"}},"error":"none"}}}}
