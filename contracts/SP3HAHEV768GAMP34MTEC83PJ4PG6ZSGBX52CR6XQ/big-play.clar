;; BigMarket play-token
;; A SIP-010 test token with unlimited faucet mint
;; Allows users to earn reputation BIGR while playing!
;; Allows the initial market creators to mint a pool for market liquidity - ie
;; allows us to simulate stable CPMM curve behaviour.

(impl-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token bmg-play)

(define-data-var token-name (string-ascii 32) "BigMarket Play Token")
(define-data-var token-symbol (string-ascii 10) "BIGPLAY")
(define-data-var token-decimals uint u6)
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-constant contract-owner tx-sender)
(define-constant max-faucet-amount u1000000000) ;; 1000.000000 PLAY (since 6 decimals)
(define-constant seed-amount u10000000000000) ;; 100_000_000.000000 PLAY (for simulating market depth)
(define-data-var seeded bool false)

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

(define-public (seed-once)
  (begin
    (asserts! (not (var-get seeded)) (err u201))
    ;; freeze!
    (var-set seeded true)
    (try! (ft-mint? bmg-play seed-amount contract-owner))
    (try! (ft-mint? bmg-play seed-amount 'SPEZD95XQ194X67C1QJW4PHKDG8F5D66ZCT8BY29))
    (try! (ft-mint? bmg-play seed-amount 'SP2XFH8D1MM2G11C0S6AZRSNP031RAY92XCARPRSQ))
    (try! (ft-mint? bmg-play seed-amount 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z))
    (try! (ft-mint? bmg-play seed-amount 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9))
    (try! (ft-mint? bmg-play seed-amount 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D))
    (ok true)
  )
)
