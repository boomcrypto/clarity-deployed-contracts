;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-claimed (err u101))
(define-constant err-unauthorized-sender (err u102))
(define-constant err-not-unlocked (err u103))
(define-constant err-no-gift-found (err u104))
(define-constant err-zero-amount (err u105))

;; data vars
(define-data-var total-gifts-created uint u0)

;; data maps
(define-map gift-cards
    uint
    {
        creator: principal,
        recipient: principal,
        amount: uint,
        unlock-height: uint,
        claimed: bool
    }
)

;; private functions
(define-private (is-valid-gift-id (gift-id uint))
    (match (map-get? gift-cards gift-id)
        gift true
        false
    )
)

(define-private (is-sender-recipient (gift-id uint))
    (match (map-get? gift-cards gift-id)
        gift (is-eq tx-sender (get recipient gift))
        false
    )
)

(define-private (is-sender-creator (gift-id uint))
    (match (map-get? gift-cards gift-id)
        gift (is-eq tx-sender (get creator gift))
        false
    )
)

(define-private (is-gift-unlocked (gift-id uint))
    (match (map-get? gift-cards gift-id)
        gift (>= block-height (get unlock-height gift))
        false
    )
)

;; public functions
(define-public (create-gift (recipient principal) (amount uint) (unlock-height uint))
    (let 
        (
            (gift-id (+ (var-get total-gifts-created) u1))
        )
        (asserts! (> amount u0) err-zero-amount)
        ;; Transfer STX from sender to contract
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        ;; Create gift card record
        (map-set gift-cards gift-id {
            creator: tx-sender,
            recipient: recipient,
            amount: amount,
            unlock-height: unlock-height,
            claimed: false
        })
        
        ;; Increment total gifts counter
        (var-set total-gifts-created gift-id)
        (ok gift-id)
    )
)

(define-public (claim-gift (gift-id uint))
    (let 
        (
            (gift (unwrap! (map-get? gift-cards gift-id) err-no-gift-found))
        )
        ;; Check if sender is recipient
        (asserts! (is-sender-recipient gift-id) err-unauthorized-sender)
        ;; Check if gift is unlocked
        (asserts! (is-gift-unlocked gift-id) err-not-unlocked)
        ;; Check if gift is not already claimed
        (asserts! (not (get claimed gift)) err-already-claimed)
        
        ;; Transfer STX from contract to recipient
        (try! (as-contract (stx-transfer? (get amount gift) tx-sender (get recipient gift))))
        
        ;; Mark gift as claimed
        (map-set gift-cards gift-id (merge gift { claimed: true }))
        (ok true)
    )
)

(define-public (reclaim-gift (gift-id uint))
    (let 
        (
            (gift (unwrap! (map-get? gift-cards gift-id) err-no-gift-found))
        )
        ;; Check if sender is creator
        (asserts! (is-sender-creator gift-id) err-unauthorized-sender)
        ;; Check if gift is not already claimed
        (asserts! (not (get claimed gift)) err-already-claimed)
        
        ;; Transfer STX back to creator
        (try! (as-contract (stx-transfer? (get amount gift) tx-sender (get creator gift))))
        
        ;; Mark gift as claimed
        (map-set gift-cards gift-id (merge gift { claimed: true }))
        (ok true)
    )
)

;; read only functions
(define-read-only (get-gift (gift-id uint))
    (ok (map-get? gift-cards gift-id))
)

(define-read-only (get-total-gifts)
    (ok (var-get total-gifts-created))
)

(define-read-only (is-claimed (gift-id uint))
    (match (map-get? gift-cards gift-id)
        gift (get claimed gift)
        false
    )
)