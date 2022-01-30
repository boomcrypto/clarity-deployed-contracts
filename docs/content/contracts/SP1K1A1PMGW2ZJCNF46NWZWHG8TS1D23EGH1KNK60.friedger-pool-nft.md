---
title: "Contract friedger-pool-nft"
draft: true
---
Deployer: SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60

SIP-009: false

SIP-010: false

Functions:
{"name":"find","access":"private","args":[{"name":"user","type":"principal"},{"name":"ctx","type":{"tuple":[{"name":"index","type":"uint128"},{"name":"member","type":"principal"},{"name":"result","type":"uint128"}]}}],"outputs":{"type":{"tuple":[{"name":"index","type":"uint128"},{"name":"member","type":"principal"},{"name":"result","type":"uint128"}]}}}, {"name":"is-owner","access":"private","args":[{"name":"token-id","type":"uint128"},{"name":"user","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"claim","access":"public","args":[{"name":"amount-in-stx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":{"tuple":[{"name":"code","type":"uint128"},{"name":"kind","type":{"string-ascii":{"length":17}}}]}}}}}, {"name":"transfer","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":{"tuple":[{"name":"code","type":"uint128"},{"name":"kind","type":{"string-ascii":{"length":19}}}]}}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-meta","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"mime-type","type":{"string-ascii":{"length":9}}},{"name":"name","type":{"string-ascii":{"length":26}}},{"name":"uri","type":{"string-ascii":{"length":32}}}]},"error":"none"}}}}, {"name":"get-nft-meta","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"mime-type","type":{"string-ascii":{"length":9}}},{"name":"name","type":{"string-ascii":{"length":13}}},{"name":"uri","type":{"string-ascii":{"length":32}}}]},"error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":33}}},"error":"none"}}}}
