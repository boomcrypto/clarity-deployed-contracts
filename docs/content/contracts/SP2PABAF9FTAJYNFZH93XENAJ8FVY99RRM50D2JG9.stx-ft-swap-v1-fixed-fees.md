---
title: "Contract stx-ft-swap-v1-fixed-fees"
draft: true
---
Deployer: SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9

SIP-009: false

SIP-010: false

Functions:
{"name":"get-fees","access":"public","args":[{"name":"ustx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"hold-fees","access":"public","args":[{"name":"ustx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"pay-fees","access":"public","args":[{"name":"ustx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"release-fees","access":"public","args":[{"name":"ustx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
