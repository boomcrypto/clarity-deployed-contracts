---
title: "Trait self-listing-helper-v2-04-a"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.extension-trait.extension-trait)

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant err-token-not-approved (err u1002))

(define-constant ONE_8 u100000000)

(define-public (request-create-and-finalize
    (request-details {
        token-x: principal, token-y: principal, factor: uint,
        bal-x: uint, bal-y: uint,
        fee-rate-x: uint, fee-rate-y: uint,
        max-in-ratio: uint, max-out-ratio: uint,
        threshold-x: uint, threshold-y: uint,
        oracle-enabled: bool, oracle-average: uint,
        start-block: uint,
        memo: (optional (buff 256)),
				lock: (buff 1) }) (token-x-trait <ft-trait>) (token-y-trait <ft-trait>))
	(let (
			(request-id (try! (contract-call? .self-listing-helper-v2-04 request-create-and-fund request-details token-x-trait token-y-trait))))
		(asserts! (contract-call? .self-listing-helper-v2-04 get-approved-token-y-or-default (contract-of token-y-trait)) err-token-not-approved)		
		(as-contract (try! (contract-call? .self-listing-helper-v2-04 approve-request request-id (contract-of token-y-trait) none)))
		(contract-call? .self-listing-helper-v2-04 finalize-request request-id token-x-trait token-y-trait)))

(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true))

;; private calls

```
