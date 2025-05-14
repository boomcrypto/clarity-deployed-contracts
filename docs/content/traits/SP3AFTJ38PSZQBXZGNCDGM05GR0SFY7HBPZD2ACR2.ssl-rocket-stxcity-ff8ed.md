---
title: "Trait ssl-rocket-stxcity-ff8ed"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-NOT-SUPPORTED (err u6004))

;; -- token implementation
(define-fungible-token wrapped-token)
(define-constant token-decimals u8)

(define-constant ONE_8 u100000000)
(define-constant VAULT 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01)
(define-read-only (get-name) (contract-call? 'SP3AFTJ38PSZQBXZGNCDGM05GR0SFY7HBPZD2ACR2.rocket-stxcity get-name))
(define-read-only (get-symbol) (contract-call? 'SP3AFTJ38PSZQBXZGNCDGM05GR0SFY7HBPZD2ACR2.rocket-stxcity get-symbol))
(define-read-only (get-base-decimals) (contract-call? 'SP3AFTJ38PSZQBXZGNCDGM05GR0SFY7HBPZD2ACR2.rocket-stxcity get-decimals))
(define-read-only (get-token-uri) (contract-call? 'SP3AFTJ38PSZQBXZGNCDGM05GR0SFY7HBPZD2ACR2.rocket-stxcity get-token-uri))
(define-read-only (get-balance (who principal)) (if (is-eq who VAULT) (ok (ft-get-balance wrapped-token who)) (ok (decimals-to-fixed (unwrap-panic (contract-call? 'SP3AFTJ38PSZQBXZGNCDGM05GR0SFY7HBPZD2ACR2.rocket-stxcity get-balance who))))))
(define-read-only (get-total-supply) (ok (decimals-to-fixed (unwrap-panic (contract-call? 'SP3AFTJ38PSZQBXZGNCDGM05GR0SFY7HBPZD2ACR2.rocket-stxcity get-total-supply)))))
(define-read-only (get-decimals) (ok token-decimals))
(define-read-only (get-total-supply-fixed) (get-total-supply))
(define-read-only (get-balance-fixed (account principal)) (get-balance account))

(define-read-only (get-base-token)
  'SP3AFTJ38PSZQBXZGNCDGM05GR0SFY7HBPZD2ACR2.rocket-stxcity)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)
		(asserts! (not (is-eq sender recipient)) ERR-TRANSFER-FAILED)
    (if (is-eq sender VAULT)
			(begin
				(try! (ft-burn? wrapped-token amount sender))
				(as-contract (contract-call? 'SP3AFTJ38PSZQBXZGNCDGM05GR0SFY7HBPZD2ACR2.rocket-stxcity transfer (fixed-to-decimals amount) tx-sender recipient memo)))
			(begin
				(and (is-eq recipient VAULT) (try! (ft-mint? wrapped-token amount recipient)))
				(contract-call? 'SP3AFTJ38PSZQBXZGNCDGM05GR0SFY7HBPZD2ACR2.rocket-stxcity transfer (fixed-to-decimals amount) tx-sender (if (is-eq recipient VAULT) (as-contract tx-sender) recipient) memo)))))

(define-public (transfer-many (recipients (list 200 { amount: uint, to: principal})))
  (fold transfer-many-iter recipients (ok true)))

(define-public (transfer-fixed (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (transfer amount sender recipient memo))

(define-public (transfer-fixed-many (recipients (list 200 { amount: uint, to: principal})))
  (transfer-many recipients))

(define-public (mint (amount uint) (recipient principal))
  ERR-NOT-SUPPORTED)

(define-public (burn (amount uint) (sender principal))
  ERR-NOT-SUPPORTED)

(define-public (mint-fixed (amount uint) (recipient principal))
  ERR-NOT-SUPPORTED)

(define-public (burn-fixed (amount uint) (sender principal))
  ERR-NOT-SUPPORTED)

;; private calls

(define-private (transfer-many-iter (recipient { amount: uint, to: principal }) (previous-response (response bool uint)))
  (match previous-response prev-ok (transfer (get amount recipient) tx-sender (get to recipient) none) prev-err previous-response))

(define-private (pow-decimals)
  (pow u10 (unwrap-panic (get-base-decimals))))

(define-private (fixed-to-decimals (amount uint))
  (/ (* amount (pow-decimals)) ONE_8))

(define-private (decimals-to-fixed (amount uint))
  (/ (* amount ONE_8) (pow-decimals)))
```
