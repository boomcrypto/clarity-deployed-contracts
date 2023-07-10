;; INTERNAL VARIABLES
(define-constant CONTRACT-OWNER tx-sender)

;; ERROR CODES
(define-constant ERROR-NOT-AUTHORIZED u1)
(define-constant ERROR-NOT-FOUND u2)
(define-constant ERROR-COLLECTION-NOT-AUTHORIZED u3)
(define-constant ERROR-USER-NOT-AUTHORIZED u4)

;; Public
(define-public (burn-to-redeem (contract-addr principal) (nft-id uint))
    (let
        (
            (is-authorised-contract (is-eq 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-parrots contract-addr))
        )
        (begin
            (asserts! (is-eq is-authorised-contract true) (err ERROR-COLLECTION-NOT-AUTHORIZED))
            ;; (asserts! (is-eq (unwrap! (unwrap! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-parrots get-owner nft-id) (err ERROR-USER-NOT-AUTHORIZED)) (err ERROR-USER-NOT-AUTHORIZED)) tx-sender) (err ERROR-NOT-AUTHORIZED))
            ;; (print (map-get? authorised-collections contract-addr))
        )
        ;; (print nft-id)
        (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-parrots get-owner nft-id)
    )
)