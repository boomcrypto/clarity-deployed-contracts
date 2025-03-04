(define-constant SUCCESS (ok true))
(define-constant ERR-NOT-AUTHORIZED (err u80000))
(define-constant ERR-UNSUPPORTED-ASSET (err u80001))
(define-constant ERR-PYTH-PRICE-STALE (err u80002))
(define-constant ERR-INVALID-MAX-CONFIDENCE-RATIO (err u80003))
(define-constant ERR-PRICE-CONFIDENCE-LOW (err u80004))

(define-constant STACKS_BLOCK_TIME (contract-call? .constants-v1 get-stacks-block-time ))
;; Minimum time delta of 1 minute.
(define-constant MINIMUM_TIME_DELTA u60)
;; Confidence ratio scaling factor  = 100% confidence
(define-constant CONFIDENCE_SCALING_FACTOR u10000)

;; price feeds can be found in https://pyth.network/developers/price-feed-ids
(define-map price-feeds principal {
  feed-id: (buff 32),
  max-confidence-ratio: uint
})
(define-data-var time-delta uint u1800)

;; admin-level maintenance functions
(define-public (update-price-feed-id (token principal) (new-feed-id (buff 32)) (max-confidence-ratio uint))
  (begin 
    (asserts! (is-eq (contract-call? .state-v1 get-governance) contract-caller) ERR-NOT-AUTHORIZED)
    (asserts! (<= max-confidence-ratio CONFIDENCE_SCALING_FACTOR) ERR-INVALID-MAX-CONFIDENCE-RATIO)
    (map-set price-feeds token {
      feed-id: new-feed-id,
      max-confidence-ratio: max-confidence-ratio
    })
    (print  {
      event-type: "update-price-feed-id",
      asset: token,
      user: contract-caller,
      feed-id: new-feed-id,
      max-confidence-ratio: max-confidence-ratio,
    })
    SUCCESS
))

(define-public (update-time-delta (delta uint))
  (begin 
    (asserts! (is-eq (contract-call? .state-v1 get-governance) contract-caller) ERR-NOT-AUTHORIZED)
    (print  {
      event-type: "update-time-delta",
      old-val: (var-get time-delta),
      new-val: delta,
      user: contract-caller,
    })
    (var-set time-delta delta)
    SUCCESS
  )
)

(define-read-only (get-pyth-time-delta)
  (var-get time-delta)
)

(define-read-only (get-pyth-minimum-time-delta) MINIMUM_TIME_DELTA)

(define-read-only (read-price (token principal))
  (let 
    (
      (pyth-feed-data (unwrap! (map-get? price-feeds token) ERR-UNSUPPORTED-ASSET))
      (pyth-record 
          (try! (contract-call? 
            .pyth-storage-v3
            get-price
            (get feed-id pyth-feed-data)
          ))
        )
    )
    (decode-pyth pyth-record (get max-confidence-ratio pyth-feed-data))
  )
)

(define-public (update-pyth (maybe-vaa-buffer (optional (buff 8192))))
  (match maybe-vaa-buffer vaa-buffer
    (begin
      (try! 
        (contract-call? .pyth-oracle-v3 verify-and-update-price-feeds 
          vaa-buffer
          {
            pyth-storage-contract: .pyth-storage-v3,
            pyth-decoder-contract: .pyth-pnau-decoder-v2,
            wormhole-core-contract: .wormhole-core-v3
          }) 
      )
      SUCCESS
    )
    SUCCESS
  )
)

(define-read-only (bulk-read-collateral-prices (collaterals (list 10 principal)))
  (fold check-collateral-price-exists collaterals (ok (list)))
)

(define-private (check-collateral-price-exists (collateral principal) (res (response (list 10 uint) uint)))
  (let (
    (price-list (try! res))
    (price (try! (read-price collateral)))
    (updated-price-list (unwrap-panic (as-max-len? (append price-list price) u10)))
  )
    (ok updated-price-list)
  )
)

(define-private (decode-pyth (pyth-record 
  {conf: uint, ema-conf: uint, ema-price: int, expo: int, prev-publish-time: uint, price: int, publish-time: uint}
) (max-confidence-ratio uint)) 
  (let 
    (
      (timestamp (get publish-time pyth-record))
      (expo (get expo pyth-record))
      (price (get price pyth-record))
      (price-conf (get conf pyth-record))
      
    )
    (asserts! (is-valid timestamp) ERR-PYTH-PRICE-STALE)
    (try! (check-confidence (to-uint price) price-conf max-confidence-ratio))
    (ok (to-uint (convert-res price expo 8)))
))

(define-private (check-confidence (price uint) (confidence uint) (max-confidence-ratio uint))
  (if (or (is-eq u0 price) (<= confidence (/ (* price max-confidence-ratio) CONFIDENCE_SCALING_FACTOR)))
    (ok true)
    ERR-PRICE-CONFIDENCE-LOW
  )
)

(define-private (is-valid (timestamp uint))
  (let ((block-timestamp (+ (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))) STACKS_BLOCK_TIME)))
    (if (>= timestamp block-timestamp) 
      true
      (> timestamp (- block-timestamp (var-get time-delta))))
  )
)

(define-private (abs (val int))
  (if (> val 0) val (- 0 val))
)

(define-private (convert-res (price int) (expo int) (resolution-digits int))
  (if (>= expo 0)
    (* price (pow 10 (+ expo resolution-digits)))
    (let ((diff (- resolution-digits (abs expo))))
      (if (is-eq diff 0) 
        price 
        (if (> diff 0) (* price (pow 10 diff)) (/ price (pow 10 (abs diff))))
    ))
))
