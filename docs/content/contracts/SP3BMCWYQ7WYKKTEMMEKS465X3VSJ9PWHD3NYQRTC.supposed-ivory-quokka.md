---
title: "Contract supposed-ivory-quokka"
draft: true
---
Deployer: SP3BMCWYQ7WYKKTEMMEKS465X3VSJ9PWHD3NYQRTC

SIP-009: false

SIP-010: false

Functions:
{"name":"get-value","access":"public","args":[{"name":"key","type":{"buffer":{"length":32}}}],"outputs":{"type":{"response":{"ok":{"buffer":{"length":32}},"error":"int128"}}}}, {"name":"set-value","access":"public","args":[{"name":"key","type":{"buffer":{"length":32}}},{"name":"value","type":{"buffer":{"length":32}}}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"test-emit-event","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"test-event-types","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}
