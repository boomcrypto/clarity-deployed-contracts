---
title: "Contract BNS-migrated-helper"
draft: true
---
Deployer: SPPJE6KB9CNCVTS9RAFHY1RSXAH381W8RKJDM9J9

SIP-009: false

SIP-010: false

Functions:
{"name":"get-migrated-names","access":"read_only","args":[{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"name","type":{"buffer":{"length":48}}},{"name":"namespace","type":{"buffer":{"length":20}}}]},"error":{"tuple":[{"name":"code","type":"int128"},{"name":"name","type":{"optional":{"tuple":[{"name":"name","type":{"buffer":{"length":48}}},{"name":"namespace","type":{"buffer":{"length":20}}}]}}}]}}}}}
