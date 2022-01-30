---
title: "Contract commoners-mint"
draft: true
---
Deployer: SPZW30K9VG6YCPYV4BX4V1FT0VJ66R1Q01W9DQ1W

SIP-009: false

SIP-010: false

Functions:
{"name":"mint","access":"private","args":[{"name":"orders","type":{"list":{"type":"bool","length":10}}}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"claim","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"claim-five","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"claim-ten","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"claim-three","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"init","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"toggle-sale-state","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-passes","access":"read_only","args":[{"name":"caller","type":"principal"}],"outputs":{"type":"uint128"}}
