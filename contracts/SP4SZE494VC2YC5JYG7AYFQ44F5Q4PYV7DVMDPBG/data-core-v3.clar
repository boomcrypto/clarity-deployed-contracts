;; @contract Data Core
;; @version 2
;;
;; Helper methods to get STX per stSTX.
;; Storing stSTXbtc withdrawal NFT info.

(use-trait reserve-trait .reserve-trait-v1.reserve-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant DENOMINATOR_6 u1000000)

;;-------------------------------------
;; STX per stSTX  
;;-------------------------------------

(define-public (get-stx-per-ststx (reserve-contract <reserve-trait>))
  (let (
    (total-stx-amount (try! (contract-call? reserve-contract get-total-stx)))
    (ststxbtc-supply (unwrap-panic (contract-call? .ststxbtc-token get-total-supply)))
    (ststxbtc-supply-v2 (unwrap-panic (contract-call? .ststxbtc-token-v2 get-total-supply)))
    (stx-for-ststx (- total-stx-amount ststxbtc-supply ststxbtc-supply-v2))
  )
    (try! (contract-call? .dao check-is-protocol (contract-of reserve-contract)))
    (ok (get-stx-per-ststx-helper stx-for-ststx))
  )
)

(define-read-only (get-stx-per-ststx-helper (stx-amount uint))
  (let (
    (ststx-supply (unwrap-panic (contract-call? .ststx-token get-total-supply)))
  )
    (if (is-eq ststx-supply u0)
      DENOMINATOR_6
      (/ (* stx-amount DENOMINATOR_6) ststx-supply)
    )
  )
)
