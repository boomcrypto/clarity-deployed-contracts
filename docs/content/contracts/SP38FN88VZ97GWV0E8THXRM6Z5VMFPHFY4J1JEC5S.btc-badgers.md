---
title: "Contract btc-badgers"
draft: true
---
Deployer: SP38FN88VZ97GWV0E8THXRM6Z5VMFPHFY4J1JEC5S

SIP-009: true

SIP-010: false

Functions:
{"name":"public-mint","access":"private","args":[{"name":"new-owner","type":"principal"},{"name":"mint-in-mia","type":"bool"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"trnsfr","access":"private","args":[{"name":"id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"white-list-mint","access":"private","args":[{"name":"new-owner","type":"principal"},{"name":"mint-in-mia","type":"bool"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"claim","access":"public","args":[{"name":"mint-in-mia","type":"bool"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"claim-four","access":"public","args":[{"name":"mint-in-mia","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-two","access":"public","args":[{"name":"mint-in-mia","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-balance","access":"read_only","args":[{"name":"account","type":"principal"}],"outputs":{"type":"uint128"}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":111}}},"error":"none"}}}}, {"name":"lookup","access":"read_only","args":[{"name":"uid","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":4}},"error":"none"}}}}, {"name":"white-list","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"list":{"type":"principal","length":164}},"error":"none"}}}}
