(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)
(use-trait points-trait .points-trait.points)

(define-trait subscriber-trait
    (
        (subscribe (<lookup-trait> uint) (response bool uint))

        (admin-unsubscribe (<lookup-trait> uint) (response bool uint))

        (collect (uint uint <points-trait>) (response bool uint))

        (get-subscribed-nfts-per-address (principal) (response (list 2500 uint) (list 2500 uint)))

        (get-collect (principal) (response uint uint))

        (get-subscribed-items-count () (response uint uint))

        (get-item-subscriber (uint) (response (optional principal) bool))        
    )
)