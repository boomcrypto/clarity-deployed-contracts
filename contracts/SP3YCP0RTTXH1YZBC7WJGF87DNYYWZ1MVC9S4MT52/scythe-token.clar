;; Scythe Coin - Mainnet Version
;; Total supply: 25 million tokens
;; Initial circulation: 3,000 tokens

(define-fungible-token scythe-coin u25000000000000) ;; 25M with 6 decimals

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; SIP-010 Transfer function
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (try! (ft-transfer? scythe-coin amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

;; SIP-010 Read-only functions
(define-read-only (get-name)
    (ok "Scythe Coin")
)

(define-read-only (get-symbol)
    (ok "SCYTHE")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance scythe-coin who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply scythe-coin))
)

(define-read-only (get-token-uri)
    (ok none)
)

;; Mint initial 3,000 tokens (3000000000 base units with 6 decimals)
(define-public (mint-initial-supply (recipient principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ft-mint? scythe-coin u3000000000 recipient)
    )
)

;; Mint additional tokens (owner only, respects 25M cap)
(define-public (mint (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ft-mint? scythe-coin amount recipient)
    )
)