(define-constant err-owner-only (err u100))

(define-data-var contract-owner principal tx-sender) ;; TODO: nextOwner
(define-data-var required uint u1)
(define-map validators principal bool)
(define-map valid-chain (buff 256) bool)

(define-read-only (get-contract-owner)
    (var-get contract-owner)
)

(define-read-only (get-required)
    (var-get required)
)

(define-read-only (is-validator (validator principal))
    (unwrap! (map-get? validators validator) false)
)

(define-read-only (is-valid-chain (chain (buff 256)))
    (unwrap! (map-get? valid-chain chain) false)
)

(define-public (set-validator (validator principal) (valid bool))
    (begin
        (asserts! (is-eq tx-sender (get-contract-owner)) err-owner-only)
        (ok (map-set validators validator valid))
    )
)

(define-public (set-required (req uint))
    (begin
        (asserts! (is-eq tx-sender (get-contract-owner)) err-owner-only)
        (ok (var-set required req))
    )
)

(define-public (set-valid-chain (chain (buff 256)) (valid bool))
    (ok (map-set valid-chain chain valid))
)

(map-set valid-chain 0x455448 true)
