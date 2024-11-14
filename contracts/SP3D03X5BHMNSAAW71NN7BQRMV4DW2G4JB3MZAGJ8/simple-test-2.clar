(impl-trait .sip-09.nft-trait)
(use-trait commission-trait .commission-trait.commission)
(define-non-fungible-token test uint)
(define-constant token-uri "https://gateway.pinata.cloud/ipfs/QmWKTZEMQNWngp23i7bgPzkineYC9LDvcxYkwNyVQVoH8y")

(define-constant ERR-UNWRAP (err u101))
(define-constant ERR-NOT-AUTHORIZED (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-WRONG-COMMISSION (err u104))
(define-constant ERR-LISTED (err u105))

(define-data-var test-index uint u0)

(define-map market uint {price: uint, commission: principal})

(define-read-only (get-last-token-id)
    (ok (var-get test-index))
)

(define-read-only (get-token-uri (id uint))
    (ok (some token-uri))
)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? test id))
)

(define-public (transfer (id uint) (owner principal) (recipient principal))
    (let 
        (
            (nft-current-owner (unwrap-panic (nft-get-owner? test id)))
        )
        (try! (nft-transfer? test id nft-current-owner recipient))
        (ok true)
    )
)

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
    (let
        (
            (listing {price: price, commission: (contract-of comm-trait)})
        )
        (map-set market id listing)
        (ok (print (merge listing {a: "list-in-ustx", id: id})))
    )
)

(define-public (unlist-in-ustx (id uint))
    (let
        (
            (market-map (unwrap! (map-get? market id) ERR-NOT-LISTED))
        )
        (map-delete market id)
        (ok (print {a: "unlist-in-ustx", id: id}))
    )
)   

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
    (let
        (
            (owner (unwrap-panic (nft-get-owner? test id)))
            (listing (unwrap! (map-get? market id) ERR-NOT-LISTED))
            (price (get price listing))
        )
        (map-delete market id)
        (ok (print {a: "buy-in-ustx", id: id}))
    )
)


(nft-mint? test u1 tx-sender)