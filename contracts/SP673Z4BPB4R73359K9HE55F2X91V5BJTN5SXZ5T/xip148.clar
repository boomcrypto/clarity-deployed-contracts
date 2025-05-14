;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)
	
(define-public (execute (sender principal))
	(begin		
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 approve-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridged-rapha, chain-id: u1002 } u"runes::895527:1311" true))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 pause-peg-in { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridged-rapha, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 pause-peg-out { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridged-rapha, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-in-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridged-rapha, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridged-rapha, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-gas-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridged-rapha, chain-id: u1002 } u1034))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-token-no-burn { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridged-rapha, chain-id: u1002 } true))

(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 approve-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u1002 } u"runes::895623:492" true))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 pause-peg-in { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 pause-peg-out { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-in-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-gas-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u1002 } u1033))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-token-no-burn { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u1002 } true))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 approve-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt, chain-id: u1002 } u"runes::895623:492" true))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 pause-peg-in { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 pause-peg-out { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-in-fee { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-fee { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-gas-fee { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt, chain-id: u1002 } u1033))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-token-no-burn { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt, chain-id: u1002 } true))

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
	{ extension: .btc-peg-in-v2-07f-agg, enabled: false }
	{ extension: .cross-peg-out-v2-01b-agg, enabled: false }
	{ extension: .meta-peg-in-v2-06g-agg, enabled: false })))

(try! (contract-call? .btc-peg-in-v2-07f-agg pause-peg-in true))
(try! (contract-call? .cross-peg-out-v2-01b-agg set-paused true))
(try! (contract-call? .meta-peg-in-v2-06g-agg pause true))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-v2-06g-agg false))

(ok true)))
