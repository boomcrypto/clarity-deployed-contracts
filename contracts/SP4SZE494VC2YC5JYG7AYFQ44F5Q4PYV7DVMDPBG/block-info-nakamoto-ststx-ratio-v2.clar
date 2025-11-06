;; @contract Block Info Nakamoto stSTX ratio
;; @version 2

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_BLOCK_INFO u42001)
(define-constant DENOMINATOR_6 u1000000)

;;-------------------------------------
;; stSTX info
;;-------------------------------------

(define-read-only (get-ststx-ratio)
  (let (
    (total-stx-amount (unwrap! (contract-call? .reserve-v1 get-total-stx) (err ERR_BLOCK_INFO)))
    (ststx-supply (unwrap-panic (contract-call? .ststx-token get-total-supply)))
  )
    (ok
      (if (is-eq ststx-supply u0)
        DENOMINATOR_6
        (/ (* total-stx-amount DENOMINATOR_6) ststx-supply)
      )
    )
  )
)

(define-read-only (get-ststx-ratio-v2)
  (let (
    (total-stx-amount (unwrap! (contract-call? .reserve-v1 get-total-stx) (err ERR_BLOCK_INFO)))
    (ststxbtc-supply (unwrap-panic (contract-call? .ststxbtc-token get-total-supply)))
    (stx-for-ststx (- total-stx-amount ststxbtc-supply))
    (ststx-supply (unwrap-panic (contract-call? .ststx-token get-total-supply)))
  )
    (ok
      (if (is-eq ststx-supply u0)
        DENOMINATOR_6
        (/ (* stx-for-ststx DENOMINATOR_6) ststx-supply)
      )
    )
  )
)

(define-read-only (get-ststx-ratio-v3)
  (let (
    (total-stx-amount (unwrap! (contract-call? .reserve-v1 get-total-stx) (err ERR_BLOCK_INFO)))
    (ststxbtc-supply (unwrap-panic (contract-call? .ststxbtc-token-v2 get-total-supply)))
    (stx-for-ststx (- total-stx-amount ststxbtc-supply))
    (ststx-supply (unwrap-panic (contract-call? .ststx-token get-total-supply)))
  )
    (ok
      (if (is-eq ststx-supply u0)
        DENOMINATOR_6
        (/ (* stx-for-ststx DENOMINATOR_6) ststx-supply)
      )
    )
  )
)

(define-read-only (get-ststx-ratio-at-block (block uint))
  (let (
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))
  )
    (if (> block u489238) ;; stSTXbtc release
      (begin
        (if (> block u2023831)
          (at-block block-hash (get-ststx-ratio-v3))
          (at-block block-hash (get-ststx-ratio-v2))
        )
      )
      (at-block block-hash (get-ststx-ratio))
    )
  )
)
