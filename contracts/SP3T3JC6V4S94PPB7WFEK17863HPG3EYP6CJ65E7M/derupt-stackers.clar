;; .derupt-stackers Contract
(define-constant unauthorized-user (err 100))
(define-constant notfound (err 101))

;; Get Derupt core contract
(define-read-only (get-derupt-core-contract)
  (contract-call? .derupt-feed get-derupt-core-contract)
)

;; Log Stack
(define-public (log-stack (cityName (string-ascii 10)) (dislike-amount uint) (lockPeriod uint))
  (let
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) notfound))) 
    (asserts! (is-eq contract-caller derupt-core-contract) unauthorized-user)
    (print { event: "stack", cityName: cityName, dislike-amount: dislike-amount })
    (ok true)
  )
)

;; Log Stacking Reward Claim
(define-public (log-stacking-reward-claim (cityName (string-ascii 10)) (cycleId uint))
  (let 
      ((derupt-core-contract (unwrap! (get-derupt-core-contract) notfound))) 
      (asserts! (is-eq contract-caller derupt-core-contract) unauthorized-user)
      (print { event: "stacking-reward-claim", cityName: cityName, cycleId: cycleId })
      (ok true)
  )
)