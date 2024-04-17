;; derupt-interfaces Contract
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; (impl-trait 'ST1NXBK3K5YYMD6FD41MVNP3JS1GABZ8TRVX023PT.nft-trait.nft-trait)

(define-constant DAPP tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-not-found (err u102))
(define-constant err-invalid-value (err u103))
(define-constant err-already-exists (err u104))
(define-constant err-limit-reached (err u105))

(define-non-fungible-token derupt-interface-token uint)
(define-data-var last-token-id uint u0)

(define-data-var soft-limit uint u99)
(define-read-only (get-soft-limit) 
    (ok (var-get soft-limit))
)
(define-public (update-soft-limit (new-limit uint)) 
    (begin 
        (asserts! (is-eq tx-sender DAPP) err-owner-only)
        (ok (var-set soft-limit new-limit))
    )
)

(define-map costs principal { mint-cost: uint, interface-update-cost: uint })
(define-public (update-interface-costs (mint-cost (optional uint)) (interface-update-cost (optional uint))) 
    (begin 
        (asserts! (is-eq tx-sender DAPP) err-owner-only)
        (match mint-cost value (map-set costs DAPP 
            { 
                mint-cost: (unwrap! mint-cost err-invalid-value),
                interface-update-cost: (unwrap! (get interface-update-cost (map-get? costs DAPP)) err-not-found)                
            }) false)
        (match interface-update-cost value (map-set costs DAPP 
            { 
                mint-cost: (unwrap! (get mint-cost (map-get? costs DAPP)) err-not-found),
                interface-update-cost: (unwrap! interface-update-cost err-invalid-value)  
            }) false)
        (ok true)
    )
)

;; Interface-badges is a map by nft uint as index
(define-map interface-badges uint {metadata-uri: (string-ascii 256), alt-origin: (string-utf8 256)})
;; Interface is a map by alt-origin as index
(define-map interface (string-utf8 256) 
    { 
        pay-dev: bool, pay-gaia: bool,
        dev-stx-amount: uint, gaia-stx-amount: uint,
        dev-ft-amount: uint, gaia-ft-amount: uint,
        dev-principal: principal, gaia-principal: (optional principal)
    }
)
(define-public (update-interface 
    (alt-origin (string-utf8 256)) (token-uri (optional (string-ascii 256)))
    (pay-dev (optional bool)) (pay-gaia (optional bool)) 
    (dev-stx-amount (optional uint)) (gaia-stx-amount (optional uint)) 
    (dev-ft-amount (optional uint)) (gaia-ft-amount (optional uint))
    (gaia-principal (optional principal))
) 
    (let 
        (
            (alt-origin-dev (unwrap! (get dev-principal (map-get? interface alt-origin)) err-not-found))
        )
        (begin 
            (asserts! (is-eq alt-origin-dev tx-sender) err-owner-only)
            (try! (stx-transfer? (unwrap! (get interface-update-cost (map-get? costs DAPP)) err-not-found) tx-sender DAPP))
            (match pay-dev value (map-set interface alt-origin 
                { 
                    pay-dev: (unwrap! pay-dev err-invalid-value), pay-gaia: (unwrap! (get pay-gaia (map-get? interface alt-origin)) err-not-found),
                    dev-stx-amount: (unwrap! (get dev-stx-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-stx-amount: (unwrap! (get gaia-stx-amount (map-get? interface alt-origin)) err-not-found),
                    dev-ft-amount: (unwrap! (get dev-ft-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-ft-amount: (unwrap! (get gaia-ft-amount (map-get? interface alt-origin)) err-not-found),
                    dev-principal: (unwrap! (get dev-principal (map-get? interface alt-origin)) err-not-found), 
                    gaia-principal: (unwrap! (get gaia-principal (map-get? interface alt-origin)) err-not-found)                   
                }) false)
            (match pay-gaia value (map-set interface alt-origin 
                { 
                    pay-dev: (unwrap! (get pay-dev (map-get? interface alt-origin)) err-not-found), pay-gaia: (unwrap! pay-gaia err-invalid-value),
                    dev-stx-amount: (unwrap! (get dev-stx-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-stx-amount: (unwrap! (get gaia-stx-amount (map-get? interface alt-origin)) err-not-found),
                    dev-ft-amount: (unwrap! (get dev-ft-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-ft-amount: (unwrap! (get gaia-ft-amount (map-get? interface alt-origin)) err-not-found),
                    dev-principal: (unwrap! (get dev-principal (map-get? interface alt-origin)) err-not-found), 
                    gaia-principal: (unwrap! (get gaia-principal (map-get? interface alt-origin)) err-not-found)                   
                }) false)
            (match dev-stx-amount value (map-set interface alt-origin 
                { 
                    pay-dev: (unwrap! (get pay-dev (map-get? interface alt-origin)) err-not-found), pay-gaia: (unwrap! (get pay-gaia (map-get? interface alt-origin)) err-not-found),
                    dev-stx-amount: (unwrap! dev-stx-amount err-invalid-value), 
                    gaia-stx-amount: (unwrap! (get gaia-stx-amount (map-get? interface alt-origin)) err-not-found),
                    dev-ft-amount: (unwrap! (get dev-ft-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-ft-amount: (unwrap! (get gaia-ft-amount (map-get? interface alt-origin)) err-not-found),
                    dev-principal: (unwrap! (get dev-principal (map-get? interface alt-origin)) err-not-found), 
                    gaia-principal: (unwrap! (get gaia-principal (map-get? interface alt-origin)) err-not-found)                   
                }) false)
            (match gaia-stx-amount value (map-set interface alt-origin 
                { 
                    pay-dev: (unwrap! (get pay-dev (map-get? interface alt-origin)) err-not-found), pay-gaia: (unwrap! (get pay-gaia (map-get? interface alt-origin)) err-not-found),
                    dev-stx-amount: (unwrap! (get dev-stx-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-stx-amount: (unwrap! gaia-stx-amount err-invalid-value),
                    dev-ft-amount: (unwrap! (get dev-ft-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-ft-amount: (unwrap! (get gaia-ft-amount (map-get? interface alt-origin)) err-not-found),
                    dev-principal: (unwrap! (get dev-principal (map-get? interface alt-origin)) err-not-found), 
                    gaia-principal: (unwrap! (get gaia-principal (map-get? interface alt-origin)) err-not-found)                   
                }) false)
            (match dev-ft-amount value (map-set interface alt-origin 
                { 
                    pay-dev: (unwrap! (get pay-dev (map-get? interface alt-origin)) err-not-found), pay-gaia: (unwrap! (get pay-gaia (map-get? interface alt-origin)) err-not-found),
                    dev-stx-amount: (unwrap! (get dev-stx-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-stx-amount: (unwrap! (get gaia-stx-amount (map-get? interface alt-origin)) err-not-found),
                    dev-ft-amount: (unwrap! dev-ft-amount err-invalid-value), 
                    gaia-ft-amount: (unwrap! (get gaia-ft-amount (map-get? interface alt-origin)) err-not-found),
                    dev-principal: (unwrap! (get dev-principal (map-get? interface alt-origin)) err-not-found), 
                    gaia-principal: (unwrap! (get gaia-principal (map-get? interface alt-origin)) err-not-found)                   
                }) false)
            (match gaia-ft-amount value (map-set interface alt-origin 
                { 
                    pay-dev: (unwrap! (get pay-dev (map-get? interface alt-origin)) err-not-found), pay-gaia: (unwrap! (get pay-gaia (map-get? interface alt-origin)) err-not-found),
                    dev-stx-amount: (unwrap! (get dev-stx-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-stx-amount: (unwrap! (get gaia-stx-amount (map-get? interface alt-origin)) err-not-found),
                    dev-ft-amount: (unwrap! (get dev-ft-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-ft-amount: (unwrap! gaia-ft-amount err-invalid-value),
                    dev-principal: (unwrap! (get dev-principal (map-get? interface alt-origin)) err-not-found), 
                    gaia-principal: (unwrap! (get gaia-principal (map-get? interface alt-origin)) err-not-found)                   
                }) false)           
            (match gaia-principal value (map-set interface alt-origin 
                { 
                    pay-dev: (unwrap! (get pay-dev (map-get? interface alt-origin)) err-not-found), pay-gaia: (unwrap! (get pay-gaia (map-get? interface alt-origin)) err-not-found),
                    dev-stx-amount: (unwrap! (get dev-stx-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-stx-amount: (unwrap! (get gaia-stx-amount (map-get? interface alt-origin)) err-not-found),
                    dev-ft-amount: (unwrap! (get dev-ft-amount (map-get? interface alt-origin)) err-not-found), 
                    gaia-ft-amount: (unwrap! (get gaia-ft-amount (map-get? interface alt-origin)) err-not-found),
                    dev-principal: (unwrap! (get dev-principal (map-get? interface alt-origin)) err-not-found), 
                    gaia-principal: gaia-principal                  
                }) false)
            (ok true)   
        )
    )
)

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (get metadata-uri (map-get? interface-badges token-id)))
)

(define-read-only (get-token-interface (alt-origin (string-utf8 256))) 
    (ok (map-get? interface alt-origin))
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? derupt-interface-token token-id))
)

(define-read-only (get-costs) 
    (ok (unwrap! (map-get? costs DAPP) err-not-found))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (let 
        (
            (alt-origin (unwrap! (get alt-origin (map-get? interface-badges token-id)) err-not-found))
        ) 
        (asserts! (is-eq tx-sender sender) err-not-token-owner)        
        (asserts! (map-set interface alt-origin {
            pay-dev: (unwrap! (get pay-dev (map-get? interface alt-origin)) err-not-found), 
            pay-gaia: (unwrap! (get pay-gaia (map-get? interface alt-origin)) err-not-found),
            dev-stx-amount: (unwrap! (get dev-stx-amount (map-get? interface alt-origin)) err-not-found), 
            gaia-stx-amount: (unwrap! (get gaia-stx-amount (map-get? interface alt-origin)) err-not-found),
            dev-ft-amount: (unwrap! (get dev-ft-amount (map-get? interface alt-origin)) err-not-found), 
            gaia-ft-amount: (unwrap! (get gaia-ft-amount (map-get? interface alt-origin)) err-not-found),
            dev-principal: recipient, 
            gaia-principal: (unwrap! (get gaia-principal (map-get? interface alt-origin)) err-not-found)
        }) err-not-found)    
        (nft-transfer? derupt-interface-token token-id sender recipient)
    )
)

(define-public (mint 
    (alt-origin (string-utf8 256)) (metadata-uri (string-ascii 256))
    (pay-dev bool) (pay-gaia bool) 
    (dev-stx-amount uint) (gaia-stx-amount uint) 
    (dev-ft-amount uint) (gaia-ft-amount uint)
    (dev-principal principal) (gaia-principal (optional principal))
)
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
            (limit (var-get soft-limit))
        )       
        (asserts! (>= limit token-id) err-limit-reached)
        (asserts! (is-eq dev-principal tx-sender) err-invalid-value)
        (try! (nft-mint? derupt-interface-token token-id dev-principal))
        (try! (stx-transfer? (unwrap! (get mint-cost (map-get? costs DAPP)) err-not-found) tx-sender DAPP))
        (asserts! (map-insert interface alt-origin 
            { 
                pay-dev: pay-dev, pay-gaia: pay-gaia,
                dev-stx-amount: dev-stx-amount, gaia-stx-amount: gaia-stx-amount,
                dev-ft-amount: dev-ft-amount, gaia-ft-amount: gaia-ft-amount,
                dev-principal: dev-principal, gaia-principal: gaia-principal
            }
        ) err-already-exists)
        (map-insert interface-badges token-id {metadata-uri: metadata-uri, alt-origin: alt-origin})
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(map-insert costs DAPP {mint-cost: u10000000000, interface-update-cost: u10000000000})