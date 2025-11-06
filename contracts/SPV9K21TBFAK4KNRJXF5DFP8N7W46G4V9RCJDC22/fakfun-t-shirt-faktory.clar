;; FakFun T-Shirt Minimal Pre-Order Contract
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_ORDERED (err u101))
(define-constant ERR_CAMPAIGN_FULL (err u102))
(define-constant ERR_NOT_SHIPPED (err u103))
(define-constant ERR_ALREADY_RATED (err u104))
(define-constant ERR_INVALID_SIZE (err u105))
(define-constant ERR_NO_ORDER (err u106))
(define-constant ERR_ALREADY_SHIPPED (err u107))
(define-constant ERR_INVALID_RATING (err u108))
(define-constant ERR_NOT_RATED (err u109))
(define-constant ERR_NOT_A_RATING (err u110))
(define-constant ERR_DEADLINE (err u111)) 
(define-constant ERR_SHIPPING_TOO_SLOW (err u112)) 
(define-constant ERR_ALREADY_CLAIMED (err u113)) 
(define-constant ERR_CAMPAIGN_ONGOING (err u114))
(define-constant ERR_CAMPAIGN_CLOSED (err u115)) 

(define-constant PRICE u50000000)
(define-constant TARGET_ORDERS u21)
(define-constant DEADLINE u2016) 
(define-constant FEES u5000000) 
(define-constant CAMPAIGN_DEADLINE u3024) 
(define-constant CAMPAIGN_START burn-block-height)
(define-constant ORACLE tx-sender)

(define-data-var artist principal tx-sender)
(define-data-var total-orders uint u0)
(define-data-var block-completion uint u0)
(define-data-var campaign-status uint u1)


(define-map orders principal 
  { 
    size: (string-ascii 3),
    ordered-block: uint,
    shipped-block: (optional uint),
    delivery-days: (optional uint),
    rating: (optional uint),
    rated-block: (optional uint),
    artist-response: (optional bool),
    claimed: bool
  }
)

(define-data-var buyer-list (list 21 principal) (list))

(define-map valid-sizes (string-ascii 3) bool)
(map-set valid-sizes "XS" true)
(map-set valid-sizes "S" true)
(map-set valid-sizes "M" true) 
(map-set valid-sizes "L" true)
(map-set valid-sizes "XL" true)
(map-set valid-sizes "XXL" true)

(define-read-only (get-order (buyer principal))
  (map-get? orders buyer)
)

(define-read-only (get-campaign-status)
  { orders: (var-get total-orders), target: TARGET_ORDERS }
)

(define-public (place-order (size (string-ascii 3)))
  (begin
    (asserts! (default-to false (map-get? valid-sizes size)) ERR_INVALID_SIZE)
    (asserts! (is-none (map-get? orders tx-sender)) ERR_ALREADY_ORDERED)
    (asserts! (< (var-get total-orders) TARGET_ORDERS) ERR_CAMPAIGN_FULL)
    (asserts! (> (var-get campaign-status) u0) ERR_CAMPAIGN_CLOSED)
  
    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer PRICE tx-sender (as-contract tx-sender) none))
    
    ;; Record order
    (map-set orders tx-sender { 
      size: size,
      ordered-block: burn-block-height, 
      shipped-block: none, 
      delivery-days: none,
      rating: none,
      rated-block: none,
      artist-response: none,
      claimed: false
    })
    (var-set buyer-list (unwrap! (as-max-len? (append (var-get buyer-list) tx-sender) u21) ERR_CAMPAIGN_FULL))
    (var-set total-orders (+ (var-get total-orders) u1))
    (if (is-eq (var-get total-orders) TARGET_ORDERS)
        (var-set block-completion burn-block-height)
        true)
    (ok true)
  )
)

(define-public (mark-shipped (buyer principal) (delivery-days uint))
  (let ((order (unwrap! (map-get? orders buyer) ERR_NO_ORDER)))
    (asserts! (is-eq tx-sender (var-get artist)) ERR_UNAUTHORIZED)
    (asserts! (is-none (get shipped-block order)) ERR_ALREADY_SHIPPED)
    (asserts! (< delivery-days u24) ERR_SHIPPING_TOO_SLOW)
    (asserts! (< burn-block-height (+ (var-get block-completion) DEADLINE)) ERR_DEADLINE)
    (asserts! (not (get claimed order)) ERR_ALREADY_CLAIMED)

    (map-set orders buyer (merge order { 
      shipped-block: (some burn-block-height),
      delivery-days: (some delivery-days)
    }))
    (ok true)
  )
)

(define-public (buyer-rates-delivery (rating uint))
  (let ((order (unwrap! (map-get? orders tx-sender) ERR_NO_ORDER)))
    (asserts! (is-some (get shipped-block order)) ERR_NOT_SHIPPED)
    (asserts! (is-none (get rating order)) ERR_ALREADY_RATED)
    (asserts! (or (is-eq rating u0) (is-eq rating u50) (is-eq rating u100)) ERR_INVALID_RATING)
    (asserts! (not (get claimed order)) ERR_ALREADY_CLAIMED)

    (map-set orders tx-sender (merge order { rating: (some rating), rated-block: (some burn-block-height) }))
    
    (if (is-eq rating u100)
      (execute-rating tx-sender)
      (ok true)
    )
  )
)

(define-public (artist-respond (buyer principal) (agrees bool))
  (let ((order (unwrap! (map-get? orders buyer) ERR_NO_ORDER)))
    (asserts! (is-eq tx-sender (var-get artist)) ERR_UNAUTHORIZED)
    (asserts! (is-some (get rating order)) ERR_NOT_RATED)
    (asserts! (not (get claimed order)) ERR_ALREADY_CLAIMED)

    (map-set orders buyer (merge order { 
      artist-response: (some agrees)
    }))
    
    (if agrees
      (execute-rating buyer)
      (ok true)
    )
  )
)

(define-public (oracle-decide (buyer principal) (final-rating uint))
  (let ((order (unwrap! (map-get? orders buyer) ERR_NO_ORDER))
        (rated-block (unwrap! (get rated-block order) ERR_NOT_SHIPPED))
        (delivery-days (unwrap! (get delivery-days order) ERR_NOT_SHIPPED))
        (artist-response-deadline (+ rated-block (* delivery-days u72)))
        (artist-resp (get artist-response order)))
    
    (asserts! (not (get claimed order)) ERR_ALREADY_CLAIMED)
    (asserts! (is-eq tx-sender ORACLE) ERR_UNAUTHORIZED)
    (asserts! (<= final-rating u100) ERR_INVALID_RATING) 
    
    (if (is-none artist-resp) 
    (asserts! (> burn-block-height artist-response-deadline) ERR_DEADLINE) 
    true)
        
    ;; Update rating and execute    
    (map-set orders buyer (merge order { rating: (some final-rating) }))
    (execute-rating buyer)
  )
)

(define-public (claim-never-rated (buyer principal))
  (let ((order (unwrap! (map-get? orders buyer) ERR_NO_ORDER)))
    (asserts! (is-eq tx-sender (var-get artist)) ERR_UNAUTHORIZED)
    (asserts! (is-some (get shipped-block order)) ERR_NOT_SHIPPED)
    (asserts! (is-none (get rating order)) ERR_NOT_RATED)
    (asserts! (not (get claimed order)) ERR_ALREADY_CLAIMED)

    ;; Check if 2x delivery time has passed
    (let ((shipped-block (unwrap! (get shipped-block order) ERR_NOT_SHIPPED))
          (delivery-days (unwrap! (get delivery-days order) ERR_NOT_SHIPPED))
          (deadline (+ shipped-block (* delivery-days u288)))) 
      (asserts! (> burn-block-height deadline) ERR_DEADLINE)
      
      ;; Mark as 100% and pay artist
      (map-set orders buyer (merge order { rating: (some u100) }))
      (execute-rating buyer)
    )
  )
)

(define-public (claim-never-shipped (buyer principal))
  (let ((order (unwrap! (map-get? orders buyer) ERR_NO_ORDER)))
    (asserts! (is-eq tx-sender buyer) ERR_UNAUTHORIZED)
    (asserts! (is-none (get shipped-block order)) ERR_ALREADY_SHIPPED)
    (asserts! (is-none (get rating order)) ERR_ALREADY_RATED)
    (asserts! (>= burn-block-height (+ (var-get block-completion) DEADLINE)) ERR_DEADLINE)
    (asserts! (not (get claimed order)) ERR_ALREADY_CLAIMED)

    (map-set orders buyer (merge order { rating: (some u0) }))
    (execute-rating buyer)
  )
)

(define-private (execute-rating (buyer principal))
  (let ((order (unwrap! (map-get? orders buyer) ERR_NO_ORDER))
        (rating (unwrap! (get rating order) ERR_NOT_RATED))
        (artista (var-get artist)))
    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer FEES tx-sender ORACLE none)))
    (map-set orders buyer (merge order { claimed: true}))
    (if (is-eq rating u100)
      (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer (- PRICE FEES) tx-sender artista none))
      (if (is-eq rating u50)
        (begin
          (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer (/ (- PRICE FEES) u2) tx-sender artista none)))
          (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer (- (- PRICE FEES) (/ (- PRICE FEES) u2)) tx-sender buyer none))
        )
        (if (is-eq rating u0)
          (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer (- PRICE FEES) tx-sender buyer none))
          (let ((artist-money (/ (* (- PRICE FEES) rating) u100)))
          (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer artist-money tx-sender artista none)))
          (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer (- (- PRICE FEES) artist-money) tx-sender buyer none))
          )
        )
      )
    )
  )
)

;; Admin functions
(define-public (set-artist (new-artist principal))
  (begin
    (asserts! (is-eq tx-sender ORACLE) ERR_UNAUTHORIZED)
    (var-set artist new-artist)
    (ok true)
  )
)

(define-public (oracle-refund-incomplete-campaign)
  (begin
    (asserts! (> burn-block-height (+ CAMPAIGN_START CAMPAIGN_DEADLINE)) ERR_CAMPAIGN_ONGOING)
    
    (asserts! (is-eq (var-get block-completion) u0) ERR_CAMPAIGN_FULL)
    (asserts! (< (var-get total-orders) TARGET_ORDERS) ERR_CAMPAIGN_FULL)

    (asserts! (is-eq tx-sender ORACLE) ERR_UNAUTHORIZED)
    (var-set campaign-status u0)
    (fold refund-buyer (var-get buyer-list) (ok true))
  )
)

(define-private (refund-buyer (buyer principal) (previous-result (response bool uint)))
  (begin
    (try! previous-result) 
    (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer PRICE tx-sender buyer none))
  )
)