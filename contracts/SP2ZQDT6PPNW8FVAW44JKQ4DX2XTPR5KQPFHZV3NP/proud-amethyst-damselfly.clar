;; fund setdev test vault
(define-public (fund-susdt (amount uint))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt transfer amount tx-sender 'SPM5G9CE1RAEEXPXQSB8QPQP6Y9F67MP61146FBA.cf-vault-setdev-v0 none)
)
(define-public (fund-wstx (amount uint))
  (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.wstx transfer amount tx-sender 'SPM5G9CE1RAEEXPXQSB8QPQP6Y9F67MP61146FBA.cf-vault-setdev-v0 none)
)