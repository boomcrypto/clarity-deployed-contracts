(define-public (bulk-transfer (ids (list 1000 uint)) (receivers (list 1000 principal))) (begin (print (map transfer ids receivers)) (ok true)))
(define-private (transfer (id uint) (receiver principal)) (contract-call? 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA.stacks-mfers transfer id tx-sender receiver))
