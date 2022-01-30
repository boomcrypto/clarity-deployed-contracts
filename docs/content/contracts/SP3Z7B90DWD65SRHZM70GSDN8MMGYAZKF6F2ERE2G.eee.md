---
title: "Contract eee"
draft: true
---
Deployer: SP3Z7B90DWD65SRHZM70GSDN8MMGYAZKF6F2ERE2G

SIP-009: false

SIP-010: false

Functions:
{"name":"del-round-record","access":"private","args":[{"name":"index","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"get-round-record","access":"private","args":[{"name":"index","type":"uint128"}],"outputs":{"type":{"optional":{"tuple":[{"name":"b","type":"uint128"},{"name":"p","type":"principal"},{"name":"s","type":"uint128"},{"name":"w","type":"int128"}]}}}}, {"name":"set-record","access":"private","args":[{"name":"index","type":"uint128"}],"outputs":{"type":"bool"}}, {"name":"combine-round-records","access":"public","args":[{"name":"bet-type","type":"uint128"},{"name":"round","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"none"}}}}, {"name":"get-bet-record","access":"read_only","args":[{"name":"index","type":"uint128"}],"outputs":{"type":{"optional":{"tuple":[{"name":"b","type":"uint128"},{"name":"p","type":"principal"},{"name":"s","type":"uint128"},{"name":"w","type":"int128"}]}}}}, {"name":"get-bet-record-v2","access":"read_only","args":[{"name":"ll","type":{"list":{"type":"uint128","length":3}}}],"outputs":{"type":{"optional":{"tuple":[{"name":"b","type":"uint128"},{"name":"p","type":"principal"},{"name":"s","type":"uint128"},{"name":"w","type":"int128"}]}}}}, {"name":"get-round-data-v2","access":"read_only","args":[{"name":"ll","type":{"list":{"type":{"list":{"type":"uint128","length":3}},"length":100}}}],"outputs":{"type":{"list":{"type":{"optional":{"tuple":[{"name":"b","type":"uint128"},{"name":"p","type":"principal"},{"name":"s","type":"uint128"},{"name":"w","type":"int128"}]}},"length":100}}}}, {"name":"get-round-records","access":"read_only","args":[{"name":"bet-type","type":"uint128"},{"name":"round","type":"uint128"}],"outputs":{"type":{"optional":{"list":{"type":{"optional":{"tuple":[{"name":"b","type":"uint128"},{"name":"p","type":"principal"},{"name":"s","type":"uint128"},{"name":"w","type":"int128"}]}},"length":360}}}}}
