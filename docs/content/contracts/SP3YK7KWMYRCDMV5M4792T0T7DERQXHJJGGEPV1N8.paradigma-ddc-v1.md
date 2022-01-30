---
title: "Contract paradigma-ddc-v1"
draft: true
---
Deployer: SP3YK7KWMYRCDMV5M4792T0T7DERQXHJJGGEPV1N8

SIP-009: false

SIP-010: false

Functions:
{"name":"is-authorized-local-owner","access":"private","args":[],"outputs":{"type":"bool"}}, {"name":"create-authorized-remote-callers-to-execute","access":"public","args":[{"name":"remoteCallerPrincipal","type":"principal"},{"name":"executePrincipal","type":"principal"},{"name":"auth","type":"bool"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"delete-authorized-remote-callers-to-execute","access":"public","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-authorized-remote-callers-to-execute-count","access":"read_only","args":[],"outputs":{"type":"uint128"}}, {"name":"get-authorized-remote-callers-to-execute-index","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"optional":{"tuple":[{"name":"executePrincipal","type":"principal"},{"name":"remoteCallerPrincipal","type":"principal"}]}}}}, {"name":"get-ref-remote-authorized-callers-to-execute","access":"read_only","args":[{"name":"remoteCallerPrincipal","type":"principal"},{"name":"executePrincipal","type":"principal"}],"outputs":{"type":{"optional":{"tuple":[{"name":"auth","type":"bool"}]}}}}, {"name":"is-remote-caller-authorized-to-execute","access":"read_only","args":[{"name":"remoteCallerPrincipal","type":"principal"}],"outputs":{"type":"bool"}}
