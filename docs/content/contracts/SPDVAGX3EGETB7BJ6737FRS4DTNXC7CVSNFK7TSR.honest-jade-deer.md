---
title: "Contract honest-jade-deer"
draft: true
---
Deployer: SPDVAGX3EGETB7BJ6737FRS4DTNXC7CVSNFK7TSR

SIP-009: false

SIP-010: false

Functions:
{"name":"claim-reward","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"emergency-withdraw","access":"public","args":[],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-user-rewards","access":"read_only","args":[{"name":"user","type":"principal"}],"outputs":{"type":{"optional":{"tuple":[{"name":"event1_1_claimed","type":"bool"},{"name":"event1_2_claimed","type":"bool"},{"name":"event1_3_claimed","type":"bool"},{"name":"stsw_reward","type":"uint128"}]}}}}
