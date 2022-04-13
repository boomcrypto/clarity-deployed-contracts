---
title: "Contract weighted-equation"
draft: true
---
Deployer: SP1P712A95CRHVZEQ8E4EPXJJNN41P3MAB0RPBATS

SIP-009: false

SIP-010: false

Functions:
{"name":"accumulate_division","access":"private","args":[{"name":"x_a_pre","type":{"tuple":[{"name":"a_pre","type":"int128"},{"name":"use_deci","type":"bool"},{"name":"x_pre","type":"int128"}]}},{"name":"rolling_a_sum","type":{"tuple":[{"name":"a","type":"int128"},{"name":"sum","type":"int128"}]}}],"outputs":{"type":{"tuple":[{"name":"a","type":"int128"},{"name":"sum","type":"int128"}]}}}, {"name":"accumulate_product","access":"private","args":[{"name":"x_a_pre","type":{"tuple":[{"name":"a_pre","type":"int128"},{"name":"use_deci","type":"bool"},{"name":"x_pre","type":"int128"}]}},{"name":"rolling_x_p","type":{"tuple":[{"name":"product","type":"int128"},{"name":"x","type":"int128"}]}}],"outputs":{"type":{"tuple":[{"name":"product","type":"int128"},{"name":"x","type":"int128"}]}}}, {"name":"exp-pos","access":"private","args":[{"name":"x","type":"int128"}],"outputs":{"type":{"response":{"ok":"int128","error":"uint128"}}}}, {"name":"ln-priv","access":"private","args":[{"name":"a","type":"int128"}],"outputs":{"type":{"response":{"ok":"int128","error":"none"}}}}, {"name":"pow-priv","access":"private","args":[{"name":"x","type":"uint128"},{"name":"y","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"rolling_div_sum","access":"private","args":[{"name":"n","type":"int128"},{"name":"rolling","type":{"tuple":[{"name":"seriesSum","type":"int128"},{"name":"term","type":"int128"},{"name":"x","type":"int128"}]}}],"outputs":{"type":{"tuple":[{"name":"seriesSum","type":"int128"},{"name":"term","type":"int128"},{"name":"x","type":"int128"}]}}}, {"name":"rolling_sum_div","access":"private","args":[{"name":"n","type":"int128"},{"name":"rolling","type":{"tuple":[{"name":"num","type":"int128"},{"name":"seriesSum","type":"int128"},{"name":"z_squared","type":"int128"}]}}],"outputs":{"type":{"tuple":[{"name":"num","type":"int128"},{"name":"seriesSum","type":"int128"},{"name":"z_squared","type":"int128"}]}}}, {"name":"set-contract-owner","access":"public","args":[{"name":"new-contract-owner","type":"principal"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-max-in-ratio","access":"public","args":[{"name":"new-max-in-ratio","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"set-max-out-ratio","access":"public","args":[{"name":"new-max-out-ratio","type":"uint128"}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"div-down","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"div-up","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"exp-fixed","access":"read_only","args":[{"name":"x","type":"int128"}],"outputs":{"type":{"response":{"ok":"int128","error":"uint128"}}}}, {"name":"get-contract-owner","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"principal","error":"none"}}}}, {"name":"get-exp-bound","access":"read_only","args":[],"outputs":{"type":{"response":{"ok":"uint128","error":"none"}}}}, {"name":"get-invariant","access":"read_only","args":[{"name":"balance-x","type":"uint128"},{"name":"balance-y","type":"uint128"},{"name":"weight-x","type":"uint128"},{"name":"weight-y","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"get-max-in-ratio","access":"read_only","args":[],"outputs":{"type":"uint128"}}, {"name":"get-max-out-ratio","access":"read_only","args":[],"outputs":{"type":"uint128"}}, {"name":"get-position-given-burn","access":"read_only","args":[{"name":"balance-x","type":"uint128"},{"name":"balance-y","type":"uint128"},{"name":"weight-x","type":"uint128"},{"name":"weight-y","type":"uint128"},{"name":"total-supply","type":"uint128"},{"name":"token","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"dx","type":"uint128"},{"name":"dy","type":"uint128"}]},"error":"uint128"}}}}, {"name":"get-position-given-mint","access":"read_only","args":[{"name":"balance-x","type":"uint128"},{"name":"balance-y","type":"uint128"},{"name":"weight-x","type":"uint128"},{"name":"weight-y","type":"uint128"},{"name":"total-supply","type":"uint128"},{"name":"token","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"dx","type":"uint128"},{"name":"dy","type":"uint128"}]},"error":"uint128"}}}}, {"name":"get-token-given-position","access":"read_only","args":[{"name":"balance-x","type":"uint128"},{"name":"balance-y","type":"uint128"},{"name":"weight-x","type":"uint128"},{"name":"weight-y","type":"uint128"},{"name":"total-supply","type":"uint128"},{"name":"dx","type":"uint128"},{"name":"dy","type":"uint128"}],"outputs":{"type":{"response":{"ok":{"tuple":[{"name":"dy","type":"uint128"},{"name":"token","type":"uint128"}]},"error":"uint128"}}}}, {"name":"get-x-given-price","access":"read_only","args":[{"name":"balance-x","type":"uint128"},{"name":"balance-y","type":"uint128"},{"name":"weight-x","type":"uint128"},{"name":"weight-y","type":"uint128"},{"name":"price","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"get-x-given-y","access":"read_only","args":[{"name":"balance-x","type":"uint128"},{"name":"balance-y","type":"uint128"},{"name":"weight-x","type":"uint128"},{"name":"weight-y","type":"uint128"},{"name":"dy","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"get-y-given-price","access":"read_only","args":[{"name":"balance-x","type":"uint128"},{"name":"balance-y","type":"uint128"},{"name":"weight-x","type":"uint128"},{"name":"weight-y","type":"uint128"},{"name":"price","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"get-y-given-x","access":"read_only","args":[{"name":"balance-x","type":"uint128"},{"name":"balance-y","type":"uint128"},{"name":"weight-x","type":"uint128"},{"name":"weight-y","type":"uint128"},{"name":"dx","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"mul-down","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"mul-up","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"pow-down","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}, {"name":"pow-fixed","access":"read_only","args":[{"name":"x","type":"uint128"},{"name":"y","type":"uint128"}],"outputs":{"type":{"response":{"ok":"uint128","error":"uint128"}}}}, {"name":"pow-up","access":"read_only","args":[{"name":"a","type":"uint128"},{"name":"b","type":"uint128"}],"outputs":{"type":"uint128"}}