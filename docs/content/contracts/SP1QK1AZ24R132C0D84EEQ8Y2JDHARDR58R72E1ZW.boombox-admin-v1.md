---
title: "Contract boombox-admin-v1"
draft: true
---
Deployer: SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW

SIP-009: false

SIP-010: false

Functions:
{"name":"delegatedly-stack","access":"private","args":[{"name":"id","type":"uint128"},{"name":"nft-id","type":"uint128"},{"name":"stacker","type":"principal"},{"name":"amount-ustx","type":"uint128"},{"name":"pox-addr","type":{"tuple":[{"name":"hashbytes","type":{"buffer":{"length":20}}},{"name":"version","type":{"buffer":{"length":1}}}]}},{"name":"locking-period","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"id","type":"uint128"},{"name":"nft-id","type":"uint128"},{"name":"pox","type":{"tuple":[{"name":"lock-amount","type":"uint128"},{"name":"stacker","type":"principal"},{"name":"unlock-burn-height","type":"uint128"}]}}]},"error":"uint128"}}}}, {"name":"get-total-stacked","access":"private","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"optional":"uint128"}}}, {"name":"get-total-stacked-ustx","access":"private","args":[{"name":"id","type":"uint128"},{"name":"nfts","type":{"list":{"type":"uint128","length":750}}}],"outputs":{"type":{"tuple":[{"name":"id","type":"uint128"},{"name":"total","type":"uint128"}]}}}, {"name":"halt-boombox","access":"private","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"pox-delegate-stx-and-stack","access":"private","args":[{"name":"amount-ustx","type":"uint128"},{"name":"pox-addr","type":{"tuple":[{"name":"hashbytes","type":{"buffer":{"length":20}}},{"name":"version","type":{"buffer":{"length":1}}}]}},{"name":"locking-period","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"lock-amount","type":"uint128"},{"name":"stacker","type":"principal"},{"name":"unlock-burn-height","type":"uint128"}]},"error":"uint128"}}}}, {"name":"sum-stacked-ustx","access":"private","args":[{"name":"nft-id","type":"uint128"},{"name":"ctx","type":{"tuple":[{"name":"id","type":"uint128"},{"name":"total","type":"uint128"}]}}],"outputs":{"type":{"tuple":[{"name":"id","type":"uint128"},{"name":"total","type":"uint128"}]}}}, {"name":"add-boombox","access":"public","args":[{"name":"nft-contract","type":"trait_reference"},{"name":"cycle","type":"uint128"},{"name":"locking-period","type":"uint128"},{"name":"minimum-amount","type":"uint128"},{"name":"pox-addr","type":{"tuple":[{"name":"hashbytes","type":{"buffer":{"length":20}}},{"name":"version","type":{"buffer":{"length":1}}}]}},{"name":"owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"allow-contract-caller","access":"public","args":[{"name":"this-contract","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"delegate-stx","access":"public","args":[{"name":"id","type":"uint128"},{"name":"fq-contract","type":"trait_reference"},{"name":"amount-ustx","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"id","type":"uint128"},{"name":"nft-id","type":"uint128"},{"name":"pox","type":{"tuple":[{"name":"lock-amount","type":"uint128"},{"name":"stacker","type":"principal"},{"name":"unlock-burn-height","type":"uint128"}]}}]},"error":"uint128"}}}}, {"name":"get-total-stacked-ustx-at-block","access":"public","args":[{"name":"id","type":"uint128"},{"name":"nfts","type":{"list":{"type":"uint128","length":750}}},{"name":"stacks-tip","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"id","type":"uint128"},{"name":"total","type":"uint128"}]},"error":"uint128"}}}}, {"name":"nft-details","access":"public","args":[{"name":"id","type":"uint128"},{"name":"fq-contract","type":"trait_reference"},{"name":"nft-id","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"owner","type":{"optional":"principal"}},{"name":"stacked-ustx","type":"uint128"}]},"error":"uint128"}}}}, {"name":"nft-details-at-block","access":"public","args":[{"name":"id","type":"uint128"},{"name":"fq-contract","type":"trait_reference"},{"name":"nft-id","type":"uint128"},{"name":"stacks-tip","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"owner","type":{"optional":"principal"}},{"name":"stacked-ustx","type":"uint128"}]},"error":"uint128"}}}}, {"name":"stack-aggregation-commit","access":"public","args":[{"name":"pox-addr","type":{"tuple":[{"name":"hashbytes","type":{"buffer":{"length":20}}},{"name":"version","type":{"buffer":{"length":1}}}]}},{"name":"reward-cycle","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"burn-height-to-reward-cycle","access":"read_only","args":[{"name":"height","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"current-cycle","access":"read_only","args":[],"outputs":{"type":"uint128"}}, {"name":"get-boombox-by-contract","access":"read_only","args":[{"name":"fq-contract","type":"trait_reference"},{"name":"cycle","type":"uint128"}],"outputs":{"type":{"optional":"uint128"}}}, {"name":"get-boombox-by-id","access":"read_only","args":[{"name":"id","type":"uint128"}],"outputs":{"type":{"optional":{"tuple":[{"name":"active","type":"bool"},{"name":"cycle","type":"uint128"},{"name":"fq-contract","type":"principal"},{"name":"locking-period","type":"uint128"},{"name":"minimum-amount","type":"uint128"},{"name":"owner","type":"principal"},{"name":"pox-addr","type":{"tuple":[{"name":"hashbytes","type":{"buffer":{"length":20}}},{"name":"version","type":{"buffer":{"length":1}}}]}}]}}}}, {"name":"reward-cycle-to-burn-height","access":"read_only","args":[{"name":"cycle","type":"uint128"}],"outputs":{"type":"uint128"}}