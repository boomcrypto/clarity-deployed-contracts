;; stx10 marketplace https://stx10.com
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-trait Wstx10-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
    (wrap (uint) (response bool uint))
    (unwrap (uint) (response bool uint))
  )
)

(define-constant ERR_NO_AUTHORITY u1001)
(define-constant ERR_INVALID_PRICE u1002)
(define-constant ERR_INVALID_STATE u1003)
(define-constant ERR_INVALID_TOKEN u1004)
(define-constant ERR_INVALID_ORDER u1005)
(define-constant ERR_ORDER_MISMATCH u1006)

(define-constant MIN_PRICE u1000000)
(define-constant MAX_PRICE u1000000000000)
(define-constant MAX_PRICE_PER_TOKEN u1000000000)
(define-constant ORDER_MODE_WTS u1)
(define-constant ORDER_MODE_WTB u2)

(define-data-var m_admin principal tx-sender)
(define-data-var m_fee uint u15) ;; 1.5%
(define-data-var m_last_order_id uint u0)

(define-map map_valid_tokens principal bool)

(define-map map_orders
  uint                  ;; order_id
  {
    mode: uint,         ;; ORDER_MODE_[WTS|WTB]
    state: uint,        ;; 1 valid, 2 cancelled, 3 successful
    block: uint,        ;; update-block
    token: principal,
    offer: principal,
    amount: uint,
    price: uint,
    taker: (optional principal),
  }
)

(define-public (wrap_and_create_order (token <Wstx10-trait>) (amount uint) (price uint))
  (begin
    (try! (contract-call? token wrap amount))
    (create_order ORDER_MODE_WTS token amount price)
  )
)

(define-public (create_order (mode uint) (token <sip-010-trait>) (amount uint) (price uint))
  (let
    (
      (offer tx-sender)
      (order_id (+ (var-get m_last_order_id) u1))
    )
    (asserts! (and (>= mode ORDER_MODE_WTS) (<= mode ORDER_MODE_WTB)) (err ERR_INVALID_ORDER))
    (asserts! (default-to false (map-get? map_valid_tokens (contract-of token))) (err ERR_INVALID_TOKEN))
    (asserts! (and (>= price MIN_PRICE) (<= price MAX_PRICE) (<= (/ price amount) MAX_PRICE_PER_TOKEN)) (err ERR_INVALID_PRICE))
    (if (is-eq mode ORDER_MODE_WTS)
      (try! (contract-call? token transfer (get_real_amount token amount) offer (as-contract tx-sender) none))
      (try! (stx-transfer? price offer (as-contract tx-sender)))
    )
    (map-set map_orders order_id {
      mode: mode,
      state: u1,
      block: block-height,
      token: (contract-of token),
      offer: offer,
      amount: amount,
      price: price,
      taker: none,
    })
    (var-set m_last_order_id order_id)
    (print {
      type: "create_order",
      mode: mode,
      token: (contract-of token),
      amount: amount,
      price: price,
      order_id: order_id,
    })
    (ok true)
  )
)

(define-public (change_price (order_id uint) (token <sip-010-trait>) (amount uint) (new_price uint))
  (let
    (
      (order_info (unwrap! (map-get? map_orders order_id) (err ERR_INVALID_ORDER)))
      (price (get price order_info))
    )
    (try! (check_order order_id token amount none))
    (asserts! (is-eq tx-sender (get offer order_info)) (err ERR_ORDER_MISMATCH))
    (asserts! (and (>= new_price MIN_PRICE) (<= new_price MAX_PRICE) (<= (/ new_price amount) MAX_PRICE_PER_TOKEN)) (err ERR_INVALID_PRICE))
    (and
      (is-eq (get mode order_info) ORDER_MODE_WTB)
      (if (> new_price price)
        (try! (stx-transfer? (- new_price price) tx-sender (as-contract tx-sender)))
        (try! (as-contract (stx-transfer? (- price new_price) tx-sender (get offer order_info)))) ;; fail if equal
      )
    )
    (map-set map_orders order_id (merge order_info {
      block: block-height,
      price: new_price,
    }))
    (print {
      type: "change_price",
      id: order_id,
      new_price: new_price,
    })
    (ok true)
  )
)

(define-public (cancel (order_id uint) (token <sip-010-trait>) (amount uint) (price uint))
  (let
    (
      (order_info (unwrap! (map-get? map_orders order_id) (err ERR_INVALID_ORDER)))
      (offer (get offer order_info))
    )
    (try! (check_order order_id token amount (some price)))
    (asserts! (or (is-eq offer tx-sender) (is-eq tx-sender (var-get m_admin))) (err ERR_NO_AUTHORITY))
    (map-set map_orders order_id (merge order_info {
      state: u2,
      block: block-height,
    }))
    (if (is-eq (get mode order_info) ORDER_MODE_WTS)
      (try! (as-contract (contract-call? token transfer (get_real_amount token amount) tx-sender offer none)))
      (try! (as-contract (stx-transfer? (get price order_info) tx-sender offer)))
    )
    (print {
      type: "cancel",
      id: order_id,
    })
    (ok true)
  )
)

(define-public (bulk_cancel (orders (list 100 { order_id: uint, token: <sip-010-trait>, amount: uint, price: uint })))
  (ok (asserts! (is-eq (len (filter bc orders)) u0) (err ERR_INVALID_STATE)))
)

(define-public (take (order_id uint) (token <sip-010-trait>) (amount uint) (price uint))
  (let
    (
      (taker tx-sender)
      (order_info (unwrap! (map-get? map_orders order_id) (err ERR_INVALID_ORDER)))
      (fee (/ (* (var-get m_fee) price) u1000))
      (remain_stx (- price fee))
    )
    (try! (check_order order_id token amount (some price)))
    ;; (asserts! (not (is-eq taker (get offer order_info))) (err ERR_INVALID_SENDER))
    (asserts! (is-none (get name (unwrap-panic (principal-destruct? contract-caller)))) (err ERR_NO_AUTHORITY))
    (map-set map_orders order_id (merge order_info {
      state: u3,
      block: block-height,
      taker: (some taker),
    }))
    (if (is-eq (get mode order_info) ORDER_MODE_WTS)
      (begin
        (try! (stx-transfer? remain_stx taker (get offer order_info)))
        (try! (stx-transfer? fee taker .stx10-marketplace-fee-collector))
        (try! (as-contract (contract-call? token transfer (get_real_amount token amount) tx-sender taker none)))
      )
      (begin
        (try! (contract-call? token transfer (get_real_amount token amount) taker (get offer order_info) none))
        (try! (as-contract (stx-transfer? fee tx-sender .stx10-marketplace-fee-collector)))
        (try! (as-contract (stx-transfer? remain_stx tx-sender taker)))
      )
    )
    (print {
      type: "take",
      id: order_id,
      taker: taker,
    })
    (ok true)
  )
)

(define-public (bulk_take (orders (list 100 { order_id: uint, token: <sip-010-trait>, amount: uint, price: uint })))
  (ok (map bt orders))
)

(define-public (cancel_and_take (token <sip-010-trait>) (cancel_order_id uint) (cancel_amount uint) (cancel_price uint) (take_order_id uint) (take_amount uint) (take_price uint))
  (begin
    (try! (cancel cancel_order_id token cancel_amount cancel_price))
    (take take_order_id token take_amount take_price)
  )
)

(define-public (set_valid_token (token principal) (valid bool))
  (ok (and (is-eq tx-sender (var-get m_admin)) (map-set map_valid_tokens token valid)))
)

(define-public (set_config (admin principal) (fee uint))
  (ok (and (is-eq tx-sender (var-get m_admin)) (var-set m_admin admin) (var-set m_fee fee)))
)

(define-read-only (get_summary)
  {
    height: block-height,
    admin: (var-get m_admin),
    fee: (var-get m_fee),
    order_id: (var-get m_last_order_id),
  }
)

(define-read-only (is_token_valid (token principal))
  (default-to false (map-get? map_valid_tokens token))
)

(define-read-only (get_order (order_id uint))
  (map-get? map_orders order_id)
)

(define-read-only (get_orders (order_ids (list 25 uint)))
  (map get_order order_ids)
)

(define-private (bc (order { order_id: uint, token: <sip-010-trait>, amount: uint, price: uint }))
  (is-err (cancel (get order_id order) (get token order) (get amount order) (get price order)))
)

(define-private (bt (order { order_id: uint, token: <sip-010-trait>, amount: uint, price: uint }))
  (is-ok (take (get order_id order) (get token order) (get amount order) (get price order)))
)

(define-private (get_real_amount (token <sip-010-trait>) (amount uint))
  (* amount (pow u10 (unwrap-panic (contract-call? token get-decimals))))
)

(define-private (check_order (order_id uint) (token <sip-010-trait>) (amount uint) (price (optional uint)))
  (match (map-get? map_orders order_id) order_info
    (ok (begin
      (asserts! (is-eq (get state order_info) u1) (err ERR_INVALID_STATE))
      (asserts! (is-eq (contract-of token) (get token order_info)) (err ERR_ORDER_MISMATCH))
      (asserts! (is-eq amount (get amount order_info)) (err ERR_ORDER_MISMATCH))
      (asserts! (or (is-none price) (is-eq (unwrap-panic price) (get price order_info))) (err ERR_ORDER_MISMATCH))
    ))
    (err ERR_INVALID_ORDER)
  )
)
