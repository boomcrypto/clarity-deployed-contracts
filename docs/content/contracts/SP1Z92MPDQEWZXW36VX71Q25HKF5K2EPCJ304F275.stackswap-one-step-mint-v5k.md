---
title: "Contract stackswap-one-step-mint-v5k"
draft: true
---
Deployer: SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275

SIP-009: false

SIP-010: false

Functions:
{"name":"is-valid-caller","access":"private","args":[{"name":"caller","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"remove-filter","access":"private","args":[{"name":"a","type":"principal"}],"outputs":{"type":"bool"}}, {"name":"remove-liquidity-token-inner","access":"private","args":[{"name":"ritem","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"remove-poxl-token-inner","access":"private","args":[{"name":"ritem","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"remove-soft-token-inner","access":"private","args":[{"name":"ritem","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"add-liquidity-token","access":"public","args":[{"name":"new-token","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"add-liquidity-tokens","access":"public","args":[{"name":"new-tokens","type":{"list":{"type":"principal","length":100}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"add-poxl-token","access":"public","args":[{"name":"new-token","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"add-poxl-tokens","access":"public","args":[{"name":"new-tokens","type":{"list":{"type":"principal","length":100}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"add-soft-token","access":"public","args":[{"name":"new-token","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"add-soft-tokens","access":"public","args":[{"name":"new-tokens","type":{"list":{"type":"principal","length":100}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"create-pair-new-liquidity-token","access":"public","args":[{"name":"token-x-trait","type":"trait_reference"},{"name":"token-y-trait","type":"trait_reference"},{"name":"token-liquidity","type":"trait_reference"},{"name":"pair-name","type":{"string-ascii":{"length":32}}},{"name":"x","type":"uint128"},{"name":"y","type":"uint128"},{"name":"token-liquidity-soft","type":"trait_reference"},{"name":"swap-contract","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"create-pair-new-poxl-token-with-stsw","access":"public","args":[{"name":"token-y-trait","type":"trait_reference"},{"name":"token-liquidity-trait","type":"trait_reference"},{"name":"pair-name","type":{"string-ascii":{"length":32}}},{"name":"x","type":"uint128"},{"name":"y","type":"uint128"},{"name":"token-y-init-trait","type":"trait_reference"},{"name":"token-liquidity-soft","type":"trait_reference"},{"name":"name-to-set","type":{"string-ascii":{"length":32}}},{"name":"symbol-to-set","type":{"string-ascii":{"length":32}}},{"name":"decimals-to-set","type":"uint128"},{"name":"uri-to-set","type":{"string-utf8":{"length":256}}},{"name":"website-to-set","type":{"string-utf8":{"length":256}}},{"name":"initial-amount","type":"uint128"},{"name":"first-stacking-block-to-set","type":"uint128"},{"name":"reward-cycle-lengh-to-set","type":"uint128"},{"name":"token-reward-maturity-to-set","type":"uint128"},{"name":"coinbase-reward-to-set","type":"uint128"},{"name":"swap-contract","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"create-pair-new-poxl-token-with-stx","access":"public","args":[{"name":"token-y-trait","type":"trait_reference"},{"name":"token-liquidity-trait","type":"trait_reference"},{"name":"pair-name","type":{"string-ascii":{"length":32}}},{"name":"x","type":"uint128"},{"name":"y","type":"uint128"},{"name":"token-y-init-trait","type":"trait_reference"},{"name":"token-liquidity-soft","type":"trait_reference"},{"name":"name-to-set","type":{"string-ascii":{"length":32}}},{"name":"symbol-to-set","type":{"string-ascii":{"length":32}}},{"name":"decimals-to-set","type":"uint128"},{"name":"uri-to-set","type":{"string-utf8":{"length":256}}},{"name":"website-to-set","type":{"string-utf8":{"length":256}}},{"name":"initial-amount","type":"uint128"},{"name":"first-stacking-block-to-set","type":"uint128"},{"name":"reward-cycle-lengh-to-set","type":"uint128"},{"name":"token-reward-maturity-to-set","type":"uint128"},{"name":"coinbase-reward-to-set","type":"uint128"},{"name":"swap-contract","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"create-pair-new-sip10-token-with-stsw","access":"public","args":[{"name":"token-y-trait","type":"trait_reference"},{"name":"token-liquidity-trait","type":"trait_reference"},{"name":"pair-name","type":{"string-ascii":{"length":32}}},{"name":"x","type":"uint128"},{"name":"y","type":"uint128"},{"name":"token-y-init-trait","type":"trait_reference"},{"name":"token-liquidity-soft","type":"trait_reference"},{"name":"name-to-set","type":{"string-ascii":{"length":32}}},{"name":"symbol-to-set","type":{"string-ascii":{"length":32}}},{"name":"decimals-to-set","type":"uint128"},{"name":"uri-to-set","type":{"string-utf8":{"length":256}}},{"name":"website-to-set","type":{"string-utf8":{"length":256}}},{"name":"initial-amount","type":"uint128"},{"name":"swap-contract","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"create-pair-new-sip10-token-with-stx","access":"public","args":[{"name":"token-y-trait","type":"trait_reference"},{"name":"token-liquidity-trait","type":"trait_reference"},{"name":"pair-name","type":{"string-ascii":{"length":32}}},{"name":"x","type":"uint128"},{"name":"y","type":"uint128"},{"name":"token-y-init-trait","type":"trait_reference"},{"name":"token-liquidity-soft","type":"trait_reference"},{"name":"name-to-set","type":{"string-ascii":{"length":32}}},{"name":"symbol-to-set","type":{"string-ascii":{"length":32}}},{"name":"decimals-to-set","type":"uint128"},{"name":"uri-to-set","type":{"string-utf8":{"length":256}}},{"name":"website-to-set","type":{"string-utf8":{"length":256}}},{"name":"initial-amount","type":"uint128"},{"name":"swap-contract","type":"trait_reference"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"remove-liquidity-token","access":"public","args":[{"name":"ritem","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"remove-poxl-token","access":"public","args":[{"name":"ritem","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"remove-soft-token","access":"public","args":[{"name":"ritem","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get-liquidity-token-list","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"list":{"type":"principal","length":200}},"error":"none"}}}}, {"name":"get-poxl-token-list","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"list":{"type":"principal","length":200}},"error":"none"}}}}, {"name":"get-soft-token-list","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":{"list":{"type":"principal","length":200}},"error":"none"}}}}