---
title: "Contract stx-ft-swap-v1"
draft: true
---
Deployer: SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9

SIP-009: false

SIP-010: false

Functions:
{"name":"stx-transfer-to","access":"private","args":[{"name":"ustx","type":"uint128"},{"name":"to","type":"principal"},{"name":"memo","type":{"buffer":{"length":34}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"cancel","access":"public","args":[{"name":"id","type":"uint128"},{"name":"ft","type":"trait_reference"},{"name":"fees","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"create-swap","access":"public","args":[{"name":"ustx","type":"uint128"},{"name":"amount","type":"uint128"},{"name":"ft-sender","type":{"optional":"principal"}},{"name":"ft","type":"trait_reference"},{"name":"fees","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"submit-swap","access":"public","args":[{"name":"id","type":"uint128"},{"name":"ft","type":"trait_reference"},{"name":"fees","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
