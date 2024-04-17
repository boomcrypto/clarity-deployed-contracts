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

(define-public (bulk_cancel (items (list 100 { order_id: uint, token: <Wstx10-trait> })))
  (ok (map bc items))
)

(define-public (bulk_set_valid_tokens (items (list 100 principal)))
  (ok (map bsvt items))
)

(define-public (bulk_load_balance (tokens (list 30 <sip-010-trait>)))
  (ok (map blb tokens))
)

(define-private (bc (item { order_id: uint, token: <Wstx10-trait> }))
  (match (contract-call? .stx10-marketplace get_order (get order_id item)) order_info
    (is-ok (contract-call? .stx10-marketplace cancel_list (get order_id item) (get token item) (get amount order_info) (get price order_info)))
    false
  )
)

(define-private (blb (token <sip-010-trait>))
  (unwrap-panic (contract-call? token get-balance tx-sender))
)

(define-private (bsvt (token principal))
  (is-ok (contract-call? .stx10-market set_valid_token token true))
)
