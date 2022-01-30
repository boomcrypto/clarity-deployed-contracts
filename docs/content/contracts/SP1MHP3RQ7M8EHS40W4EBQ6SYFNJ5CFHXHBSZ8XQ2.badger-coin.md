---
title: "Contract badger-coin"
draft: true
---
Deployer: SP1MHP3RQ7M8EHS40W4EBQ6SYFNJ5CFHXHBSZ8XQ2

SIP-009: false

SIP-010: true

Functions:
{"name":"burn","access":"public","args":[{"name":"count","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"get-token-uri","access":"public","args":[],"outputs":{"type":{"response":{"ok":{"optional":{"string-utf8":{"length":80}}},"error":"none"}}}}, {"name":"transfer","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"},{"name":"memo","type":{"optional":{"buffer":{"length":34}}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-balance","access":"read_only","args":[{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-decimals","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-name","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":12}},"error":"none"}}}}, {"name":"get-symbol","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":6}},"error":"none"}}}}, {"name":"get-total-supply","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get_summary","access":"read_only","args":[{"name":"player","type":{"optional":"principal"}}],"outputs":{"type":{"tuple":[{"name":"bh","type":"uint128"},{"name":"ft","type":"uint128"},{"name":"last_get_bh","type":"uint128"},{"name":"stx","type":"uint128"},{"name":"supply","type":"uint128"},{"name":"tmc","type":"uint128"}]}}}
