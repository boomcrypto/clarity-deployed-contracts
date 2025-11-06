;; SPDX-License-Identifier: BUSL-1.1

;; XIP-181: Reduce Bridge Fees for tBTC and WBTC to 25 Basis Points
;; 
;; This proposal reduces the bridge fees for tBTC and WBTC (TOKEN_BTC) from 40 basis points (0.4%)
;; to 25 basis points (0.25%) across all supported chains. This fee reduction aims to improve
;; competitiveness and encourage more Bitcoin-backed token bridging activity.
;;
;; Current fee: 400,000 (40 bps / 0.4%)
;; New fee: 250,000 (25 bps / 0.25%)
;;
;; tBTC fee reductions:
;; - Ethereum (chain 1): 40 bps -> 25 bps
;; - Mezo (chain 18): 40 bps -> 25 bps
;;
;; WBTC (TOKEN_BTC) fee reductions:
;; - Ethereum (chain 1): 40 bps -> 25 bps
;; - BSC (chain 2): 40 bps -> 25 bps
;; - AVAX (chain 12): 40 bps -> 25 bps
;; - Base (chain 16): 40 bps -> 25 bps
;; - Arbitrum (chain 17): 40 bps -> 25 bps
;; - Solana (chain 19): 40 bps -> 25 bps
;;
;; The proposal maintains all other parameters (min-fee, min-amount, max-amount) unchanged
;; to ensure operational stability while reducing the fee burden on users.

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
;; Reduce tBTC fees to 25 bps
(print "Reducing tBTC fee on Ethereum (chain 1) from 40 bps to 25 bps")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-tbtc, chain-id: u1 } { approved: true, burnable: true, fee: u250000, min-fee: u1000, min-amount: u1000, max-amount: u1000000000 }))

(print "Reducing tBTC fee on Mezo (chain 18) from 40 bps to 25 bps")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-tbtc, chain-id: u18 } { approved: true, burnable: true, fee: u250000, min-fee: u1000, min-amount: u1000, max-amount: u1000000000 }))

;; Reduce WBTC (TOKEN_BTC) fees to 25 bps
(print "Reducing WBTC fee on Ethereum (chain 1) from 40 bps to 25 bps")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u1 } { approved: true, burnable: true, fee: u250000, min-fee: u921, min-amount: u921, max-amount: u921854402 }))

(print "Reducing WBTC fee on BSC (chain 2) from 40 bps to 25 bps")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u2 } { approved: true, burnable: true, fee: u250000, min-fee: u921, min-amount: u921, max-amount: u921854402 }))

(print "Reducing WBTC fee on AVAX (chain 12) from 40 bps to 25 bps")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u12 } { approved: true, burnable: true, fee: u250000, min-fee: u921, min-amount: u921, max-amount: u921854402 }))

(print "Reducing WBTC fee on Base (chain 16) from 40 bps to 25 bps")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u16 } { approved: true, burnable: true, fee: u250000, min-fee: u921, min-amount: u921, max-amount: u921854402 }))

(print "Reducing WBTC fee on Arbitrum (chain 17) from 40 bps to 25 bps")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u17 } { approved: true, burnable: true, fee: u250000, min-fee: u921, min-amount: u921, max-amount: u921854402 }))

(print "Reducing WBTC fee on Solana (chain 19) from 40 bps to 25 bps")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u19 } { approved: true, burnable: true, fee: u250000, min-fee: u921, min-amount: u921, max-amount: u921854402 }))

(print "Successfully reduced all tBTC and WBTC fees to 25 basis points (0.25%)")

(ok true)))
