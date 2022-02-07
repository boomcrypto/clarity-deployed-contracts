---
title: "Contract diko-query"
draft: true
---
Deployer: SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE

SIP-009: false

SIP-010: false

Functions:
{"name":"query-balance","access":"private","args":[{"name":"address","type":"principal"}],"outputs":{"type":{"tuple":[{"name":"diko-usda","type":"uint128"},{"name":"wstx-diko","type":"uint128"},{"name":"wstx-usda","type":"uint128"}]}}}, {"name":"query-total-supply","access":"private","args":[],"outputs":{"type":{"tuple":[{"name":"diko-usda","type":"uint128"},{"name":"wstx-diko","type":"uint128"},{"name":"wstx-usda","type":"uint128"}]}}}, {"name":"get-block-hash","access":"read_only","args":[{"name":"height","type":"uint128"}],"outputs":{"type":{"optional":{"buffer":{"length":32}}}}}, {"name":"get-lp-balances","access":"read_only","args":[{"name":"address","type":"principal"},{"name":"block-hash","type":{"buffer":{"length":32}}}],"outputs":{"type":{"tuple":[{"name":"diko-usda","type":"uint128"},{"name":"wstx-diko","type":"uint128"},{"name":"wstx-usda","type":"uint128"}]}}}, {"name":"get-total-supply","access":"read_only","args":[{"name":"block-hash","type":{"buffer":{"length":32}}}],"outputs":{"type":{"tuple":[{"name":"diko-usda","type":"uint128"},{"name":"wstx-diko","type":"uint128"},{"name":"wstx-usda","type":"uint128"}]}}}
