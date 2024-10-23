(define-private (transfer-tokens (amount uint) (recipient principal))
  (contract-call? 'SP27NSH3M94XD65CZ81BPFR64CQZBMGE9WNAAK7ZG.nashville transfer amount tx-sender recipient none))

(transfer-tokens u1000000000 'SP251V0S6MECW6FN422YP19H74Y2YP5JZ4GBVNNJH)