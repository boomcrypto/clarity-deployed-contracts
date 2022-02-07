---
title: "Contract stackswap-security-list-v1a"
draft: true
---
Deployer: SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275

SIP-009: false

SIP-010: false

Functions:
{"name":"add-router","access":"public","args":[{"name":"router","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"remove-router","access":"public","args":[{"name":"router","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"is-secure-router","access":"read_only","args":[{"name":"router","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"is-secure-router-or-input","access":"read_only","args":[{"name":"contractcaller","type":"principal"},{"name":"input","type":"bool"}],"outputs":{"type":"bool"}}, {"name":"is-secure-router-or-user","access":"read_only","args":[{"name":"contractcaller","type":"principal"}],"outputs":{"type":"bool"}}
