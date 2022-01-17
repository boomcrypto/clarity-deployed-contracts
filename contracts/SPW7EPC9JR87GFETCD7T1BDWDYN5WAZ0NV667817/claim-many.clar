(define-public (claim-many (blocks (list 50 uint)))
  (let
    (
      (resp (fold claim-block-fold blocks (ok true)))
    )
    resp
  )
)

(define-private (claim-block-fold (height uint) (count (response bool uint)))
  (let
    (
      (h (try! count))
      (resp (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-core-v1 claim-mining-reward height))
    )
    resp
  )
)