(define-constant ERR_NO_AUTHORITY 20001)
(define-constant ERR_TRANSFER_STX 20002)
(define-constant ERR_INVALID_FEE 20003)

(define-data-var m_owner principal tx-sender)
(define-data-var m_total_shares uint u0)
(define-data-var m_total_withdrawn_fee uint u0)

(define-map map_shares
  principal
  uint
)

(define-map map_withdrawn_fee
  principal
  uint
)

(define-public (withdraw_fee (fee uint))
  (let
    (
      (caller contract-caller)
      (available_fee (get_available_fee caller))
    )
    (asserts! (and (> fee u0) (<= fee available_fee)) (err ERR_INVALID_FEE))
    (map-set map_withdrawn_fee caller (+ (default-to u0 (map-get? map_withdrawn_fee caller)) fee))
    (var-set m_total_withdrawn_fee (+ (var-get m_total_withdrawn_fee) fee))
    (unwrap! (as-contract (stx-transfer? fee tx-sender caller)) (err ERR_TRANSFER_STX))
    (ok (print { user: caller, fee: fee }))
  )
)

(define-public (set_shares (user principal) (amount uint))
  (begin
    (asserts! (is-eq contract-caller (var-get m_owner)) (err ERR_NO_AUTHORITY))
    (map-set map_shares user amount)
    (var-set m_total_shares (+ (var-get m_total_shares) amount))
    (ok true)
  )
)

(define-public (change_owner (new_owner principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get m_owner)) (is-eq contract-caller (var-get m_owner))) (err ERR_NO_AUTHORITY))
    (var-set m_owner new_owner)
    (ok true)
  )
)

(define-read-only (get_info (user (optional principal)))
  {
    owner: (var-get m_owner),
    total_shares: (var-get m_total_shares),
    total_withdrawn_fee: (var-get m_total_withdrawn_fee),
    total_fee: (get_total_fee),
    shares: (if (is-some user) (get_shares (unwrap-panic user)) u0),
    withdrawn_fee: (if (is-some user) (get_withdrawn_fee (unwrap-panic user)) u0),
    get_available_fee: (if (is-some user) (get_available_fee (unwrap-panic user)) u0),
  }
)

(define-read-only (get_shares (user principal))
  (default-to u0 (map-get? map_shares user))
)

(define-read-only (get_withdrawn_fee (user principal))
  (default-to u0 (map-get? map_withdrawn_fee user))
)

(define-read-only (get_available_fee (user principal))
  (- (/ (* (get_shares user) (get_total_fee)) (var-get m_total_shares)) (get_withdrawn_fee user))
)

(define-read-only (get_total_fee)
  (+ (var-get m_total_withdrawn_fee) (stx-get-balance (as-contract tx-sender)))
)

(define-read-only (get_total_shares)
  (var-get m_total_shares)
)
