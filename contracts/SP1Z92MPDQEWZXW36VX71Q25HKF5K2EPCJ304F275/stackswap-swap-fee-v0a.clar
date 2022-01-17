;; contract for intiial stackswap fee

;; start from 26000
;; daily block 170
;; 3 year block 186150

(define-constant FEE-START-BLOCK u212150)

(define-read-only (get-fee-1)
  (if (> block-height FEE-START-BLOCK)
    (ok u997)
    (ok u997)
  )
)

(define-read-only (get-fee-2)
  (if (> block-height FEE-START-BLOCK)
    (ok u1000)
    (ok u1000)
  )
)

(define-read-only (get-fee-3)
  (if (> block-height FEE-START-BLOCK)
    (ok u5)
    (ok u5)
  )
)

(define-read-only (get-fee-4)
  (if (> block-height FEE-START-BLOCK)
    (ok u10000)
    (ok u10000)
  )
)