;; NFT Simple
;; The most simple NFT (for 100 ___ __ ______)
;; Written by Setzeus / StrataLabs


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define NFT
(define-non-fungible-token simple-nft uint)

;; Adhere to SIP09
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Collection Limit
(define-constant collection-limit u100)

;; Root URI
(define-constant collection-root-uri "ipfs://ipfs/QmYcrELFT5c9pjSygFFXk8jfVMHB5cBoWJDGaTvrP/")

;; NFT Price
(define-constant simple-nft-price u10000000)

;; Collection Index
(define-data-var collection-index uint u1)



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
    (ok (nft-get-owner? simple-nft id))
)

;; Transfer
(define-public (transfer (id uint) (sender principal) (recipient principal)) 
    (begin
        (asserts! (is-eq tx-sender sender) (err u1))
        (nft-transfer? simple-nft id sender recipient)
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

    ;; Charge tx-sender for Simple-NFT
    (unwrap! (stx-transfer? simple-nft-price tx-sender (as-contract tx-sender)) (err "err-stx-transfer"))

    ;; Mint Simple-NFT
    (ok (unwrap! (nft-mint? simple-nft current-index tx-sender) (err "err-minting")))

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