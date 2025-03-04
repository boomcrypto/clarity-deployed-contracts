
;; (define-constant STX_TOKEN 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx)
;; (define-constant STONE_TOKEN 'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve) 
(define-constant ERR-INSUFFICIENT-FUNDS (err 101));; Replace with actual address
(define-constant  ERR-SWAP-FAILED (err 102));; Replace with actual address
(define-constant ERR-NOT-AUTHORIZED (err 103))
(define-constant ERR-ENTER-NEW-WALLET (err 104))

(define-data-var contract-owner principal tx-sender)

(define-public (set-contract-owner (owner principal))
  (begin  
  (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
  (asserts! (not (is-eq owner (var-get contract-owner))) ERR-ENTER-NEW-WALLET)
    (var-set contract-owner owner)
    (ok owner)
  )
)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (swap (stx-amount uint))
  (begin 
  (asserts! (> stx-amount u0) ERR-INSUFFICIENT-FUNDS)

  (let 
    (
      ;; Define the swap path
      (swap-path 
        (list
          (tuple 
            (a "u") 
            (b 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-stone) 
            (c u79) 
            (d 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx) 
            (e 'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve) 
            (f true)
          )
        )
      )    
    )
 
    
    ;; Swap STX to STONE using the specified path
    (let 
      (
        (swapped-stone 
          (asserts! 
          (is-ok  (contract-call? 
             'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging
              apply 
              swap-path 
              stx-amount 
              (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx) 
              (some 'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve) 
              none 
              none
              none 
              (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to) 
              none 
              none
              none
              none
 
              none
              none
              none
              none 

               none
               none
               none 
               none 

               none
               none 
               none 
               none 

              none 
              none 
              none 
              none 

               none
               none 
               none 
               none 
              
            ) )
            ERR-SWAP-FAILED
          )
        )
      )
      
      ;; Return the swapped token amount
      (ok swapped-stone)
    )
  )
  )
)
