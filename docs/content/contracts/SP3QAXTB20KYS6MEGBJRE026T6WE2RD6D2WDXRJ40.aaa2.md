---
title: "Contract aaa2"
draft: true
---
Deployer: SP3QAXTB20KYS6MEGBJRE026T6WE2RD6D2WDXRJ40

SIP-009: false

SIP-010: false

Functions:
{"name":"set_master_contract","access":"public","args":[{"name":"contract_owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"int128"}}}}, {"name":"transfer","access":"public","args":[{"name":"namespace","type":{"buffer":{"length":20}}},{"name":"name","type":{"buffer":{"length":48}}},{"name":"new_owner","type":"principal"},{"name":"zonefile-hash","type":{"optional":{"buffer":{"length":20}}}}],"outputs":{"type":{"response":{"ok":"bool","error":"int128"}}}}
