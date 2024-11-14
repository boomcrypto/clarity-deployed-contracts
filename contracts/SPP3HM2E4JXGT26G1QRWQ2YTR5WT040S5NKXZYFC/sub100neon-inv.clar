(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait) 

(define-non-fungible-token sub100neon-inv uint)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_BATCH (err u405))
(define-constant ERR_UNWRAP_OWNERS (err u406))

(define-data-var last-token-id uint u0)
(define-data-var index-helper uint u0)
(define-data-var swap-id-helper uint u0)

(define-map batches uint (list 100 {token-id: uint, recipient: principal})) 

(define-private (is-called-by-charging-ctr)
  (is-eq contract-caller .sub100neon-invader))

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (get-batch (swap-id uint))
  (match (map-get? batches swap-id)
    batch (ok batch)
    (err ERR_INVALID_BATCH)
  )
)

(define-read-only (get-token-uri (token-id uint))
  (ok none))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? sub100neon-inv token-id)))


(define-private (mint-batch-item (item {token-id: uint, recipient: principal}))
  (nft-mint? sub100neon-inv (get token-id item) (get recipient item)))

(define-private (create-batch-item (recipient principal))
  (let
    (
      (current-index (var-get index-helper))
      (token-id (+ (* (var-get swap-id-helper) u100) (+ current-index u1)))
    )
    (var-set index-helper (+ current-index u1))
    {
      token-id: token-id,
      recipient: recipient
    }
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (print "People are illogical, unreasonable, and self-centered. Love them anyway.")
    (ok true)
  )
)

(define-public (mint-batch (swap-id uint))
  (let
    (
      (recipients (unwrap! (contract-call? .sub100inv-owners get-sub100-owners) ERR_UNWRAP_OWNERS))
    )
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTHORIZED)
    (var-set index-helper u0) 
    (var-set swap-id-helper swap-id)
    (let
      (
        (batch (map create-batch-item recipients))
      )
      (map-set batches swap-id batch)
      (map mint-batch-item batch)
      (var-set last-token-id (+ (* swap-id u100) u100))
      (var-set index-helper u0) 
      (var-set swap-id-helper u0)
      (ok true)
    )
  )
)

(define-public (burn-one (token-id uint))
  (let 
    (
      (owner (unwrap! (nft-get-owner? sub100neon-inv token-id) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender owner) ERR_NOT_AUTHORIZED)
    (nft-burn? sub100neon-inv token-id owner)
  )
)

(define-private (burn (item {token-id: uint, recipient: principal})) 
  (nft-burn? sub100neon-inv (get token-id item) (get recipient item))) 

(define-public (burn-batch (swap-id uint))
  (let
    (
      (batch (unwrap! (map-get? batches swap-id) ERR_INVALID_BATCH))
    )
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTHORIZED)
    (map burn batch)
    (map-delete batches swap-id)
    (ok true)
  )
)