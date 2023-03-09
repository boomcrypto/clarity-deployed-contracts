
;; title: neoswap-ordinals
;; version: 1.0.0
;; summary: Swaps between Ordinals and STX where the admin is a trusted party
;; description:
;;   This contract allows users to swap between STX and Ordinals. The admin
;;   is a trusted party that approves offer when the ordinal is delivered
;;   to the indicated address.
;;   This contract is heavily based on the ordyswap contract 
;;   by @hstove (https://github.com/mechanismHQ/ordyswap)

;; constants
;;
(define-constant CONTRACT_OWNER tx-sender)

;; error codes
;; (define-constant ERR_TX_NOT_MINED (err u100))
;; (define-constant ERR_INVALID_TX (err u101))
(define-constant ERR_INVALID_OFFER (err u102))
(define-constant ERR_OFFER_MISMATCH (err u103))
(define-constant ERR_OFFER_ACCEPTED (err u104))
(define-constant ERR_OFFER_CANCELED (err u105))
(define-constant ERR_OFFER_APPROVED (err u106))
(define-constant ERR_OFFER_REFUNDED (err u107))
(define-constant ERR_OFFER_NOT_CANCELED (err u115))
(define-constant ERR_OFFER_NOT_APPROVED (err u116))
(define-constant ERR_OFFER_NOT_READY_FOR_REFUND (err u117))
(define-constant ERR_NOT_AUTHORIZED (err u110))


;; data vars
;;
(define-data-var last-id-var uint u0)

;; data maps
;;
;; approved admins
(define-map admins principal bool)

;; Main map for storing offers
(define-map offers-map uint {
  txid: (buff 32), 
  index: uint,
  amount: uint,
  output: (string-ascii 62),
  sender: principal,
  recipient: principal,
})

(define-map offers-accepted-map uint bool)
;; mapping of offer -> block height
(define-map offers-approved-map uint bool)
(define-map offers-canceled-map uint uint)
(define-map offers-refunded-map uint bool)


;; public functions
;;

(define-public (add-admin (admin principal)) 
(begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (map-set admins admin true)
    (ok true)
))

(define-public (remove-admin (admin principal)) 
(begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (map-set admins admin false)
    (ok true)
))

(define-public (create-offer
    (txid (buff 32))
    (index uint)
    (amount uint)
    (output (string-ascii 62))
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
        id: id,
        txid: txid,
        index: index,
        amount: amount,
        output: output,
        sender: tx-sender,
        recipient: recipient,
      }
    })
    (ok id)
  )
)

(define-public (approve-offer 
    (offer-id uint)
    (seller principal)
    (txid (buff 32))
    (index uint)
    (output (string-ascii 62))
  ) 
  (let
    (
        (offer (try! (verify-offer offer-id seller txid index output )))
        (admin-approved (unwrap! (map-get? admins tx-sender) ERR_NOT_AUTHORIZED))
    )    
    ;; Ensure it wasn't canceled
    (try! 
        (match (map-get? offers-canceled-map offer-id)
            canceled-at (
                if (<= burn-block-height canceled-at)
                (ok true)
                ERR_OFFER_CANCELED
            )
            (ok true)
        ) 
    )
    (asserts! (is-eq admin-approved true) ERR_NOT_AUTHORIZED)
    (map-set offers-approved-map offer-id true)
    (ok true)
  )
)

(define-public (finalize-offer
    (offer-id uint)
    (seller principal)
    (txid (buff 32))
    (index uint)
    (output (string-ascii 62))
  )
  (let
    (
      (offer (try! (verify-offer offer-id seller txid index output )))
    )
    (unwrap! (map-get? offers-approved-map offer-id) ERR_OFFER_NOT_APPROVED)
    (try! (as-contract (stx-transfer? (get amount offer) (as-contract tx-sender) (get recipient offer))))
    (asserts! (map-insert offers-accepted-map offer-id true) ERR_OFFER_ACCEPTED)
    (print {
      topic: "offer-finalized",
      offer: (merge offer { id: offer-id })
    })
    (ok offer-id)
  )
)

;; Cancel an offer
;; 
;; The Ordinal owner still has 150 blocks to send the ordinal. This
;; prevents an attack where an offer is canceled after the Ordinal transfer
;; hits the mempool.
(define-public (cancel-offer (id uint))
  (let
    (
      (offer (unwrap! (map-get? offers-map id) ERR_INVALID_OFFER))
    )
    (asserts! (is-eq (get sender offer) tx-sender) ERR_OFFER_MISMATCH)
    ;; Ensure it hasn't been approved
    (asserts! (is-eq (map-get? offers-approved-map id) none) ERR_OFFER_APPROVED)
    (asserts! (map-insert offers-canceled-map id (+ burn-block-height u150)) ERR_INVALID_OFFER)
    (print {
      topic: "offer-canceled",
      offer: (merge offer { id: id }),
    })
    (ok true)
  )
)

;; 150+ blocks after cancelling, the offerer can get their STX back
(define-public (refund-canceled-offer (id uint))
  (let
    (
      (offer (unwrap! (map-get? offers-map id) ERR_INVALID_OFFER))
      (canceled (unwrap! (map-get? offers-canceled-map id) ERR_OFFER_NOT_CANCELED))
    )
    (asserts! (is-eq (map-get? offers-approved-map id) none) ERR_OFFER_APPROVED)
    (asserts! (> burn-block-height canceled) ERR_OFFER_NOT_READY_FOR_REFUND)
    (asserts! (map-insert offers-refunded-map id true) ERR_OFFER_REFUNDED)
    (try! (as-contract (stx-transfer? (get amount offer) (as-contract tx-sender) (get sender offer))))
    (print {
      topic: "offer-refunded",
      offer: (merge offer { id: id }),
    })
    (ok id)
  )
)


;; read only functions
;;
(define-read-only (get-offer (id uint)) (map-get? offers-map id))

(define-read-only (get-offer-accepted (id uint)) (map-get? offers-accepted-map id))

(define-read-only (get-offer-approved (id uint)) (map-get? offers-approved-map id))

(define-read-only (get-offer-canceled (id uint)) (map-get? offers-canceled-map id))

(define-read-only (get-offer-refunded (id uint)) (map-get? offers-refunded-map id))

(define-read-only (get-last-id) (var-get last-id-var))

(define-read-only (verify-offer
    (offer-id uint)
    (seller principal)
    (txid (buff 32))
    (index uint)
    (output (string-ascii 62))
  )
  (let
    (
      (offer (unwrap! (map-get? offers-map offer-id) ERR_INVALID_OFFER))
    )
    ;; Ensure that the right ordinal is being sent
    (asserts! (is-eq txid (get txid offer)) ERR_OFFER_MISMATCH)
    (asserts! (is-eq index (get index offer)) ERR_OFFER_MISMATCH)
    ;; Ensure it was sent to the right address
    (asserts! (is-eq output (get output offer)) ERR_OFFER_MISMATCH)
    ;; Ensure the seller is the recipient
    (asserts! (is-eq seller (get recipient offer)) ERR_OFFER_MISMATCH)
    ;; Ensure it hasn't been accepted
    (asserts! (is-eq (map-get? offers-accepted-map offer-id) none) ERR_OFFER_ACCEPTED)
    (ok offer)
  )
)

;; private functions
;;

(define-private (make-next-id)
  (let
    (
      (last-id (var-get last-id-var))
    )
    (var-set last-id-var (+ last-id u1))
    last-id
  )
)