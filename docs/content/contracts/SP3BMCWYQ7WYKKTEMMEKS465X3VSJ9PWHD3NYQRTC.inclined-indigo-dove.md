---
title: "Contract inclined-indigo-dove"
draft: true
---
Deployer: SP3BMCWYQ7WYKKTEMMEKS465X3VSJ9PWHD3NYQRTC

SIP-009: false

SIP-010: false

Functions:
{"name":"check-balance","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"issue-vote-tokens","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"int128","error":"int128"}}}}, {"name":"transfer-token","access":"public","args":[{"name":"address","type":"principal"},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
