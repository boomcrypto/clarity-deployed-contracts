
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-public (accept-bid (item-id uint) (contract principal) (approval bool) (collection <nft-trait>) (collection-id (string-ascii 256)))
  (let (
    (approved (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 set-approved item-id contract approval))
  )
    (contract-call? 'SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH.byzantion-market-v6 accept-bid collection collection-id item-id)
  )
)

(define-public (accept-collection-bid (item-id uint) (contract principal) (approval bool) (collection <nft-trait>) (collection-id (string-ascii 256)))
  (let (
    (approved (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 set-approved item-id contract approval))
  )
    (contract-call? 'SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH.byzantion-market-v6 accept-collection-bid collection collection-id item-id)
  )
)