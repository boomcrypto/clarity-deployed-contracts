;; OrdinalSwap
;; 
;; Trustless p2p atomic swaps between Ordinals and STX
;; 
;; The basic flow is:
;; 
;; - Someone makes an offer on a specific Ordinal. They must know the
;; sender's STX address ahead of time
;;   - This contract escrows the STX
;; - Ordinal owner sends the Ordinal to the specified BTC address made
;; in the offer
;; - Ordinal owner calls this contract with a transaction inclusion proof
;; to show that they send the right Ordinal to the right address
;; - This contract sends STX to the Ordinal owner
;; 

;; Main map for storing offers
(define-map offers-map uint {
  txid: (buff 32),
  index: uint,
  amount: uint,
  output: (buff 128),
  sender: principal,
  recipient: principal,
})

(define-map offers-accepted-map uint bool)
;; mapping of offer -> block height
(define-map offers-cancelled-map uint uint)
(define-map offers-refunded-map uint bool)

(define-data-var last-id-var uint u0)

(define-constant ERR_TX_NOT_MINED (err u100))
(define-constant ERR_INVALID_TX (err u101))
(define-constant ERR_INVALID_OFFER (err u102))
(define-constant ERR_OFFER_MISMATCH (err u103))
(define-constant ERR_OFFER_ACCEPTED (err u104))
(define-constant ERR_OFFER_CANCELLED (err u105))

(define-public (create-offer
    (txid (buff 32))
    (index uint)
    (amount uint)
    (output (buff 128))
    (recipient principal)
  )
  (let
    (
      (id (make-next-id))
    )
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-insert offers-map id {
      txid: txid,
      index: index,
      amount: amount,
      output: output,
      sender: tx-sender,
      recipient: recipient,
    })
    (print {
      topic: "new-offer",
      offer: {
        txid: txid,
        index: index,
        amount: amount,
        output: output,
        sender: tx-sender,
        recipient: recipient,
      }
    })
    (ok true)
  )
)

;; Helper function to validate the transfer of an Ordinal.
;; 
;; This function is validating:
;; 
;; - The transaction was mined in a BTC block
;; - The transaction was sent to the right address
;; - The transaction includes the right Ordinal as an input
;; - The offer wasn't cancelled
;; - The offer wasn't already accepted
(define-read-only (validate-offer-transfer
    (block { header: (buff 80), height: uint })
    (prev-blocks (list 10 (buff 80)))
    (tx (buff 1024))
    (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint })
    (input-index uint)
    (output-index uint)
    (offer-id uint)
  )
  (let
    (
      (was-mined-bool (unwrap! (contract-call? 'SP1WN90HKT0E1FWCJT9JFPMC8YP7XGBGFNZGHRVZX.clarity-bitcoin was-tx-mined-prev? block prev-blocks tx proof) ERR_TX_NOT_MINED))
      (was-mined (asserts! was-mined-bool ERR_TX_NOT_MINED))
      (mined-height (get height block))
      (parsed-tx (unwrap! (contract-call? 'SP1WN90HKT0E1FWCJT9JFPMC8YP7XGBGFNZGHRVZX.clarity-bitcoin parse-tx tx) ERR_INVALID_TX))
      (output (unwrap! (element-at (get outs parsed-tx) output-index) ERR_INVALID_TX))
      (offer (unwrap! (map-get? offers-map offer-id) ERR_INVALID_OFFER))
      (input (get outpoint (unwrap! (element-at (get ins parsed-tx) input-index) ERR_INVALID_TX)))
      (input-txid (get hash input))
      (input-idx (get index input))
    )
    ;; Ensure that the right ordinal is being sent - based on the `{txid,index}`
    (asserts! (is-eq input-txid (get txid offer)) ERR_OFFER_MISMATCH)
    (asserts! (is-eq input-idx (get index offer)) ERR_OFFER_MISMATCH)
    ;; Ensure it was sent to the right address
    (asserts! (is-eq (get scriptPubKey output) (get output offer)) ERR_OFFER_MISMATCH)
    ;; Ensure it hasn't been accepted
    (asserts! (is-eq (map-get? offers-accepted-map offer-id) none) ERR_OFFER_ACCEPTED)
    ;; Ensure it wasn't cancelled
    (match (map-get? offers-cancelled-map offer-id)
      cancelled-at (if (<= burn-block-height cancelled-at)
        (ok offer)
        ERR_OFFER_CANCELLED
      )
      (ok offer)
    )
  )
)

(define-public (finalize-offer
    (block { header: (buff 80), height: uint })
    (prev-blocks (list 10 (buff 80)))
    (tx (buff 1024))
    (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint })
    (output-index uint)
    (input-index uint)
    (offer-id uint)
  )
  (let
    (
      (offer (try! (validate-offer-transfer block prev-blocks tx proof input-index output-index offer-id)))
    )
    (try! (as-contract (stx-transfer? (get amount offer) (as-contract tx-sender) (get recipient offer))))
    (asserts! (map-insert offers-accepted-map offer-id true) ERR_OFFER_ACCEPTED)
    (print {
      topic: "offer-finalized",
      offer: offer,
      txid: (contract-call? 'SP1WN90HKT0E1FWCJT9JFPMC8YP7XGBGFNZGHRVZX.clarity-bitcoin get-txid tx)
    })
    (ok true)
  )
)

;; Cancel an offer
;; 
;; The Ordinal owner still has 50 blocks to send the ordinal. This
;; prevents an attack where an offer is cancelled after the Ordinal transfer
;; hits the mempool.
(define-public (cancel-offer (id uint))
  (let
    (
      (offer (unwrap! (map-get? offers-map id) ERR_INVALID_OFFER))
    )
    (asserts! (is-eq (get sender offer) tx-sender) ERR_INVALID_OFFER)
    
    (asserts! (map-insert offers-cancelled-map id (+ burn-block-height u50)) ERR_INVALID_OFFER)
    (print {
      topic: "offer-cancelled",
      offer: offer,
    })
    (ok true)
  )
)

;; 50+ blocks after cancelling, the offerer can get their STX back
(define-public (refund-cancelled-offer (id uint))
  (let
    (
      (offer (unwrap! (map-get? offers-map id) ERR_INVALID_OFFER))
      (cancelled (unwrap! (map-get? offers-cancelled-map id) ERR_INVALID_OFFER))
    )
    (asserts! (> burn-block-height cancelled) ERR_INVALID_OFFER)
    (asserts! (map-insert offers-refunded-map id true) ERR_INVALID_OFFER)
    (try! (as-contract (stx-transfer? (get amount offer) (as-contract tx-sender) (get sender offer))))
    (print {
      topic: "offer-refunded",
      offer: offer,
    })
    (ok true)
  )
)

;; Getters

(define-read-only (get-offer (id uint)) (map-get? offers-map id))

(define-read-only (get-offer-accepted (id uint)) (map-get? offers-accepted-map id))

(define-read-only (get-offer-cancelled (id uint)) (map-get? offers-cancelled-map id))

(define-read-only (get-offer-refunded (id uint)) (map-get? offers-cancelled-map id))

;; Private

(define-private (make-next-id)
  (let
    (
      (last-id (var-get last-id-var))
    )
    (var-set last-id-var (+ last-id u1))
    last-id
  )
)