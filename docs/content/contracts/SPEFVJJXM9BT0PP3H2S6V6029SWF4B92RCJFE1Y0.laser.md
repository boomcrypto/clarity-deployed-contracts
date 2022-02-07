---
title: "Contract laser"
draft: true
---
Deployer: SPEFVJJXM9BT0PP3H2S6V6029SWF4B92RCJFE1Y0

SIP-009: false

SIP-010: true

Functions:
{"name":"buy","access":"public","args":[{"name":"count","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-token-uri","access":"public","args":[],"outputs":{"type":{"response":{"ok":{"optional":{"string-utf8":{"length":67}}},"error":"none"}}}}, {"name":"reward_minter","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set_buy_switch","access":"public","args":[{"name":"buy_switch","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"set_master_contract","access":"public","args":[{"name":"contract_owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set_price","access":"public","args":[{"name":"price","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"transfer","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"},{"name":"memo","type":{"optional":{"buffer":{"length":34}}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-balance","access":"read_only","args":[{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-decimals","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-name","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":5}},"error":"none"}}}}, {"name":"get-symbol","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":5}},"error":"none"}}}}, {"name":"get-total-supply","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get_summary","access":"read_only","args":[{"name":"player","type":{"optional":"principal"}}],"outputs":{"type":{"tuple":[{"name":"balance","type":"uint128"},{"name":"buy_switch","type":"bool"},{"name":"price","type":"uint128"},{"name":"supply","type":"uint128"}]}}}
