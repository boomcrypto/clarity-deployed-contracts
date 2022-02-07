---
title: "Contract btc-rocks-marketplace"
draft: true
---
Deployer: SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9

SIP-009: false

SIP-010: false

Functions:
{"name":"is-sender-owner","access":"private","args":[{"name":"id","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"buy-in-ustx","access":"public","args":[{"name":"id","type":"uint128"},{"name":"comm","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"list-in-ustx","access":"public","args":[{"name":"id","type":"uint128"},{"name":"price","type":"uint128"},{"name":"comm","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"unlist-in-ustx","access":"public","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-listing-in-ustx","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"optional":{"tuple":[{"name":"commission","type":"principal"},{"name":"price","type":"uint128"}]}}}}
