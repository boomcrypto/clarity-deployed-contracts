---
title: "Contract zzz"
draft: true
---
Deployer: SP1GV5427A35574F7YFB7BD49AK5DH0EVD07W1W9F

SIP-009: false

SIP-010: false

Functions:
{"name":"gen-record","access":"private","args":[{"name":"index","type":"uint128"}],"outputs":{"type":{"optional":{"tuple":[{"name":"p","type":"principal"},{"name":"v","type":"int128"}]}}}}, {"name":"s-is-some","access":"private","args":[{"name":"a","type":{"optional":{"tuple":[{"name":"p","type":"principal"},{"name":"v","type":"int128"}]}}}],"outputs":{"type":"bool"}}, {"name":"s-unwrap","access":"private","args":[{"name":"a","type":{"optional":{"tuple":[{"name":"p","type":"principal"},{"name":"v","type":"int128"}]}}}],"outputs":{"type":{"tuple":[{"name":"p","type":"principal"},{"name":"v","type":"int128"}]}}}, {"name":"get-mapp","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"optional":{"list":{"type":{"tuple":[{"name":"p","type":"principal"},{"name":"v","type":"int128"}]},"length":400}}},"error":"none"}}}}
