;; Storage
(define-map private-presale-count principal uint)
(define-map public-sale-count principal uint)

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-SALE-NOT-ACTIVE (err u500))
(define-constant ERR-NO-MINTPASS-REMAINING (err u501))

;; Define Variables
(define-data-var stx-private-cost-per-mint uint u60000000)
(define-data-var stx-public-cost-per-mint uint u70000000)
(define-data-var private-mintpass-sale-active bool false)
(define-data-var sale-active bool false)
(define-data-var sale-stage uint u0)
(define-data-var admin principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)

(define-read-only (get-private-presale-balance (account principal))
  (default-to u0
    (map-get? private-presale-count account)))

(define-read-only (get-public-balance (account principal))
  (default-to u0
    (map-get? public-sale-count account)))

;; Claim a new NFT
(define-public (claim)
  (if (var-get sale-active)
    (public-mint tx-sender)
      (if (var-get private-mintpass-sale-active)
        (private-mintpass-mint tx-sender)
        (not-live)
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

(define-public (claim-seven)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-eight)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-nine)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-ten)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-eleven)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-twelve)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (set-stx-private-cost (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set stx-private-cost-per-mint amount)
    (ok true)))

(define-public (set-stx-public-cost (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set stx-public-cost-per-mint amount)
    (ok true)))

;; Internal - Mint NFT using Mintpass mechanism
(define-private (private-mintpass-mint (new-owner principal))
  (let ((mint-count (get-private-presale-balance new-owner)))
    (asserts! (var-get private-mintpass-sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (> mint-count u0) ERR-NO-MINTPASS-REMAINING)
    (map-set private-presale-count
              new-owner
              (- mint-count u1))
    (contract-call? .minotauri-nft mint new-owner)  
  )
)

;; Internal - Mint public sale NFT
(define-private (public-mint (new-owner principal))
  (let ((mint-count (get-public-balance new-owner)))
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (contract-call? .minotauri-nft mint new-owner)  
  )
)

(define-private (not-live)
  (begin
    (asserts! (or (var-get sale-active) (var-get private-mintpass-sale-active)) ERR-SALE-NOT-ACTIVE)
    (ok false)
  )
)

;; Set public sale flag
(define-public (flip-private-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    ;; Disable the Public sale
    (var-set sale-active false)
    (var-set private-mintpass-sale-active (not (var-get private-mintpass-sale-active)))
    (try! (contract-call? .minotauri-nft set-stx-cost (var-get stx-private-cost-per-mint)))
    (ok (var-get private-mintpass-sale-active))))

;; Set public sale flag
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set private-mintpass-sale-active false)
    (var-set sale-active (not (var-get sale-active)))
    (try! (contract-call? .minotauri-nft set-stx-cost (var-get stx-public-cost-per-mint)))
    (ok (var-get sale-active))))

(define-read-only (get-sale-status)
  (list (var-get private-mintpass-sale-active) (var-get sale-active))
)

(as-contract (contract-call? .minotauri-nft set-mint-address))

;; update pre-sale counts
(define-public (set-private-wl (address principal) (limit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set private-presale-count address limit)
    (ok true)
  )
)

(define-public (bulk-add-partner (addresses (list 1000 principal)) (limits (list 1000 uint)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (print (map set-private-wl addresses limits))
    (ok true)
  )
)

;; ###### BEGIN: banana fungible token code ##################################################
;; Claim a new NFT
(define-public (claim-banana)
  (if (or (var-get sale-active) (var-get private-mintpass-sale-active))
    (banana-public-mint tx-sender)
    (not-live)
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

(define-public (claim-banana-seven)
  (begin
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (ok true)))

(define-public (claim-banana-eight)
  (begin
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (ok true)))

(define-public (claim-banana-nine)
  (begin
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (ok true)))

(define-public (claim-banana-ten)
  (begin
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (try! (claim-banana))
    (ok true)))


;; Internal - Mint public sale NFT
(define-private (banana-public-mint (new-owner principal))
  (let ((mint-count (get-public-balance new-owner)))
    (contract-call? .minotauri-nft banana-mint new-owner)
  )
)
;; ###### END: banana fungible token mint template code ##################################################

;; ###### BEGIN: slime-token fungible token code ##################################################
;; Claim a new NFT
(define-public (claim-slime)
  (if (or (var-get sale-active) (var-get private-mintpass-sale-active))
    (slime-public-mint tx-sender)
    (not-live)
  )
)

(define-public (claim-slime-two)
  (begin
    (try! (claim-slime))
    (try! (claim-slime))
    (ok true)))

(define-public (claim-slime-three)
  (begin
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (ok true)))

(define-public (claim-slime-four)
  (begin
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (ok true)))

(define-public (claim-slime-five)
  (begin
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (ok true)))

(define-public (claim-slime-six)
  (begin
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (ok true)))

(define-public (claim-slime-seven)
  (begin
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (ok true)))

(define-public (claim-slime-eight)
  (begin
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (ok true)))

(define-public (claim-slime-nine)
  (begin
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (ok true)))

(define-public (claim-slime-ten)
  (begin
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (ok true)))

(define-public (claim-slime-eleven)
  (begin
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (ok true)))

(define-public (claim-slime-twelve)
  (begin
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (try! (claim-slime))
    (ok true)))

;; ;; Internal - Mint public sale NFT
(define-private (slime-public-mint (new-owner principal))
  (let ((mint-count (get-public-balance new-owner)))
    (contract-call? .minotauri-nft slime-mint new-owner)
  )
)
;; ###### END: slime-token fungible token mint template code ##################################################