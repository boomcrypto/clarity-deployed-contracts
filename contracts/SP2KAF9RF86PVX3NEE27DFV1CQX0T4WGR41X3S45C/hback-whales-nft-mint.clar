;; Storage
(define-map og-presale-count principal uint)
(define-map private-presale-count principal uint)
(define-map public-sale-count principal uint)

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-SALE-NOT-ACTIVE (err u500))
(define-constant ERR-NO-MINTPASS-REMAINING (err u501))
(define-constant ERR-NO-MORE-MINTS (err u502))

;; Define Variables
(define-data-var og-mintpass-sale-active bool false)
(define-data-var private-mintpass-sale-active bool false)
(define-data-var sale-active bool false)
(define-data-var sale-stage uint u0)
(define-data-var og-mintpasses (list 1000 principal) (list ))
(define-data-var private-mintpasses (list 1000 principal) (list ))
(define-data-var admin principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)

;; Presale balance
(define-read-only (get-og-presale-balance (account principal))
  (default-to u0
    (map-get? og-presale-count account)))

(define-read-only (get-private-presale-balance (account principal))
  (default-to u0
    (map-get? private-presale-count account)))

(define-read-only (get-public-balance (account principal))
  (default-to u0
    (map-get? public-sale-count account)))

(define-read-only (get-og-list)
  (var-get og-mintpasses)
)

(define-read-only (get-private-list)
  (var-get private-mintpasses)
)

;; Claim a new NFT
(define-public (claim)
  (if (var-get sale-active)
    (public-mint tx-sender)
    (if (var-get og-mintpass-sale-active)
      (og-mintpass-mint tx-sender)
      (if (var-get private-mintpass-sale-active)
        (private-mintpass-mint tx-sender)
        (not-live)
      )
    )
  )
)

(define-public (claim-two)
  (begin
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-three)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-four)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-five)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-six)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))
    
;; Claim a new NFT
(define-public (claim-banana)
  (if (var-get sale-active)
    (public-banana-mint tx-sender)
    (if (var-get og-mintpass-sale-active)
      (og-mintpass-banana-mint tx-sender)
      (if (var-get private-mintpass-sale-active)
        (private-mintpass-banana-mint tx-sender)
        (not-live)
      )
    )
  )
)

(define-public (claim-banana-two)
  (begin
    (try! (claim-banana))
    (try! (claim-banana))
    (ok true)))

(define-public (claim-banana-three)
  (begin
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (ok true)))

(define-public (claim-banana-four)
  (begin
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (ok true)))

(define-public (claim-banana-five)
  (begin
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (ok true)))

(define-public (claim-banana-six)
  (begin
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (ok true)))

;; Internal - Mint NFT using Mintpass mechanism
(define-private (og-mintpass-mint (new-owner principal))
  (let ((mint-count (get-og-presale-balance new-owner)))
    (asserts! (var-get og-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (is-some (index-of (var-get og-mintpasses) tx-sender)) ERR-NO-MINTPASS-REMAINING)
    (asserts! (< mint-count u5) ERR-NO-MINTPASS-REMAINING)
    (map-set og-presale-count
              new-owner
              (+ mint-count u1))
    (contract-call? .hback-whales-nft stx-mint new-owner)
  ))

  ;; Internal - Mint NFT using Mintpass mechanism
(define-private (og-mintpass-banana-mint (new-owner principal))
  (let ((mint-count (get-og-presale-balance new-owner)))
    (asserts! (var-get og-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (is-some (index-of (var-get og-mintpasses) tx-sender)) ERR-NO-MINTPASS-REMAINING)
    (asserts! (< mint-count u5) ERR-NO-MINTPASS-REMAINING)
    (map-set og-presale-count
              new-owner
              (+ mint-count u1))
    (contract-call? .hback-whales-nft banana-mint new-owner)
  ))

;; Internal - Mint NFT using Mintpass mechanism
(define-private (private-mintpass-mint (new-owner principal))
  (let ((mint-count (+ (get-og-presale-balance new-owner) (get-private-presale-balance new-owner))))
    (asserts! (var-get private-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (or (is-some (index-of (var-get og-mintpasses) tx-sender)) (is-some (index-of (var-get private-mintpasses) tx-sender))) ERR-NO-MINTPASS-REMAINING)
    (if (is-some (index-of (var-get og-mintpasses) tx-sender))
        (asserts! (< mint-count u5) ERR-NO-MINTPASS-REMAINING)
        (asserts! (< mint-count u4) ERR-NO-MINTPASS-REMAINING)
    )
    (map-set og-presale-count
              new-owner
              u0)
    (map-set private-presale-count
              new-owner
              (+ mint-count u1))
    (contract-call? .hback-whales-nft stx-mint new-owner)  
  )
)

;; Internal - Mint NFT using Mintpass mechanism
(define-private (private-mintpass-banana-mint (new-owner principal))
  (let ((mint-count (+ (get-og-presale-balance new-owner) (get-private-presale-balance new-owner))))
    (asserts! (var-get private-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (or (is-some (index-of (var-get og-mintpasses) tx-sender)) (is-some (index-of (var-get private-mintpasses) tx-sender))) ERR-NO-MINTPASS-REMAINING)
    (if (is-some (index-of (var-get og-mintpasses) tx-sender))
        (asserts! (< mint-count u5) ERR-NO-MINTPASS-REMAINING)
        (asserts! (< mint-count u4) ERR-NO-MINTPASS-REMAINING)
    )
    (map-set og-presale-count
              new-owner
              u0)
    (map-set private-presale-count
              new-owner
              (+ mint-count u1))
    (contract-call? .hback-whales-nft banana-mint new-owner)
  )
)

;; Internal - Mint public sale NFT
(define-private (public-mint (new-owner principal))
    (let (
        (mint-count (get-public-balance new-owner))
    )
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (< mint-count u6) ERR-NO-MORE-MINTS)
    (map-set public-sale-count
              new-owner
              (+ mint-count u1))
    (contract-call? .hback-whales-nft stx-mint new-owner)  
    )
)

;; Internal - Mint public sale NFT
(define-private (public-banana-mint (new-owner principal))
    (let (
        (mint-count (get-public-balance new-owner))
    )
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (< mint-count u6) ERR-NO-MORE-MINTS)
    (map-set public-sale-count
              new-owner
              (+ mint-count u1))
    (contract-call? .hback-whales-nft banana-mint new-owner)
    )
)

(define-private (not-live)
  (begin
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (var-get og-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (var-get private-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (ok false)
  )
)

;; Set public sale flag
(define-public (flip-og-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER)  ERR-NOT-AUTHORIZED)
    ;; Disable the Public sale
    (var-set sale-active false)
    (var-set private-mintpass-sale-active false)
    (var-set og-mintpass-sale-active (not (var-get og-mintpass-sale-active)))
    (ok (var-get og-mintpass-sale-active))))

;; Set public sale flag
(define-public (flip-private-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER)  ERR-NOT-AUTHORIZED)
    ;; Disable the Public sale
    (var-set sale-active false)
    (var-set og-mintpass-sale-active false)
    (var-set private-mintpass-sale-active (not (var-get private-mintpass-sale-active)))
    (ok (var-get private-mintpass-sale-active))))

;; Set public sale flag
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set og-mintpass-sale-active false)
    (var-set private-mintpass-sale-active false)
    (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))))

(define-read-only (get-sale-status)
  (list (var-get og-mintpass-sale-active) (var-get private-mintpass-sale-active) (var-get sale-active))
)

(as-contract (contract-call? .hback-whales-nft set-mint-address))

(define-public (og-change (addresses (list 1000 principal)))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set og-mintpasses addresses))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (private-change (addresses (list 1000 principal)))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set private-mintpasses addresses))
    (err ERR-NOT-AUTHORIZED)
  )
)