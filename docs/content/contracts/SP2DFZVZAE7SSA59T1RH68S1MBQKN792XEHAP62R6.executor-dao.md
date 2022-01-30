---
title: "Contract executor-dao"
draft: true
---
Deployer: SP2DFZVZAE7SSA59T1RH68S1MBQKN792XEHAP62R6

SIP-009: false

SIP-010: false

Functions:
{"name":"is-self-or-extension","access":"private","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-extensions-iter","access":"private","args":[{"name":"item","type":{"tuple":[{"name":"enabled","type":"bool"},{"name":"extension","type":"principal"}]}}],"outputs":{"type":"bool"}}, {"name":"construct","access":"public","args":[{"name":"proposal","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"execute","access":"public","args":[{"name":"proposal","type":"trait_reference"},{"name":"sender","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"request-extension-callback","access":"public","args":[{"name":"extension","type":"trait_reference"},{"name":"memo","type":{"buffer":{"length":34}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-extension","access":"public","args":[{"name":"extension","type":"principal"},{"name":"enabled","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-extensions","access":"public","args":[{"name":"extension-list","type":{"list":{"type":{"tuple":[{"name":"enabled","type":"bool"},{"name":"extension","type":"principal"}]},"length":200}}}],"outputs":{"type":{"response":{"ok":{"list":{"type":"bool","length":200}},"error":"uint128"}}}}, {"name":"executed-at","access":"read_only","args":[{"name":"proposal","type":"trait_reference"}],"outputs":{"type":{"optional":"uint128"}}}, {"name":"is-extension","access":"read_only","args":[{"name":"extension","type":"principal"}],"outputs":{"type":"bool"}}
