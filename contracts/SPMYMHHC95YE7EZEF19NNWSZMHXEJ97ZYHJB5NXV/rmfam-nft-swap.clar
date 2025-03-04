;; NFT Buyback Contract for RNFAM
;; Allows users to sell back up NFTs from the collection and get paid in RMFAM.

;; Define traits with full contract paths
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Error constants
(define-constant err-not-owner (err u100))
(define-constant err-exceed-max-buyback (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-nft (err u103))
(define-constant err-already-listed (err u104))
(define-constant err-not-listed (err u105))
(define-constant err-listing-expired (err u106))
(define-constant err-not-whitelisted (err u107))
(define-constant err-price-mismatch (err u108))
(define-constant err-collection-not-approved (err u109))
(define-constant err-invalid-price (err u110))


;; Set Admin
(define-constant admin 'SPZ2X8P6QTV1SPN5NKP4VVCFPDWWK63RPB9PHCMK)
(define-constant gated 'SP2BRB6P0BK6T35DHTGXCV6MZ5TGRN5E0RKZ1T8B5)

;; Add at the top with other data variables
(define-data-var gated-fee uint u100000)  ;; Initial fee set to 0.1 STX (100000 microSTX)

;; Add minimum price check
(define-constant minimum-price u100000) ;; 0.1 STX
(define-constant maximum-price u1000000000) ;; 1000 STX


;; Add new admin function to update fee
(define-public (set-transaction-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender gated) err-unauthorized)
        (var-set gated-fee new-fee)
        (ok true)
    )
)

;; Length of time until expire block initial value set at 144
(define-data-var listing-duration uint u144)

;; Data maps for managing escrow
(define-map vault
    { token-id: uint, nft-contract: principal }
    {
        seller: principal,
        price: uint,
        expiry: uint  ;; Block height when listing expires
    }
)

;; managing approved nft collections
(define-map approved-collections principal bool)

;; Add read-only function to check if collection is approved
(define-read-only (is-collection-approved (collection-address principal))
    (default-to false (map-get? approved-collections collection-address))
)

;;Sell NFT to deployer
(define-public (sell-nft-to-deployer
    (nft-contract <nft-trait>)
    (token-id uint)
    (price uint)
    (rmfam-token <ft-trait>))
    (let
    (
        (buyer 'SPZ2X8P6QTV1SPN5NKP4VVCFPDWWK63RPB9PHCMK)
        (seller tx-sender)
        (owner-response (try! (contract-call? nft-contract get-owner token-id)))
        (duration (var-get listing-duration)) 
        (nft-contract-address (contract-of nft-contract)) 

    )

        ;; Verify collection is approved
        (asserts! (is-collection-approved nft-contract-address) err-collection-not-approved)

        ;; Verify ownership
        (asserts! (is-eq (some seller) owner-response) err-not-owner)

        ;; Verify NFT isn't already listed
        (asserts! (is-none (map-get? vault {token-id: token-id, nft-contract: (contract-of nft-contract)})) err-already-listed)
        

        ;; Create listing
        (map-set vault 
            {token-id: token-id, nft-contract: (contract-of nft-contract)}
            {
                seller: seller,
                price: price,
                expiry: (+ block-height duration)
            }
        )

    ;; Do the NFT transfer
    (try! (contract-call?
        nft-contract
        transfer
        token-id
        seller
        (as-contract tx-sender)))


        ;; Emit listing created event
        (print {
            event: "nft-listed",
            token-id: token-id,
            seller: seller,
            price: price,
            contract: (contract-of nft-contract),
            expiry: (+ block-height duration)
        })
    
        ;; pay platform-fee
        (try! (stx-transfer? (var-get gated-fee) tx-sender gated))
    
    (ok true)
    )
)

;; Complete purchase with within alloted time
(define-public (complete-purchase
    (nft-contract <nft-trait>)
    (token-id uint)
    (price uint)
    (rmfam-token <ft-trait>))
    (let (
        (listing (unwrap! (map-get? vault {token-id: token-id, nft-contract: (contract-of nft-contract)}) err-not-listed))
        (buyer tx-sender)
    )
        ;; Verify listing hasn't expired
        (asserts! (< block-height (get expiry listing)) err-listing-expired)

        ;; verify price min and max
        (asserts! (and (>= price minimum-price) (<= price maximum-price)) err-invalid-price)

        ;; Verify the price matches the listing
        (asserts! (is-eq price (get price listing)) err-price-mismatch)
        
        
        ;; Process payment
        (try! (contract-call? 
            rmfam-token
            transfer
            (get price listing)
            buyer
            (get seller listing)
            none))
            
        ;; Transfer NFT from contract to buyer
        (try! (as-contract (contract-call?
            nft-contract
            transfer
            token-id
            tx-sender
            buyer)))

             ;; Emit purchase event
        (print {
            event: "nft-purchased",
            token-id: token-id,
            seller: (get seller listing),
            buyer: buyer,
            price: price,
            contract: (contract-of nft-contract)
        })

        ;; pay platform-fee
        (try! (stx-transfer? (var-get gated-fee) tx-sender gated))
                
        ;; Clear listing map
        (map-delete vault {token-id: token-id, nft-contract: (contract-of nft-contract)})
        (ok true)
    )
)

;; Allow seller to cancel their listing if:
;; 1. They are the seller (can cancel anytime before purchase)
;; 2. The listing has expired (and no purchase occurred)
(define-public (cancel-listing
    (nft-contract <nft-trait>)
    (token-id uint))
    (let (
        (listing (unwrap! (map-get? vault {token-id: token-id, nft-contract: (contract-of nft-contract)}) err-not-listed))
        (caller tx-sender)
    )
        ;; Verify caller is seller OR listing has expired
        (asserts! (or 
            (is-eq caller (get seller listing))
            (>= block-height (get expiry listing))
        ) err-unauthorized)
        
        ;; Return NFT to original seller
        (try! (as-contract (contract-call?
            nft-contract
            transfer
            token-id
            tx-sender
            (get seller listing))))
        
        ;; pay platform-fee
        (try! (stx-transfer? (var-get gated-fee) tx-sender gated))
            
        ;; Clear listing
        (map-delete vault {token-id: token-id, nft-contract: (contract-of nft-contract)})
        
        (ok true)
    )
)

;; Get status of listing
(define-read-only (get-listing 
    (token-id uint) 
    (nft-contract principal))
    (map-get? vault 
        { 
            token-id: token-id, 
            nft-contract: nft-contract 
        }
    )
)

;; Admin check
(define-private (is-admin)
    (is-eq tx-sender admin)
)

;; Updates block duration 
(define-public (set-listing-duration (new-duration uint))
    (begin
        (asserts! (is-admin) err-unauthorized)
        (var-set listing-duration new-duration)
        (ok true)  ;; Public functions must return a response
    )
)

;; Admin functions to manage approved collections
(define-public (add-approved-collection (collection-address principal))
    (begin
        (asserts! (is-admin) err-unauthorized)
        (ok (map-set approved-collections collection-address true))
    )
)

(define-public (remove-approved-collection (collection-address principal))
    (begin
        (asserts! (is-admin) err-unauthorized)
        (ok (map-delete approved-collections collection-address))
    )
)
