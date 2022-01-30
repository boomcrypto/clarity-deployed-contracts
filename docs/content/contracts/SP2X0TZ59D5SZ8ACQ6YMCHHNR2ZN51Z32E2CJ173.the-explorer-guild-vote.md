---
title: "Contract the-explorer-guild-vote"
draft: true
---
Deployer: SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173

SIP-009: false

SIP-010: false

Functions:
{"name":"disable-vote","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"enable-vote","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"vote","access":"public","args":[{"name":"vote-option","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-vote-balance","access":"read_only","args":[{"name":"account","type":"principal"}],"outputs":{"type":"uint128"}}, {"name":"get-vote-option-balance","access":"read_only","args":[{"name":"vote-option","type":"uint128"}],"outputs":{"type":"uint128"}}
