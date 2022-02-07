---
title: "Contract estimated-lime-crow"
draft: true
---
Deployer: SP1WBNM0A4ZVY1GVZMXDPMV831BF0BMHFJK9ZXNRW

SIP-009: false

SIP-010: false

Functions:
{"name":"send-many-iter","access":"private","args":[{"name":"data","type":{"tuple":[{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"},{"name":"sender","type":"principal"}]}},{"name":"sip010-token","type":"trait_reference"}],"outputs":{"type":"trait_reference"}}, {"name":"send-many","access":"public","args":[{"name":"data","type":{"list":{"type":{"tuple":[{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"},{"name":"sender","type":"principal"}]},"length":200}}},{"name":"sip010-token","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}
