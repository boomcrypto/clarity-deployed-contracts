---
title: "Contract sss"
draft: true
---
Deployer: SP3Z7B90DWD65SRHZM70GSDN8MMGYAZKF6F2ERE2G

SIP-009: false

SIP-010: false

Functions:
{"name":"set-record","access":"private","args":[{"name":"index","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"get-bet-record","access":"read_only","args":[{"name":"index","type":"uint128"}],"outputs":{"type":{"optional":{"tuple":[{"name":"bet-value","type":"uint128"},{"name":"player","type":"principal"},{"name":"shares","type":"uint128"},{"name":"win-num","type":"int128"}]}}}}, {"name":"get-bet-record-v2","access":"read_only","args":[{"name":"ll","type":{"list":{"type":"uint128","length":3}}}],"outputs":{"type":{"optional":{"tuple":[{"name":"bet-value","type":"uint128"},{"name":"player","type":"principal"},{"name":"shares","type":"uint128"},{"name":"win-num","type":"int128"}]}}}}, {"name":"get-round-data","access":"read_only","args":[{"name":"bet-type","type":"uint128"},{"name":"round","type":"uint128"}],"outputs":{"type":{"tuple":[{"name":"records","type":{"list":{"type":{"optional":{"tuple":[{"name":"bet-value","type":"uint128"},{"name":"player","type":"principal"},{"name":"shares","type":"uint128"},{"name":"win-num","type":"int128"}]}},"length":400}}},{"name":"summary","type":{"optional":{"tuple":[{"name":"end-at","type":"uint128"},{"name":"end-time","type":"uint128"},{"name":"player-num","type":"uint128"},{"name":"rand-num","type":"uint128"},{"name":"s-num","type":"uint128"},{"name":"start-at","type":"uint128"},{"name":"start-time","type":"uint128"},{"name":"total-shares","type":"uint128"},{"name":"v-num","type":"uint128"}]}}}]}}}, {"name":"get-round-data-v2","access":"read_only","args":[{"name":"ll","type":{"list":{"type":{"list":{"type":"uint128","length":3}},"length":100}}}],"outputs":{"type":{"list":{"type":{"optional":{"tuple":[{"name":"bet-value","type":"uint128"},{"name":"player","type":"principal"},{"name":"shares","type":"uint128"},{"name":"win-num","type":"int128"}]}},"length":100}}}}
