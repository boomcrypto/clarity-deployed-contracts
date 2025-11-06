;; fund setdev test vault
(define-public (fund-susdt (amount uint))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt transfer amount tx-sender 'SP16ZJF9P5BZHSWQT00F3XE2E54T372Z5W6S8NRBA.cf-vault-setdevv0-v0 none)
)
(define-public (fund-wstx (amount uint))
  (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.wstx transfer amount tx-sender 'SP16ZJF9P5BZHSWQT00F3XE2E54T372Z5W6S8NRBA.cf-vault-setdevv0-v0 none)
)