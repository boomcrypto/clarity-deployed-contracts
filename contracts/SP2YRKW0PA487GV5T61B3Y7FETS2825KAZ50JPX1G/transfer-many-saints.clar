(define-public (bulk-transfer (ids (list 1000 uint)) (receivers (list 1000 principal))) (begin (print (map transfer ids receivers)) (ok true)))
(define-private (transfer (id uint) (receiver principal)) (contract-call? 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.saints transfer id tx-sender receiver))