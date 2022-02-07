---
title: "Contract mighty-apricot-slug"
draft: true
---
Deployer: SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C

SIP-009: false

SIP-010: false

Functions:
{"name":"get-name-details","access":"read_only","args":[{"name":"namespace","type":{"buffer":{"length":20}}},{"name":"name","type":{"buffer":{"length":48}}}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"lease-ending-at","type":{"optional":"uint128"}},{"name":"lease-started-at","type":"uint128"},{"name":"owner","type":"principal"},{"name":"zonefile-hash","type":{"buffer":{"length":20}}}]},"error":"int128"}}}}
