(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-trait boostx-options-trait (
    (update-bns-contract
        (<nft-trait>)
        (response bool uint)
    )   
    (update-storage-uri
        ((string-utf8 255))
        (response bool uint)
    )
    (set-referee
        ((optional uint) <nft-trait>)
        (response bool uint)
    )
    (update-sponsor
        ((list 3 uint) <nft-trait>)
        (response bool uint)
    )
    (get-options-id-list
        ()
        (response (list 4 uint) (list 0 uint))
    )
))