(define-private (trans (address principal) (amount uint))
    (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer amount tx-sender address none)
)

(trans 'SP1EMXT9RET8W5TXQ325BG3TJ6X15NXV5GKEGVQE6 u1000000)
