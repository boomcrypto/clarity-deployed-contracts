;; author: eriq.btc
;; description: activate multiple actions for nft collections
;; license MIT

;; SIP-09 implementation
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait);; 

;; SIP-09 transfer implementation
(define-private (transfer-nft (token-contract <nft-trait>) (id uint) (sender principal) (recipient principal))
  (contract-call? token-contract transfer id sender recipient)
)

;; Helper to loop bulk actions
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

;; Bulk transfer function
(define-public (bulk-transfer (transfers (list 100 {contract: <nft-trait>, id: uint, recipient: principal})))
  (fold check-err (map transfer-single transfers) (ok true))
)

;; helper for single transfer
(define-private (transfer-single (transfer {contract: <nft-trait>, id: uint, recipient: principal}))
    (transfer-nft (get contract transfer) (get id transfer) tx-sender (get recipient transfer))
)

;; Marketplace commission trait
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission) ;; 
(use-trait market-trait .market-trait.market-trait)

;; bulk listing
(define-public (bulk-list-in-ustx 
    (listings (list 100 {contract: <market-trait>, id: uint, price: uint, commission: <commission-trait>})))
    (fold check-err (map list-single listings) (ok true))
)

;; helper for single list
(define-private (list-single (listing {contract: <market-trait>, id: uint, price: uint, commission: <commission-trait>}))
  (let (
    (contract (get contract listing))
    (id (get id listing))
    (price (get price listing))
    (commission (get commission listing))
  )
    (contract-call? contract list-in-ustx id price commission)
  )
)

;; bulk unlisting
(define-public (bulk-unlist-in-ustx
  (listings (list 100 {contract: <market-trait>, id: uint})))
  (fold check-err (map unlist-single listings) (ok true))
)

;; helper for single unlist
(define-private (unlist-single (listing {contract: <market-trait>, id: uint}))
  (let (
    (contract (get contract listing))
    (id (get id listing))
  )
    (contract-call? contract unlist-in-ustx id)
  )
)

;; bulk buy
(define-public (bulk-buy 
  (listings (list 100 {contract: <market-trait>, id: uint, commission: <commission-trait>})))
  (fold check-err (map buy-single listings) (ok true))
)

;; helper for single buy
(define-private (buy-single (listing {contract: <market-trait>, id: uint, commission: <commission-trait>}))
  (let (
    (contract (get contract listing))
    (id (get id listing))
    (commission (get commission listing))
  )
    (contract-call? contract buy-in-ustx id commission)
  )
)

