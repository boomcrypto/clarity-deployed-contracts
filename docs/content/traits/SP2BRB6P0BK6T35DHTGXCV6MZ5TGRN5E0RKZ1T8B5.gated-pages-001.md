---
title: "Trait gated-pages-001"
draft: true
---
```
;; title: gated.so 
;; version: 0.002
;; summary: Ability to create pages 
;; description: Smart contract to create and manage pages on gated.so

;;Define Constant
    ;; Error codes
    (define-constant ERR_PAGE_EXISTS (err u100))
    (define-constant ERR_INVALID_PAGE (err u101))
    (define-constant ERR_TITLE_INVALID_LENGTH (err u102))
    (define-constant ERR_DESC_INVALID_LENGTH (err u103))
    (define-constant ERR_UNAUTHORIZED (err u104))
    (define-constant ERR_NOT_TOKEN_OWNER (err u105))
    (define-constant ERR_INVALID_TOKEN (err u106))


    ;; Min and max length constraints
    (define-constant MIN_TITLE_LENGTH u1)
    (define-constant MAX_TITLE_LENGTH u64)
    (define-constant MIN_DESC_LENGTH u1)
    (define-constant MAX_DESC_LENGTH u256)

    ;; hardcoded gated address
    (define-constant gated 'SP2BRB6P0BK6T35DHTGXCV6MZ5TGRN5E0RKZ1T8B5)
    
    ;; define non-fungible-token
    (define-non-fungible-token gated-page (string-ascii 64))

    ;; Data variables
        ;; page-id
        (define-data-var token-id uint u0)
        ;; gated-fee set to 1 STX
        (define-data-var gated-fee uint u1000000)
        ;; set contract-owner
        (define-data-var contract-owner principal tx-sender)

;; maps
    (define-map pages 
        { owner: principal, title: (string-ascii 64) }
        {   
        owner: principal,  
        title: (string-ascii 64), 
        active: bool, 
        description: (string-ascii 256),
        metadata-uri:  (optional (string-ascii 256))}
    )

    ;; NFT transfer function
(define-public (transfer (sender principal) (recipient principal)  (title (string-ascii 64)) )
    (begin
        (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
        ;; Add NFT transfer
        (try! (nft-transfer? gated-page title sender recipient))
        ;; Update pages map
        (match (map-get? pages { owner: sender, title: title })
            token-data
            (begin
                (asserts! (is-eq (get owner token-data) sender) ERR_NOT_TOKEN_OWNER)
                (map-set pages
                    {owner: sender, title: title}
                    (merge token-data {owner: recipient})
                )
                (ok true)
            )
            ERR_INVALID_TOKEN
        )
    )
)

    ;; Private functions
    (define-private (validate-string-length-title (str (string-ascii 64)) (min uint) (max uint))
    (let
        (
            (str-length (len str))  ;; Changed from 'len' to 'str-length'
        )
        (and (>= str-length min) (<= str-length max))
    )
)

    (define-private (validate-string-length-description (str (string-ascii 256)) (min uint) (max uint))
        (let
        (
            (str-length (len str))  ;; Changed from 'len' to 'str-length'
        )
        (and (>= str-length min) (<= str-length max))
    )
)

;; Add a new page
    (define-public (add-page (title (string-ascii 64)) (description (string-ascii 256)) (metadata-uri (string-ascii 256))) 
        (let
            (
                (new-id (+ (var-get token-id) u1))
            )
            (begin
                ;; Input validation
                (asserts! (validate-string-length-title title MIN_TITLE_LENGTH MAX_TITLE_LENGTH) ERR_TITLE_INVALID_LENGTH)
                (asserts! (validate-string-length-description description MIN_DESC_LENGTH MAX_DESC_LENGTH) ERR_DESC_INVALID_LENGTH)

                ;; Check if page already exists
                (asserts! (is-none (map-get? pages { owner: tx-sender, title: title })) ERR_PAGE_EXISTS)

                ;; Process payment for page
                (try! (stx-transfer? (var-get gated-fee) tx-sender gated))

                ;; mint NFT 
                (try! (nft-mint? gated-page title tx-sender))  

                ;; Add the page with metadata
                (map-set pages 
                    { owner: tx-sender, title: title }
                    {
                        owner: tx-sender,
                        title: title,
                        description: description,
                        metadata-uri:  (some metadata-uri),
                        active: true
                    }
                )
                
                ;; Update the page counter
                (var-set token-id new-id)

                ;; Emit event
                (print {event: "page-created", page-id: new-id, owner: tx-sender})
                
                ;; Return the new page ID
                (ok new-id)
            )
        )
    )

(define-public (update-page (owner principal) (title (string-ascii 64)) (description (string-ascii 256)) (metadata-uri (string-ascii 256)) (active bool))
    (begin
        ;; Input validation
        (asserts! (validate-string-length-title title MIN_TITLE_LENGTH MAX_TITLE_LENGTH) ERR_TITLE_INVALID_LENGTH)
        (asserts! (validate-string-length-description description MIN_DESC_LENGTH MAX_DESC_LENGTH) ERR_DESC_INVALID_LENGTH)

        ;; Check if page exists and get it
        (match (map-get? pages { owner: owner, title: title })
            existing-page-data  ;; More descriptive name
            (begin
                ;; Verify the stored owner matches the sender
                (asserts! (is-eq (get owner existing-page-data) tx-sender) ERR_UNAUTHORIZED)

                ;; Update the page
                (some (map-set pages
                    { owner: owner, title: title }
                    {
                        owner: tx-sender,
                        active: active,
                        title: title,
                        description: description,
                        metadata-uri:  (some metadata-uri)
                    }
                ))

                ;; Emit event
                (print {event: "page-updated", owner: tx-sender, active: active, title: title, description: description, metadata-uri:  (some metadata-uri)})

                ;; Return success
                (ok true)
            )
            ERR_INVALID_PAGE
        )
    )
)

;; Contract owner functions
(define-public (update-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (var-set gated-fee new-fee)
        (print {event: "fee-updated", new-fee: new-fee})
        (ok true)
    )
)

;; Read page details
(define-read-only (get-page (owner principal) (title (string-ascii 64)))
    (map-get? pages { owner: owner, title: title })
)


;; Add these required read-only functions
(define-read-only (get-last-token-id)
    (ok (var-get token-id))
)

(define-read-only (get-token-uri (owner principal) (title (string-ascii 64)))
    (match 
        (map-get? pages { owner: owner, title: title })
        token-data (ok (get metadata-uri token-data))
        ERR_INVALID_TOKEN
    )
)

(define-read-only (get-owner (owner principal) (title (string-ascii 64)))
    (ok (nft-get-owner? gated-page title))
)
```
