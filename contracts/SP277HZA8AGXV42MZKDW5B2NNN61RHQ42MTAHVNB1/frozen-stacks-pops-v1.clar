(define-non-fungible-token frozen-stacks-pops uint)

;; Storage
(define-map token-count principal uint)

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-MINT-ALREADY-SET (err u506))

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 256) "ipfs://QmayHCoY25enr4XmBQxyVFKSU9tkRPy64JywNDDaK9c8MT/frozen-stacks-pops-{id}.json")
(define-constant contract-uri "ipfs://QmayHCoY25enr4XmBQxyVFKSU9tkRPy64JywNDDaK9c8MT/frozen-stacks-pops.json")
(define-map mint-address bool principal)

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  ERR-NOT-AUTHORIZED)

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  ;; Make sure to replace frozen-stacks-pops
  (ok (nft-get-owner? frozen-stacks-pops id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some (var-get base-uri))))

(define-read-only (get-contract-uri)
  (ok contract-uri))

;; Mint new NFT
;; can only be called from the Mint
(define-public (mint (new-owner principal) (id uint))
  (let 
    ((owner-balance (get-balance new-owner)))
    (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
    (try! (nft-mint? frozen-stacks-pops id new-owner))
    (map-set token-count
      new-owner
      (+ owner-balance u1))
    (ok true)
  )
)

(define-public (burn (id uint) (owner principal))
  (let 
    ((owner-balance (get-balance owner)))
    (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
    (try! (nft-burn? frozen-stacks-pops id owner))
    (map-set token-count
      owner
      (- owner-balance u1))
    (ok true)
  )
)

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 256)))
  (begin
    (asserts! (is-eq contract-caller CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set base-uri new-base-uri)
    (ok true)))

;; Freeze metadata
(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq contract-caller CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set metadata-frozen true)
    (ok true)))

;; Manage the Mint
(define-private (called-from-mint)
  (is-eq contract-caller (unwrap! (map-get? mint-address true) false)))

;; can only be called once
(define-public (set-mint-address)
  (begin
    (asserts! (map-insert mint-address true tx-sender) ERR-MINT-ALREADY-SET)
    (ok (print tx-sender))))