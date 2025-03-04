;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
{ extension: .btc-peg-in-endpoint-v2-05-lisa, enabled: true }
{ extension: .meta-peg-in-endpoint-v2-04-lisa, enabled: true }
{ extension: .liabtc-mint-endpoint, enabled: true })))

(try! (contract-call? .btc-peg-in-endpoint-v2-05-lisa pause-peg-in false))
(try! (contract-call? .meta-peg-in-endpoint-v2-04-lisa pause false))
(try! (contract-call? .meta-peg-in-endpoint-v2-04-lisa set-fee-to-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao))

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-endpoint-v2-04-lisa true))

(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 approve-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-vliabtc, chain-id: u1001 } u"vliab" true))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 pause-peg-in { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-vliabtc, chain-id: u1001 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-in-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-vliabtc, chain-id: u1001 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 pause-peg-out { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-vliabtc, chain-id: u1001 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-vliabtc, chain-id: u1001 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-gas-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-vliabtc, chain-id: u1001 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-token-no-burn { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-vliabtc, chain-id: u1001 } true))

(try! (contract-call? .xlink-staking set-approved-token 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc true))
(try! (contract-call? .xlink-staking set-block-threshold u500))
(try! (contract-call? .xlink-staking set-required-validators u4))
(try! (contract-call? .xlink-staking add-validator 'SPXXE649XHZHZR6ZK9PTRHNXSFDKVJ4WRSSE7HPA  { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, pubkey: 0x02054a9c621cfd0fe8ecabab155c7e031004f5728d28c779cf72a6622df75aecba }))
(try! (contract-call? .xlink-staking add-validator 'SP1NZK5MA1WNR777MTVQTT758BGQ5FAMJXCG2FVBS  { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, pubkey: 0x039681c7cc187144641a85757e3e5e6344a131ac6da615272ab353f2c28c355b37 }))
(try! (contract-call? .xlink-staking add-validator 'SP33TEVJ1VAG6JTJ7RD2MAQ64WACT4Z5MV7NAXN69  { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, pubkey: 0x032eec59051333ac290cab7c03316758f50fbb4204920605d82cade3560e1b3df9 }))
(try! (contract-call? .xlink-staking add-validator 'SPTHNGNM0TSC5FBK6JN02NKA49NKW71TWYTQK1W7  { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, pubkey: 0x039e8a6011cc557d249bcc313797e21351d9f59654d469617a8f9ec9583a4cb870 }))
(try! (contract-call? .xlink-staking add-validator 'SP2TMQF8SFFR2RFH142DZSZG58H76DAB2FPFTPDMM  { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, pubkey: 0x0317a23328090a9f927258a30329834b1acbb0c265ac0af1f45fbf465230f7caaa }))
(try! (contract-call? .xlink-staking set-paused false))

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee u250000))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee u5000))
(try! (contract-call? .btc-peg-in-endpoint-v2-05 set-peg-in-fee u0))
(try! (contract-call? .btc-peg-in-endpoint-v2-05 set-peg-in-min-fee u0))
(ok true)))
