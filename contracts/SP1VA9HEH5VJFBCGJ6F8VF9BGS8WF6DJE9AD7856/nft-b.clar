;; Test NFT for upcoming BOS / Badger Board


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Define NFT
(define-non-fungible-token nft-b uint)

;; Collection Limit
(define-constant collection-limit u100)

;; Root URI
(define-constant collection-root-uri "")

;; NFT Price
(define-constant nft-b-price u100000)

;; Collection Index
(define-data-var collection-index uint u1)

;; Define Deployer (for charging)
(define-constant deployer tx-sender)


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SIP-09 Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get last token id
(define-public (get-last-token-id) 
    (ok (var-get collection-index))
)

;; Get token URL
(define-public (get-token-uri (id uint)) 
    (ok
        (some (concat
            collection-root-uri
            (concat 
                (uint-to-ascii id)
                ".json"
            )
        ))
    )
)

;; Get token owner
(define-public (get-owner (id uint)) 
    (ok (nft-get-owner? nft-b id))
)

;; Transfer
(define-public (transfer (id uint) (sender principal) (recipient principal)) 
    (begin
        (asserts! (is-eq tx-sender sender) (err u1))
        (nft-transfer? nft-b id sender recipient)
    )
)



;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Core Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Core Mint Func
;; @desc - core function used for minting one nft-simple
(define-public (mint) 
  (let 
    (
      (current-index (var-get collection-index))
      (next-index (+ current-index u1))
    )

    ;; Assert that current-index < collection-limit
    (asserts! (< current-index collection-limit) (err "err-minted-out"))

    ;; Charge tx-sender for nft-b
    (unwrap! (stx-transfer? nft-b-price tx-sender deployer) (err "err-stx-transfer"))

    ;; Mint NFT
    (unwrap! (nft-mint? nft-b current-index tx-sender) (err "err-minting"))

    ;; Var-Set collection-index to next-index
    (ok (var-set collection-index next-index))

  )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Helper Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc utility function that takes in a unit & returns a string
;; @param value; the unit we're casting into a string to concatenate
;; thanks to Lnow for the guidance
(define-read-only (uint-to-ascii (value uint))
  (if (<= value u9)
    (unwrap-panic (element-at "0123456789" value))
    (get r (fold uint-to-ascii-inner
      0x000000000000000000000000000000000000000000000000000000000000000000000000000000
      {v: value, r: ""}
    ))
  )
)

(define-read-only (uint-to-ascii-inner (i (buff 1)) (d {v: uint, r: (string-ascii 39)}))
  (if (> (get v d) u0)
    {
      v: (/ (get v d) u10),
      r: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get v d) u10))) (get r d)) u39))
    }
    d
  )
)