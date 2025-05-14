;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)
	
(define-public (execute (sender principal))
	(begin		
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 approve-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.bridged-trenches, chain-id: u1002 } u"runes::896270:1971" true))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 pause-peg-in { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.bridged-trenches, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 pause-peg-out { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.bridged-trenches, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-in-fee { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.bridged-trenches, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-fee { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.bridged-trenches, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-gas-fee { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.bridged-trenches, chain-id: u1002 } u969))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-token-no-burn { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.bridged-trenches, chain-id: u1002 } true))

(ok true)))
