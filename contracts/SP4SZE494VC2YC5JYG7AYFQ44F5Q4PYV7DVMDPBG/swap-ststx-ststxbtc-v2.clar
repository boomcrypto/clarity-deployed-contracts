;; @contract Swap stSTX / stSTXbtc
;; @version 2
;;
;; User can swap stSTX for stSTXbtc and vice versa.
;; Original tokens are burned and new tokens are minted.
;; Underlying STX remains the same.

(use-trait reserve-trait .reserve-trait-v1.reserve-trait)

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_LOW_SUPPLY u903001)

(define-constant DENOMINATOR_6 u1000000)

;;-------------------------------------
;; Swaps 
;;-------------------------------------

(define-public (swap-ststx-for-ststxbtc (ststx-amount uint) (reserve <reserve-trait>) )
  (let (
    (stx-ststx (try! (contract-call? .data-core-v3 get-stx-per-ststx reserve)))
    (stx-amount (/ (* ststx-amount stx-ststx) DENOMINATOR_6))
  )
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))

    (try! (contract-call? .ststxbtc-token-v2 mint-for-protocol stx-amount tx-sender))
    (try! (contract-call? .ststx-token burn-for-protocol ststx-amount tx-sender))

    (asserts! (>= (unwrap-panic (contract-call? .ststx-token get-total-supply)) u1000000) (err ERR_LOW_SUPPLY))
    (asserts! (>= (unwrap-panic (contract-call? .ststxbtc-token-v2 get-total-supply)) u1000000) (err ERR_LOW_SUPPLY))

    (ok stx-amount)
  )
)

(define-public (swap-ststxbtc-for-ststx (ststxbtc-amount uint) (reserve <reserve-trait>) )
  (let (
    (stx-ststx (try! (contract-call? .data-core-v3 get-stx-per-ststx reserve)))
    (ststx-amount (/ (* ststxbtc-amount DENOMINATOR_6) stx-ststx))
  )
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))

    (try! (contract-call? .ststx-token mint-for-protocol ststx-amount tx-sender))
    (try! (contract-call? .ststxbtc-token-v2 burn-for-protocol ststxbtc-amount tx-sender))

    (asserts! (>= (unwrap-panic (contract-call? .ststx-token get-total-supply)) u1000000) (err ERR_LOW_SUPPLY))
    (asserts! (>= (unwrap-panic (contract-call? .ststxbtc-token-v2 get-total-supply)) u1000000) (err ERR_LOW_SUPPLY))

    (ok ststx-amount)
  )
)
