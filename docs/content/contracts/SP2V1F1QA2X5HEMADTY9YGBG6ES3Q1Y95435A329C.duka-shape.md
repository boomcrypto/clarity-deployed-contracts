---
title: "Contract duka-shape"
draft: true
---
Deployer: SP2V1F1QA2X5HEMADTY9YGBG6ES3Q1Y95435A329C

SIP-009: true

SIP-010: false

Functions:
{"name":"mint-many","access":"private","args":[{"name":"orders","type":{"list":{"type":"bool","length":10}}}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"mint-many-iter","access":"private","args":[{"name":"ignore","type":"bool"},{"name":"next-id","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"claim","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"claim-five","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"claim-ten","access":"public","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"freeze-ipfs-root","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-artist-address","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-ipfs-root","access":"public","args":[{"name":"new-ipfs-root","type":{"string-ascii":{"length":80}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-mint-limit","access":"public","args":[{"name":"new-limit","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-price","access":"public","args":[{"name":"price","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":89}}},"error":"none"}}}}
