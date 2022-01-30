---
title: "Contract duv-app"
draft: true
---
Deployer: SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M

SIP-009: false

SIP-010: false

Functions:
{"name":"get-balance","access":"private","args":[{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"increment-content-index","access":"private","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"like-message","access":"public","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"send-message","access":"public","args":[{"name":"content","type":{"string-utf8":{"length":140}}},{"name":"attachment-uri","type":{"optional":{"string-utf8":{"length":256}}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer-duv","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-content-index","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-like-count","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"likes","type":"uint128"}]},"error":"none"}}}}, {"name":"get-message-publisher","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"principal","error":"none"}}}}
