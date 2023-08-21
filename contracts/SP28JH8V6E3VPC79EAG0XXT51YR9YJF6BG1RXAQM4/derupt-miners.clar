;; .derupt-miners Contract
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))

;; Get Derupt core contract
(define-read-only (get-derupt-core-contract)
  (contract-call? .derupt-feed get-derupt-core-contract)
)

;; Log Mine
(define-public (log-mine (miner principal) (cityName (string-ascii 10)) (mine-amount uint))
  (let 
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))) 
    (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
    (print { event: "mine", miner: miner, cityName: cityName, mine-total: mine-amount })
    (ok true)
  )
)

;; Log Mining Reward Claim
(define-public (log-mining-reward-claim (cityName (string-ascii 10)) (claimHeight uint))
  (let 
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))) 
    (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
    (print { event: "mining-reward-claim", cityName: cityName, claimHeight: claimHeight })
    (ok true)
  )
)