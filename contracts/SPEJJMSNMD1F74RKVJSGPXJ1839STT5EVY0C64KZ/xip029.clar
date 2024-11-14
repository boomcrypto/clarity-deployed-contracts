;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000)
(define-constant MAX_UINT u240282366920938463463374607431768211455)

(define-public (execute (sender principal))
	(begin	
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u10 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: MAX_UINT }))		
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.mint-for-vault-v2-01 mint-for-vault 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc (* u200 ONE_8) u10 0x0055797647eA5aE4977bB8CB444E8D7ac1b20fB3 0x00145aad24d11c4d5ac6576c9c1c4b1ed0ee797a1897))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u10 } { approved: true, burnable: false, fee: u250000, min-fee: u5000, min-amount: u5000, max-amount: u2000000000 }))
		(ok true)))
