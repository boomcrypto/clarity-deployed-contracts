(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-trait marketplace
    (
        (list-in-ustx (uint uint <commission-trait>) (response bool uint))

        (unlist-in-ustx (uint) (response bool uint))

        (buy-in-ustx (uint <commission-trait>) (response bool uint))
    )
)