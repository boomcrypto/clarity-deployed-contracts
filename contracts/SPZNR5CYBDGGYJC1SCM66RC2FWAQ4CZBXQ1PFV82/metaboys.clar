;; title: metaboys
;; version: 1
;; summary: Burn a MetaBoy Cartridge to Mint a Stacks MetaBoy!
;; description: Aside from the Burn to Reveal aspect, this contract follows standard conventions of NFT's and non-custodial marketplaces

;; *** CHANGE ALL .cartridges to Wontons actual Cartridge contract

;; Network NFT trait
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; Network commission trait
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission) 

;; Defining NFT
(define-non-fungible-token metaboys uint)

;; Storage
;; Keeping track of token count for each principal
(define-map token-count principal uint)
;; Keeping track of non-custodial market listings
(define-map market uint {price: uint, commission: principal, royalty: uint})

;; Constants
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-INVALID-USER (err u405))
(define-constant ERR-SAME-VALUE (err u500))
(define-constant ERR-CANT-GET-OWNER (err u504))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-INVALID-PERCENTAGE (err u514))
(define-constant ERR-CANT-BURN (err u600))
(define-constant ERR-STX-TRANSFER (err u601))
(define-constant ERR-PAY-ROYALTY (err u602))
(define-constant ERR-CANT-TRANSFER-NFT (err u603))
(define-constant ERR-MARKETPLACE-ROYALTY (err u604))
(define-constant ERR-BURN-FAILED (err u10000))

;; Internal variables
;; Deployer
(define-data-var CONTRACT-OWNER principal tx-sender)
;; Index counter
(define-data-var last-id uint u1)
;; Metadata freezer
(define-data-var metadata-frozen bool false) 
;; Base URI for token metadata
(define-data-var ipfs-root (string-ascii 100) "ipfs://ipfs/QmUgXA2zuJhvgJy5Q1ycsx3LQ1mffHySDrfVCSy5fk8WZQ/json/")
;; Team royalty percentage per sale (0.5%)
(define-data-var royalty-percent uint u500)

;; NFT traits - SIP009
;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    ;; Asserting that sender owns token -> not needed as nft-transfer? implicitly checks this but nice to have anyways
    (asserts! (is-eq (unwrap! (unwrap! (get-owner id) ERR-CANT-GET-OWNER) ERR-CANT-GET-OWNER) recipient) ERR-NOT-AUTHORIZED) ;; Check if sender owns token
    ;; Asserting that tx-sender is sender from params
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED) ;; Check if sender is actually the sender
    ;; Asserting that listing is empty
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? metaboys id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-id)))

;; SIP009: Get the token URI.
(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

;; Set the base of the uri that prepends the token uri.
(define-public (set-base-uri (new-base-uri (string-ascii 100)))
  (begin
    ;; Asserting new value isn't same value
    (asserts! (not (is-eq new-base-uri (var-get ipfs-root))) (err ERR-SAME-VALUE))
    ;; Asserting tx-sender is contract owner / admin
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) (err ERR-NOT-AUTHORIZED)) ;; Must be contract owner
    ;; Asserting that metadata is not frozen
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (print { notification: "token-metadata-update", payload: { token-class: "nft", contract-id: (as-contract tx-sender) }})
    ;; Update IPFS root
    (var-set ipfs-root new-base-uri)
    (ok true)))

;; Change the contract owner 
(define-public (change-owner (address principal))
  (begin
    ;; Asserting new value isn't same value
    (asserts! (not (is-eq tx-sender address)) ERR-SAME-VALUE)
    ;; Asserting tx-sender is contract owner / admin
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) ERR-NOT-AUTHORIZED)
    ;; Update contract owner
    (var-set CONTRACT-OWNER address)
    (ok true)))

;; Freeze metadata
(define-public (freeze-metadata)
  (begin
    ;; Asserting tx-sender is contract owner / admin
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) ERR-NOT-AUTHORIZED)
    ;; Update metadata frozen
    (var-set metadata-frozen true)
    (ok true)))

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; Does the actual transfer, checks are handled by calling function
(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? metaboys id sender recipient) ;;Transfer NFT from sender to recipient
    success
      (begin
          (map-set token-count ;;Decrease sender balance
                sender
                (- (get-balance sender) u1))
          (map-set token-count ;;Increase recipient balance
                recipient
                (+ (get-balance recipient) u1))
          (ok success)
      )
    error (err error)))

;; Burn to Reveal mint. Check if sender has a Cartridge from the original mint contract. Burn Cartridge, mint Meta Boy
(define-public (mint (id uint))
  (begin
    (asserts! (is-eq (unwrap! (unwrap! (contract-call? 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7.numbers get-owner id) ERR-INVALID-USER) ERR-INVALID-USER) tx-sender) ERR-NOT-AUTHORIZED)
    (match (nft-mint? metaboys id tx-sender) ;; MINT
      success
        (begin
          (unwrap! (contract-call? 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7.numbers burn id) ERR-CANT-BURN)
          (var-set last-id (+ u1 (var-get last-id)))
          (map-set token-count ;; Increase the new-owner NFT count
            tx-sender
            (+ (get-balance tx-sender) u1)
          )
          (ok true))
      error (err (* error u10000))
    )
  )
)

;; Iterate through, and mint, the list of ids
(define-private (mint-many-iter (id uint) )
    (begin
      (asserts! (is-eq (unwrap! (unwrap! (contract-call? 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7.numbers get-owner id) ERR-INVALID-USER) ERR-INVALID-USER) tx-sender) ERR-NOT-AUTHORIZED)
      (match (nft-mint? metaboys id tx-sender)
        success
            (begin
              (unwrap! (contract-call? 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7.numbers burn id) ERR-CANT-BURN)
              (var-set last-id (+ u1 (var-get last-id)))
              (map-set token-count
                tx-sender
                (+ (get-balance tx-sender) u1)
              )
              (ok true)
            )
        error (err (* error u10000)))
    )
)

;; Mint many NFTs, through array of ids
(define-public (mint-many (ids (list 50 uint)))
  (begin   
    (print (map mint-many-iter ids)) 
    (ok true)
  ))

;; Burn the NFT, by received id
(define-public (burn (id uint))
    (let (
      (token-owner (unwrap! (unwrap! (get-owner id) ERR-CANT-GET-OWNER) ERR-CANT-GET-OWNER)) 
    )
    (asserts! (is-eq tx-sender token-owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (match (nft-burn? metaboys id token-owner)
        success
        (let
        ((current-balance (get-balance token-owner)))
          (begin
            (map-set token-count
              token-owner
              (- current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))
    )
)

;; Non-custodial marketplace extras

;; Check if the tx-sender is the owner of this NFT id
(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? metaboys id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

;; Get the NFT listing, in micro stacks
(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

;; List an NFT, in micro stacks
(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

;; Remove listing of an NFT
(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))


;; Buy an NFT! In micro stacks
(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? metaboys id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
    (unwrap! (stx-transfer? price tx-sender owner) ERR-STX-TRANSFER)
    (unwrap! (pay-royalty price royalty) ERR-PAY-ROYALTY) 
    (unwrap! (contract-call? comm-trait pay id price) ERR-MARKETPLACE-ROYALTY)
    (unwrap! (trnsfr id owner tx-sender) ERR-CANT-TRANSFER-NFT)
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))
    
(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

;; Set the royalty percentage to the received value
(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (is-eq tx-sender (var-get CONTRACT-OWNER)) (err ERR-INVALID-USER))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))


(define-private (pay-royalty (price uint) (royalty uint))
  (let (
    (royalty-amount (/ (* price royalty) u10000))
  )
  (if (and (> royalty-amount u0) (not (is-eq tx-sender (var-get CONTRACT-OWNER))))
    (unwrap! (stx-transfer? royalty-amount tx-sender (var-get CONTRACT-OWNER)) ERR-PAY-ROYALTY)
    (print false)
  )
  (ok true)))
