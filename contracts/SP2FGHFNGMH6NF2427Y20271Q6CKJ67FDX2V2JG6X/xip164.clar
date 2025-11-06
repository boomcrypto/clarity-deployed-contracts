;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
  { extension: .token-usdg, enabled: true }
	{ extension: .token-usdc, enabled: true }
	{ extension: .token-xbtc, enabled: true }
)))	
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-router-v2-03 add-wrapped .token-usdg 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-router-v2-03 add-wrapped .token-usdc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-router-v2-03 add-wrapped .token-xbtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc))

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u19 } { approved: true, burnable: true, fee: u100000, min-fee: u100000000, min-amount: u100000000, max-amount: u100000000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u19 } { approved: true, burnable: true, fee: u100000, min-fee: u949, min-amount: u949, max-amount: u949325029 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-sol, chain-id: u19 } { approved: true, burnable: true, fee: u100000, min-fee: u823655, min-amount: u823655, max-amount: u823655382587 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-usdc, chain-id: u19 } { approved: true, burnable: true, fee: u100000, min-fee: u100000000, min-amount: u100000000, max-amount: u100000000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-usdg, chain-id: u19 } { approved: true, burnable: true, fee: u100000, min-fee: u100000000, min-amount: u100000000, max-amount: u100000000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-xbtc, chain-id: u19 } { approved: true, burnable: true, fee: u100000, min-fee: u1000, min-amount: u1000, max-amount: u1000000000 }))

(ok true)))
