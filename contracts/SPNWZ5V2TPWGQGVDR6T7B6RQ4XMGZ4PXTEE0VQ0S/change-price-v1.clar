(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait tradables-trait .tradable-trait.tradables-trait)

(define-trait marketplace-unlist-type-a 
  (
    (unlist-asset (<tradables-trait> uint) (response bool uint))
  )
)
  
(define-trait marketplace-unlist-type-b 
  (
    (unlist-item (<nft-trait> uint uint) (response bool uint))
  )
)
  
(define-trait marketplace-unlist-type-c 
  (
    (unlist-item (<nft-trait> (string-ascii 256) uint) (response bool uint))
  )
)

(define-trait marketplace-list 
  (
    (list-asset (<tradables-trait> uint uint uint) (response bool uint))
  )
)
  
(define-public (change-price-a (first-marketplace <marketplace-unlist-type-a>) (second-marketplace <marketplace-list>)  
                               (tradables <tradables-trait>) (tradable-id uint) (new-price uint) (commission uint))
  (begin
    (try! (contract-call? first-marketplace unlist-asset tradables tradable-id))
    (contract-call? second-marketplace list-asset tradables tradable-id new-price commission)
  )
)

(define-public (change-price-b (first-marketplace <marketplace-unlist-type-b>) (second-marketplace <marketplace-list>) 
                               (collection <nft-trait>) (collection-id uint) (item-id uint)
                               (tradables <tradables-trait>) (new-price uint) (commission uint))
  (begin
    (try! (contract-call? first-marketplace unlist-item collection collection-id item-id))
    (contract-call? second-marketplace list-asset tradables item-id new-price commission)
  )
)

(define-public (change-price-c (first-marketplace <marketplace-unlist-type-c>) (second-marketplace <marketplace-list>) 
                               (collection <nft-trait>) (collection-id (string-ascii 256)) (item-id uint)
                               (tradables <tradables-trait>) (new-price uint) (commission uint))
  (begin
    (try! (contract-call? first-marketplace unlist-item collection collection-id item-id))
    (contract-call? second-marketplace list-asset tradables item-id new-price commission)
  )
)
