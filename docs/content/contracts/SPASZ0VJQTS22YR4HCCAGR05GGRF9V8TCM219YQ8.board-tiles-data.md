---
title: "Contract board-tiles-data"
draft: true
---
Deployer: SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8

SIP-009: false

SIP-010: false

Functions:
{"name":"create-tile","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"tile-id","type":"uint128"},{"name":"first-version","type":"bool"},{"name":"level","type":"uint128"},{"name":"background","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-tile-background","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"background","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"upgrade-tile","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"level","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"get-all-token-info","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"tuple":[{"name":"tile-background","type":"uint128"},{"name":"tile-first-version","type":"bool"},{"name":"tile-id","type":"uint128"},{"name":"tile-level","type":"uint128"},{"name":"tile-points","type":"uint128"}]}}}, {"name":"get-tile-mints-left","access":"read_only","args":[{"name":"tile-id","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"get-tile-points","access":"read_only","args":[{"name":"tile-id","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"get-tile-to-token","access":"read_only","args":[{"name":"tile-id","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"get-tiles-info","access":"read_only","args":[{"name":"tile-id","type":"uint128"}],"outputs":{"type":{"optional":{"tuple":[{"name":"mints-left","type":"uint128"},{"name":"points","type":"uint128"}]}}}}, {"name":"get-token-background","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"get-token-first-version","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"get-token-level","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"get-token-points","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"get-token-to-tile","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":"uint128"}}
