---
title: "Contract stackswap-dao-v4a"
draft: true
---
Deployer: SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275

SIP-009: false

SIP-010: false

Functions:
{"name":"burn-token","access":"public","args":[{"name":"token","type":"trait_reference"},{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint-token","access":"public","args":[{"name":"token","type":"trait_reference"},{"name":"amount","type":"uint128"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-contract-address","access":"public","args":[{"name":"name","type":{"string-ascii":{"length":256}}},{"name":"address","type":"principal"},{"name":"qualified-name","type":"principal"},{"name":"can-mint","type":"bool"},{"name":"can-burn","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-dao-owner","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-payout-address","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-contract-address-by-name","access":"read_only","args":[{"name":"name","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"optional":"principal"}}}, {"name":"get-contract-can-burn-by-qualified-name","access":"read_only","args":[{"name":"qualified-name","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"get-contract-can-mint-by-qualified-name","access":"read_only","args":[{"name":"qualified-name","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"get-dao-owner","access":"read_only","args":[],"outputs":{"type":"principal"}}, {"name":"get-payout-address","access":"read_only","args":[],"outputs":{"type":"principal"}}, {"name":"get-qualified-name-by-name","access":"read_only","args":[{"name":"name","type":{"string-ascii":{"length":256}}}],"outputs":{"type":{"optional":"principal"}}}
