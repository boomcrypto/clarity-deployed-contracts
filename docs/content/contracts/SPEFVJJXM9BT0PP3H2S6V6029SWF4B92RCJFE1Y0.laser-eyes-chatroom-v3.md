---
title: "Contract laser-eyes-chatroom-v3"
draft: true
---
Deployer: SPEFVJJXM9BT0PP3H2S6V6029SWF4B92RCJFE1Y0

SIP-009: false

SIP-010: false

Functions:
{"name":"loop_latest","access":"private","args":[{"name":"i","type":"uint128"},{"name":"ud","type":{"tuple":[{"name":"i","type":"uint128"},{"name":"r","type":{"list":{"type":{"tuple":[{"name":"msg","type":{"buffer":{"length":120}}},{"name":"ud","type":"uint128"}]},"length":12}}}]}}],"outputs":{"type":{"tuple":[{"name":"i","type":"uint128"},{"name":"r","type":{"list":{"type":{"tuple":[{"name":"msg","type":{"buffer":{"length":120}}},{"name":"ud","type":"uint128"}]},"length":12}}}]}}}, {"name":"chat","access":"public","args":[{"name":"msg","type":{"buffer":{"length":120}}}],"outputs":{"type":{"response":{"ok":"bool","error":"uint128"}}}}, {"name":"get_chat","access":"read_only","args":[{"name":"key","type":"uint128"}],"outputs":{"type":{"optional":{"tuple":[{"name":"msg","type":{"buffer":{"length":120}}},{"name":"ud","type":"uint128"}]}}}}, {"name":"get_chat_index","access":"read_only","args":[],"outputs":{"type":"uint128"}}, {"name":"get_chats","access":"read_only","args":[{"name":"keys","type":{"list":{"type":"uint128","length":25}}}],"outputs":{"type":{"list":{"type":{"optional":{"tuple":[{"name":"msg","type":{"buffer":{"length":120}}},{"name":"ud","type":"uint128"}]}},"length":25}}}}, {"name":"get_summary","access":"read_only","args":[{"name":"player","type":{"optional":"principal"}}],"outputs":{"type":{"tuple":[{"name":"index","type":"uint128"},{"name":"latest","type":{"list":{"type":{"tuple":[{"name":"msg","type":{"buffer":{"length":120}}},{"name":"ud","type":"uint128"}]},"length":12}}},{"name":"p","type":{"tuple":[{"name":"meta","type":{"optional":{"tuple":[{"name":"bio","type":{"buffer":{"length":80}}},{"name":"cid","type":{"string-ascii":{"length":64}}},{"name":"minor_name","type":{"buffer":{"length":25}}},{"name":"name","type":{"buffer":{"length":25}}},{"name":"ud","type":"uint128"}]}}},{"name":"tid","type":"uint128"}]}}]}}}
