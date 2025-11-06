;; BigMarket play-token
;; A SIP-010 test token with unlimited faucet mint
;; Allows users to earn reputation BIGR while playing!

(impl-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token bmg-play)

(define-data-var token-name (string-ascii 32) "BigMarket Play Token")
(define-data-var token-symbol (string-ascii 10) "BIGPLAY")
(define-data-var token-decimals uint u6)
(define-data-var token-uri (optional (string-utf8 256)) none)

(define-constant max-faucet-amount u10000000000) ;; 10000.000000 PLAY (since 6 decimals)

(define-public (get-name) (ok (var-get token-name)))
(define-public (get-symbol) (ok (var-get token-symbol)))
(define-public (get-decimals) (ok (var-get token-decimals)))

(define-public (get-balance (who principal))
  (ok (ft-get-balance bmg-play who))
)

(define-public (get-total-supply)
  (ok (ft-get-supply bmg-play))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)


;; Standard transfer
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) (err u100))
    (ft-transfer? bmg-play amount sender recipient)
  )
)

;; Faucet: anyone can mint tokens for themselves
(define-public (faucet (amount uint))
  (begin
    (asserts! (<= amount max-faucet-amount) (err u101)) ;; prevent silly mint requests
    (ft-mint? bmg-play amount tx-sender)
  )
)
