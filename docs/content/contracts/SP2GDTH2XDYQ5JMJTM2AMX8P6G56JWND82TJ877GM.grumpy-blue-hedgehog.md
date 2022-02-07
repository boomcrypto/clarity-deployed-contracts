---
title: "Contract grumpy-blue-hedgehog"
draft: true
---
Deployer: SP2GDTH2XDYQ5JMJTM2AMX8P6G56JWND82TJ877GM

SIP-009: false

SIP-010: false

Functions:
{"name":"get-value","access":"public","args":[{"name":"key","type":{"buffer":{"length":32}}}],"outputs":{"type":{"response":{"ok":{"buffer":{"length":32}},"error":"int128"}}}}, {"name":"set-value","access":"public","args":[{"name":"key","type":{"buffer":{"length":32}}},{"name":"value","type":{"buffer":{"length":32}}}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"test-emit-event","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"test-event-types","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}
