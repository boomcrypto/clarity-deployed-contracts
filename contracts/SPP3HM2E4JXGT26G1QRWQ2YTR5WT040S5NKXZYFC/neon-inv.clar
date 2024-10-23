(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token neon-inv uint)

(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_LIGHT (err u405))
(define-constant ERR_UNWRAP_OWNER (err u406))
(define-constant ERR_UNWRAP (err u407))
(define-constant ERR_UNWRAP_INV (err u408))

(define-data-var last-token-id uint u0)

(define-map lights uint principal)

(define-private (is-called-by-charging-ctr)
  (is-eq contract-caller .neon-invader))

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok none))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? neon-inv token-id)))

(define-read-only (get-light (swap-id uint)) 
  (map-get? lights swap-id))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (print "The fight is won or lost far away from witnesses: behind the lines, in the gym, and out there on the road, long before I dance under those lights.")
    (ok true)
  )
)

(define-public (mint-light (swap-id uint) (invader-id (optional uint)))
  (begin
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTHORIZED)
    (match invader-id
      inv-id (let
        (
          (recipient (unwrap! (unwrap! (contract-call? 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ.stacks-invaders-v0 get-owner inv-id) ERR_UNWRAP_OWNER) ERR_UNWRAP))
        )
        (try! (nft-mint? neon-inv swap-id recipient))
        (map-set lights swap-id recipient)
        (var-set last-token-id swap-id)
        (ok true)
      )
      (begin
        (var-set last-token-id swap-id)
        (ok true)
      )
    )
  )
)

(define-public (burn-candle (token-id uint))
  (let 
    (
      (owner (unwrap! (nft-get-owner? neon-inv token-id) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender owner) ERR_NOT_AUTHORIZED)
    (try! (nft-burn? neon-inv token-id owner))
    (map-delete lights token-id)
    (ok true)
  )
)

(define-public (blow-light (swap-id uint))
  (begin
    (asserts! (is-called-by-charging-ctr) ERR_NOT_AUTHORIZED)
    (match (map-get? lights swap-id)
      owner 
        (begin
          (try! (nft-burn? neon-inv swap-id owner))
          (map-delete lights swap-id)
          (ok true)
        )
      (ok false)
    )
  )
)