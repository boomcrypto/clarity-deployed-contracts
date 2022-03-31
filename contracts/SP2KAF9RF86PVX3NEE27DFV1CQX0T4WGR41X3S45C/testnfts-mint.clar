;; Storage
(define-map og-presale-count principal uint)
(define-map private-presale-count principal uint)

;; Define Constants
(define-constant mint-price u45000000)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-SALE-NOT-ACTIVE (err u500))
(define-constant ERR-NO-MINTPASS-REMAINING (err u501))

;; Define Variables
(define-data-var og-mintpass-sale-active bool false)
(define-data-var private-mintpass-sale-active bool false)
(define-data-var sale-active bool false)
(define-data-var sale-stage uint u0)

;; Presale balance
(define-read-only (get-og-presale-balance (account principal))
  (default-to u0
    (map-get? og-presale-count account)))

(define-read-only (get-private-presale-balance (account principal))
  (default-to u0
    (map-get? private-presale-count account)))

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
  (let ((presale-balance (get-og-presale-balance new-owner)))
    (asserts! (var-get og-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (> presale-balance u0) ERR-NO-MINTPASS-REMAINING)
    (map-set og-presale-count
              new-owner
              (- presale-balance u1))
    (if banana-mint
        (contract-call? .testnfts banana-mint new-owner)
        (contract-call? .testnfts stx-mint new-owner)  
    )
  ))

;; Internal - Mint NFT using Mintpass mechanism
(define-private (private-mintpass-mint (new-owner principal) (banana-mint bool))
  (let ((presale-balance (+ (get-og-presale-balance new-owner) (get-private-presale-balance new-owner))))
    (asserts! (var-get private-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (> presale-balance u0) ERR-NO-MINTPASS-REMAINING)
    (map-set og-presale-count
              new-owner
              u0)
    (map-set private-presale-count
              new-owner
              (- presale-balance u1))
  (if banana-mint
        (contract-call? .testnfts banana-mint new-owner)
        (contract-call? .testnfts stx-mint new-owner)  
    )
  )
)

;; Internal - Mint public sale NFT
(define-private (public-mint (new-owner principal) (banana-mint bool))
  (begin
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (if banana-mint
        (contract-call? .testnfts banana-mint new-owner)
        (contract-call? .testnfts stx-mint new-owner)  
    )
    ))

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

(as-contract (contract-call? .testnfts set-mint-address))


(define-public (set-bm-wl (address principal) (limit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set og-presale-count address limit)
    (ok true)
  )
)

(define-public (bulk-add-bm (addresses (list 1000 principal)) (limits (list 1000 uint)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (print (map set-bm-wl addresses limits))
    (ok true)
  )
)

(define-public (set-partner-wl (address principal) (limit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set private-presale-count address limit)
    (ok true)
  )
)

(define-public (bulk-add-partner (addresses (list 1000 principal)) (limits (list 1000 uint)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (print (map set-partner-wl addresses limits))
    (ok true)
  )
)
