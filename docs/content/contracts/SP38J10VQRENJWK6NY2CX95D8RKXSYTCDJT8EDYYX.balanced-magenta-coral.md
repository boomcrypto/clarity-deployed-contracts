---
title: "Contract balanced-magenta-coral"
draft: true
---
Deployer: SP38J10VQRENJWK6NY2CX95D8RKXSYTCDJT8EDYYX

SIP-009: false

SIP-010: false

Functions:
{"name":"get-value","access":"public","args":[{"name":"key","type":{"buffer":{"length":32}}}],"outputs":{"type":{"response":{"ok":{"buffer":{"length":32}},"error":"int128"}}}}, {"name":"set-value","access":"public","args":[{"name":"key","type":{"buffer":{"length":32}}},{"name":"value","type":{"buffer":{"length":32}}}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"test-emit-event","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"test-event-types","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}
