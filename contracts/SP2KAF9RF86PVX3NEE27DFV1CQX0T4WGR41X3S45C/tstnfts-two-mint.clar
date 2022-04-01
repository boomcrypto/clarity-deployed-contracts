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
(define-data-var admin principal 'SP3ZJP253DENMN3CQFEQSPZWY7DK35EH3SEH0J8PK)

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
(define-public (claim (bananas bool))
  (if (var-get sale-active)
    (public-mint tx-sender bananas)
    (if (var-get og-mintpass-sale-active)
      (og-mintpass-mint tx-sender bananas)
      (if (var-get private-mintpass-sale-active)
        (private-mintpass-mint tx-sender bananas)
        (not-live)
      )
    )
  )
)

(define-public (claim-many (banana-selection (list 6 bool)))
    (begin
        (print (map claim banana-selection))
        (ok true)
    )
)

;; Internal - Mint NFT using Mintpass mechanism
(define-private (og-mintpass-mint (new-owner principal) (banana-mint bool))
  (let ((mint-count (get-og-presale-balance new-owner)))
    (asserts! (var-get og-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (is-some (index-of (var-get og-mintpasses) tx-sender)) ERR-NO-MINTPASS-REMAINING)
    (asserts! (< mint-count u5) ERR-NO-MINTPASS-REMAINING)
    (map-set og-presale-count
              new-owner
              (+ mint-count u1))
    (if banana-mint
        (contract-call? .tstnfts-two banana-mint new-owner)
        (contract-call? .tstnfts-two stx-mint new-owner)  
    )
  ))

;; Internal - Mint NFT using Mintpass mechanism
(define-private (private-mintpass-mint (new-owner principal) (banana-mint bool))
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
  (if banana-mint
        (contract-call? .tstnfts-two banana-mint new-owner)
        (contract-call? .tstnfts-two stx-mint new-owner)  
    )
  )
)

;; Internal - Mint public sale NFT
(define-private (public-mint (new-owner principal) (banana-mint bool))
    (let (
        (mint-count (get-public-balance new-owner))
    )
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (< mint-count u6) ERR-NO-MORE-MINTS)
    (map-set public-sale-count
              new-owner
              (+ mint-count u1))
    (if banana-mint
        (contract-call? .tstnfts-two banana-mint new-owner)
        (contract-call? .tstnfts-two stx-mint new-owner)  
    )
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

(as-contract (contract-call? .tstnfts-two set-mint-address))

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