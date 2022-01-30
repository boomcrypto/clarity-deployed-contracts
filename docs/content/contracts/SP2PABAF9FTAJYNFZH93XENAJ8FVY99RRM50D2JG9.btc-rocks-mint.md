---
title: "Contract btc-rocks-mint"
draft: true
---
Deployer: SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9

SIP-009: false

SIP-010: false

Functions:
{"name":"upgrade","access":"public","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-owner-boom","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"uint128"}}}}, {"name":"to-boom","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"optional":"uint128"}}}
