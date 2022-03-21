;; l-m
(define-non-fungible-token l-m uint)

;; constants
(define-constant l-m-limit u24000)
(define-constant contract-owner tx-sender)

;; error messages
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-1ST-MINT-OUT (err u102))
(define-constant ERR-2ND-MINT-OUT (err u103))
(define-constant ERR-NOT-AUTH (err u104))
(define-constant ERR-META-FRZN (err u105))

;; admin vars
(define-data-var metadata-frozen bool true)
(define-data-var ipfs-root (string-ascii 102) "ipfs://ipfs/QmYcrELFT5c9pjSygFFXk8jfVMHB5cBoWJDGaTvrP/")
(define-data-var l-m-index uint u0)

;; l-ms batch sizes
(define-data-var l-m-1st-limit uint u13000)
(define-data-var l-m-2nd-limit uint u9000)

;; l-m batch prices - in STX
(define-data-var l-m-1-price uint u255000)
(define-data-var l-m-2-price uint u536000)
(define-data-var l-m-3-price uint u677000)

;; l-m batch release schedule
(define-data-var mint-block-height-2 uint u51253)
(define-data-var mint-block-height-3 uint u51541)

;;;;;;;;;;;;;;;;;;;;;;
;; SIP009 Functions ;;
;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (get-last-token-id)
  (ok (var-get l-m-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? l-m id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok
    (some
      (concat
        (concat
          (var-get ipfs-root)
          "test"
          ;;(unwrap-panic (unwrap-panic (contract-call? .moon-project-v1 uint-to-ascii token-id)))
        )
        ".json"
      )
    )
  )
)

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u103))
    (nft-transfer? l-m id sender recipient)
  )
)

;;;;;;;;;;;;;;;;;;;;
;; Core Functions ;;
;;;;;;;;;;;;;;;;;;;;

;; l m claim
(define-public (l-m-claim)
  (let (
        (next-l-m-index (+ u1 (var-get l-m-index)))
      )
      ;;checking for l-m-index against entire l-m collection (24k)
      (asserts! (< (var-get l-m-index) l-m-limit) ERR-ALL-MINTED)

      ;;checking current block height against 2nd scheduled mint release block height
      ;;need different stx-transfer functions since diff prices but only need 1 mint function
      (if (< block-height (var-get mint-block-height-2))
        ;; if true (block height is lower than scheduled 2nd mint)
        (begin
          (asserts! (< (var-get l-m-index) (var-get l-m-1st-limit)) ERR-1ST-MINT-OUT)
          (unwrap! (stx-transfer? (var-get l-m-1-price) tx-sender contract-owner) (err u104))
        )
        ;; if false (block height has now surpassed 2nd mint)
        (begin
          (if (< block-height (var-get mint-block-height-3))
            (begin
              (asserts! (< (var-get l-m-index) (var-get l-m-2nd-limit)) ERR-2ND-MINT-OUT)
              (unwrap! (stx-transfer? (var-get l-m-2-price) tx-sender contract-owner) (err u104))
            )
            (unwrap! (stx-transfer? (var-get l-m-3-price) tx-sender contract-owner) (err u104))
          )
        )
      )
      (try! (nft-mint? l-m (var-get l-m-index) tx-sender))
      ;;(unwrap-panic (unwrap-panic (contract-call? .moon-project-v1 update-user-l-f-mint-count)))
      (ok (var-set l-m-index next-l-m-index))
  )
)

;;;;;;;;;;;;;;;;;;;;
;; List Functions ;;
;;;;;;;;;;;;;;;;;;;;

;; @desc function to mint 2 l ms
(define-public (claim-two-l-ms)
  (begin
    (try! (l-m-claim))
    (ok (l-m-claim))
  )
)

;; @desc function to mint 4 l ms
(define-public (claim-four-l-ms)
  (begin
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (ok (l-m-claim))
  )
)

;; @desc function to mint 8 l ms
(define-public (claim-eight-l-ms)
  (begin
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (ok (l-m-claim))
  )
)

;; @desc function to mint 12 l ms
(define-public (claim-twelve-l-ms)
  (begin
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (try! (l-m-claim))
    (ok (l-m-claim))
  )
)
