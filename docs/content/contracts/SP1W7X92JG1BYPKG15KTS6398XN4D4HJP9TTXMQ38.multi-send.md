---
title: "Contract multi-send"
draft: true
---
Deployer: SP1W7X92JG1BYPKG15KTS6398XN4D4HJP9TTXMQ38

SIP-009: false

SIP-010: false

Functions:
{"name":"multi-send-iter","access":"private","args":[{"name":"data","type":{"tuple":[{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"},{"name":"sender","type":"principal"}]}},{"name":"sip010-token","type":"trait_reference"}],"outputs":{"type":"trait_reference"}}, {"name":"multi-send","access":"public","args":[{"name":"data","type":{"list":{"type":{"tuple":[{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"},{"name":"sender","type":"principal"}]},"length":200}}},{"name":"sip010-token","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}
