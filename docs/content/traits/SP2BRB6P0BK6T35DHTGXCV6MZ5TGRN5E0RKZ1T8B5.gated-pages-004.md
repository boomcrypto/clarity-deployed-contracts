---
title: "Trait gated-pages-004"
draft: true
---
```
;; title: gated.so 
;; version: 0.004
;; summary: Page management for Gated
;; description: Smart contract to create and manage pages on gated.so

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; define non-fungible-token
(define-non-fungible-token gated-page uint)

;;Define Constant
;; Error codes
(define-constant ERR_PAGE_EXISTS (err u100))
(define-constant ERR_INVALID_PAGE (err u101))
(define-constant ERR_TITLE_INVALID_LENGTH (err u102))
(define-constant ERR_DESC_INVALID_LENGTH (err u103))
(define-constant ERR_UNAUTHORIZED (err u104))
(define-constant ERR_NOT_TOKEN_OWNER (err u105))
(define-constant ERR_INVALID_TOKEN (err u106))
(define-constant ERR_DUPLICATE_TITLE (err u107))
(define-constant ERR-INVALID-PERCENTAGE (err u108))
(define-constant ERR-INVALID-USER (err u109))
(define-constant ERR-NOT-AUTHORIZED (err u110))
(define-constant ERR-WRONG-COMMISSION (err u111))
(define-constant ERR-NOT-FOUND (err u112))
(define-constant ERR-LISTING (err u113))
(define-constant ERR-TRANSFER (err u114))
(define-constant ERR-INSUFFICIENT-BALANCE (err u115))

;; Min and max length constraints
(define-constant MIN_TITLE_LENGTH u1)
(define-constant MAX_TITLE_LENGTH u64)
(define-constant MIN_DESC_LENGTH u1)
(define-constant MAX_DESC_LENGTH u256)

;; hardcoded gated address
(define-constant gated 'SP2BRB6P0BK6T35DHTGXCV6MZ5TGRN5E0RKZ1T8B5)

;; set the deployer
(define-constant deployer tx-sender)

;; Data variables ;;
;; last-token-id variable
(define-data-var last-token-id uint u0)
;; gated-fee set to 1 STX
(define-data-var gated-fee uint u1000000)
;; sets default page-creator 
(define-data-var page-creator principal deployer)
;; Add these required read-only functions
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id)))
;; URI for metadata associated with the token
(define-read-only (get-token-uri (token-id uint))
    (let 
        ((token-data (map-get? token-metadata token-id)))
        (match token-data
        data (ok (some (get uri-suffix data)))
        (ok none))))

;; NFT transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
    (if (and 
        (is-eq tx-sender sender)
        (is-none (map-get? market id)))
        (nft-transfer? gated-page id sender recipient)
        (err u1)
    )
)

;; get owner function
(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? gated-page id))
)

;; maps for id
    (define-map pages-by-id 
        { id: uint}
        {owner: principal,  
        title: (string-ascii 64), 
        description: (string-ascii 256),
        active: bool}
    )

;; maps for titile
    (define-map pages-by-title
        { owner: principal, title: (string-ascii 64) }
        { id: uint }
    )

    ;; Map to store token-specific URI suffixes
(define-map token-metadata
    uint
    {
        uri-suffix: (string-ascii 256),
        version: uint  ;; For tracking metadata updates
    }
)

;; Private functions
;;validate length of title
(define-private (validate-string-length-title (str (string-ascii 64)) (min uint) (max uint))
    (let
    ((str-length (len str)))  ;; Changed from 'len' to 'str-length')
    (and (>= str-length min) (<= str-length max)))
)
;;validate length of description

(define-private (validate-string-length-description (str (string-ascii 256)) (min uint) (max uint))
    (let
    ((str-length (len str)) )
    (and (>= str-length min) (<= str-length max)))
)

;; Add a new page
(define-public (create-page (title (string-ascii 64)) (description (string-ascii 256)) (metadata-uri (string-ascii 256))) 
    (let
        ((new-id (+ (var-get last-token-id) u1)))
    (begin
        ;; Input validation
        (asserts! (validate-string-length-title title MIN_TITLE_LENGTH MAX_TITLE_LENGTH) ERR_TITLE_INVALID_LENGTH)
        (asserts! (validate-string-length-description description MIN_DESC_LENGTH MAX_DESC_LENGTH) ERR_DESC_INVALID_LENGTH)

        ;; Check if title already exists for this owner
        (asserts! (is-none (map-get? pages-by-title { owner: tx-sender, title: title })) ERR_DUPLICATE_TITLE)

        ;; Assigns page-creator for royalty purposes
        (var-set page-creator tx-sender)

        ;; Process payment for page
        (try! (stx-transfer? (var-get gated-fee) tx-sender gated))

        ;; mint NFT 
        (try! (nft-mint? gated-page new-id tx-sender))  

        ;; Add the page to map
        (map-set pages-by-id 
            { id: new-id }
                {
                owner: tx-sender,
                title: title,
                description: description,
                active: true
                }
        )

        ;; Store in reverse lookup map
        (map-set pages-by-title
            { owner: tx-sender, title: title }
            { id: new-id }
        )

        ;; store token-metadata
        (map-set token-metadata
                    new-id
                    {
                        uri-suffix: metadata-uri,  ;; Use the provided IPFS hash
                        version: (+ (default-to u0 (get version (map-get? token-metadata new-id))) u1)
                    }
                )
        
        ;; Update the page counter
        (var-set last-token-id new-id)

        ;; Emit event
        (print {event: "page-created", page-id: new-id, owner: tx-sender,  metadata-uri: metadata-uri})
        
        ;; Return the new page ID
        (ok new-id)
        )
    )
)

;; is-sender-owner?
(define-private (is-sender-owner (token-id uint))
    (match (nft-get-owner? gated-page token-id)
        owner (is-eq tx-sender owner)
        false
    )
)

;; update-page
(define-public (update-page (id uint) (title (string-ascii 64)) (description (string-ascii 256)) (active bool) (metadata-uri (string-ascii 256)))
    (begin
        (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
        ;; Input validation
        (asserts! (validate-string-length-title title MIN_TITLE_LENGTH MAX_TITLE_LENGTH) ERR_TITLE_INVALID_LENGTH)
        (asserts! (validate-string-length-description description MIN_DESC_LENGTH MAX_DESC_LENGTH) ERR_DESC_INVALID_LENGTH)

            ;; Process payment for page
            (try! (stx-transfer? (var-get gated-fee) tx-sender gated))

        ;; Check if page exists and get it
        (match (map-get? pages-by-id { id: id })
            existing-page-data  ;; More descriptive name
            (begin
                ;; Verify the stored owner matches the sender
                (asserts! (is-eq (get owner existing-page-data) tx-sender) ERR_UNAUTHORIZED)

            ;; If title is different from current, check it's not already used
                (if (not (is-eq title (get title existing-page-data)))
                    (asserts! (is-none (map-get? pages-by-title { owner: tx-sender, title: title })) ERR_DUPLICATE_TITLE)
                    true
                )

                ;; Update the page
                (some (map-set pages-by-id
                    { id: id }
                    {
                    owner: tx-sender,
                    title: title,
                    description: description,
                    active: active
                    }
                ))

                ;; Delete old title mapping if title has changed
                (if (not (is-eq title (get title existing-page-data)))
                    (map-delete pages-by-title { owner: tx-sender, title: (get title existing-page-data) })
                    true
                )

                ;; Update the reverse lookup map
                (map-set pages-by-title
                    { owner: tx-sender, title: title }
                    { id: id }
                )

                ;; Update token metadata with the provided IPFS hash
                (map-set token-metadata
                    id
                    {
                        uri-suffix: metadata-uri,  ;; Use the provided IPFS hash
                        version: (+ (default-to u0 (get version (map-get? token-metadata id))) u1)
                    }
                )

                ;; Emit event
                (print {event: "page successfully updated", owner: tx-sender, active: active, title: title, description: description, metadata-uri: metadata-uri})

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
        (asserts! (is-eq tx-sender deployer) ERR_UNAUTHORIZED)
        (var-set gated-fee new-fee)
        (print {event: "fee-updated", new-fee: new-fee})
        (ok true)
    )
)

;; Look up page by ID
(define-read-only (get-page-by-id (page-id uint))
    (map-get? pages-by-id { id: page-id })
)

;; Read page details
(define-read-only (get-page-by-title (owner principal) (title (string-ascii 64)))
    (match (map-get? pages-by-title { owner: owner, title: title })
        id-data 
        (match (map-get? pages-by-id { id: (get id id-data) })
            page-data (some (merge page-data { id: (get id id-data) }))
            none
        )
        none
    )
)

(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
    (default-to u0
    (map-get? token-count account))
)

(define-private (trnsfr (token-id uint) (sender principal) (recipient principal))
    (begin
        ;; Check if the sender owns the NFT
        (asserts! (is-eq (unwrap! (nft-get-owner? gated-page token-id) ERR-NOT-FOUND) sender) (err u112))
        
        ;; Perform the NFT transfer
        (try! (nft-transfer? gated-page token-id sender recipient))
        
        (ok true)
    )
)

(define-read-only (get-listing-in-ustx (id uint))
    (map-get? market id)
)

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
        (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)}))
        
        (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
        (map-set market id listing)
        (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true))
)

(define-public (unlist-in-ustx (id uint))
    (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true))
)

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
    (let 
    ((owner (unwrap! (nft-get-owner? gated-page id) (err u1)))
    (listing (unwrap! (map-get? market id) (err u2)))
    (price (get price listing))
    (royalty (get royalty listing)))
    
    ;; First check commission contract
    (if (not (is-eq (contract-of comm-trait) (get commission listing)))
        (err u3)
        (begin
            ;; Combine all operations that need to succeed
            (try! (stx-transfer? price tx-sender owner))
            (try! (pay-royalty price royalty))
            (try! (contract-call? comm-trait pay id price))
            (try! (trnsfr id owner tx-sender))
            (map-delete market id)
            (print {a: "buy-in-ustx", id: id})
            (ok true))))
)

(define-data-var royalty-percent uint u500)

(define-read-only (get-royalty-percent)
    (ok (var-get royalty-percent))
)

(define-public (set-royalty-percent (royalty uint))
    (begin
        (asserts! (or (is-eq tx-sender (var-get page-creator)) (is-eq tx-sender deployer)) (err ERR-INVALID-USER))
        (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
        (ok (var-set royalty-percent royalty)))
)

(define-private (pay-royalty (price uint) (royalty uint))
    (let (
        (royalty-amount (/ (* price royalty) u10000)))
            (if (and (> royalty-amount u0) (not (is-eq tx-sender (var-get page-creator))))
            (try! (stx-transfer? royalty-amount tx-sender (var-get page-creator)))
            (print false))
            (ok true))
)

;; Define a public function that only the deployer can call to airdrop pages to multiple recipients
(define-public (airdrop-pages 
    (recipients (list 200 principal)) 
    (titles (list 200 (string-ascii 64)))
    (descriptions (list 200 (string-ascii 256)))
    (metadata-uri (string-ascii 256)))
    
    (begin
        ;; Check that only the deployer can call this function
        (asserts! (is-eq tx-sender deployer) ERR_UNAUTHORIZED)
        
        ;; Check that all lists have the same length
        (asserts! (is-eq (len recipients) (len titles)) ERR_INVALID_PAGE)
        (asserts! (is-eq (len titles) (len descriptions)) ERR_INVALID_PAGE)
        
        ;; Map through the lists and create pages for each recipient
        (map airdrop-single-page recipients titles descriptions metadata-uri)
        
        (ok true)
    )
)

;; Private function to handle individual page creation during airdrop
(define-private (airdrop-single-page 
    (recipient principal) 
    (title (string-ascii 64)) 
    (description (string-ascii 256))
    (metadata-uri (string-ascii 256)))
    
    (let
        ((new-id (+ (var-get last-token-id) u1)))
        (begin
            ;; Input validation
            (asserts! (validate-string-length-title title MIN_TITLE_LENGTH MAX_TITLE_LENGTH) ERR_TITLE_INVALID_LENGTH)
            (asserts! (validate-string-length-description description MIN_DESC_LENGTH MAX_DESC_LENGTH) ERR_DESC_INVALID_LENGTH)
            
            ;; Check if title already exists for this recipient
            (asserts! (is-none (map-get? pages-by-title { owner: recipient, title: title })) ERR_DUPLICATE_TITLE)
            
            ;; Set page creator for royalty purposes
            (var-set page-creator recipient)
            
            ;; Mint NFT to recipient
            (try! (nft-mint? gated-page new-id recipient))
            
            ;; Add the page to map
            (map-set pages-by-id 
                { id: new-id }
                {
                    owner: recipient,
                    title: title,
                    description: description,
                    active: true
                }
            )
            
            ;; Store in reverse lookup map
            (map-set pages-by-title
                { owner: recipient, title: title }
                { id: new-id }
            )

            ;; store token-metadata
        (map-set token-metadata
                    new-id
                    {
                        uri-suffix: metadata-uri,  ;; Use the provided IPFS hash
                        version: (+ (default-to u0 (get version (map-get? token-metadata new-id))) u1)
                    }
                )
        
            
            ;; Update the page counter
            (var-set last-token-id new-id)
            
            ;; Emit event
            (print {event: "page-airdropped", page-id: new-id, recipient: recipient})
            
            (ok true)
        )
    )
)
```
