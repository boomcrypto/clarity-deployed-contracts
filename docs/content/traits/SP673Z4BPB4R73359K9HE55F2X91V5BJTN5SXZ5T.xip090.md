---
title: "Trait xip090"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-token-mismatch (err u1001))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
	
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u4 } { approved: true, burnable: true, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u2 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u2 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u3 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u3 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u5 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u5 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u6 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u6 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u7 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u7 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u8 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u8 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u9 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u9 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u10 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u10 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u11 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u11 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u12 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u12 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u13 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u13 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u14 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u14 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u15 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u15 } MAX_UINT))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u16 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u5000, max-amount: u10000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-ubtc, chain-id: u16 } MAX_UINT))

(ok true)))

```
