---
title: "Contract send-many-memo"
draft: true
---
Deployer: SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE

SIP-009: false

SIP-010: false

Functions:
{"name":"check-err","access":"private","args":[{"name":"result","type":{"response":{"ok":"bool","error":"uint128"}}},{"name":"prior","type":{"response":{"ok":"bool","error":"uint128"}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"send-stx","access":"private","args":[{"name":"recipient","type":{"tuple":[{"name":"memo","type":{"buffer":{"length":34}}},{"name":"to","type":"principal"},{"name":"ustx","type":"uint128"}]}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"send-many","access":"public","args":[{"name":"recipients","type":{"list":{"type":{"tuple":[{"name":"memo","type":{"buffer":{"length":34}}},{"name":"to","type":"principal"},{"name":"ustx","type":"uint128"}]},"length":200}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"send-stx-with-memo","access":"public","args":[{"name":"ustx","type":"uint128"},{"name":"to","type":"principal"},{"name":"memo","type":{"buffer":{"length":34}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
