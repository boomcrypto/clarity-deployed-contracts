---
title: "Contract bizarre-peach-earwig"
draft: true
---
Deployer: SP3TZ3NY4GB3E3Y1K1D40BHE07P20KMS4A8YC4QRJ

SIP-009: false

SIP-010: false

Functions:
{"name":"create-link","access":"public","args":[{"name":"code","type":{"string-ascii":{"length":5}}},{"name":"url","type":{"string-ascii":{"length":1000}}}],"outputs":{"type":{"response":{"ok":"bool","error":"int128"}}}}, {"name":"get-link","access":"read_only","args":[{"name":"code","type":{"string-ascii":{"length":5}}}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"owner","type":"principal"},{"name":"url","type":{"string-ascii":{"length":1000}}}]},"error":"int128"}}}}
