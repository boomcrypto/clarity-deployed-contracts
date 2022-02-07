---
title: "Contract kcv-pool"
draft: true
---
Deployer: SP1W7X92JG1BYPKG15KTS6398XN4D4HJP9TTXMQ38

SIP-009: false

SIP-010: false

Functions:
{"name":"check-err","access":"private","args":[{"name":"result","type":{"response":{"ok":"bool","error":"uint128"}}},{"name":"prior","type":{"response":{"ok":"bool","error":"uint128"}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"send-stx","access":"private","args":[{"name":"recipient","type":{"tuple":[{"name":"to","type":"principal"},{"name":"ustx","type":"uint128"}]}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"join-pool","access":"public","args":[{"name":"recipients","type":{"list":{"type":{"tuple":[{"name":"to","type":"principal"},{"name":"ustx","type":"uint128"}]},"length":200}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
