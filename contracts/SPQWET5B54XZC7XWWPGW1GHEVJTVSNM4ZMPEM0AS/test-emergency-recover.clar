;; @contract Recover
;; @version 1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_BLACKLISTED (err u7001))

;;-------------------------------------
;; Recover
;;-------------------------------------

(define-public (recover-usdh (address principal) (recipient principal))
  (let (
    (balance (unwrap-panic (contract-call? .test-usdh-token get-balance address)))
  )
    (try! (contract-call? .test-hq check-is-enabled))
    (try! (contract-call? .test-hq check-is-protocol tx-sender))

    (try! (as-contract (contract-call? .test-usdh-token burn-for-protocol balance address)))
    (ok (try! (as-contract (contract-call? .test-usdh-token mint-for-protocol balance recipient))))
  )
)

(define-public (recover-susdh (address principal) (recipient principal))
  (let (
    (balance (unwrap-panic (contract-call? .test-susdh-token get-balance address)))
  )
    (try! (contract-call? .test-hq check-is-enabled))
    (try! (contract-call? .test-hq check-is-protocol tx-sender))

    (if (contract-call? .test-susdh-token get-blacklist-enabled)
      (begin 
        (try! (contract-call? .test-blacklist-susdh check-is-not-full-blacklist recipient))
        (asserts! (contract-call? .test-blacklist-susdh get-full-blacklist address) ERR_NOT_BLACKLISTED)
      )
      true
    )

    (try! (as-contract (contract-call? .test-susdh-token burn-for-protocol balance address)))
    (ok (try! (as-contract (contract-call? .test-susdh-token mint-for-protocol balance recipient))))
  )
)