---
title: "Contract stxswap_v8"
draft: true
---
Deployer: SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY

SIP-009: false

SIP-010: false

Functions:
{"name":"add-and-shift-uint-le","access":"private","args":[{"name":"idx","type":"uint128"},{"name":"input","type":{"tuple":[{"name":"acc","type":"uint128"},{"name":"data","type":{"buffer":{"length":16}}}]}}],"outputs":{"type":{"tuple":[{"name":"acc","type":"uint128"},{"name":"data","type":{"buffer":{"length":16}}}]}}}, {"name":"buff-to-u8","access":"private","args":[{"name":"byte","type":{"buffer":{"length":1}}}],"outputs":{"type":"uint128"}}, {"name":"checkSwapIsLocked","access":"private","args":[{"name":"hash","type":{"buffer":{"length":32}}}],"outputs":{"type":"bool"}}, {"name":"hashValuesbuf","access":"private","args":[{"name":"preimageHash","type":{"buffer":{"length":32}}},{"name":"amount","type":{"buffer":{"length":16}}},{"name":"timelock","type":{"buffer":{"length":16}}}],"outputs":{"type":{"buffer":{"length":32}}}}, {"name":"claimStx","access":"public","args":[{"name":"preimage","type":{"buffer":{"length":32}}},{"name":"amount","type":{"buffer":{"length":16}}},{"name":"claimAddress","type":{"buffer":{"length":42}}},{"name":"refundAddress","type":{"buffer":{"length":42}}},{"name":"timelock","type":{"buffer":{"length":16}}}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"lockStx","access":"public","args":[{"name":"preimageHash","type":{"buffer":{"length":32}}},{"name":"amount","type":{"buffer":{"length":16}}},{"name":"claimAddress","type":{"buffer":{"length":42}}},{"name":"refundAddress","type":{"buffer":{"length":42}}},{"name":"timelock","type":{"buffer":{"length":16}}},{"name":"claimPrincipal","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"bool"}}}}, {"name":"refundStx","access":"public","args":[{"name":"preimageHash","type":{"buffer":{"length":32}}},{"name":"amount","type":{"buffer":{"length":16}}},{"name":"claimAddress","type":{"buffer":{"length":42}}},{"name":"refundAddress","type":{"buffer":{"length":42}}},{"name":"timelock","type":{"buffer":{"length":16}}}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"buff-to-uint-le","access":"read_only","args":[{"name":"word","type":{"buffer":{"length":16}}}],"outputs":{"type":"uint128"}}
