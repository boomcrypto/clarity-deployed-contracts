(define-constant ERR-INSUFFICIENT-FUNDS (err u504))
(define-constant ERR-SWAP-FAILED (err u509))
(define-constant  INVALID-DIAMOND-COUNT (err u601))
(define-constant  INVALID-STX-CALCULATION (err u602))

(define-private (swap (stx-amount uint))
  (begin 
  (asserts! (> stx-amount u0) ERR-INSUFFICIENT-FUNDS)

 (let ((swapped-amount 
        (asserts! 
        (is-ok 
        (contract-call? 
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router
        swap-exact-tokens-for-tokens
        u79
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
        'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
        'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
        stx-amount
        u1


        )) ERR-SWAP-FAILED)))
       (ok swapped-amount )
        )
  )
)


  (define-public (buy-diamonds (diamond-count uint))
  (begin
    (asserts! (or (is-eq diamond-count u5) (is-eq diamond-count u25) (is-eq diamond-count u50) (is-eq diamond-count u100))
      INVALID-DIAMOND-COUNT)

    (let ((required-stx
            (if (is-eq diamond-count u5) u200000
              (if (is-eq diamond-count u25) u400000
                (if (is-eq diamond-count u50) u700000
                  (if (is-eq diamond-count u100) u1000000 u0))))))
      (asserts! (>= (stx-get-balance tx-sender) required-stx) INVALID-STX-CALCULATION)
     
         (try! ( swap required-stx) )
              
        
        (ok diamond-count))))

    
     
  

