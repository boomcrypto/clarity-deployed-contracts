(define-private (transfer-tokens (amount uint) (recipient principal))
  (contract-call? 'SP295MNE41DC74QYCPRS8N37YYMC06N6Q3T5P1YC2.foundry-Of-bGqnY transfer amount tx-sender recipient none))

(transfer-tokens u1000000000000 'SP1XQCE0W6RTHS06JQHZXQ4ZBTJ8V8TXGD0J7T03J)