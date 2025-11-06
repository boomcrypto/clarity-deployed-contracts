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
(define-constant err-minimum-stx (err u5002))

(define-constant MICROSTX u1000000)

;; 10,10 -- > 1 STX = 1 BIGR, 10 STX = 3 BIGR, 100 STX = 10 BIGR
(define-data-var stx-to-bigr-rate uint u10)
(define-data-var stx-to-bigr-dampener uint u10)

(define-map stx-contributions {who: principal} uint)

;; Authorization check
(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .bigmarket-dao) (contract-call? .bigmarket-dao is-extension contract-caller)) err-unauthorised))
)

;; DAO can update the reward rate
(define-public (set-liquidity-reward-params (params {rate: uint, dampener: uint}))
  (begin
    (try! (is-dao-or-extension))
    (var-set stx-to-bigr-rate (get rate params))
    (var-set stx-to-bigr-dampener (get dampener params))
    (ok true)
  )
)
;; DAO can update the reward dampener
(define-read-only (get-liquidity-reward-params)
  {
    rate: (var-get stx-to-bigr-rate),
    dampener: (var-get stx-to-bigr-dampener)
  }
)

(define-public (contribute-stx (amount uint))
  (let (
        (user tx-sender)
        (rate (var-get stx-to-bigr-rate))
        (dampener (var-get stx-to-bigr-dampener))
        (amount-stx (/ amount MICROSTX))
        (bigr-earned (/ (* (sqrti amount-stx) rate) dampener))
        (existing (default-to u0 (map-get? stx-contributions {who: user})))
      )
    (asserts! (>= amount MICROSTX) err-minimum-stx)

    (try! (stx-transfer? amount user .bme006-0-treasury))
    (map-set stx-contributions {who: user} (+ existing amount))

    (try! (contract-call? .bme030-0-reputation-token mint user u4 bigr-earned))

    (print {event: "liquidity_contribution", from: user, amount: amount, bigr: bigr-earned})
    (ok bigr-earned)
  )
)

;; Extension trait callback stub
(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)