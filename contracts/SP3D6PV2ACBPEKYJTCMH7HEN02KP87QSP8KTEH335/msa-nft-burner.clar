(define-constant SCRAPYARD .scrapyard)
(define-constant MAX-BURN u200)

(define-public (burn-many (tokens (list 200 uint)))
    (let (
        (count-burned u0)
    )
    (begin
        (fold burn-many-iter tokens count-burned)
        (ok true))))


(define-private (burn-many-iter (token-id uint) (count-burned uint))
    (if (<= count-burned MAX-BURN)
        (begin
            (unwrap! (contract-call? .msa-nft transfer token-id tx-sender SCRAPYARD) count-burned)
            (+ count-burned u1)
        )
        count-burned))
