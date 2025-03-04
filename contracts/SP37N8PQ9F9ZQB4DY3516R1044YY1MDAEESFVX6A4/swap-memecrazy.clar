
(use-trait sip-010 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant OWNER tx-sender)

(define-constant err-not-contract-owner (err u1001))
(define-constant err-get-pool-data (err u2001))
(define-constant err-get-token-supply (err u2002))
(define-constant err-get-level (err u2003))
(define-constant err-get-market-cap (err u2004))
(define-constant err-core-create-pool (err u3001))
(define-constant err-core-burn (err u3002))
(define-constant err-fee-range-check (err u8001))  
(define-constant err-level-range-check (err u8002))  
(define-constant err-exceed-max-slippage (err u8003))  

(define-data-var protocol-fee-init (tuple (num uint) (den uint)) {num: u200, den: u1000}) 
(define-data-var trade-fee-stx-l1 (tuple (num uint) (den uint)) {num: u10, den: u1000}) 
(define-data-var trade-fee-meme-l1 (tuple (num uint) (den uint)) {num: u30, den: u1000}) 
(define-data-var mc-limit-l1 uint u1000000000000)
(define-data-var trade-fee-stx-l2 (tuple (num uint) (den uint)) {num: u5, den: u1000}) 
(define-data-var trade-fee-meme-l2 (tuple (num uint) (den uint)) {num: u20, den: u1000}) 
(define-data-var mc-limit-l2 uint u6000000000000)
(define-data-var trade-fee-stx-l3 (tuple (num uint) (den uint)) {num: u3, den: u1000})  
(define-data-var trade-fee-meme-l3 (tuple (num uint) (den uint)) {num: u10, den: u1000}) 


(define-read-only (check-trade-fee-level-benchmark)
    (ok 
        {
            trade-fee-stx-l1: (var-get trade-fee-stx-l1),
            trade-fee-meme-l1: (var-get trade-fee-meme-l1),
            trade-fee-stx-l2: (var-get trade-fee-stx-l2),
            trade-fee-meme-l2: (var-get trade-fee-meme-l2),
            trade-fee-stx-l3: (var-get trade-fee-stx-l3),
            trade-fee-meme-l3: (var-get trade-fee-meme-l3),
            mc-limit-l1: (var-get mc-limit-l1),
            mc-limit-l2: (var-get mc-limit-l2),
            protocol-fee-init: (var-get protocol-fee-init)
        }
    )
)

(define-public (modify-trade-fee-level-benchmark (level uint) (trade-fee-stx (tuple (num uint) (den uint))) (trade-fee-meme (tuple (num uint) (den uint))))
    (begin
        (asserts! (is-eq OWNER tx-sender) err-not-contract-owner)  
        (asserts! (< (get num trade-fee-stx)  (get den trade-fee-stx)) err-fee-range-check)  
        (asserts! (< (get num trade-fee-meme)  (get den trade-fee-meme)) err-fee-range-check) 
        (asserts! (<= level u3) err-level-range-check)

        (if (is-eq level u1)
            (ok (begin (var-set trade-fee-stx-l1 trade-fee-stx) (var-set trade-fee-meme-l1 trade-fee-meme)))   
        (if (is-eq level u2)
            (ok (begin (var-set trade-fee-stx-l2 trade-fee-stx) (var-set trade-fee-meme-l2 trade-fee-meme)))   
            (ok (begin (var-set trade-fee-stx-l3 trade-fee-stx) (var-set trade-fee-meme-l3 trade-fee-meme))))) 
    )
)

(define-public (modify-mc-limit-level-benchmark (level uint) (mc-limit uint))
    (begin
        (asserts! (is-eq OWNER tx-sender) err-not-contract-owner)  
        (asserts! (<= level u2) err-level-range-check)

    (if (is-eq level u1)
        (ok (var-set mc-limit-l1 mc-limit))    
        (ok (var-set mc-limit-l2 mc-limit))))   
)

(define-public (modify-protocol-fee-init (protocol-fee (tuple (num uint) (den uint))))
    (begin
        (asserts! (is-eq OWNER tx-sender) err-not-contract-owner)  
        (asserts! (< (get num protocol-fee)  (get den protocol-fee)) err-fee-range-check)  
        (ok (var-set protocol-fee-init protocol-fee))))

(define-read-only (get-trade-fee-level (id uint))
    (let ((pool-data (unwrap! (contract-call? .swap-core get-pool-data id) err-get-pool-data)) 
          (trade-fee-meme (get trade-fee-1 pool-data))
          (num (get num trade-fee-meme))
          (den (get den trade-fee-meme))
          (num1 (get num (var-get trade-fee-meme-l1)))
          (den1 (get den (var-get trade-fee-meme-l1)))
          (num2 (get num (var-get trade-fee-meme-l2)))
          (den2 (get den (var-get trade-fee-meme-l2))))

        (ok (if (contract-call? .swap-math fraction-compare num den num1 den1) u1 
                (if (contract-call? .swap-math fraction-compare num den num2 den2) u2 u3)))
    )
)

(define-private (calc-meme-market-cap (id uint) (meme-contract <sip-010>)) 
    (let ((pool-data (unwrap! (contract-call? .swap-core get-pool-data id) err-get-pool-data)) 
          (stx-reserve (get reserve0 pool-data))
          (meme-reserve (get reserve1 pool-data))
          (total-supply (unwrap! (contract-call? meme-contract get-total-supply) err-get-token-supply)))
    (ok (/ (* stx-reserve total-supply) meme-reserve))
    )
)

(define-public (level-up-trade-fee (id uint) (meme-contract <sip-010>))
    (let ((trade-fee-level (unwrap! (get-trade-fee-level id) err-get-level))
          (mc (unwrap! (calc-meme-market-cap id meme-contract) err-get-market-cap)))

        (if (is-eq trade-fee-level u1)  
            (if (>= mc (var-get mc-limit-l1)) 
                (as-contract (contract-call? .swap-core set-trade-fee id (var-get trade-fee-stx-l2) (var-get trade-fee-meme-l2)))
                (ok false))
        (if (is-eq trade-fee-level u2) 
            (if (>= mc (var-get mc-limit-l2)) 
                (as-contract (contract-call? .swap-core set-trade-fee id (var-get trade-fee-stx-l3) (var-get trade-fee-meme-l3)))
                (ok false))
        (ok false))) 
    )
)

(define-public (create-pool (meme-contract <sip-010>) (amount-stx uint) (amount-meme uint)) 
    (let
        ((pool-id (unwrap! (contract-call? .swap-core create-pool 
                            'SP37N8PQ9F9ZQB4DY3516R1044YY1MDAEESFVX6A4.wstx meme-contract
                            (var-get trade-fee-stx-l1) (var-get trade-fee-meme-l1) (var-get protocol-fee-init)) 
                            err-core-create-pool)))

        (try! (contract-call? .swap-core mint 
               pool-id 'SP37N8PQ9F9ZQB4DY3516R1044YY1MDAEESFVX6A4.wstx meme-contract amount-stx amount-meme))

        (ok true)
    )
)  

(define-public (add-liquidity (id uint) (meme-contract <sip-010>) (stx-input uint) (meme-input uint) (stx-min uint) (meme-min uint))
    (let ((pool-data (unwrap! (contract-call? .swap-core get-pool-data id) err-get-pool-data)) 
          (stx-reserve (get reserve0 pool-data))
          (meme-reserve (get reserve1 pool-data))
          (opts (contract-call? .swap-math calc-mint-opt stx-reserve meme-reserve stx-input meme-input)) 
          (stx-opt (get opt0 opts))
          (meme-opt (get opt1 opts)))

        (asserts! (and (>= stx-opt stx-min) (>= meme-opt meme-min)) err-exceed-max-slippage)  
        (try! (contract-call? .swap-core mint id 'SP37N8PQ9F9ZQB4DY3516R1044YY1MDAEESFVX6A4.wstx meme-contract stx-opt meme-opt))
        (ok true)
    )
)

(define-public (remove-liquidity (id uint) (meme-contract <sip-010>) (liquidity uint) (stx-min uint) (meme-min uint))
    (let ((pool-data (unwrap! (contract-call? .swap-core get-pool-data id) err-get-pool-data)) 
          (stx-reserve (get reserve0 pool-data))
          (meme-reserve (get reserve1 pool-data))
          (burn-res (unwrap! (contract-call? .swap-core burn id 'SP37N8PQ9F9ZQB4DY3516R1044YY1MDAEESFVX6A4.wstx meme-contract liquidity) err-core-burn))
          (stx-amount (get amount0 burn-res))
          (meme-amount (get amount1 burn-res)))

        (asserts! (and (>= stx-amount stx-min) (>= meme-amount meme-min)) err-exceed-max-slippage) 
        (ok true)
    )
)

(define-public (swap-exact-stx-for-meme (id uint) (meme-contract <sip-010>) (in-stx uint) (out-meme-min uint)) 
    (let ((pool-data (unwrap! (contract-call? .swap-core get-pool-data id) err-get-pool-data)) 
          (stx-reserve (get reserve0 pool-data))
          (meme-reserve (get reserve1 pool-data))
          (trade-fee (get trade-fee-0 pool-data))
          (out-meme (contract-call? .swap-math calc-swap stx-reserve meme-reserve in-stx trade-fee)))

        (asserts! (>= out-meme out-meme-min) err-exceed-max-slippage)
        (try! (contract-call? .swap-core swap id 'SP37N8PQ9F9ZQB4DY3516R1044YY1MDAEESFVX6A4.wstx meme-contract in-stx out-meme))
        (try! (level-up-trade-fee id meme-contract))
        (ok true)
    )
)

(define-public (swap-exact-meme-for-stx (id uint) (meme-contract <sip-010>) (in-meme uint) (out-stx-min uint)) 
    (let ((pool-data (unwrap! (contract-call? .swap-core get-pool-data id) err-get-pool-data)) 
          (stx-reserve (get reserve0 pool-data))
          (meme-reserve (get reserve1 pool-data))
          (trade-fee (get trade-fee-1 pool-data))
          (out-stx (contract-call? .swap-math calc-swap meme-reserve stx-reserve in-meme trade-fee)))

        (asserts! (>= out-stx out-stx-min) err-exceed-max-slippage)
        (try! (contract-call? .swap-core swap id meme-contract 'SP37N8PQ9F9ZQB4DY3516R1044YY1MDAEESFVX6A4.wstx in-meme out-stx)) 
        (ok true)
    )
)

(define-public (swap-stx-for-exact-meme (id uint) (meme-contract <sip-010>) (out-meme uint) (in-stx-max uint)) 
    (let ((pool-data (unwrap! (contract-call? .swap-core get-pool-data id) err-get-pool-data)) 
          (stx-reserve (get reserve0 pool-data))
          (meme-reserve (get reserve1 pool-data))
          (trade-fee (get trade-fee-0 pool-data))
          (in-stx (contract-call? .swap-math calc-swap-exact stx-reserve meme-reserve out-meme trade-fee)))

        (asserts! (<= in-stx in-stx-max) err-exceed-max-slippage)
        (try! (contract-call? .swap-core swap id 'SP37N8PQ9F9ZQB4DY3516R1044YY1MDAEESFVX6A4.wstx meme-contract in-stx out-meme))
        (try! (level-up-trade-fee id meme-contract))
        (ok true)
    )
)

(define-public (swap-meme-for-exact-stx (id uint) (meme-contract <sip-010>) (out-stx uint) (in-meme-max uint)) 
    (let ((pool-data (unwrap! (contract-call? .swap-core get-pool-data id) err-get-pool-data)) 
          (stx-reserve (get reserve0 pool-data))
          (meme-reserve (get reserve1 pool-data))
          (trade-fee (get trade-fee-1 pool-data))
          (in-meme (contract-call? .swap-math calc-swap-exact meme-reserve stx-reserve out-stx trade-fee)))

        (asserts! (<= in-meme in-meme-max) err-exceed-max-slippage)
        (try! (contract-call? .swap-core swap id meme-contract 'SP37N8PQ9F9ZQB4DY3516R1044YY1MDAEESFVX6A4.wstx in-meme out-stx))
        (ok true)
    )
)
    