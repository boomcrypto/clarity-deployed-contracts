---
title: "Contract miner-registry"
draft: true
---
Deployer: SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ

SIP-009: false

SIP-010: false

Functions:
{"name":"register-block","access":"private","args":[{"name":"block-number","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":24}},"error":"uint128"}}}}, {"name":"register-blocks","access":"public","args":[{"name":"block-numbers","type":{"list":{"type":"uint128","length":750}}}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}
