---
title: "Contract stackswap-dao-v5g"
draft: true
---
Deployer: SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275

SIP-009: false

SIP-010: false

Functions:
{"name":"execute-proposal-change-contract","access":"private","args":[{"name":"change","type":{"tuple":[{"name":"address","type":"principal"},{"name":"name","type":{"string-ascii":{"length":256}}},{"name":"qualified-name","type":"principal"}]}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"execute-proposals","access":"public","args":[{"name":"contract-changes","type":{"list":{"type":{"tuple":[{"name":"address","type":"principal"},{"name":"name","type":{"string-ascii":{"length":256}}},{"name":"qualified-name","type":"principal"}]},"length":10}}}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"set-contract-address","access":"public","args":[{"name":"name","type":{"string-ascii":{"length":256}}},{"name":"address","type":"principal"},{"name":"qualified-name","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-dao-owner","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-payout-address","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-contract-address-by-name","access":"read_only","args":[{"name":"name","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"optional":"principal"}}}, {"name":"get-dao-owner","access":"read_only","args":[],"outputs":{"type":"principal"}}, {"name":"get-payout-address","access":"read_only","args":[],"outputs":{"type":"principal"}}, {"name":"get-qualified-name-by-name","access":"read_only","args":[{"name":"name","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"optional":"principal"}}}
