(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-constant err-not-authorised (err u1000))
(define-constant err-invalid-token-or-ticker (err u1001))
(define-constant err-invalid-peg-in-address (err u1002))
(define-constant err-invalid-tx (err u1003))
(define-constant err-amount-exceeds-max-len (err u1004))
(define-constant ONE_8 u100000000)
(define-data-var contract-owner principal tx-sender)
(define-data-var fee uint u1000000)
(define-read-only (get-approved-operator-or-default (operator principal))
    (contract-call? .stx20-bridge-registry-v1-01 get-approved-operator-or-default operator))
(define-read-only (get-ticker-to-token-or-fail (ticker (string-ascii 8)))
    (contract-call? .stx20-bridge-registry-v1-01 get-ticker-to-token-or-fail ticker))
(define-read-only (get-token-to-ticker-or-fail (token principal))
    (contract-call? .stx20-bridge-registry-v1-01 get-token-to-ticker-or-fail token))
(define-read-only (get-tx-sent-or-default (tx { txid: (buff 32), from: principal, to: principal, ticker: (string-ascii 8), amount: uint }))
    (contract-call? .stx20-bridge-registry-v1-01 get-tx-sent-or-default tx))
(define-public (set-contract-owner (owner principal))
    (begin 
        (try! (check-is-owner))
        (ok (var-set contract-owner owner))))
(define-public (set-fee (new-fee uint))
    (begin 
        (try! (check-is-owner))
        (ok (var-set fee new-fee))))
(define-public (finalize-peg-in (tx { txid: (buff 32), from: principal, to: principal, ticker: (string-ascii 8), amount: uint }) (token-trait <ft-trait>))
    (begin 
        (asserts! (get-approved-operator-or-default tx-sender) err-not-authorised) ;; only oracle can call this.
        (asserts! (is-eq (get to tx) .stx20-bridge-registry-v1-01) err-invalid-peg-in-address) ;; recipient must be this contract.
        (asserts! (not (get-tx-sent-or-default tx)) err-invalid-tx) ;; it should not have been sent before.
        (asserts! (is-eq (contract-of token-trait) (try! (get-ticker-to-token-or-fail (get ticker tx)))) err-invalid-token-or-ticker) ;; token-trait must be the token for this ticker.        
        (as-contract (try! (contract-call? .stx20-bridge-registry-v1-01 set-tx-sent tx true)))
        (as-contract (contract-call? token-trait mint-fixed (* (get amount tx) ONE_8) (get from tx)))))
(define-public (finalize-peg-out (token-trait <ft-trait>) (amount uint))
    (let (
            (sender tx-sender)
            (ticker (try! (get-token-to-ticker-or-fail (contract-of token-trait))))
            (memo (concat "t" (concat ticker (unwrap! (as-max-len? (int-to-ascii (/ amount ONE_8)) u20) err-amount-exceeds-max-len)))))
        (as-contract (try! (contract-call? token-trait burn-fixed amount sender)))
        (try! (stx-transfer? (var-get fee) tx-sender .stx20-bridge-registry-v1-01))
        (as-contract (try! (contract-call? .stx20-bridge-registry-v1-01 transfer-stx u1 sender (unwrap-panic (to-consensus-buff? memo)))))
        (ok memo)))
        
(define-private (check-is-owner)
    (ok (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorised)))