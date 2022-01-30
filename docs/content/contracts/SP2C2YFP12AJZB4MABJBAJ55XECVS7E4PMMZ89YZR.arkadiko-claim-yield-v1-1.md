---
title: "Contract arkadiko-claim-yield-v1-1"
draft: true
---
Deployer: SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR

SIP-009: false

SIP-010: false

Functions:
{"name":"add-claim","access":"public","args":[{"name":"recipient","type":{"tuple":[{"name":"to","type":"uint128"},{"name":"ustx","type":"uint128"}]}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"add-claims","access":"public","args":[{"name":"recipients","type":{"list":{"type":{"tuple":[{"name":"to","type":"uint128"},{"name":"ustx","type":"uint128"}]},"length":200}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim","access":"public","args":[{"name":"vault-id","type":"uint128"},{"name":"reserve","type":"trait_reference"},{"name":"coll-type","type":"trait_reference"},{"name":"stack-yield","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-to-pay-debt","access":"public","args":[{"name":"vault-id","type":"uint128"},{"name":"reserve","type":"trait_reference"},{"name":"coll-type","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"remove-claim","access":"public","args":[{"name":"recipient","type":{"tuple":[{"name":"to","type":"uint128"},{"name":"ustx","type":"uint128"}]}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"remove-claims","access":"public","args":[{"name":"recipients","type":{"list":{"type":{"tuple":[{"name":"to","type":"uint128"},{"name":"ustx","type":"uint128"}]},"length":200}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"return-stx","access":"public","args":[{"name":"ustx-amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"toggle-claim-shutdown","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-claim-by-vault-id","access":"read_only","args":[{"name":"vault-id","type":"uint128"}],"outputs":{"type":{"tuple":[{"name":"ustx","type":"uint128"}]}}}, {"name":"get-stx-balance","access":"read_only","args":[],"outputs":{"type":"uint128"}}
