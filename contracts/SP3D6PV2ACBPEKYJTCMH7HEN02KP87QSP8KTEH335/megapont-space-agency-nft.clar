;; MSA NFT collection by Megapont.
;; Technical partner: Apollo Labs, Inc.
;; EXCLUSIVE COMMERCIAL RIGHTS WITH NO CREATOR RETENTION ("CBE-EXCLUSIVE")
;; https://zzttkwj3ferbc4svr43g6b6aehbajrfri7tfkha4oug5gbpa4fxq.arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/1
(impl-trait .nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)


(define-non-fungible-token Megapont-Space-Agency uint)

;; Storage
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})
(define-map mint-address bool principal)
(define-map airdrop-claimed uint bool)
(define-map suit-mapping uint (string-ascii 10))

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant CONTRACT-URI "ipfs://QmZPv48fV1HfJe1pmmJSneQp6oqFVrp7DTtKLbxT1MR4vK")
(define-constant MAX-SUPPLY u10000)

;; Megapont shared wallet
(define-constant WALLET 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX)

;; Errors
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-SUITED (err u405))
(define-constant ERR-LISTING (err u406))
(define-constant ERR-MINT-ALREADY-SET (err u407))
(define-constant ERR-MINT-FROZEN (err u408))
(define-constant ERR-AIRDROP-CLAIMED (err u409))
(define-constant ERR-SUITING-INACTIVE (err u410))

;; Variables
;; Index last-id at 2500 as 1-2500 are reserved for Megapont NFTs
(define-data-var last-id uint u2500)
(define-data-var base-uri (string-ascii 80) "https://api.megapont.com/metadata/msa/{id}")
(define-data-var mint-override bool false)
(define-data-var suiting-active bool false)

(define-read-only (get-balance (account principal))
    (default-to u0
        (map-get? token-count account)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? Megapont-Space-Agency id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-id)))

;; SIP009: Get the token URI
(define-read-only (get-token-uri (id uint))
    (ok
        (if (is-none (get-suit-mapping id))
            (some (var-get base-uri))
            (some
                (concat (var-get base-uri) (concat "/" (default-to "" (get-suit-mapping id))))
            )
            )))

(define-read-only (get-contract-uri)
    (ok CONTRACT-URI))

(define-read-only (get-suit-mapping (token-id uint))
    (map-get? suit-mapping token-id))

(define-read-only (get-listing-in-ustx (id uint))
    (map-get? market id))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
    (match (nft-transfer? Megapont-Space-Agency id sender recipient)
        success
            (let
                ((sender-balance (get-balance sender))
                    (recipient-balance (get-balance recipient)))
                (map-set token-count sender (- sender-balance u1))
                (map-set token-count recipient (+ recipient-balance u1))
                (ok success))
        error
            (err error)))

(define-private (is-sender-owner (id uint))
    (let
        ((owner (unwrap! (nft-get-owner? Megapont-Space-Agency id) false)))
        (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-private (called-from-mint)
    (let ((the-mint
        (unwrap! (map-get? mint-address true) false)))
    (is-eq contract-caller the-mint)))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
    (begin
        ;; Only the owner of the token can transfer it
        (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
        (asserts! (is-none (map-get? market id)) ERR-LISTING)
        (trnsfr id sender recipient)))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
    (let ((listing  {price: price, commission: (contract-of comm)}))
        (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
        (map-set market id listing)
        (print (merge listing {action: "list-in-ustx", id: id}))
        (ok true)))

(define-public (unlist-in-ustx (id uint))
    (begin
        (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
        (map-delete market id)
        (print {action: "unlist-in-ustx", id: id})
        (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
    (let ((owner (unwrap! (nft-get-owner? Megapont-Space-Agency id) ERR-NOT-FOUND))
        (listing (unwrap! (map-get? market id) ERR-LISTING))
        (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {action: "buy-in-ustx", id: id})
    (ok true)))

;; can only be called once
(define-public (set-mint-address)
    (let ((the-mint (map-get? mint-address true)))
        (asserts! (and (is-none the-mint)
            (map-insert mint-address true tx-sender)) ERR-MINT-ALREADY-SET)
        (ok tx-sender)))

(define-public (set-suiting-active)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set suiting-active true)
        (ok true)))

;; can only be called once
;; will forever freeze minting but allow for airdrops
(define-public (set-mint-override)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set mint-override true)
        (ok true)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set base-uri new-base-uri)
        (ok true)))

;; Mint new NFT
;; can only be called from the Mint
(define-public (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
        (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (var-get mint-override) false) ERR-MINT-FROZEN)
        (asserts! (< (var-get last-id) MAX-SUPPLY) ERR-SOLD-OUT)
        (match (nft-mint? Megapont-Space-Agency next-id new-owner)
            success
                (let
                    ((current-balance (get-balance new-owner)))
                    (begin
                        (try! (stx-transfer? u50000000 tx-sender WALLET))
                        (var-set last-id next-id)
                        (map-set token-count new-owner (+ current-balance u1))
                (ok true)))
            error (err (* error u10000)))))

(define-public (airdrop (new-owner principal) (ape-id uint))
    (begin
        (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (default-to false (map-get? airdrop-claimed ape-id)) false) ERR-AIRDROP-CLAIMED)
        (match (nft-mint? Megapont-Space-Agency ape-id new-owner)
            success
                (let
                    ((current-balance (get-balance new-owner)))
                    (begin
                        (map-set token-count new-owner (+ current-balance u1))
                        (map-set airdrop-claimed ape-id true)
                (ok true)))
            error (err (* error u10000)))))

;; Fuck clarity, bring on 2.1
(define-public (set-suit-mapping (token-id uint) (ape-id uint))
    (begin
        (asserts! (is-sender-owner token-id) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq tx-sender (unwrap-panic (unwrap-panic (contract-call? .megapont-ape-club-nft get-owner ape-id)))) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (var-get suiting-active) true) ERR-SUITING-INACTIVE)
        ;; can't suit a listed token for safety
        (asserts! (is-none (map-get? market token-id)) ERR-LISTING)
        ;; can't suit a suited token
        (asserts! (is-none (get-suit-mapping token-id)) ERR-ALREADY-SUITED)
        (map-set suit-mapping token-id (uint-to-ascii ape-id))
        (ok true)))

;; Credit goes to lnow for this conversion work
(define-read-only (uint-to-ascii (value uint))
    (if (<= value u9)
        (unwrap-panic (element-at "0123456789" value))
        (get r (fold uint-to-ascii-inner
          0x000000000000000000000000000000000000000000000000000000000000000000000000000000
          {v: value, r: ""}
        ))
    )
)

(define-read-only (uint-to-ascii-inner (i (buff 1)) (d {v: uint, r: (string-ascii 10)}))
    (if (> (get v d) u0)
        {
          v: (/ (get v d) u10),
          r: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get v d) u10))) (get r d)) u10))
        }
        d
    )
)
