;; fund setdev test vault
(define-public (fund (amount uint))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt transfer amount tx-sender 'SP16ZJF9P5BZHSWQT00F3XE2E54T372Z5W6S8NRBA.cf-vault-setdevv0-v0 none)
)