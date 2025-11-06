;; Title: BME010 Reputation-Gated Liquidity Contribution
;; Synopsis:
;; Accept STX from contributors and reward them with BIGR reputation tokens
;; Description:
;; Users are rewarded with BIGR by contributing STX to the DAO treasury.
;; BIGR is used to claim BIG through the main reputation contract.
;; The rate is set by the DAO and can be updated as needed.

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.extension-trait.extension-trait)

;; Constants and Errors
(define-constant err-unauthorised (err u5000))
(define-constant err-zero-amount (err u5001))

;; Contract variables
(define-data-var stx-to-bigr-rate uint u1) ;; Default: 1 STX = 1 BIGR

(define-map stx-contributions {who: principal} uint)

;; Authorization check
(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .bigmarket-dao) (contract-call? .bigmarket-dao is-extension contract-caller)) err-unauthorised))
)

;; DAO can update the reward rate
(define-public (set-liquidity-reward-rate (new-rate uint))
  (begin
    (try! (is-dao-or-extension))
    (var-set stx-to-bigr-rate new-rate)
    (ok true)
  )
)
(define-read-only (get-liquidity-reward-rate)
	(var-get stx-to-bigr-rate)
)

(define-public (contribute-stx (amount uint))
  (let (
        (user tx-sender)
        (rate (var-get stx-to-bigr-rate))
        (bigr-earned (* amount rate))
        (existing (default-to u0 (map-get? stx-contributions {who: user})))
    )
    (asserts! (> amount u0) err-zero-amount)

    ;; Transfer STX to the DAO treasury
    (try! (stx-transfer? amount user .bme006-0-treasury))

    ;; Record contribution
    (map-set stx-contributions {who: user} (+ existing amount))

    ;; Mint BIGR to the contributor
    (try! (contract-call? .bme030-0-reputation-token mint user u7 bigr-earned))
    (print {event: "liquidity_contribution", from: user, amount: amount, bigr: bigr-earned})
    (ok bigr-earned)
  )
)

;; Extension trait callback stub
(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)