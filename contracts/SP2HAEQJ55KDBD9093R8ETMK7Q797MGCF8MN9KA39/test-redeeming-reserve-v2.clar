;; @contract Redeeming Reserve
;; @version 1

(use-trait sip-010-trait .sip-010-trait.sip-010-trait)

;;-------------------------------------
;; Get USDh
;;-------------------------------------

(define-public (transfer (amount uint) (recipient principal) (redeeming-asset <sip-010-trait>) (memo (optional (buff 34))))
  (begin 
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (ok (try! (as-contract (contract-call? redeeming-asset transfer amount tx-sender recipient memo))))
  )
)