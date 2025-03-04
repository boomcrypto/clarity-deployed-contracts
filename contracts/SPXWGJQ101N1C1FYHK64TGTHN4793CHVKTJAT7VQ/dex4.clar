

(define-constant ERR-INSUFFICIENT-FUNDS (err 101))
(define-constant  ERR-SWAP-FAILED (err 102))
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
