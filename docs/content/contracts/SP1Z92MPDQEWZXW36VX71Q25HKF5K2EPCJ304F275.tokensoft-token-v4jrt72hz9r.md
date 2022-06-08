---
title: "Contract tokensoft-token-v4jrt72hz9r"
draft: true
---
Deployer: SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275

SIP-009: false

SIP-010: true

Functions:
{"name":"add-principal-to-role","access":"public","args":[{"name":"role-to-add","type":"uint128"},{"name":"principal-to-add","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"approve","access":"public","args":[{"name":"is-approved","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"burn-tokens","access":"public","args":[{"name":"burn-amount","type":"uint128"},{"name":"burn-from","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"initialize","access":"public","args":[{"name":"name-to-set","type":{"string-ascii":{"length":32}}},{"name":"symbol-to-set","type":{"string-ascii":{"length":32}}},{"name":"decimals-to-set","type":"uint128"},{"name":"uri-to-set","type":{"string-utf8":{"length":256}}},{"name":"website-to-set","type":{"string-utf8":{"length":256}}},{"name":"initial-owner","type":"principal"},{"name":"initial-amount","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"mint-tokens","access":"public","args":[{"name":"mint-amount","type":"uint128"},{"name":"mint-to","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"remove-principal-from-role","access":"public","args":[{"name":"role-to-remove","type":"uint128"},{"name":"principal-to-remove","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"revoke-tokens","access":"public","args":[{"name":"revoke-amount","type":"uint128"},{"name":"revoke-from","type":"principal"},{"name":"revoke-to","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-token-uri","access":"public","args":[{"name":"updated-uri","type":{"string-utf8":{"length":256}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-token-website","access":"public","args":[{"name":"updated-website","type":{"string-utf8":{"length":256}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"transfer","access":"public","args":[{"name":"amount","type":"uint128"},{"name":"from","type":"principal"},{"name":"to","type":"principal"},{"name":"memo","type":{"optional":{"buffer":{"length":34}}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"update-blacklisted","access":"public","args":[{"name":"principal-to-update","type":"principal"},{"name":"set-blacklisted","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"detect-transfer-restriction","access":"read_only","args":[{"name":"amount","type":"uint128"},{"name":"sender","type":"principal"},{"name":"recipient","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"get-balance","access":"read_only","args":[{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-decimals","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-is-approved","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"optional":"bool"},"error":"none"}}}}, {"name":"get-name","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":32}},"error":"none"}}}}, {"name":"get-symbol","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":32}},"error":"none"}}}}, {"name":"get-token-uri","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"optional":{"string-utf8":{"length":256}}},"error":"none"}}}}, {"name":"get-token-website","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"optional":{"string-utf8":{"length":256}}},"error":"none"}}}}, {"name":"get-total-supply","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"has-role","access":"read_only","args":[{"name":"role-to-check","type":"uint128"},{"name":"principal-to-check","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"is-blacklisted","access":"read_only","args":[{"name":"principal-to-check","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"message-for-restriction","access":"read_only","args":[{"name":"restriction-code","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"string-ascii":{"length":70}},"error":"none"}}}}