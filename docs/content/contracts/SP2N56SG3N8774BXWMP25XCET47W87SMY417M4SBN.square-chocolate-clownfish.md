---
title: "Contract square-chocolate-clownfish"
draft: true
---
Deployer: SP2N56SG3N8774BXWMP25XCET47W87SMY417M4SBN

SIP-009: false

SIP-010: false

Functions:
{"name":"get-value","access":"public","args":[{"name":"key","type":{"buffer":{"length":32}}}],"outputs":{"type":{"response":{"ok":{"buffer":{"length":32}},"error":"int128"}}}}, {"name":"set-value","access":"public","args":[{"name":"key","type":{"buffer":{"length":32}}},{"name":"value","type":{"buffer":{"length":32}}}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"test-emit-event","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"test-event-types","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}
