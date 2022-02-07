---
title: "Contract stackswap-swap-router-v1a"
draft: true
---
Deployer: SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275

SIP-009: false

SIP-010: false

Functions:
{"name":"router-swap","access":"public","args":[{"name":"from","type":"trait_reference"},{"name":"bridge","type":"trait_reference"},{"name":"to","type":"trait_reference"},{"name":"from-lp","type":"trait_reference"},{"name":"to-lp","type":"trait_reference"},{"name":"from-type","type":"bool"},{"name":"to-type","type":"bool"},{"name":"from-amt","type":"uint128"},{"name":"from-2-bridge-min-amt","type":"uint128"},{"name":"bridge-2-to-min-amt","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"list":{"type":"uint128","length":3}},"error":"uint128"}}}}
