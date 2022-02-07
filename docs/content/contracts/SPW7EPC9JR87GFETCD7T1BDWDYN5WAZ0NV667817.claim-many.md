---
title: "Contract claim-many"
draft: true
---
Deployer: SPW7EPC9JR87GFETCD7T1BDWDYN5WAZ0NV667817

SIP-009: false

SIP-010: false

Functions:
{"name":"claim-block-fold","access":"private","args":[{"name":"height","type":"uint128"},{"name":"count","type":{"response":{"ok":"bool","error":"uint128"}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-many","access":"public","args":[{"name":"blocks","type":{"list":{"type":"uint128","length":50}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
