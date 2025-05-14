---
title: "Trait pool"
draft: true
---
```

    (use-trait sip-010 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

    ;; ============DEF============
    (define-constant OWNER tx-sender)
    (define-constant VAULT-CA 'SP35DAESSEJTKD4VNZPMKZKF6VGBC1DWBNVX08445.vault)
    (define-constant FOUNDATION 'SPVRE11KGM8MWVQ35Y2TQP8ATKC3P6M3F5PGHAYK)

    (define-constant err-not-contract-owner (err u1001))  
    (define-constant err-get-pool-id (err u2001))
    (define-constant err-get-pool-data (err u2002))
    (define-constant err-token-address-uneq (err u2003)) 
    (define-constant err-create-pool-exists (err u2004)) 
    (define-constant err-non-positive-swap-amount (err u3001)) 
    (define-constant err-swap-pool-launched (err u3002)) 
    (define-constant err-calc-curve (err u4001)) 
    (define-constant err-vault-not-mint (err u5002)) 
    (define-constant err-get-vault-balance (err u5003)) 
    (define-constant err-launch-stx-insufficient (err u6001))
    (define-constant err-launch-token-insufficient (err u6002))

    (define-constant DECI u1000000)
    (define-constant token-max-supply (* u1000000000 DECI))
    (define-constant launch-stx-amount (* u8000 DECI))
    (define-constant launch-token-amount (* u200000000 DECI))
    (define-constant delta-virtual-x u2909090909)  
    (define-constant delta-virtual-y u290909090900000)
    (define-constant fee-rate-num u1)
    (define-constant fee-rate-den u100)
    (define-constant fee-launch (* u500 DECI))

    (define-data-var pool-id uint u0)
    (define-data-var pool-trade-fee uint u0)
    (define-data-var pool-launch-fee uint u0)

    (define-map pools  
        uint {  
        pool-id: uint,
        token: principal,
        stx-reserve: uint,
        token-reserve: uint,
        virtual-stx-reserve: uint,
        virtual-token-reserve: uint,
        is-launched: bool,
        trade-fee: uint
    })

    (define-map pool-id-map principal uint)


    ;; ============FUNC============
    (define-read-only (get-pool-id (token principal))
        (map-get? pool-id-map token))
    (define-read-only (get-pool-data (id uint)) 
        (map-get? pools id))
    (define-read-only (get-pool-nums) 
        (var-get pool-id))
    (define-read-only (check-pool-launch (id uint)) 
        (unwrap-panic (get is-launched (get-pool-data id))))
    (define-read-only (check-fee)  
        {trade-fee: (var-get pool-trade-fee), launch-fee: (var-get pool-launch-fee)})

    (define-private (calc-trade-fee (stx-amount uint))
        (contract-call? .math div-ceil (* stx-amount fee-rate-num) fee-rate-den))
    (define-private (calc-required-amount-of-in-stx-real (in-stx-real uint))
        (contract-call? .math div-ceil (* in-stx-real fee-rate-den) (- fee-rate-den fee-rate-num)))
    (define-private (calc-launch-required-stx (stx-reserve uint))
        (calc-required-amount-of-in-stx-real (- launch-stx-amount stx-reserve)))


    (define-public (create-pool (token-contract <sip-010>))
        (let ((token (contract-of token-contract))
            (next-pool-id (+ (var-get pool-id) u1)))

            (asserts! (is-eq OWNER tx-sender) err-not-contract-owner)        
            (asserts! (is-none (map-get? pool-id-map token)) err-create-pool-exists)     
            (asserts! (is-eq 
                (unwrap! (contract-call? token-contract get-balance VAULT-CA) err-get-vault-balance)
                token-max-supply) err-vault-not-mint)                             
            
            (map-set pools 
                next-pool-id {
                    pool-id: next-pool-id,
                    token: token,
                    stx-reserve: u0,
                    token-reserve: token-max-supply,
                    virtual-stx-reserve: delta-virtual-x,
                    virtual-token-reserve: (- (+ delta-virtual-y token-max-supply) launch-token-amount),
                    is-launched: false,
                    trade-fee: u0,
                    })
            (map-set pool-id-map token next-pool-id)  
            (var-set pool-id next-pool-id)  
            (ok next-pool-id)
        )
    )

    (define-public (swap-token (token-contract <sip-010>) (in-stx uint))  
        (let ((id (unwrap! (get-pool-id (contract-of token-contract)) err-get-pool-id)) 
              (pool-data (unwrap! (get-pool-data id) err-get-pool-data))
              (rx (get stx-reserve pool-data))
              (ry (get token-reserve pool-data))
              (vrx (get virtual-stx-reserve pool-data))
              (vry (get virtual-token-reserve pool-data)))

            (asserts! (is-eq (contract-of token-contract) (get token pool-data)) err-token-address-uneq) 
            (asserts! (is-eq (get is-launched pool-data) false) err-swap-pool-launched)                  
            (asserts! (> in-stx u0) err-non-positive-swap-amount)                                        

            (let ((launch-required-stx (calc-launch-required-stx rx))
                  (in-stx-limited (if (> in-stx launch-required-stx) launch-required-stx in-stx)) 
                  (trade-fee (calc-trade-fee in-stx-limited))
                  (in-stx-real (- in-stx-limited trade-fee))                                  
                  (out-token (unwrap! (contract-call? .math calc-out-y in-stx-real vrx vry) err-calc-curve)) 
                  (recipient tx-sender))
                
                (asserts! (and (> out-token u0) (> in-stx-real u0) (> trade-fee u0)) err-non-positive-swap-amount)        

                (try! (stx-transfer? in-stx-limited recipient VAULT-CA))                                               
                (try! (as-contract (contract-call? .vault vault-token-out token-contract out-token recipient)))  

                (try! (update-pool-reserves id (+ rx in-stx-real) (- ry out-token) (+ vrx in-stx-real) (- vry out-token))) 
                (try! (update-trade-fee id trade-fee))                                                                    
                
                (try! (if (>= (+ rx in-stx-real) launch-stx-amount) (migrate-pool id token-contract) (ok false)))                     

                (ok out-token)
            )
        )
    )

    (define-public (swap-stx (token-contract <sip-010>) (in-token uint)) 
        (let ((id (unwrap! (get-pool-id (contract-of token-contract)) err-get-pool-id))
              (pool-data (unwrap! (get-pool-data id) err-get-pool-data))
              (rx (get stx-reserve pool-data))
              (ry (get token-reserve pool-data))
              (vrx (get virtual-stx-reserve pool-data))
              (vry (get virtual-token-reserve pool-data)))

            (asserts! (is-eq (contract-of token-contract) (get token pool-data)) err-token-address-uneq) 
            (asserts! (is-eq (get is-launched pool-data) false) err-swap-pool-launched)                 
            (asserts! (> in-token u0) err-non-positive-swap-amount)                                       

            (let ((out-stx (unwrap! (contract-call? .math calc-out-x in-token vrx vry) err-calc-curve)) 
                  (trade-fee (calc-trade-fee out-stx))
                  (out-stx-real (- out-stx trade-fee))
                  (recipient tx-sender))
                
                (asserts! (and (> out-stx-real u0) (> trade-fee u0)) err-non-positive-swap-amount)                                 
                (try! (contract-call? token-contract transfer in-token recipient VAULT-CA none))              
                (try! (as-contract (contract-call? .vault vault-stx-out out-stx-real recipient)))

                (try! (update-pool-reserves id (- rx out-stx) (+ ry in-token) (- vrx out-stx) (+ vry in-token))) 
                (try! (update-trade-fee id trade-fee))                                                         
            
                (ok out-stx-real)
            )
        )
    )

    (define-public (swap-exact-token (token-contract <sip-010>) (out-token uint)) 
        (let ((id (unwrap! (get-pool-id (contract-of token-contract)) err-get-pool-id)) 
              (pool-data (unwrap! (get-pool-data id) err-get-pool-data))
              (vrx (get virtual-stx-reserve pool-data))
              (vry (get virtual-token-reserve pool-data))
              (required-in-stx-real (unwrap! (contract-call? .math calc-required-in-x out-token vrx vry) err-calc-curve))
              (required-in-stx (calc-required-amount-of-in-stx-real required-in-stx-real)))
            
        (try! (match (swap-token token-contract required-in-stx) success-out-token (ok success-out-token) error-code (err error-code)))
        (ok required-in-stx)
        )
    )

    (define-public (swap-exact-stx (token-contract <sip-010>) (out-stx-real uint)) 
        (let ((id (unwrap! (get-pool-id (contract-of token-contract)) err-get-pool-id)) 
              (pool-data (unwrap! (get-pool-data id) err-get-pool-data))
              (vrx (get virtual-stx-reserve pool-data))
              (vry (get virtual-token-reserve pool-data))
              (out-stx (calc-required-amount-of-in-stx-real out-stx-real))
              (required-in-token (unwrap! (contract-call? .math calc-required-in-y out-stx vrx vry) err-calc-curve)))
            
        (try! (match (swap-stx token-contract required-in-token) success-out-stx-real (ok success-out-stx-real) error-code (err error-code)))
        (ok required-in-token)
        )
    )

    (define-public (collect)
        (begin
            (asserts! (is-eq OWNER tx-sender) err-not-contract-owner) 
            (if (> (var-get pool-trade-fee) u0)                                                    
                (try! (as-contract (contract-call? .vault vault-stx-out (var-get pool-trade-fee) FOUNDATION))) true)  
            (if (> (var-get pool-launch-fee) u0) 
                (try! (as-contract (contract-call? .vault vault-stx-out (var-get pool-launch-fee) FOUNDATION))) true)
            (var-set pool-trade-fee u0) 
            (var-set pool-launch-fee u0)
            (ok true)))


    (define-private (update-pool-reserves (id uint) (rx uint) (ry uint) (vrx uint) (vry uint))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data)))
            (ok (map-set pools id 
                (merge pool-data {
                    stx-reserve: rx, 
                    token-reserve: ry, 
                    virtual-stx-reserve: vrx, 
                    virtual-token-reserve: vry})))))

    (define-private (update-trade-fee (id uint) (trade-fee uint))
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data)))
            (map-set pools id (merge pool-data {trade-fee: (+ trade-fee (get trade-fee pool-data))}))
            (var-set pool-trade-fee (+ trade-fee (var-get pool-trade-fee)))
            (ok true)))

    (define-private (migrate-pool (id uint) (token-contract <sip-010>)) 
        (let ((pool-data (unwrap! (get-pool-data id) err-get-pool-data))
              (stx-reserve (get stx-reserve pool-data))
              (token-reserve (get token-reserve pool-data))
              (pool-ca (as-contract tx-sender)))
            
            (asserts! (>= stx-reserve launch-stx-amount) err-launch-stx-insufficient)
            (asserts! (>= token-reserve launch-token-amount) err-launch-token-insufficient)
            
            (map-set pools id 
                (merge pool-data {is-launched: true}))                      
            (var-set pool-launch-fee (+ fee-launch (var-get pool-launch-fee)))  

            (try! (as-contract (contract-call? .vault vault-stx-out (- stx-reserve fee-launch) pool-ca)))
            (try! (as-contract (contract-call? .vault vault-token-out token-contract token-reserve pool-ca)))
            (try! (as-contract (contract-call? 'SPTSC1VVBT6AWAB1HMQ94CTNSTPZY6R1FZ40XK5J.swap-route-memecrazy create-pool 
                                              token-contract (- stx-reserve fee-launch) token-reserve)))
            (ok true)
        )
    )
    
```
