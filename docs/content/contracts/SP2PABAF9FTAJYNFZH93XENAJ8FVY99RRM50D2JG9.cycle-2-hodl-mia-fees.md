---
title: "Contract cycle-2-hodl-mia-fees"
draft: true
---
Deployer: SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9

SIP-009: false

SIP-010: false

Functions:
{"name":"get-fees","access":"public","args":[{"name":"ustx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"hold-fees","access":"public","args":[{"name":"ustx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"pay-fees","access":"public","args":[{"name":"ustx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"release-fees","access":"public","args":[{"name":"ustx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"hodls-mia","access":"read_only","args":[{"name":"user","type":"principal"}],"outputs":{"type":"bool"}}
