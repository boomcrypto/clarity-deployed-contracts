;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-token-mismatch (err u1001))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
	
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 approve-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry, chain-id: u1002 } u"runes::871918:990" true))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 pause-peg-in { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-in-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 pause-peg-out { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-gas-fee { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-token-no-burn { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry, chain-id: u1002 } false))

(ok true)))
