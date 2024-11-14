(define-private (transfer-tokens (amount uint) (recipient principal))
  (contract-call? 'SP13XTE1X5CBEDB8N3YNZBPZP59TGA8W6F36WQ1T8.foundry-o7LoOBie transfer amount tx-sender recipient none))

(transfer-tokens u1 'SP27NSH3M94XD65CZ81BPFR64CQZBMGE9WNAAK7ZG)
(transfer-tokens u1 'SP3Q0YT5Z9J3KEYJ48MC3T0TDSQEQE27CRSQRNCW2)