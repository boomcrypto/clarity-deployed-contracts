---
title: "Contract stackwap-oracle-v1b"
draft: true
---
Deployer: SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275

SIP-009: false

SIP-010: false

Functions:
{"name":"fetch-price","access":"public","args":[{"name":"token","type":{"string-ascii":{"length":12}}}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"decimals","type":"uint128"},{"name":"last-block","type":"uint128"},{"name":"last-price","type":"uint128"}]},"error":"none"}}}}, {"name":"set-oracle-owner","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"update-price","access":"public","args":[{"name":"token","type":{"string-ascii":{"length":12}}},{"name":"price","type":"uint128"},{"name":"decimals","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"get-price","access":"read_only","args":[{"name":"token","type":{"string-ascii":{"length":12}}}],"outputs":{"type":{"tuple":[{"name":"decimals","type":"uint128"},{"name":"last-block","type":"uint128"},{"name":"last-price","type":"uint128"}]}}}, {"name":"get-price1","access":"read_only","args":[{"name":"token","type":{"string-ascii":{"length":12}}}],"outputs":{"type":{"tuple":[{"name":"decimals","type":"uint128"},{"name":"last-block","type":"uint128"},{"name":"last-price","type":"uint128"}]}}}, {"name":"get-price2","access":"read_only","args":[{"name":"token","type":{"string-ascii":{"length":12}}}],"outputs":{"type":{"tuple":[{"name":"decimals","type":"uint128"},{"name":"last-block","type":"uint128"},{"name":"last-price","type":"uint128"}]}}}, {"name":"get-price3","access":"read_only","args":[{"name":"token","type":{"string-ascii":{"length":12}}}],"outputs":{"type":{"tuple":[{"name":"decimals","type":"uint128"},{"name":"last-block","type":"uint128"},{"name":"last-price","type":"uint128"}]}}}
