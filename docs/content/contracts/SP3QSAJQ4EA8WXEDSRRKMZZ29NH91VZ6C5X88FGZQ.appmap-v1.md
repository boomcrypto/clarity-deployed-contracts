---
title: "Contract appmap-v1"
draft: true
---
Deployer: SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ

SIP-009: false

SIP-010: false

Functions:
{"name":"is-storage-allowed","access":"private","args":[{"name":"storage","type":"int128"}],"outputs":{"type":"bool"}}, {"name":"is-update-allowed","access":"private","args":[{"name":"index","type":"int128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"register-app","access":"public","args":[{"name":"owner","type":"principal"},{"name":"app-contract-id","type":{"buffer":{"length":100}}},{"name":"storage-model","type":"int128"}],"outputs":{"type":{"response":{"ok":"int128","error":"uint128"}}}}, {"name":"set-app-status","access":"public","args":[{"name":"index","type":"int128"},{"name":"status","type":"int128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer-administrator","access":"public","args":[{"name":"new-administrator","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"update-app","access":"public","args":[{"name":"index","type":"int128"},{"name":"owner","type":"principal"},{"name":"app-contract-id","type":{"buffer":{"length":100}}},{"name":"storage-model","type":"int128"},{"name":"status","type":"int128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-administrator","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"principal","error":"none"}}}}, {"name":"get-app","access":"read_only","args":[{"name":"index","type":"int128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"app-contract-id","type":{"buffer":{"length":100}}},{"name":"owner","type":"principal"},{"name":"status","type":"int128"},{"name":"storage-model","type":"int128"}]},"error":"uint128"}}}}, {"name":"get-app-counter","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"int128","error":"none"}}}}, {"name":"get-app-index","access":"read_only","args":[{"name":"app-contract-id","type":{"buffer":{"length":100}}}],"outputs":{"type":{"response":{"ok":"int128","error":"uint128"}}}}, {"name":"get-contract-data","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"administrator","type":"principal"},{"name":"appCounter","type":"int128"}]},"error":"none"}}}}
