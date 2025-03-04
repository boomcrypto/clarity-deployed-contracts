;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant TOKEN_TEMPLATE (list 
";; SPDX-License-Identifier: BUSL-1.1\n(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)\n\n(define-constant ERR-NOT-AUTHORIZED (err u1000))\n(define-constant ERR-TRANSFER-FAILED (err u3000))\n(define-constant ERR-NOT-SUPPORTED (err u6004))\n\n;; -- token implementation\n(define-fungible-token wrapped-token)\n(define-constant token-decimals u8)\n\n(define-constant ONE_8 u100000000)\n(define-constant VAULT 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01)\n(define-read-only (get-name) (contract-call? '"
" get-name))\n(define-read-only (get-symbol) (contract-call? '"
" get-symbol))\n(define-read-only (get-base-decimals) (contract-call? '"
" get-decimals))\n(define-read-only (get-token-uri) (contract-call? '"
" get-token-uri))\n(define-read-only (get-balance (who principal)) (if (is-eq who VAULT) (ok (ft-get-balance wrapped-token who)) (ok (decimals-to-fixed (unwrap-panic (contract-call? '"
" get-balance who))))))\n(define-read-only (get-total-supply) (ok (decimals-to-fixed (unwrap-panic (contract-call? '"
" get-total-supply)))))\n(define-read-only (get-decimals) (ok token-decimals))\n(define-read-only (get-total-supply-fixed) (get-total-supply))\n(define-read-only (get-balance-fixed (account principal)) (get-balance account))\n\n(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))\n  (begin\n    (asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)\n\t\t(asserts! (not (is-eq sender recipient)) ERR-TRANSFER-FAILED)\n    (if (is-eq sender VAULT)\n\t\t\t(begin\n\t\t\t\t(try! (ft-burn? wrapped-token amount sender))\n\t\t\t\t(as-contract (contract-call? '"
" transfer (fixed-to-decimals amount) tx-sender recipient memo)))\n\t\t\t(begin\n\t\t\t\t(and (is-eq recipient VAULT) (try! (ft-mint? wrapped-token amount recipient)))\n\t\t\t\t(contract-call? '"
" transfer (fixed-to-decimals amount) tx-sender (if (is-eq recipient VAULT) (as-contract tx-sender) recipient) memo)))))\n\n(define-public (transfer-many (recipients (list 200 { amount: uint, to: principal})))\n  (fold transfer-many-iter recipients (ok true)))\n\n(define-public (transfer-fixed (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))\n  (transfer amount sender recipient memo))\n\n(define-public (transfer-fixed-many (recipients (list 200 { amount: uint, to: principal})))\n  (transfer-many recipients))\n\n(define-public (mint (amount uint) (recipient principal))\n  ERR-NOT-SUPPORTED)\n\n(define-public (burn (amount uint) (sender principal))\n  ERR-NOT-SUPPORTED)\n\n(define-public (mint-fixed (amount uint) (recipient principal))\n  ERR-NOT-SUPPORTED)\n\n(define-public (burn-fixed (amount uint) (sender principal))\n  ERR-NOT-SUPPORTED)\n\n;; private calls\n\n(define-private (transfer-many-iter (recipient { amount: uint, to: principal }) (previous-response (response bool uint)))\n  (match previous-response prev-ok (transfer (get amount recipient) tx-sender (get to recipient) none) prev-err previous-response))\n\n(define-private (pow-decimals)\n  (pow u10 (unwrap-panic (get-base-decimals))))\n\n(define-private (fixed-to-decimals (amount uint))\n  (/ (* amount (pow-decimals)) ONE_8))\n\n(define-private (decimals-to-fixed (amount uint))\n  (/ (* amount ONE_8) (pow-decimals)))"
))

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list 
	{ extension: .self-listing-helper-v3, enabled: false }			
	{ extension: .self-listing-helper-v3a, enabled: true } )))			

(try! (contract-call? .self-listing-helper-v3a approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpomboo true (* u40587174 ONE_8)))
(try! (contract-call? .self-listing-helper-v3a approve-token-x .token-wsbtc true u10000))
(try! (contract-call? .self-listing-helper-v3a approve-token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc true u10000))
(try! (contract-call? .self-listing-helper-v3a approve-token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt true u100000000000))
(try! (contract-call? .self-listing-helper-v3a approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex true u1000000000000))
(try! (contract-call? .self-listing-helper-v3a approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 true u180000000000))
(try! (contract-call? .self-listing-helper-v3a approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot true u8500000000000000000))

(try! (contract-call? .self-listing-helper-v3a set-fee-rebate u50000000))

(try! (contract-call? .self-listing-helper-v3a set-wrapped-token-template TOKEN_TEMPLATE))

		(ok true)))

