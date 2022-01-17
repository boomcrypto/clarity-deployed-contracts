;; 'BTC Day' Contract.

(define-constant blocks-per-day u144)

;; If time is in am period, will return true.
;; Otherwise, will return false.
(define-read-only (get-btc-time)
    (let (
        (blocks-minted-today (mod burn-block-height blocks-per-day)))
        (ok (< blocks-minted-today (/ blocks-per-day u2)))
    ))
