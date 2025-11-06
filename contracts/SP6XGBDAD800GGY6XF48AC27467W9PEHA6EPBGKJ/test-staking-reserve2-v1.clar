;; @contract Staking Reserve
;; @version 1

;;-------------------------------------
;; Transfer USDh
;;-------------------------------------

(define-public (transfer (amount uint) (recipient principal))
  (begin 
    (try! (contract-call? .test-hq-v1 check-is-minting-contract contract-caller))
    (try! (contract-call? .test-hq-v1 check-is-protocol recipient))
    (ok (try! (as-contract (contract-call? .test-usdh-token-v1 transfer amount tx-sender recipient none))))
  )
)