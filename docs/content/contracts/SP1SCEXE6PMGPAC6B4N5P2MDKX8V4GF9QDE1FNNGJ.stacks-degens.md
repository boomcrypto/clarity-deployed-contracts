---
title: "Contract stacks-degens"
draft: true
---
Deployer: SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ

SIP-009: true

SIP-010: false

Functions:
{"name":"mint","access":"private","args":[{"name":"new-owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"mint-helper","access":"private","args":[{"name":"new-owner","type":"principal"},{"name":"next-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-ipfs-root","access":"public","args":[{"name":"new-ipfs-root","type":{"string-ascii":{"length":80}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-mint-limit","access":"public","args":[{"name":"new-mint-limit","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"tournament-award","access":"public","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"token-id","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-base-uri","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":80}},"error":"none"}}}}, {"name":"get-last-token-id","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-mint-limit","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-owner","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":"principal"},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[{"name":"token-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"optional":{"string-ascii":{"length":88}}},"error":"none"}}}}
