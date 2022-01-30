---
title: "Contract citycoin-vrf"
draft: true
---
Deployer: SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27

SIP-009: false

SIP-010: false

Functions:
{"name":"add-and-shift-uint-le","access":"private","args":[{"name":"idx","type":"uint128"},{"name":"input","type":{"tuple":[{"name":"acc","type":"uint128"},{"name":"data","type":{"buffer":{"length":16}}}]}}],"outputs":{"type":{"tuple":[{"name":"acc","type":"uint128"},{"name":"data","type":{"buffer":{"length":16}}}]}}}, {"name":"buff-to-u8","access":"private","args":[{"name":"byte","type":{"buffer":{"length":1}}}],"outputs":{"type":"uint128"}}, {"name":"buff-to-uint-le","access":"private","args":[{"name":"word","type":{"buffer":{"length":16}}}],"outputs":{"type":"uint128"}}, {"name":"lower-16-le","access":"private","args":[{"name":"input","type":{"buffer":{"length":32}}}],"outputs":{"type":{"buffer":{"length":16}}}}, {"name":"lower-16-le-closure","access":"private","args":[{"name":"idx","type":"uint128"},{"name":"input","type":{"tuple":[{"name":"acc","type":{"buffer":{"length":16}}},{"name":"data","type":{"buffer":{"length":32}}}]}}],"outputs":{"type":{"tuple":[{"name":"acc","type":{"buffer":{"length":16}}},{"name":"data","type":{"buffer":{"length":32}}}]}}}, {"name":"get-random-uint-at-block","access":"read_only","args":[{"name":"stacksBlock","type":"uint128"}],"outputs":{"type":{"optional":"uint128"}}}
