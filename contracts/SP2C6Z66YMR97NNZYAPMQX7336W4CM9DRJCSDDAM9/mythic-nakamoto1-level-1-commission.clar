;; gamma-indigo-comission-container-equipment-landmark
(define-public (pay (id uint) (price uint)) 
    (begin 
        ;; Gamma (2%)
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP2C6Z66YMR97NNZYAPMQX7336W4CM9DRJCSDDAM9))
        (try! (stx-transfer? (/ (* price u1000) u10000) tx-sender 'SPWEAVXBZ9JTB9CVZR3VN29P748P7GECVE5DHECZ))
        (ok true)
    )
)