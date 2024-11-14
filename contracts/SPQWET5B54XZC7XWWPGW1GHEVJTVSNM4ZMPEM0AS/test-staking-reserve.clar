;; @contract Staking Reserve
;; @version 1

;;-------------------------------------
;; Protocol
;;-------------------------------------

(define-public (transfer (amount uint))
  (begin 
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (ok (try! (as-contract (contract-call? .test-usdh-token transfer amount tx-sender .test-staking-silo none))))
  )
)