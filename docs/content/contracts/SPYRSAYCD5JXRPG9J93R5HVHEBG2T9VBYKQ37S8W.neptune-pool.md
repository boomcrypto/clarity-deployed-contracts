---
title: "Contract neptune-pool"
draft: true
---
Deployer: SPYRSAYCD5JXRPG9J93R5HVHEBG2T9VBYKQ37S8W

SIP-009: false

SIP-010: false

Functions:
{"name":"check-caller-allowed","access":"private","args":[],"outputs":{"type":"bool"}}, {"name":"claim-rewards","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"int128"}}}}, {"name":"fill-liquidity-pool","access":"public","args":[{"name":"amount-ustx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"int128"}}}}, {"name":"set-rewards","access":"public","args":[{"name":"stacker","type":"principal"},{"name":"amount-ustx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"int128"}}}}
