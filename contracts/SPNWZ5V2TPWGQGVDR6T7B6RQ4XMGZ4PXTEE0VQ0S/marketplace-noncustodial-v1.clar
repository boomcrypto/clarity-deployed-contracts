(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)
(use-trait marketplace-trait .marketplace-trait.marketplace)

(define-public (list-asset (nft <marketplace-trait>) 
                           (token-id uint) 
                           (price uint)
                           (comm <commission-trait>))
  (contract-call? nft list-in-ustx token-id price comm)
)

(define-public (unlist-asset (nft <marketplace-trait>)
                             (comm <commission-trait>)
                             (token-id uint)
                             (price uint))
  (contract-call? nft unlist-in-ustx token-id)
)

(define-public (purchase-asset (nft <marketplace-trait>)
                               (comm <commission-trait>)
                               (token-id uint))
  (contract-call? nft buy-in-ustx token-id comm)
)

