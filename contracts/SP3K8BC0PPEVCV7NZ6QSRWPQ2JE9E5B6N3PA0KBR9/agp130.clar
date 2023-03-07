(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-constant amount u1000000)
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant token-halving-cycle u100) ;; number of cycles before coinbase change / ~ 1 year
(define-constant TOKEN_LIST 
    (list 
        .age000-governance-token
        .fwp-wstx-alex-50-50-v1-01
        .fwp-wstx-wbtc-50-50-v1-01
        .fwp-wstx-wxusd-50-50-v1-01
        .fwp-alex-usda
        .fwp-alex-wban
    )
)
(define-constant fwp-wxusd-coinbase-1 (* u20000  ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-wxusd-coinbase-2 (* u10000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-wxusd-coinbase-3 (* u5000 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-wxusd-coinbase-4 (* u2500 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-wxusd-coinbase-5 (* u1250 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant fwp-usda-coinbase-1 (* u2000 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-usda-coinbase-2 (* u0 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-usda-coinbase-3 (* u0 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-usda-coinbase-4 (* u0 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-usda-coinbase-5 (* u0 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant fwp-wban-coinbase-1 (* u2000 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-wban-coinbase-2 (* u1000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-wban-coinbase-3 (* u500 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-wban-coinbase-4 (* u250 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-wban-coinbase-5 (* u125 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant alex-coinbase-1 (* u206400 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant alex-coinbase-2 (* u103200 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant alex-coinbase-3 (* u51600 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant alex-coinbase-4 (* u25800 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant alex-coinbase-5 (* u12900 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant fwp-wstx-coinbase-1 (* u567600 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-wstx-coinbase-2 (* u283800 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-wstx-coinbase-3 (* u141900 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-wstx-coinbase-4 (* u70950 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-wstx-coinbase-5 (* u35475 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-constant fwp-wbtc-coinbase-1 (* u258000 ONE_8)) ;; emission of $ALEX per cycle in 1st year
(define-constant fwp-wbtc-coinbase-2 (* u129000 ONE_8)) ;; emission of $ALEX per cycle in 2nd year
(define-constant fwp-wbtc-coinbase-3 (* u64500 ONE_8)) ;; emission of $ALEX per cycle in 3rd year
(define-constant fwp-wbtc-coinbase-4 (* u32250 ONE_8)) ;; emission of $ALEX per cycle in 4th year
(define-constant fwp-wbtc-coinbase-5 (* u16125 ONE_8)) ;; emission of $ALEX per cycle in 5th year
(define-public (execute (sender principal))
    (begin  
        (try! (contract-call? .age000-governance-token mint-fixed (* amount ONE_8) 'SPC7TY5JGGGA8HS4HGTTWXBN8NJ28XH2JR9HCXN4))
        (try! (contract-call? .auto-alex set-end-cycle MAX_UINT))
        (try! (contract-call? .alex-reserve-pool set-token-halving-cycle token-halving-cycle))
		(try! (contract-call? .alex-reserve-pool set-coinbase-amount .age000-governance-token alex-coinbase-1 alex-coinbase-2 alex-coinbase-3 alex-coinbase-4 alex-coinbase-5))
    	(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-alex-50-50-v1-01 fwp-wstx-coinbase-1 fwp-wstx-coinbase-2 fwp-wstx-coinbase-3 fwp-wstx-coinbase-4 fwp-wstx-coinbase-5))
		(try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-wbtc-50-50-v1-01 fwp-wbtc-coinbase-1 fwp-wbtc-coinbase-2 fwp-wbtc-coinbase-3 fwp-wbtc-coinbase-4 fwp-wbtc-coinbase-5))
        (try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-alex-wban fwp-wban-coinbase-1 fwp-wban-coinbase-2 fwp-wban-coinbase-3 fwp-wban-coinbase-4 fwp-wban-coinbase-5))
        (try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-alex-usda fwp-usda-coinbase-1 fwp-usda-coinbase-2 fwp-usda-coinbase-3 fwp-usda-coinbase-4 fwp-usda-coinbase-5))
        (try! (contract-call? .alex-reserve-pool set-coinbase-amount .fwp-wstx-wxusd-50-50-v1-01 fwp-wxusd-coinbase-1 fwp-wxusd-coinbase-2 fwp-wxusd-coinbase-3 fwp-wxusd-coinbase-4 fwp-wxusd-coinbase-5))
        
        (ok true)
    )
)