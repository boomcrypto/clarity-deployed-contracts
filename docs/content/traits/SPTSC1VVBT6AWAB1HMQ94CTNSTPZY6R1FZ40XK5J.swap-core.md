---
title: "Trait swap-core"
draft: true
---
```

    (use-trait sip-010 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

    ;; ============DEF============
    (define-constant OWNER tx-sender)
    (define-constant VAULT-CA 'SPTSC1VVBT6AWAB1HMQ94CTNSTPZY6R1FZ40XK5J.swap-vault) 
    (define-constant ROUTE-CA 'SPTSC1VVBT6AWAB1HMQ94CTNSTPZY6R1FZ40XK5J.swap-route)
    (define-constant ROUTE-MEME-CA 'SPTSC1VVBT6AWAB1HMQ94CTNSTPZY6R1FZ40XK5J.swap-route-memecrazy)
    (define-constant FOUNDATION 'SPVRE11KGM8MWVQ35Y2TQP8ATKC3P6M3F5PGHAYK)
    (define-constant MEME-POOL-CA 'SP35DAESSEJTKD4VNZPMKZKF6VGBC1DWBNVX08445.pool)

    (define-constant err-not-contract-owner (err u1001))  
    (define-constant err-not-call-by-route (err u1002))  
    (define-constant err-get-pool-data (err u2001))
    (define-constant err-token-pair-mismatch (err u2002))
    (define-constant err-same-token-pair (err u2003))
    (define-constant err-token-pair-exists (err u2004))
    (define-constant err-check-token-reversed (err u2005))
    (define-constant err-lp-get-total-supply (err u2006))
    (define-constant err-non-positive-mint-amount (err u4001))
    (define-constant err-non-positive-burn-amount (err u4002))  
    (define-constant err-non-positive-swap-amount (err u4003))  
    (define-constant err-non-positive-reserve (err u4004))  
    (define-constant err-swap-amount-in-validation (err u4005))  
    (define-constant err-swap-k-condition (err u4006))  
    (define-constant err-overflow-check (err u4007))  
    (define-constant err-fee-range-check (err u4008))  
    (define-constant err-zero-revenue (err u4009))  

    (define-data-var pool-id uint u0)

    (define-map pools  
        uint {  
        pool-id: uint,
        token0: principal,
        token1: principal,
        reserve0: uint,
        reserve1: uint,
        trade-fee-0: (tuple (num uint) (den uint)),
        trade-fee-1: (tuple (num uint) (den uint)),
        protocol-fee: (tuple (num uint) (den uint)),
        revenue0: uint,
        revenue1: uint,
        fee0: uint,
        fee1: uint,
    })

    (define-map pool-id-map (tuple (token0 principal) (token1 principal)) uint)


    ;; ============FUNC============
    (define-read-only (get-pool-id (token0 principal) (token1 principal))
        (map-get? pool-id-map {token0: token0, token1: token1}))
    (define-read-only (find-pool-id (token0 principal) (token1 principal))
      (match (get-pool-id token0 token1)
            id (some id) (get-pool-id token1 token0)))
    (define-read-only (get-pool-data (id uint)) 
        (map-get? pools id))
    (define-read-only (get-pool-nums) 
        (var-get pool-id))
    (define-read-only (check-if-token-reversed (id uint) (token0 principal) (token1 principal))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data))) 
            (if (and (is-eq token0 (get token0 pool-data)) (is-eq token1 (get token1 pool-data)))
                (ok false)  
            (if (and (is-eq token0 (get token1 pool-data)) (is-eq token1 (get token0 pool-data))) 
                (ok true) 
                err-token-pair-mismatch)) 
        )
    )

    (define-public (create-pool (token0-contract <sip-010>) (token1-contract <sip-010>) 
                                (trade-fee-0 (tuple (num uint) (den uint))) (trade-fee-1 (tuple (num uint) (den uint))) (protocol-fee (tuple (num uint) (den uint))))
        (let ((token0 (contract-of token0-contract))
              (token1 (contract-of token1-contract))
              (next-pool-id (+ (var-get pool-id) u1)))

            (asserts! (or (is-eq OWNER tx-sender) (is-eq MEME-POOL-CA tx-sender)) err-not-contract-owner)       
            (asserts! (not (is-eq token0 token1)) err-same-token-pair)                                       
            (asserts! (is-none (find-pool-id token0 token1)) err-token-pair-exists)                            
            
            (asserts! (and (< (get num trade-fee-0) (get den trade-fee-0))
                          (< (get num trade-fee-1) (get den trade-fee-1))
                          (< (get num protocol-fee) (get den protocol-fee))) err-fee-range-check)     

            (map-set pools 
                next-pool-id {
                    pool-id: next-pool-id,
                    token0: token0,
                    token1: token1,
                    reserve0: u0,
                    reserve1: u0,
                    trade-fee-0: trade-fee-0,
                    trade-fee-1: trade-fee-1,
                    protocol-fee: protocol-fee,
                    revenue0: u0,
                    revenue1: u0,
                    fee0: u0,
                    fee1: u0,
                    })
            (map-set pool-id-map {token0: token0, token1: token1} next-pool-id)  
            (var-set pool-id next-pool-id)  
            (ok next-pool-id)
        )
    )

    (define-public (mint (id uint) (token0-contract <sip-010>) (token1-contract <sip-010>) (amount0 uint) (amount1 uint))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data))  
              (token0 (contract-of token0-contract))
              (token1 (contract-of token1-contract))
              (r0 (get reserve0 pool-data))
              (r1 (get reserve1 pool-data))
              
              (reversed (unwrap! (check-if-token-reversed id token0 token1) err-check-token-reversed))  
              (a0 (if reversed amount1 amount0))
              (a1 (if reversed amount0 amount1))
              
              (lp-supply (unwrap! (contract-call? .swap-lp-token lp-get-total-supply id) err-lp-get-total-supply))
              (liquidity (contract-call? .swap-math calc-mint r0 r1 a0 a1 lp-supply))
              (provider tx-sender))
            
            (asserts! (and (> a0 u0) (> a1 u0) (> liquidity u0)) err-non-positive-mint-amount)  

            (try! (contract-call? token0-contract transfer amount0 provider VAULT-CA none))
            (try! (contract-call? token1-contract transfer amount1 provider VAULT-CA none))    

            (try! (as-contract (contract-call? .swap-lp-token lp-mint id liquidity provider)))

            (try! (update-reserve id (+ r0 a0) (+ r1 a1)))

            (asserts! (and (> (* (+ lp-supply liquidity) (+ r0 a0)) u0)
                          (> (* (+ lp-supply liquidity) (+ r1 a1)) u0)
                          (> (* (+ r0 a0) (+ r1 a1)) u0)) err-overflow-check)       

            (ok liquidity)
        )
    )

    (define-public (burn (id uint) (token0-contract <sip-010>) (token1-contract <sip-010>) (liquidity uint))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data))  
              (token0 (contract-of token0-contract))
              (token1 (contract-of token1-contract))
              (reversed (unwrap! (check-if-token-reversed id token0 token1) err-check-token-reversed)) 
              (r0 (get reserve0 pool-data))
              (r1 (get reserve1 pool-data))
              (lp-supply (unwrap! (contract-call? .swap-lp-token lp-get-total-supply id) err-lp-get-total-supply))
              (amounts (contract-call? .swap-math calc-burn r0 r1 liquidity lp-supply))
              (a0 (get a0 amounts))
              (a1 (get a1 amounts))
              (provider tx-sender))

            (asserts! (and (> liquidity u0) (> lp-supply u0) (> a0 u0) (> a1 u0)) err-non-positive-burn-amount) 

            (try! (contract-call? .swap-lp-token lp-burn id liquidity provider))

            (try! (as-contract (contract-call? .swap-vault vault-token-out token0-contract (if reversed a1 a0) provider)))
            (try! (as-contract (contract-call? .swap-vault vault-token-out token1-contract (if reversed a0 a1) provider)))

            (try! (update-reserve id (- r0 a0) (- r1 a1)))

            (ok {amount0: (if reversed a1 a0), amount1: (if reversed a0 a1)})
        )
    )

    (define-public (swap (id uint) (token-in-contract <sip-010>) (token-out-contract <sip-010>) (amount-in uint) (amount-out uint))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data))  
              (token-in (contract-of token-in-contract))
              (token-out (contract-of token-out-contract))
              (reversed (unwrap! (check-if-token-reversed id token-in token-out) err-check-token-reversed))  
              (r-in (if reversed (get reserve1 pool-data) (get reserve0 pool-data)))  
              (r-out (if reversed (get reserve0 pool-data) (get reserve1 pool-data))) 
              (k (* r-in r-out))
              
              (trade-fee (if reversed (get trade-fee-1 pool-data) (get trade-fee-0 pool-data))) 
              (protocol-fee (get protocol-fee pool-data))
              (fee-total (contract-call? .swap-math div-ceil (* amount-in (get num trade-fee)) (get den trade-fee)))  
              (fee-protocol (/ (* fee-total (get num protocol-fee)) (get den protocol-fee)))  
              (fee-lp (- fee-total fee-protocol)) 
              (amount-in-real (- amount-in fee-total))  
              (sender tx-sender))

            (asserts! (or (is-eq contract-caller ROUTE-CA) (is-eq contract-caller ROUTE-MEME-CA)) err-not-call-by-route)  

            (asserts! (and (> amount-in u0) (> amount-out u0) (> amount-in-real u0)) err-non-positive-swap-amount) 
            (asserts! (and (> r-in u0) (> r-out u0)) err-non-positive-reserve) 
            (asserts! (and (< (get num trade-fee) (get den trade-fee))
                          (< (get num protocol-fee) (get den protocol-fee))) err-fee-range-check) 
            (asserts! (or (is-eq (get num trade-fee) u0) (> fee-lp u0)) err-fee-range-check) 
            (asserts! (is-eq amount-in (+ amount-in-real fee-protocol fee-lp)) err-swap-amount-in-validation)  
            (asserts! (>= (* (+ r-in amount-in-real) (- r-out amount-out)) k) err-swap-k-condition)   

            (try! (contract-call? token-in-contract transfer amount-in sender VAULT-CA none)) 
            (try! (as-contract (contract-call? .swap-vault vault-token-out token-out-contract amount-out sender))) 

            (try! (update-reserve id                                                
                (if reversed (- r-out amount-out) (+ r-in amount-in-real fee-lp))
                (if reversed (+ r-in amount-in-real fee-lp) (- r-out amount-out))))  
            (try! (add-revenue id token-in fee-protocol))
            (try! (add-lp-fee id token-in fee-lp))                                  

            (ok true)
        )
    )

    (define-public (collect (id uint) (token0-contract <sip-010>) (token1-contract <sip-010>))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data))
              (token0 (contract-of token0-contract))
              (token1 (contract-of token1-contract))
              (reversed (unwrap! (check-if-token-reversed id token0 token1) err-check-token-reversed))
              (revenue0 (if reversed (get revenue1 pool-data) (get revenue0 pool-data)))
              (revenue1 (if reversed (get revenue0 pool-data) (get revenue1 pool-data))))

            (asserts! (or (is-eq OWNER tx-sender)) err-not-contract-owner)  
            (asserts! (or (> revenue0 u0) (> revenue1 u0)) err-zero-revenue)  

            (if (> revenue0 u0) (try! (as-contract (contract-call? .swap-vault vault-token-out token0-contract revenue0 FOUNDATION))) true) 
            (if (> revenue1 u0) (try! (as-contract (contract-call? .swap-vault vault-token-out token1-contract revenue1 FOUNDATION))) true)

            (ok (map-set pools id (merge pool-data {revenue0: u0, revenue1: u0})))
        )
    )

    (define-public (set-trade-fee (id uint) (trade-fee-0 (tuple (num uint) (den uint))) (trade-fee-1 (tuple (num uint) (den uint))))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data)))

            (asserts! (or (is-eq OWNER tx-sender) (is-eq ROUTE-CA tx-sender) (is-eq ROUTE-MEME-CA tx-sender)) err-not-contract-owner) 
            (asserts! (and (< (get num trade-fee-0) (get den trade-fee-0))
                          (< (get num trade-fee-1) (get den trade-fee-1))) err-fee-range-check) 

            (ok (map-set pools id (merge pool-data {trade-fee-0: trade-fee-0, trade-fee-1: trade-fee-1})))
        )
    )

    (define-public (set-protocol-fee (id uint) (protocol-fee (tuple (num uint) (den uint))))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data))) 

            (asserts! (or (is-eq OWNER tx-sender) (is-eq ROUTE-CA tx-sender) (is-eq ROUTE-MEME-CA tx-sender)) err-not-contract-owner) 
            (asserts! (< (get num protocol-fee)  (get den protocol-fee)) err-fee-range-check) 

            (ok (map-set pools id (merge pool-data {protocol-fee: protocol-fee} )))
        )
    )


    (define-private (update-reserve (id uint) (r0 uint) (r1 uint))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data)))
        (ok (map-set pools id (merge pool-data {reserve0: r0, reserve1: r1})))))
    (define-private (add-revenue (id uint) (token principal) (revenue uint))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data)))
            (if (is-eq token (get token0 pool-data))
                (ok (map-set pools id (merge pool-data {revenue0: (+ (get revenue0 pool-data) revenue)})))
                (ok (map-set pools id (merge pool-data {revenue1: (+ (get revenue1 pool-data) revenue)}))))))
    (define-private (add-lp-fee (id uint) (token principal) (fee uint))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data)))
            (if (is-eq token (get token0 pool-data))
                (ok (map-set pools id (merge pool-data {fee0: (+ (get fee0 pool-data) fee)})))
                (ok (map-set pools id (merge pool-data {fee1: (+ (get fee1 pool-data) fee)}))))))
    
```
