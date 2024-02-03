;; stx10 marketplace
;; https://stacksinscription.com/#/stx10

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

(define-constant ERR_NO_AUTHORITY u3001)
(define-constant ERR_INVALID_PRICE u3002)
(define-constant ERR_INVALID_STATE u3003)
(define-constant ERR_INVALID_TOKEN u3004)
(define-constant ERR_INVALID_BUYER u3005)
(define-constant ERR_INVALID_AMOUNT u3006)
(define-constant ERR_ORDER_NOT_EXIST u3007)
(define-constant ERR_BALANCE_UNENOUGH u3008)
(define-constant ERR_ORDER_INCONSISTENT u3009)

(define-constant MAX_AMOUNT u1000000000000000)
(define-constant MIN_PRICE u1000000)
(define-constant MAX_PRICE u1000000000000)
(define-constant MAX_PRICE_PER_TOKEN u1000000000)

(define-data-var m_admin principal tx-sender)
(define-data-var m_fee_collector principal tx-sender)
(define-data-var m_fee uint u15) ;; 1.5%
(define-data-var m_last_wrapper_id uint u0)
(define-data-var m_last_order_id uint u0)

(define-map map_index2wrapper
  uint
  principal ;; wrapper contract
)

(define-map map_wrapper2tick
  principal         ;; wrapper contract
  (string-ascii 16) ;; tick
)

(define-map map_tick2wrapper
  (string-ascii 16) ;; tick
  principal         ;; wrapper contract
)

(define-map map_orders
  uint                  ;; order_id
  {
    state: uint,        ;; 1 valid, 2 cancelled, 3 successful
    block: uint,        ;; block-height when the order is updated
    wrapper: principal,
    seller: principal,
    amount: uint,
    price: uint,
    buyer: (optional principal),
  }
)

(define-map map_user_order_count
  principal
  uint
)

(define-map map_user_order
  { user: principal, index: uint }
  uint  ;; order_id
)

(define-public (list_token (token <Wstx10-trait>) (amount uint) (price uint))
  (let
    (
      (sender tx-sender)
      (wrapper (contract-of token))
      (order_id (+ (var-get m_last_order_id) u1))
      (decimal (unwrap-panic (contract-call? token get-decimals)))
      (balance (unwrap-panic (contract-call? token get-balance sender)))
      (real_amount (* amount (pow u10 decimal)))
      (user_order_index (+ (default-to u0 (map-get? map_user_order_count sender)) u1))
    )
    (asserts! (is-some (map-get? map_wrapper2tick wrapper)) (err ERR_INVALID_TOKEN))
    (asserts! (and (> amount u0) (<= amount MAX_AMOUNT) (>= balance real_amount)) (err ERR_INVALID_AMOUNT))
    (asserts! (and (>= price MIN_PRICE) (<= price MAX_PRICE) (<= (/ price amount) MAX_PRICE_PER_TOKEN)) (err ERR_INVALID_PRICE))
    (try! (contract-call? token transfer real_amount sender (as-contract tx-sender) none))
    (map-set map_orders order_id {
      state: u1,
      block: block-height,
      wrapper: wrapper,
      seller: sender,
      amount: amount,
      price: price,
      buyer: none,
    })
    (var-set m_last_order_id order_id)
    (map-set map_user_order_count sender user_order_index)
    (map-set map_user_order { user: sender, index: user_order_index } order_id)
    (print {
      type: "list_token",
      order_id: order_id,
      wrapper: wrapper,
      amount: amount,
      price: price,
    })
    (ok true)
  )
)

(define-public (wrap_and_list_token (token <Wstx10-trait>) (amount uint) (price uint))
  (begin
    (try! (contract-call? token wrap amount))
    (list_token token amount price)
  )
)

(define-public (change_price (order_id uint) (token <Wstx10-trait>) (amount uint) (new_price uint))
  (let
    (
      (sender tx-sender)
      (order_info (unwrap! (map-get? map_orders order_id) (err ERR_ORDER_NOT_EXIST)))
    )
    (asserts! (is-eq (get state order_info) u1) (err ERR_INVALID_STATE))
    (asserts! (is-eq (contract-of token) (get wrapper order_info)) (err ERR_ORDER_INCONSISTENT))
    (asserts! (is-eq sender (get seller order_info)) (err ERR_ORDER_INCONSISTENT))
    (asserts! (is-eq amount (get amount order_info)) (err ERR_ORDER_INCONSISTENT))
    (asserts! (and (>= new_price MIN_PRICE) (<= new_price MAX_PRICE) (<= (/ new_price amount) MAX_PRICE_PER_TOKEN)) (err ERR_INVALID_PRICE))
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

(define-public (cancel_list (order_id uint) (token <Wstx10-trait>) (amount uint) (price uint))
  (let
    (
      (sender tx-sender)
      (order_info (unwrap! (map-get? map_orders order_id) (err ERR_ORDER_NOT_EXIST)))
      (decimal (unwrap-panic (contract-call? token get-decimals)))
      (real_amount (* amount (pow u10 decimal)))
    )
    (asserts! (is-eq (get state order_info) u1) (err ERR_INVALID_STATE))
    (asserts! (is-eq (contract-of token) (get wrapper order_info)) (err ERR_ORDER_INCONSISTENT))
    (asserts! (or (is-eq (get seller order_info) sender) (is-eq sender (var-get m_admin))) (err ERR_NO_AUTHORITY))
    (asserts! (is-eq amount (get amount order_info)) (err ERR_ORDER_INCONSISTENT))
    (asserts! (is-eq price (get price order_info)) (err ERR_ORDER_INCONSISTENT))    
    (map-set map_orders order_id (merge order_info {
      state: u2,
      block: block-height,
    }))
    (try! (as-contract (contract-call? token transfer real_amount tx-sender (get seller order_info) none)))
    (print {
      type: "cancel_list",
      id: order_id,
    })
    (ok true)
  )
)

(define-public (buy (order_id uint) (token <Wstx10-trait>) (amount uint) (price uint))
  (let
    (
      (sender tx-sender)
      (order_info (unwrap! (map-get? map_orders order_id) (err ERR_ORDER_NOT_EXIST)))
      (fee (/ (* (var-get m_fee) price) u1000))
      (remain_price (- price fee))
      (decimal (unwrap-panic (contract-call? token get-decimals)))
      (real_amount (* amount (pow u10 decimal)))
    )
    (asserts! (is-eq (get state order_info) u1) (err ERR_INVALID_STATE))
    (asserts! (is-eq (contract-of token) (get wrapper order_info)) (err ERR_ORDER_INCONSISTENT))
    (asserts! (is-eq amount (get amount order_info)) (err ERR_ORDER_INCONSISTENT))
    (asserts! (is-eq price (get price order_info)) (err ERR_ORDER_INCONSISTENT))
    (asserts! (not (is-eq sender (get seller order_info))) (err ERR_INVALID_BUYER))
    (map-set map_orders order_id (merge order_info {
      state: u3,
      block: block-height,
      buyer: (some sender),
    }))
    (try! (stx-transfer? price sender (as-contract tx-sender)))
    (try! (as-contract (stx-transfer? remain_price tx-sender (get seller order_info))))
    (try! (as-contract (stx-transfer? fee tx-sender (var-get m_fee_collector))))
    (try! (as-contract (contract-call? token transfer real_amount tx-sender sender none)))
    (print {
      type: "buy",
      id: order_id,
      buyer: sender,
    })
    (ok true)
  )
)

(define-public (add_tick_wrapper_pair (tick (string-ascii 16)) (wrapper principal))
  (ok (and
    (is-eq tx-sender (var-get m_admin))
    (map-set map_tick2wrapper tick wrapper)
    (map-set map_wrapper2tick wrapper tick)
    (var-set m_last_wrapper_id (+ (var-get m_last_wrapper_id) u1))
    (map-set map_index2wrapper (var-get m_last_wrapper_id) wrapper)
  ))
)

(define-public (set_admin (admin principal))
  (ok (and
    (is-eq tx-sender (var-get m_admin))
    (var-set m_admin admin))
  )
)

(define-public (set_fee_collector (fee_collector principal))
  (ok (and
    (is-eq tx-sender (var-get m_fee_collector))
    (var-set m_fee_collector fee_collector))
  )
)

(define-public (set_fee (fee uint))
  (ok (and 
    (is-eq tx-sender (var-get m_admin))
    (>= fee u1)
    (<= fee u25)
    (var-set m_fee fee)
  ))
)

(define-read-only (get_summary)
  {
    height: block-height,
    admin: (var-get m_admin),
    fee: (var-get m_fee),
    order_id: (var-get m_last_order_id),
    wrapper_id: (var-get m_last_wrapper_id),
    fee_collector: (var-get m_fee_collector),
  }
)

(define-read-only (get_order (order_id uint))
  (map-get? map_orders order_id)
)

(define-read-only (get_orders (order_ids (list 25 uint)))
  (map get_order order_ids)
)

(define-read-only (get_user_order_count (user principal))
  (default-to u0 (map-get? map_user_order_count user))
)

(define-read-only (get_user_order_id (item { user: principal, index: uint }))
  (map-get? map_user_order item)
)

(define-read-only (get_user_order_ids (items (list 25 { user: principal, index: uint })))
  (map get_user_order_id items)
)

(define-read-only (get_tick_by_wrapper (token <Wstx10-trait>))
  (map-get? map_wrapper2tick (contract-of token))
)

(define-read-only (get_wrapper_by_tick (tick (string-ascii 16)))
  (map-get? map_tick2wrapper tick)
)

(define-read-only (get_wrapper_by_index (index uint))
  (map-get? map_index2wrapper index)
)

(define-read-only (get_wrapper_by_indexes (indexes (list 25 uint)))
  (map get_wrapper_by_index indexes)
)
