---
title: "Contract a87"
draft: true
---
Deployer: SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ

SIP-009: false

SIP-010: false

Functions:
{"name":"set_master_contract","access":"public","args":[{"name":"contract_owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"int128"}}}}, {"name":"transfer","access":"public","args":[{"name":"namespace","type":{"buffer":{"length":20}}},{"name":"name","type":{"buffer":{"length":48}}},{"name":"new_owner","type":"principal"},{"name":"zonefile-hash","type":{"optional":{"buffer":{"length":20}}}}],"outputs":{"type":{"response":{"ok":"bool","error":"int128"}}}}
