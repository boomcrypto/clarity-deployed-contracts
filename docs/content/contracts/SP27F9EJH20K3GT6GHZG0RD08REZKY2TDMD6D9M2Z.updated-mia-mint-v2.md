---
title: "Contract updated-mia-mint-v2"
draft: true
---
Deployer: SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z

SIP-009: false

SIP-010: false

Functions:
{"name":"admin-claim-test","access":"public","args":[{"name":"mint-in-mia","type":"bool"},{"name":"test-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"admin-stop-mint","access":"public","args":[{"name":"mint-live","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"admin-transfer","access":"public","args":[{"name":"recipient","type":"principal"},{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"change-mia-price","access":"public","args":[{"name":"new-price","type":"uint128"},{"name":"new-commission","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-four","access":"public","args":[{"name":"mint-in-mia","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-one","access":"public","args":[{"name":"mint-in-mia","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"claim-two","access":"public","args":[{"name":"mint-in-mia","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}
