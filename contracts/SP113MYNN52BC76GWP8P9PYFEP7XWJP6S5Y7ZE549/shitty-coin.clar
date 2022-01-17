;; Simple AF token contract

;; Set Token variables
(define-fungible-token shitty-coin)

(define-read-only (get-name)
  (ok "Shitty"))

(define-read-only (get-decimals)
  (ok u6))

(define-read-only (get-symbol)
  (ok "SHIT"))

(define-read-only (get-token-uri)
  (ok "http://example.com/some.json"))

;; Define and read total supply
(define-data-var total-supply uint u0)

(define-read-only (get-total-supply)
  (var-get total-supply))

;; Mint function
(define-private (mint! (account principal) (amount uint))
  (if (<= amount u0)
      (err u0)
      (begin
        (var-set total-supply (+ (var-get total-supply) amount))
        (ft-mint? shitty-coin amount account))))

;; Transfer function
(define-public (transfer (to principal) (amount uint))
  (if
    (> (ft-get-balance shitty-coin tx-sender) u0)
    (ft-transfer? shitty-coin amount tx-sender to)
    (err u0)))

;; Get balance function
(define-public (balance-of (owner principal))
      (begin
          (print owner)
          (ok (ft-get-balance shitty-coin owner))
      )
    )

;; Initialize the contract
(mint! 'ST113MYNN52BC76GWP8P9PYFEP7XWJP6S5YFQM4ZE u20000000000000)