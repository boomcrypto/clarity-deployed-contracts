(impl-trait .sys-rnft-thresholds-trait.thresholds)

(define-read-only (get-threshold-pp (sales-value uint))
    (ok 
     (if (> sales-value                                  u100000) u1500
         (if (> sales-value                               u50000) u1300
             (if (> sales-value                           u20000) u1200
                 (if (> sales-value                       u10000) u1100
                     (if (> sales-value                    u5000) u1000
                         (if (> sales-value                u2000)  u900
                             (if (> sales-value            u1000)  u800
                                 (if (> sales-value         u500)  u700
                                     (if (> sales-value     u100)  u600
                                                                     u0
                                                                     )
                                     )
                                 )
                             )
                         )
                     )
                 )
             )
         )
     )
  )
