;; .derupt-miners Contract
(define-constant unauthorized-user (err 100))
(define-constant notfound (err 101))

;; Get Derupt core contract
(define-read-only (get-derupt-core-contract)
  (contract-call? .derupt-feed get-derupt-core-contract)
)

;; Log Mine
(define-public (log-mine (miner principal) (cityName (string-ascii 10)) (mine-amount uint))
  (let 
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) notfound))) 
    (asserts! (is-eq contract-caller derupt-core-contract) unauthorized-user)
    (print { event: "mine", miner: miner, cityName: cityName, mine-amount: mine-amount })
    (ok true)
  )
)

;; Log Mining Reward Claim
(define-public (log-mining-reward-claim (cityName (string-ascii 10)) (claimHeight uint))
  (let 
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) notfound))) 
    (asserts! (is-eq contract-caller derupt-core-contract) unauthorized-user)
    (print { event: "mining-reward-claim", cityName: cityName, claimHeight: claimHeight })
    (ok true)
  )
)