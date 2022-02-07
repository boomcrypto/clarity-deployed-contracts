---
title: "Contract agp018"
draft: true
---
Deployer: SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9

SIP-009: false

SIP-010: false

Functions:
{"name":"claim-alex-staking-reward","access":"private","args":[{"name":"reward-cycle","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"entitled-token","type":"uint128"},{"name":"to-return","type":"uint128"}]},"error":"uint128"}}}}, {"name":"claim-fwp-alex-staking-reward","access":"private","args":[{"name":"reward-cycle","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"entitled-token","type":"uint128"},{"name":"to-return","type":"uint128"}]},"error":"uint128"}}}}, {"name":"claim-fwp-wbtc-staking-reward","access":"private","args":[{"name":"reward-cycle","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"entitled-token","type":"uint128"},{"name":"to-return","type":"uint128"}]},"error":"uint128"}}}}, {"name":"execute","access":"public","args":[{"name":"sender","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
