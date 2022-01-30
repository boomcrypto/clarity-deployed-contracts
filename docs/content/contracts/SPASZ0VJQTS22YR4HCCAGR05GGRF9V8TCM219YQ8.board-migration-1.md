---
title: "Contract board-migration-1"
draft: true
---
Deployer: SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8

SIP-009: false

SIP-010: false

Functions:
{"name":"migrate-token","access":"public","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"is-migrated","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":"bool"}}
