;; use the SIP090 interface (testnet)
;;live (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;test (impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.nft-trait.nft-trait)
(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token Stackswap-Silver-Pass uint)

;; Storage
(define-map token-count principal uint)

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))   
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-MINT-ALREADY-SET (err u506))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-MINT-PASS-LIMIT-REACHED (err u109))
(define-constant ERR-ADD-MINT-PASS (err u110))

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 80) "ipfs://QmQMArAThFXsFtDUyBWBepThCUbANjomWSw9cnmLALLcaM")
(define-constant contract-uri "ipfs://QmQMArAThFXsFtDUyBWBepThCUbANjomWSw9cnmLALLcaM")

(define-data-var silver-pass-limit uint u10000)

;; whitelist address -> # they can mint
(define-map mint-pass principal uint)

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? Stackswap-Silver-Pass id sender recipient)
    success
      (let
        ((sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
          (map-set token-count
            sender
            (- sender-balance u1))
          (map-set token-count
            recipient
            (+ recipient-balance u1))
          (ok success))
    error (err error)))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (trnsfr id sender recipient)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  ;; Make sure to replace Stackswap-Silver-Pass
  (ok (nft-get-owner? Stackswap-Silver-Pass id)))

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
(define-public (mint (new-owner principal))
  (let ((next-id (+ u1 (var-get last-id))))
    (asserts! (< (var-get last-id) (var-get silver-pass-limit)) ERR-SOLD-OUT)
    (match (nft-mint? Stackswap-Silver-Pass next-id new-owner)
      success
      (let (
          (current-balance (get-balance new-owner))
          (mintPassBalance (get-mint-pass-balance contract-caller))
        )
        (begin
          (asserts! (> mintPassBalance u0) ERR-MINT-PASS-LIMIT-REACHED)
          (map-set mint-pass contract-caller (- mintPassBalance u1))
          (var-set last-id next-id)
          (map-set token-count
            new-owner
            (+ current-balance u1)
          )
          (ok true)))
      error (err (* error u10000)))))

(define-public (batch-mint (entries (list 200 principal)))
    (fold check-err
      (map mint entries)
      (ok true)
    )
)

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? Stackswap-Silver-Pass id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))


;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
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

(define-read-only (get-mint-pass-balance (account principal))
  (default-to u0
    (map-get? mint-pass account)
  )
)

(define-public (set-mint-pass (account principal) (limit uint))
  (begin
    (asserts! (is-eq contract-caller CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set mint-pass account limit))
  )
)

;; Set pass limit
(define-public (set-pass-limit (limit uint))
  (begin
    (asserts! (is-eq contract-caller CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set silver-pass-limit limit)
    (ok true)))

(define-public (batch-set-mint-pass (entries (list 200 {account: principal, limit: uint})))
  (fold check-err
    (map set-mint-pass-helper entries)
    (ok true)
  )
)

(define-private (set-mint-pass-helper (entry {account: principal, limit: uint}))
    (set-mint-pass (get account entry) (get limit entry))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior 
    ok-value result
    err-value (err err-value)
  )
)

(map-set mint-pass 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275 u2)
