---
title: "Contract sporting-lavender-amphibian"
draft: true
---
Deployer: SP35F05N3KSNS8E7MSG8CC1MA350BZ6R1X9S610VQ

SIP-009: false

SIP-010: false

Functions:
{"name":"get-value","access":"public","args":[{"name":"key","type":{"buffer":{"length":32}}}],"outputs":{"type":{"response":{"ok":{"buffer":{"length":32}},"error":"int128"}}}}, {"name":"set-value","access":"public","args":[{"name":"key","type":{"buffer":{"length":32}}},{"name":"value","type":{"buffer":{"length":32}}}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"test-emit-event","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"test-event-types","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}
