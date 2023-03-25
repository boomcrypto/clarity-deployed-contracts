;; (impl-trait .registry-trait.reg-trait)
(use-trait nft-trait 'SP39EMTZG4P7D55FMEQXEB8ZEQEK0ECBHB1GD8GMT.nft-trait.nft-trait)
;; (use-trait nft-trait .registry-trait.nft-trait)
(define-data-var nonce uint u0)


(define-map creators principal uint)
(define-map contracts uint {metadata: (string-ascii 256), address: principal, last-nonce: uint, creator: principal})


(define-public (register (cont <nft-trait>) (nft-contract principal)) 
    (let (
        (url-opt (unwrap! (contract-call? cont get-token-uri u0) (err u1)))
    )
        
        (match url-opt
            url
            (match (map-get? creators tx-sender)
                non
                (begin
                    (var-set nonce (+ (var-get nonce) u1))
                    (map-insert contracts (var-get nonce) {metadata: url, address: nft-contract, last-nonce: non, creator: tx-sender})
                    (map-set creators tx-sender (var-get nonce))
                    (ok u1)
                )
                (begin
                    (map-insert creators tx-sender (var-get nonce))
                    (map-insert contracts (var-get nonce) {metadata: url, address: nft-contract, last-nonce: (var-get nonce), creator: tx-sender})
                    (ok u1)
                )
            )
            (err u2)
        )
    )
)


(define-read-only (get-creator-nonce (creator principal)) 
    (match (map-get? creators creator)
        non
        (some non)
        none
    )
)

(define-read-only (get-contract (non uint)) 
    (match (map-get? contracts non)
            tup
            (some tup)
            none
    )
)
