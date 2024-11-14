(define-private (transfer-tokens (amount uint) (recipient principal))
  (contract-call? 'SP295MNE41DC74QYCPRS8N37YYMC06N6Q3T5P1YC2.foundry-6s-FSwIm transfer amount tx-sender recipient none))

(transfer-tokens u10317300000000 'SP1NSCD02EE377W77JA5RHXF9S6RT6A6CA7K039DH)