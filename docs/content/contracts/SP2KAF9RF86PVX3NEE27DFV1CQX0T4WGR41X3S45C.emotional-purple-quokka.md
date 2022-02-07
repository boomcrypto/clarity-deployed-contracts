---
title: "Contract emotional-purple-quokka"
draft: true
---
Deployer: SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C

SIP-009: false

SIP-010: false

Functions:
{"name":"accept-bid","access":"public","args":[{"name":"namespace","type":{"buffer":{"length":20}}},{"name":"domain","type":{"buffer":{"length":48}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"admin-unbid","access":"public","args":[{"name":"namespace","type":{"buffer":{"length":20}}},{"name":"domain","type":{"buffer":{"length":48}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"bid","access":"public","args":[{"name":"namespace","type":{"buffer":{"length":20}}},{"name":"domain","type":{"buffer":{"length":48}}},{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-bid","access":"public","args":[{"name":"namespace","type":{"buffer":{"length":20}}},{"name":"domain","type":{"buffer":{"length":48}}}],"outputs":{"type":{"response":{"ok":{"optional":{"tuple":[{"name":"buyer","type":"principal"},{"name":"offer","type":"uint128"}]}},"error":"none"}}}}, {"name":"set-active","access":"public","args":[{"name":"value","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":{"response":{"ok":"none","error":"uint128"}}}}}}, {"name":"set-commisssion","access":"public","args":[{"name":"value","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":{"response":{"ok":"none","error":"uint128"}}}}}}, {"name":"withdraw-bid","access":"public","args":[{"name":"namespace","type":{"buffer":{"length":20}}},{"name":"domain","type":{"buffer":{"length":48}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
