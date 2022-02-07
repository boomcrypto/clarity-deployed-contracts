---
title: "Contract resolver_v1_coinbase_btc"
draft: true
---
Deployer: SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY

SIP-009: false

SIP-010: false

Functions:
{"name":"decideResolution","access":"private","args":[{"name":"marketId","type":"int128"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"getOraclePrice","access":"private","args":[],"outputs":{"type":{"optional":{"tuple":[{"name":"amount","type":"uint128"},{"name":"height","type":"uint128"},{"name":"timestamp","type":"uint128"}]}}}}, {"name":"resolveMarket","access":"private","args":[{"name":"marketId","type":"int128"},{"name":"result","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"requestResolution","access":"public","args":[{"name":"marketId","type":"int128"}],"outputs":{"type":{"response":{"ok":{"response":{"ok":"bool","error":"none"}},"error":"none"}}}}, {"name":"readMarketThreshold","access":"read_only","args":[{"name":"marketId","type":"int128"}],"outputs":{"type":{"response":{"ok":{"optional":"int128"},"error":"none"}}}}
