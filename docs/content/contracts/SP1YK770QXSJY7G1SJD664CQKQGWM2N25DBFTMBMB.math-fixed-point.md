---
title: "Contract math-fixed-point"
draft: true
---
Deployer: SP1YK770QXSJY7G1SJD664CQKQGWM2N25DBFTMBMB

SIP-009: false

SIP-010: false

Functions:
{"name":"div-down","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"div-up","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"get_one","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"mul-down","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"mul-up","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"pow-down","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"pow-up","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"round-for-up","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"tolerance","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"scale-down","access":"read_only","args":[{"name":"a","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"scale-up","access":"read_only","args":[{"name":"a","type":"uint128"}],"outputs":{"type":"uint128"}}
