;; .derupt-stackers Contract
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))

;; Get Derupt core contract
(define-read-only (get-derupt-core-contract)
  (contract-call? .derupt-feed get-derupt-core-contract)
)

;; Log Stack
(define-public (log-stack (stacker principal) (cityName (string-ascii 10)) (dislike-ft-total uint) (lockPeriod uint))
  (let
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))) 
    (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
    (print { event: "stack", stacker: stacker, cityName: cityName, dislike-ft-total: dislike-ft-total, lockPeriod: lockPeriod })
    (ok true)
  )
)

;; Log Stacking Reward Claim
(define-public (log-stacking-reward-claim (cityName (string-ascii 10)) (cycleId uint))
  (let 
      ((derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))) 
      (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
      (print { event: "stacking-reward-claim", cityName: cityName, cycleId: cycleId })
      (ok true)
  )
)