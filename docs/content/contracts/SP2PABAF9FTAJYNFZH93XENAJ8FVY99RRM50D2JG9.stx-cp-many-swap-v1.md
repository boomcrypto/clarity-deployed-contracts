---
title: "Contract stx-cp-many-swap-v1"
draft: true
---
Deployer: SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9

SIP-009: false

SIP-010: false

Functions:
{"name":"check-err","access":"private","args":[{"name":"transfer-result","type":{"response":{"ok":"bool","error":"uint128"}}},{"name":"result","type":{"response":{"ok":"bool","error":"uint128"}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"stx-transfer-to","access":"private","args":[{"name":"ustx","type":"uint128"},{"name":"to","type":"principal"},{"name":"memo","type":{"buffer":{"length":34}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer-many","access":"private","args":[{"name":"nft-ids","type":{"list":{"type":"uint128","length":200}}},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"trnsfr","access":"private","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"cancel","access":"public","args":[{"name":"id","type":"uint128"},{"name":"fees","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"create-swap","access":"public","args":[{"name":"ustx","type":"uint128"},{"name":"nft-ids","type":{"list":{"type":"uint128","length":200}}},{"name":"nft-sender","type":{"optional":"principal"}},{"name":"fees","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"submit-swap","access":"public","args":[{"name":"id","type":"uint128"},{"name":"fees","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
