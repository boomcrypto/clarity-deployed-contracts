---
title: "Trait emergency-recover-v1"
draft: true
---
```
;; @contract Emergency recover
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
    (balance (unwrap-panic (contract-call? .usdh-token-v1 get-balance address)))
  )
    (try! (contract-call? .hq-v1 check-is-enabled))
    (try! (contract-call? .hq-v1 check-is-protocol tx-sender))

    (try! (contract-call? .usdh-token-v1 burn-for-protocol balance address))
    (ok (try! (contract-call? .usdh-token-v1 mint-for-protocol balance recipient)))
  )
)

(define-public (recover-susdh (address principal) (recipient principal))
  (let (
    (balance (unwrap-panic (contract-call? .susdh-token-v1 get-balance address)))
  )
    (try! (contract-call? .hq-v1 check-is-enabled))
    (try! (contract-call? .hq-v1 check-is-protocol tx-sender))

    (if (contract-call? .susdh-token-v1 get-blacklist-enabled)
      (begin 
        (try! (contract-call? .blacklist-susdh-v1 check-is-not-full-blacklist recipient))
        (asserts! (contract-call? .blacklist-susdh-v1 get-full-blacklist address) ERR_NOT_BLACKLISTED)
      )
      true
    )

    (try! (contract-call? .susdh-token-v1 burn-for-protocol balance address))
    (ok (try! (contract-call? .susdh-token-v1 mint-for-protocol balance recipient)))
  )
)
```
