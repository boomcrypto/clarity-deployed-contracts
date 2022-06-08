---
title: "Contract stacks-stingers-v0"
draft: true
---
Deployer: SP331YTEWH6RBGXH4GFVAN2GXHKQGHEAADMWR220P

SIP-009: false

SIP-010: false

Functions:
{"name":"add-and-shift-uint-le","access":"private","args":[{"name":"idx","type":"uint128"},{"name":"input","type":{"tuple":[{"name":"acc","type":"uint128"},{"name":"data","type":{"buffer":{"length":16}}}]}}],"outputs":{"type":{"tuple":[{"name":"acc","type":"uint128"},{"name":"data","type":{"buffer":{"length":16}}}]}}}, {"name":"append-deposit","access":"private","args":[{"name":"amount","type":"uint128"},{"name":"memo","type":{"string-utf8":{"length":70}}},{"name":"height","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"award-stinger","access":"private","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"buff-to-u8","access":"private","args":[{"name":"byte","type":{"buffer":{"length":1}}}],"outputs":{"type":"uint128"}}, {"name":"buff-to-uint-le","access":"private","args":[{"name":"word","type":{"buffer":{"length":16}}}],"outputs":{"type":"uint128"}}, {"name":"get-winning-address","access":"private","args":[{"name":"entry","type":{"tuple":[{"name":"address","type":"principal"},{"name":"amount","type":"uint128"},{"name":"high-amount","type":"uint128"},{"name":"low-amount","type":"uint128"},{"name":"memo","type":{"string-utf8":{"length":70}}}]}},{"name":"context","type":{"tuple":[{"name":"random-value","type":"uint128"},{"name":"result","type":{"optional":"principal"}}]}}],"outputs":{"type":{"tuple":[{"name":"random-value","type":"uint128"},{"name":"result","type":{"optional":"principal"}}]}}}, {"name":"lower-16-le","access":"private","args":[{"name":"input","type":{"buffer":{"length":32}}}],"outputs":{"type":{"buffer":{"length":16}}}}, {"name":"lower-16-le-closure","access":"private","args":[{"name":"idx","type":"uint128"},{"name":"input","type":{"tuple":[{"name":"acc","type":{"buffer":{"length":16}}},{"name":"data","type":{"buffer":{"length":32}}}]}}],"outputs":{"type":{"tuple":[{"name":"acc","type":{"buffer":{"length":16}}},{"name":"data","type":{"buffer":{"length":32}}}]}}}, {"name":"deposit","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"memo","type":{"string-utf8":{"length":70}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"redeem-stinger","access":"public","args":[{"name":"amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-deposit-last-high-amount-by-height","access":"read_only","args":[{"name":"height","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"get-deposits-by-height","access":"read_only","args":[{"name":"height","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"list":{"type":{"tuple":[{"name":"address","type":"principal"},{"name":"amount","type":"uint128"},{"name":"high-amount","type":"uint128"},{"name":"low-amount","type":"uint128"},{"name":"memo","type":{"string-utf8":{"length":70}}}]},"length":100}},"error":"uint128"}}}}, {"name":"get-random-uint-at-block","access":"read_only","args":[{"name":"stacksBlock","type":"uint128"}],"outputs":{"type":{"optional":"uint128"}}}, {"name":"get-winner-by-height","access":"read_only","args":[{"name":"height","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"address","type":"principal"},{"name":"amount","type":"uint128"}]},"error":"uint128"}}}}, {"name":"randomize","access":"read_only","args":[{"name":"seed","type":"uint128"},{"name":"max","type":"uint128"}],"outputs":{"type":"uint128"}}