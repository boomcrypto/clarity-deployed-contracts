(impl-trait .trait-ownable.ownable-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait sft-trait .trait-semi-fungible.semi-fungible-trait)
(define-constant MAX_T u95000000)
(define-constant ERR-INVALID-POOL (err u2001))
(define-constant ERR-INVALID-LIQUIDITY (err u2003))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-POOL-ALREADY-EXISTS (err u2000))
(define-constant ERR-TOO-MANY-POOLS (err u2004))
(define-constant ERR-PERCENT-GREATER-THAN-ONE (err u5000))
(define-constant ERR-NO-FEE (err u2005))
(define-constant ERR-NO-FEE-Y (err u2006))
(define-constant ERR-INVALID-EXPIRY (err u2009))
(define-constant ERR-GET-EXPIRY-FAIL-ERR (err u2013))
(define-constant ERR-DY-BIGGER-THAN-AVAILABLE (err u2016))
(define-constant ERR-EXPIRY (err u2017))
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-EXCEEDS-MAX-SLIPPAGE (err u2020))
(define-constant ERR-INVALID-TOKEN (err u2026))
(define-constant ERR-ORACLE-NOT-ENABLED (err u7002))
(define-constant ERR-ORACLE-ALREADY-ENABLED (err u7003))
(define-constant ERR-ORACLE-AVERAGE-BIGGER-THAN-ONE (err u7004))
(define-constant ERR-INVALID-BALANCE (err u1001))
(define-constant ERR-GET-BALANCE-FIXED-FAIL (err u6001))
(define-data-var contract-owner principal tx-sender)
(define-map approved-contracts principal bool)
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    (ok (var-set contract-owner owner))
  )
)
(define-private (check-is-owner)
    (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)
(define-private (check-is-self)
  (ok (asserts! (is-eq tx-sender (as-contract tx-sender)) ERR-NOT-AUTHORIZED))
)
(define-private (check-is-approved)
  (ok (asserts! (default-to false (map-get? approved-contracts tx-sender)) ERR-NOT-AUTHORIZED))
)
(define-public (set-approved-contract (owner principal) (approved bool))
	(begin
		(try! (check-is-owner))
		(ok (map-set approved-contracts owner approved))
	)
)
(define-map pools-data-map
  {
    yield-token: principal, 
    expiry: uint
  }
  {
    total-supply: uint,    
    balance-token: uint, ;; dx    
    balance-yield-token: uint, ;; dy_actual
    balance-virtual: uint, ;; dy_virtual
    fee-to-address: principal,
    pool-token: principal,
    fee-rate-token: uint,    
    fee-rate-yield-token: uint,
    fee-rebate: uint,
    listed: uint,
    oracle-enabled: bool,
    oracle-average: uint,
    oracle-resilient: uint,
    underlying-token: principal,
    small-threshold: uint,
    min-fee: uint
  }
)
(define-data-var max-expiry uint u210240)
(define-read-only (get-max-expiry)
    (var-get max-expiry)
)
(define-public (set-max-expiry (new-max-expiry uint))
    (begin
        (try! (check-is-owner))
        (asserts! (> new-max-expiry block-height) ERR-INVALID-EXPIRY)
        (ok (var-set max-expiry new-max-expiry)) 
    )
)
(define-read-only (get-t (expiry uint) (listed uint))
  (begin
    (asserts! (and (> (var-get max-expiry) expiry) (> (var-get max-expiry) block-height)) ERR-INVALID-EXPIRY)
    (let
      (
        (t (div-down (if (< expiry block-height) u0 (- expiry block-height)) (- (var-get max-expiry) listed)))
      )
      (ok (if (< t MAX_T) t MAX_T)) ;; to avoid numerical error
    )
  )
)
(define-read-only (get-pool-details (expiry uint) (yield-token principal))
    (ok (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
)
(define-read-only (get-yield (expiry uint) (yield-token principal))
    (ok (- (try! (get-price expiry yield-token)) ONE_8))
)
(define-read-only (get-price (expiry uint) (yield-token principal))
    (let
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )      
        (ok (get-price-internal (get balance-token pool) (+ (get balance-yield-token pool) (get balance-virtual pool)) (try! (get-t expiry (get listed pool)))))
    )
)
(define-private (get-price-internal (balance-x uint) (balance-y uint) (t uint))
    (let
        (
          (price (pow-up (div-up balance-y balance-x) t))
        )
        (if (<= price ONE_8) ONE_8 price)
    )
)
(define-read-only (get-price-down (expiry uint) (yield-token principal))
    (let
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )      
        (ok (get-price-down-internal (get balance-token pool) (+ (get balance-yield-token pool) (get balance-virtual pool)) (try! (get-t expiry (get listed pool)))))
    )
)
(define-private (get-price-down-internal (balance-x uint) (balance-y uint) (t uint))
    (let
        (
          (price (pow-down (div-up balance-y balance-x) t))
        )
        (if (<= price ONE_8) ONE_8 price)
    )
)
(define-read-only (get-oracle-enabled (expiry uint) (yield-token principal))
    (ok (get oracle-enabled (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL)))
)
(define-public (set-oracle-enabled (expiry uint) (yield-token principal))
    (let
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )
        (try! (check-is-owner))
        (asserts! (not (get oracle-enabled pool)) ERR-ORACLE-ALREADY-ENABLED)
        (map-set pools-data-map { yield-token: yield-token, expiry: expiry } (merge pool {oracle-enabled: true}))
        (ok true)
    )    
)
(define-read-only (get-oracle-average (expiry uint) (yield-token principal))
    (ok (get oracle-average (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL)))
)
(define-public (set-oracle-average (expiry uint) (yield-token principal) (new-oracle-average uint))
    (let
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
            (pool-updated (merge pool {
                oracle-average: new-oracle-average,
                oracle-resilient: (try! (get-oracle-instant expiry yield-token))
                }))
        )
        (try! (check-is-owner))
        (asserts! (get oracle-enabled pool) ERR-ORACLE-NOT-ENABLED)
        (asserts! (< new-oracle-average ONE_8) ERR-ORACLE-AVERAGE-BIGGER-THAN-ONE)
        (map-set pools-data-map { yield-token: yield-token, expiry: expiry } pool-updated)
        (ok true)
    )    
)
(define-read-only (get-oracle-resilient (expiry uint) (yield-token principal))
    (let
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )
        (asserts! (get oracle-enabled pool) ERR-ORACLE-NOT-ENABLED)
        (ok (+ (mul-down (- ONE_8 (get oracle-average pool)) (try! (get-oracle-instant expiry yield-token)))
               (mul-down (get oracle-average pool) (get oracle-resilient pool))))
    )
)
(define-read-only (get-oracle-instant (expiry uint) (yield-token principal))
    (ok (div-down ONE_8 (try! (get-price expiry yield-token))))
)
(define-public (create-pool (expiry uint) (yield-token-trait <sft-trait>) (token-trait <ft-trait>) (pool-token-trait <sft-trait>) (multisig-vote principal) (dx uint) (dy uint))
  (create-and-configure-pool expiry yield-token-trait token-trait pool-token-trait multisig-vote u0 u0 u0 u0 u0 dx dy)
)
(define-public (create-and-configure-pool 
  (expiry uint) (yield-token-trait <sft-trait>) (token-trait <ft-trait>) (pool-token-trait <sft-trait>) (multisig-vote principal) 
  (fee-rebate uint) (fee-rate-yield-token uint) (fee-rate-token uint) (small-threshold uint) (min-fee uint)
  (dx uint) (dy uint))   
    (begin
        (asserts! (or (is-ok (check-is-owner)) (is-ok (check-is-approved))) ERR-NOT-AUTHORIZED)
        (asserts! (is-none (map-get? pools-data-map { yield-token: (contract-of yield-token-trait), expiry: expiry })) ERR-POOL-ALREADY-EXISTS)
        (let
            (
                (yield-token (contract-of yield-token-trait))            
                (pool-data {
                    total-supply: u0,
                    balance-token: u0,                
                    balance-yield-token: u0,
                    balance-virtual: u0,
                    fee-to-address: multisig-vote,
                    pool-token: (contract-of pool-token-trait),
                    fee-rate-yield-token: fee-rate-yield-token,
                    fee-rate-token: fee-rate-token,
                    fee-rebate: fee-rebate,
                    listed: block-height,
                    oracle-enabled: false,
                    oracle-average: u0,
                    oracle-resilient: u0,
                    underlying-token: (contract-of token-trait),
                    small-threshold: small-threshold,
                    min-fee: min-fee
                })
            )
            (map-set pools-data-map { yield-token: yield-token, expiry: expiry } pool-data)
            (print { object: "pool", action: "created", data: pool-data })
            (add-to-position expiry yield-token-trait token-trait pool-token-trait dx (some dy))
        )
    )
)
(define-data-var buy-and-add-buffer uint u101000000) ;; 1.01x
(define-read-only (get-buy-and-add-buffer)
  (var-get buy-and-add-buffer)
)
(define-public (set-buy-and-add-buffer (new-buffer uint))
  (begin 
    (try! (check-is-owner))
    (ok (var-set buy-and-add-buffer new-buffer))
  )
)
(define-public (buy-and-add-to-position (expiry uint) (yield-token-trait <sft-trait>) (token-trait <ft-trait>) (pool-token-trait <sft-trait>) (dx uint))
    (let
        (
            (yield-token (contract-of yield-token-trait))
            (dy-act (get dy-act (try! (get-token-given-position expiry yield-token dx))))
            (dx-to-sell (if (is-eq dy-act u0) u0 (mul-down (var-get buy-and-add-buffer) (try! (get-x-in-given-y-out expiry yield-token dy-act)))))
            (dy (if (is-eq dy-act u0) u0 (get dy (try! (swap-x-for-y expiry yield-token-trait token-trait dx-to-sell none)))))
        )
        (add-to-position expiry yield-token-trait token-trait pool-token-trait (- dx dx-to-sell) (some dy-act))
    )
)
(define-public (roll-position 
    (expiry uint) (yield-token-trait <sft-trait>) (token-trait <ft-trait>) (pool-token-trait <sft-trait>) (percent uint) 
    (expiry-to-roll uint))
    (let
        (
            (reduce-data (try! (reduce-position expiry yield-token-trait token-trait pool-token-trait percent)))
            (dy-to-dx (get dx (try! (swap-y-for-x expiry yield-token-trait token-trait (get dy reduce-data) none))))
        )
        (buy-and-add-to-position expiry-to-roll yield-token-trait token-trait pool-token-trait (+ (get dx reduce-data) dy-to-dx))
    )
)
(define-public (add-to-position (expiry uint) (yield-token-trait <sft-trait>) (token-trait <ft-trait>) (pool-token-trait <sft-trait>) (dx uint) (max-dy (optional uint)))
    (begin
        (asserts! (> dx u0) ERR-INVALID-LIQUIDITY)
        (let
            (
                (yield-token (contract-of yield-token-trait))
                (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
                (balance-token (get balance-token pool))            
                (balance-yield-token (get balance-yield-token pool))
                (balance-virtual (get balance-virtual pool))
                (total-supply (get total-supply pool))
                (add-data (try! (get-token-given-position expiry yield-token dx)))
                (new-supply (get token add-data))
                (new-dy-act (get dy-act add-data))
                (new-dy-vir (get dy-vir add-data))
                (pool-updated (merge pool {
                    total-supply: (+ new-supply total-supply),
                    balance-token: (+ balance-token dx),
                    balance-yield-token: (+ balance-yield-token new-dy-act),
                    balance-virtual: (+ balance-virtual new-dy-vir)   
                }))
                (sender tx-sender)
            )
            (asserts! (and (is-eq (get underlying-token pool) (contract-of token-trait)) (is-eq (get pool-token pool) (contract-of pool-token-trait))) ERR-INVALID-TOKEN)    
            (asserts! (or (> new-dy-act u0) (> new-dy-vir u0)) ERR-INVALID-LIQUIDITY)
            (asserts! (>= (default-to u340282366920938463463374607431768211455 max-dy) new-dy-act) ERR-EXCEEDS-MAX-SLIPPAGE)
            (unwrap! (contract-call? token-trait transfer-fixed dx sender .alex-vault none) ERR-TRANSFER-FAILED)
            (and (> new-dy-act u0) (unwrap! (contract-call? yield-token-trait transfer-fixed expiry new-dy-act sender .alex-vault) ERR-TRANSFER-FAILED))
            (map-set pools-data-map { yield-token: yield-token, expiry: expiry } pool-updated)    
            (as-contract (try! (contract-call? pool-token-trait mint-fixed expiry new-supply sender)))
            (print { object: "pool", action: "pool-added", data: pool-updated })
            (ok {supply: new-supply, balance-token: dx, balance-yield-token: new-dy-act, balance-virtual: new-dy-vir})
        )
    )
)    
(define-public (reduce-position (expiry uint) (yield-token-trait <sft-trait>) (token-trait <ft-trait>) (pool-token-trait <sft-trait>) (percent uint))
    (begin
        (asserts! (<= percent ONE_8) ERR-PERCENT-GREATER-THAN-ONE)
        (let
            (
                (yield-token (contract-of yield-token-trait))
                (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
                (balance-token (get balance-token pool))
                (balance-yield-token (get balance-yield-token pool))
                (balance-virtual (get balance-virtual pool))                
                (total-supply (get total-supply pool))
                (total-shares (unwrap-panic (contract-call? pool-token-trait get-balance-fixed expiry tx-sender)))
                (shares (if (is-eq percent ONE_8) total-shares (mul-down total-shares percent)))                 
                (reduce-data (try! (get-position-given-burn expiry yield-token shares)))
                (dx (get dx reduce-data))
                (dy-act (get dy-act reduce-data))
                (dy-vir (get dy-vir reduce-data))
                (pool-updated (merge pool {
                    total-supply: (if (<= total-supply shares) u0 (- total-supply shares)),
                    balance-token: (if (<= balance-token dx) u0 (- balance-token dx)),
                    balance-yield-token: (if (<= balance-yield-token dy-act) u0 (- balance-yield-token dy-act)),
                    balance-virtual: (if (<= balance-virtual dy-vir) u0 (- balance-virtual dy-vir))
                    })
                )
                (sender tx-sender)
            )
            (asserts! (and (is-eq (get underlying-token pool) (contract-of token-trait)) (is-eq (get pool-token pool) (contract-of pool-token-trait))) ERR-INVALID-TOKEN)
            (and (> dx u0) (as-contract (try! (contract-call? .alex-vault transfer-ft token-trait dx sender))))
            (and (> dy-act u0) (as-contract (try! (contract-call? .alex-vault transfer-sft yield-token-trait expiry dy-act sender))))
            (map-set pools-data-map { yield-token: yield-token, expiry: expiry } pool-updated)
            (as-contract (try! (contract-call? pool-token-trait burn-fixed expiry shares sender)))
            (print { object: "pool", action: "pool-removed", data: pool-updated })
            (ok {dx: dx, dy: dy-act})
        )    
    )    
)
(define-public (swap-x-for-y (expiry uint) (yield-token-trait <sft-trait>) (token-trait <ft-trait>) (dx uint) (min-dy (optional uint)))
    (begin
        (asserts! (> dx u0) ERR-INVALID-LIQUIDITY)
        (let
            (
                (yield-token (contract-of yield-token-trait))
                (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
                (balance-token (get balance-token pool))
                (balance-yield-token (get balance-yield-token pool))
                (balance-virtual (get balance-virtual pool))
                (fee-yield (mul-up (try! (get-yield expiry yield-token)) (get fee-rate-token pool)))
                (fee (if (< (mul-down dx fee-yield) (get min-fee pool)) (get min-fee pool) (mul-down dx fee-yield)))
                (dx-net-fees (if (<= dx fee) u0 (- dx fee)))
                (fee-rebate (mul-down fee (get fee-rebate pool)))
                (dy (try! (get-y-given-x expiry yield-token dx-net-fees)))
                (pool-updated
                    (merge pool
                        {
                            balance-token: (+ balance-token dx-net-fees fee-rebate),
                            balance-yield-token: (if (<= balance-yield-token dy) u0 (- balance-yield-token dy)),
                            oracle-resilient: (if (get oracle-enabled pool) (try! (get-oracle-resilient expiry yield-token)) u0)
                        }
                    )
                )
                (sender tx-sender)                
            )
            (asserts! (is-eq (get underlying-token pool) (contract-of token-trait)) ERR-INVALID-TOKEN)
            (asserts! (<= dy (mul-down dx-net-fees (get-price-internal balance-token (+ balance-yield-token balance-virtual) (try! (get-t expiry (get listed pool)))))) ERR-INVALID-LIQUIDITY)
            (asserts! (< (default-to u0 min-dy) dy) ERR-EXCEEDS-MAX-SLIPPAGE)
            (and (> dx u0) (unwrap! (contract-call? token-trait transfer-fixed dx sender .alex-vault none) ERR-TRANSFER-FAILED))
            (and (> dy u0) (as-contract (try! (contract-call? .alex-vault transfer-sft yield-token-trait expiry dy sender))))
            (as-contract (try! (contract-call? .alex-reserve-pool add-to-balance (contract-of token-trait) (- fee fee-rebate))))
            (map-set pools-data-map { yield-token: yield-token, expiry: expiry } pool-updated)
            (print { object: "pool", action: "swap-x-for-y", data: pool-updated })
            (ok {dx: dx-net-fees, dy: dy})
        )
    )
)
(define-public (swap-y-for-x (expiry uint) (yield-token-trait <sft-trait>) (token-trait <ft-trait>) (dy uint) (min-dx (optional uint)))
    (begin
        (asserts! (> dy u0) ERR-INVALID-LIQUIDITY)
        (let
            (
                (yield-token (contract-of yield-token-trait))
                (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
                (balance-token (get balance-token pool))
                (balance-yield-token (get balance-yield-token pool))
                (balance-virtual (get balance-virtual pool))         
                (fee-yield (mul-up (try! (get-yield expiry yield-token)) (get fee-rate-yield-token pool)))
                (fee (if (< (mul-down dy fee-yield) (get min-fee pool)) (get min-fee pool) (mul-down dy fee-yield)))
                (dy-net-fees (if (<= dy fee) u0 (- dy fee)))
                (fee-rebate (mul-down fee (get fee-rebate pool)))
                (dx (try! (get-x-given-y expiry yield-token dy-net-fees)))
                (pool-updated
                    (merge pool
                        {
                            balance-token: (if (<= balance-token dx) u0 (- balance-token dx)),
                            balance-yield-token: (+ balance-yield-token dy-net-fees fee-rebate),
                            oracle-resilient: (if (get oracle-enabled pool) (try! (get-oracle-resilient expiry yield-token)) u0)
                        }
                    )
                )
                (sender tx-sender)
            )
            (asserts! (is-eq (get underlying-token pool) (contract-of token-trait)) ERR-INVALID-TOKEN)
            (asserts! (>= dy-net-fees (mul-down dx (get-price-internal balance-token (+ balance-yield-token balance-virtual) (try! (get-t expiry (get listed pool)))))) ERR-INVALID-LIQUIDITY)
            (asserts! (< (default-to u0 min-dx) dx) ERR-EXCEEDS-MAX-SLIPPAGE)
            (and (> dx u0) (as-contract (try! (contract-call? .alex-vault transfer-ft token-trait dx sender))))
            (and (> dy u0) (unwrap! (contract-call? yield-token-trait transfer-fixed expiry dy sender .alex-vault) ERR-TRANSFER-FAILED))
            (as-contract (try! (contract-call? .alex-reserve-pool add-to-balance yield-token (- fee fee-rebate))))
            (map-set pools-data-map { yield-token: yield-token, expiry: expiry } pool-updated)
            (print { object: "pool", action: "swap-y-for-x", data: pool-updated })
            (ok {dx: dx, dy: dy-net-fees})
        )
    )
)
(define-read-only (get-fee-rebate (expiry uint) (yield-token principal))
    (ok (get fee-rebate (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL)))
)
(define-public (set-fee-rebate (expiry uint) (yield-token principal) (fee-rebate uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )
        (asserts! (or (is-ok (check-is-owner)) (is-ok (check-is-approved))) ERR-NOT-AUTHORIZED)
        (map-set pools-data-map { yield-token: yield-token, expiry: expiry } (merge pool { fee-rebate: fee-rebate }))
        (ok true)
    )
)
(define-read-only (get-small-threshold (expiry uint) (yield-token principal))
    (ok (get small-threshold (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL)))
)
(define-public (set-small-threshold (expiry uint) (yield-token principal) (small-threshold uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )
        (asserts! (or (is-ok (check-is-owner)) (is-ok (check-is-approved))) ERR-NOT-AUTHORIZED)
        (map-set pools-data-map { yield-token: yield-token, expiry: expiry } (merge pool { small-threshold: small-threshold }))
        (ok true)
    )
)
(define-read-only (get-min-fee (expiry uint) (yield-token principal))
    (ok (get min-fee (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL)))
)
(define-public (set-min-fee (expiry uint) (yield-token principal) (min-fee uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )
        (asserts! (or (is-ok (check-is-owner)) (is-ok (check-is-approved))) ERR-NOT-AUTHORIZED)
        (map-set pools-data-map { yield-token: yield-token, expiry: expiry } (merge pool { min-fee: min-fee }))
        (ok true)
    )
)
(define-read-only (get-fee-rate-yield-token (expiry uint) (yield-token principal))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )
        (ok (get fee-rate-yield-token pool))
    )
)
(define-read-only (get-fee-rate-token (expiry uint) (yield-token principal))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )
        (ok (get fee-rate-token pool))
    )
)
(define-public (set-fee-rate-yield-token (expiry uint) (yield-token principal) (fee-rate-yield-token uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )
        (asserts! (or (is-eq tx-sender (get fee-to-address pool)) (is-ok (check-is-owner)) (is-ok (check-is-approved))) ERR-NOT-AUTHORIZED)
        (map-set pools-data-map { yield-token: yield-token, expiry: expiry } (merge pool { fee-rate-yield-token: fee-rate-yield-token }))
        (ok true)
    
    )
)
(define-public (set-fee-rate-token (expiry uint) (yield-token principal) (fee-rate-token uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )
        (asserts! (or (is-eq tx-sender (get fee-to-address pool)) (is-ok (check-is-owner)) (is-ok (check-is-approved))) ERR-NOT-AUTHORIZED)
        (map-set pools-data-map { yield-token: yield-token, expiry: expiry } (merge pool { fee-rate-token: fee-rate-token }))
        (ok true) 
    )
)
(define-read-only (get-fee-to-address (expiry uint) (yield-token principal))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
        )
        (ok (get fee-to-address pool))
    )
)
(define-public (set-fee-to-address (expiry uint) (yield-token principal) (fee-to-address principal))
    (let 
        (
            (pool (try! (get-pool-details expiry yield-token)))
        )
        (try! (check-is-owner))
        (map-set pools-data-map 
            { yield-token: yield-token, expiry: expiry }
            (merge pool { fee-to-address: fee-to-address })
        )
        (ok true)     
    )
)
(define-read-only (get-y-given-x (expiry uint) (yield-token principal) (dx uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
            (balance-x (get balance-token pool))
            (balance-y (+ (get balance-yield-token pool) (get balance-virtual pool)))
            (t (try! (get-t expiry (get listed pool))))
            (dy
              (if (> dx (get small-threshold pool))
                (try! (get-y-given-x-internal balance-x balance-y t dx))
                (mul-down dx (get-price-internal balance-x balance-y t))
              )
            )     
        )
        (asserts! (> (get balance-yield-token pool) dy) ERR-DY-BIGGER-THAN-AVAILABLE)
        (ok (if (< dy dx) dx dy))        
    )
)
(define-read-only (get-y-in-given-x-out (expiry uint) (yield-token principal) (dx uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))            
            (dy (try! (get-y-in-given-x-out-internal (get balance-token pool) (+ (get balance-yield-token pool) (get balance-virtual pool)) (try! (get-t expiry (get listed pool))) dx)))
        )
        (ok (if (< dy dx) dx dy))        
    )
)
(define-read-only (get-x-given-y (expiry uint) (yield-token principal) (dy uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
            (balance-x (get balance-token pool))
            (balance-y (+ (get balance-yield-token pool) (get balance-virtual pool)))
            (t (try! (get-t expiry (get listed pool))))
            (dx
              (if (> dy (get small-threshold pool))
                (try! (get-x-given-y-internal balance-x balance-y t dy))
                (div-down dy (get-price-internal balance-x balance-y t))
              )
            )
        )
        (ok (if (< dy dx) dy dx))        
    )
)
(define-read-only (get-x-in-given-y-out (expiry uint) (yield-token principal) (dy uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
            (dx (try! (get-x-in-given-y-out-internal (get balance-token pool) (+ (get balance-yield-token pool) (get balance-virtual pool)) (try! (get-t expiry (get listed pool))) dy)))
        )
        (asserts! (> (get balance-yield-token pool) dy) ERR-DY-BIGGER-THAN-AVAILABLE)
        (ok (if (< dy dx) dy dx))        
    )
)
(define-read-only (get-x-given-price (expiry uint) (yield-token principal) (price uint))
  (begin
    (asserts! (< price (try! (get-price expiry yield-token))) ERR-NO-LIQUIDITY) 
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
            (balance-x (get balance-token pool))
            (balance-y (+ (get balance-yield-token pool) (get balance-virtual pool)))
            (t (try! (get-t expiry (get listed pool))))
            (t-comp (if (<= ONE_8 t) u0 (- ONE_8 t)))
            (t-comp-num-uncapped (div-down ONE_8 t-comp))
            (t-comp-num (if (< t-comp-num-uncapped MILD_EXPONENT_BOUND) t-comp-num-uncapped MILD_EXPONENT_BOUND))            
            (numer (+ ONE_8 (pow-down (div-down balance-y balance-x) t-comp)))
            (denom (+ ONE_8 (pow-down price (div-down t-comp t))))
            (lead-term (pow-down (div-down numer denom) t-comp-num))            
        )
        (ok (if (<= lead-term ONE_8) u0 (mul-down balance-x (- lead-term ONE_8))))
    )
  )
)
(define-read-only (get-y-given-price (expiry uint) (yield-token principal) (price uint))
  (begin
    (asserts! (> price (try! (get-price expiry yield-token))) ERR-NO-LIQUIDITY) 
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
            (balance-x (get balance-token pool))
            (balance-y (+ (get balance-yield-token pool) (get balance-virtual pool)))
            (t (try! (get-t expiry (get listed pool))))
            (t-comp (if (<= ONE_8 t) u0 (- ONE_8 t)))
            (t-comp-num-uncapped (div-down ONE_8 t-comp))
            (t-comp-num (if (< t-comp-num-uncapped MILD_EXPONENT_BOUND) t-comp-num-uncapped MILD_EXPONENT_BOUND))            
            (numer (+ ONE_8 (pow-down (div-down balance-y balance-x) t-comp)))
            (denom (+ ONE_8 (pow-down price (div-down t-comp t))))
            (lead-term (mul-down balance-x (pow-down (div-down numer denom) t-comp-num)))            
        )
        (ok (if (<= balance-y lead-term) u0 (- balance-y lead-term)))
    )
  )
)
(define-read-only (get-x-given-yield (expiry uint) (yield-token principal) (yield uint))
  (get-x-given-price expiry yield-token (+ yield ONE_8))
)
(define-read-only (get-y-given-yield (expiry uint) (yield-token principal) (yield uint))
  (get-y-given-price expiry yield-token (+ yield ONE_8))
)
(define-read-only (get-token-given-position (expiry uint) (yield-token principal) (dx uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
            (balance-actual (get balance-yield-token pool))
            (balance-virtual (get balance-virtual pool))
            (balance-yield-token (+ balance-actual balance-virtual))
            (data (try! (get-token-given-position-internal (get balance-token pool) balance-yield-token (try! (get-t expiry (get listed pool))) (get total-supply pool) dx)))
            (token (get token data))
            (dy (get dy data))
            (dy-act (if (is-eq token dy) u0 (mul-down dy (if (is-eq balance-yield-token u0) u0 (div-down balance-actual balance-yield-token)))))
        )        
        (ok {token: token, dy-act: dy-act, dy-vir: (if (is-eq token dy) token (if (<= dy dy-act) u0 (- dy dy-act)))})
    )
)
(define-read-only (get-position-given-mint (expiry uint) (yield-token principal) (token uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
            (balance-actual (get balance-yield-token pool))
            (balance-virtual (get balance-virtual pool))
            (balance-yield-token (+ balance-actual balance-virtual))
            (balance-token (get balance-token pool))
            (data (try! (get-position-given-mint-internal balance-token balance-yield-token (try! (get-t expiry (get listed pool))) (get total-supply pool) token)))   
            (dx (get dx data))
            (dy (get dy data))
            (dy-act (mul-down dy (div-down balance-actual balance-yield-token)))
        )
        (ok {dx: dx, dy-act: dy-act, dy-vir: (if (<= dy dy-act) u0 (- dy dy-act))})
    )
)
(define-read-only (get-position-given-burn (expiry uint) (yield-token principal) (token uint))
    
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { yield-token: yield-token, expiry: expiry }) ERR-INVALID-POOL))
            (balance-actual (get balance-yield-token pool))
            (balance-virtual (get balance-virtual pool))
            (balance-yield-token (+ balance-actual balance-virtual))
            (balance-token (get balance-token pool))
            (data (try! (get-position-given-burn-internal balance-token balance-yield-token (try! (get-t expiry (get listed pool))) (get total-supply pool) token)))   
            (dx (get dx data))
            (dy (get dy data))
            (dy-act (mul-down dy (div-down balance-actual balance-yield-token)))
        )
        (ok {dx: dx, dy-act: dy-act, dy-vir: (if (<= dy dy-act) u0 (- dy dy-act))})
    )
)
(define-constant ERR-NO-LIQUIDITY (err u2002))
(define-constant ERR-MAX-IN-RATIO (err u4001))
(define-constant ERR-MAX-OUT-RATIO (err u4002))
(define-data-var MAX-IN-RATIO uint (* u5 (pow u10 u6))) ;; 5%
(define-data-var MAX-OUT-RATIO uint (* u5 (pow u10 u6))) ;; 5%
(define-read-only (get-max-in-ratio)
  (var-get MAX-IN-RATIO)
)
(define-public (set-max-in-ratio (new-max-in-ratio uint))
  (begin
    (try! (check-is-owner))
    (asserts! (> new-max-in-ratio u0) ERR-MAX-IN-RATIO)    
    (var-set MAX-IN-RATIO new-max-in-ratio)
    (ok true)
  )
)
(define-read-only (get-max-out-ratio)
  (var-get MAX-OUT-RATIO)
)
(define-public (set-max-out-ratio (new-max-out-ratio uint))
  (begin
    (try! (check-is-owner))
    (asserts! (> new-max-out-ratio u0) ERR-MAX-OUT-RATIO)    
    (var-set MAX-OUT-RATIO new-max-out-ratio)
    (ok true)
  )
)
(define-private (get-y-given-x-internal (balance-x uint) (balance-y uint) (t uint) (dx uint))
  (begin
    (asserts! (>= balance-x dx) ERR-INVALID-BALANCE)
    (asserts! (< dx (mul-down balance-x (var-get MAX-IN-RATIO))) ERR-MAX-IN-RATIO)     
    (let 
      (
        (t-comp (if (<= ONE_8 t) u0 (- ONE_8 t)))
        (t-comp-num-uncapped (div-up ONE_8 t-comp))
        (t-comp-num (if (< t-comp-num-uncapped MILD_EXPONENT_BOUND) t-comp-num-uncapped MILD_EXPONENT_BOUND))            
        (x-pow (pow-up balance-x t-comp))
        (y-pow (pow-up balance-y t-comp))
        (x-dx-pow (pow-down (+ balance-x dx) t-comp))
        (add-term (+ x-pow y-pow))
        (term (if (<= add-term x-dx-pow) u0 (- add-term x-dx-pow)))
        (final-term (pow-up term t-comp-num))
        (dy (if (<= balance-y final-term) u0 (- balance-y final-term)))
      )
      (asserts! (< dy (mul-down balance-y (var-get MAX-OUT-RATIO))) ERR-MAX-OUT-RATIO)
      (ok dy)
    )  
  )
)
(define-private (get-x-given-y-internal (balance-x uint) (balance-y uint) (t uint) (dy uint))
  (begin
    (asserts! (>= balance-y dy) ERR-INVALID-BALANCE)
    (asserts! (< dy (mul-down balance-y (var-get MAX-IN-RATIO))) ERR-MAX-IN-RATIO)
    (let 
      (          
        (t-comp (if (<= ONE_8 t) u0 (- ONE_8 t)))
        (t-comp-num-uncapped (div-up ONE_8 t-comp))
        (t-comp-num (if (< t-comp-num-uncapped MILD_EXPONENT_BOUND) t-comp-num-uncapped MILD_EXPONENT_BOUND))            
        (x-pow (pow-up balance-x t-comp))
        (y-pow (pow-up balance-y t-comp))
        (y-dy-pow (pow-down (+ balance-y dy) t-comp))
        (add-term (+ x-pow y-pow))
        (term (if (<= add-term y-dy-pow) u0 (- add-term y-dy-pow)))
        (final-term (pow-up term t-comp-num))
        (dx (if (<= balance-x final-term) u0 (- balance-x final-term)))
      )
      (asserts! (< dx (mul-down balance-x (var-get MAX-OUT-RATIO))) ERR-MAX-OUT-RATIO)
      (ok dx)
    )  
  )
)
(define-private (get-y-in-given-x-out-internal (balance-x uint) (balance-y uint) (t uint) (dx uint))
  (begin
    (asserts! (>= balance-x dx) ERR-INVALID-BALANCE)
    (asserts! (< dx (mul-down balance-x (var-get MAX-OUT-RATIO))) ERR-MAX-OUT-RATIO)     
    (let 
      (
        (t-comp (if (<= ONE_8 t) u0 (- ONE_8 t)))
        (t-comp-num-uncapped (div-down ONE_8 t-comp))
        (t-comp-num (if (< t-comp-num-uncapped MILD_EXPONENT_BOUND) t-comp-num-uncapped MILD_EXPONENT_BOUND))            
        (x-pow (pow-down balance-x t-comp))
        (y-pow (pow-down balance-y t-comp))
        (x-dx-pow (pow-up (if (<= balance-x dx) u0 (- balance-x dx)) t-comp))
        (add-term (+ x-pow y-pow))
        (term (if (<= add-term x-dx-pow) u0 (- add-term x-dx-pow)))
        (final-term (pow-down term t-comp-num))
        (dy (if (<= final-term balance-y) u0 (- final-term balance-y)))
      )
      (asserts! (< dy (mul-down balance-y (var-get MAX-IN-RATIO))) ERR-MAX-IN-RATIO)
      (ok dy)
    )  
  )
)
(define-private (get-x-in-given-y-out-internal (balance-x uint) (balance-y uint) (t uint) (dy uint))
  (begin
    (asserts! (>= balance-y dy) ERR-INVALID-BALANCE)
    (asserts! (< dy (mul-down balance-y (var-get MAX-OUT-RATIO))) ERR-MAX-OUT-RATIO)
    (let 
      (          
        (t-comp (if (<= ONE_8 t) u0 (- ONE_8 t)))
        (t-comp-num-uncapped (div-down ONE_8 t-comp))
        (t-comp-num (if (< t-comp-num-uncapped MILD_EXPONENT_BOUND) t-comp-num-uncapped MILD_EXPONENT_BOUND))            
        (x-pow (pow-down balance-x t-comp))
        (y-pow (pow-down balance-y t-comp))
        (y-dy-pow (pow-up (if (<= balance-y dy) u0 (- balance-y dy)) t-comp))
        (add-term (+ x-pow y-pow))
        (term (if (<= add-term y-dy-pow) u0 (- add-term y-dy-pow)))
        (final-term (pow-down term t-comp-num))
        (dx (if (<= final-term balance-x) u0 (- final-term balance-x)))
      )
      (asserts! (< dx (mul-down balance-x (var-get MAX-IN-RATIO))) ERR-MAX-IN-RATIO)
      (ok dx)
    )  
  )
)
(define-private (get-token-given-position-internal (balance-x uint) (balance-y uint) (t uint) (total-supply uint) (dx uint))
  (begin
    (asserts! (> dx u0) ERR-NO-LIQUIDITY)
    (ok
      (if (or (is-eq total-supply u0) (is-eq balance-x balance-y)) ;; either at inception or if yield == 0
        {token: dx, dy: dx}
        (let
          (
            ;; if total-supply > zero, we calculate dy proportional to dx / balance-x
            (dy (mul-down balance-y (div-down dx balance-x)))
            (token (mul-down total-supply (div-down dx balance-x)))
          )
          {token: token, dy: dy}
        )
      )            
    )
  )
)
(define-private (get-position-given-mint-internal (balance-x uint) (balance-y uint) (t uint) (total-supply uint) (token uint))
  (begin
    (asserts! (> total-supply u0) ERR-NO-LIQUIDITY)
    (let
      (
        (token-div-supply (div-down token total-supply))
        (dx (mul-down balance-x token-div-supply))
        (dy (mul-down balance-y token-div-supply))
      )                
      (ok {dx: dx, dy: dy})
    )      
  )
)
(define-private (get-position-given-burn-internal (balance-x uint) (balance-y uint) (t uint) (total-supply uint) (token uint))
    (get-position-given-mint-internal balance-x balance-y t total-supply token)
)
(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_POW_RELATIVE_ERROR u4) 
(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)
(define-private (mul-up (a uint) (b uint))
    (let
        (
            (product (* a b))
       )
        (if (is-eq product u0)
            u0
            (+ u1 (/ (- product u1) ONE_8))
       )
   )
)
(define-private (div-down (a uint) (b uint))
    (if (is-eq a u0)
        u0
        (/ (* a ONE_8) b)
   )
)
(define-private (div-up (a uint) (b uint))
    (if (is-eq a u0)
        u0
        (+ u1 (/ (- (* a ONE_8) u1) b))
    )
)
(define-private (pow-down (a uint) (b uint))    
    (let
        (
            (raw (unwrap-panic (pow-fixed a b)))
            (max-error (+ u1 (mul-up raw MAX_POW_RELATIVE_ERROR)))
        )
        (if (< raw max-error)
            u0
            (- raw max-error)
        )
    )
)
(define-private (pow-up (a uint) (b uint))
    (let
        (
            (raw (unwrap-panic (pow-fixed a b)))
            (max-error (+ u1 (mul-up raw MAX_POW_RELATIVE_ERROR)))
        )
        (+ raw max-error)
    )
)
(define-constant UNSIGNED_ONE_8 (pow 10 8))
(define-constant MAX_NATURAL_EXPONENT (* 69 UNSIGNED_ONE_8))
(define-constant MIN_NATURAL_EXPONENT (* -18 UNSIGNED_ONE_8))
(define-constant MILD_EXPONENT_BOUND (/ (pow u2 u126) (to-uint UNSIGNED_ONE_8)))
(define-constant x_a_list_no_deci (list {x_pre: 6400000000, a_pre: 62351490808116168829, use_deci: false} ))
(define-constant x_a_list (list 
{x_pre: 3200000000, a_pre: 78962960182680695161, use_deci: true} ;; x2 = 2^5, a2 = e^(x2)
{x_pre: 1600000000, a_pre: 888611052050787, use_deci: true} ;; x3 = 2^4, a3 = e^(x3)
{x_pre: 800000000, a_pre: 298095798704, use_deci: true} ;; x4 = 2^3, a4 = e^(x4)
{x_pre: 400000000, a_pre: 5459815003, use_deci: true} ;; x5 = 2^2, a5 = e^(x5)
{x_pre: 200000000, a_pre: 738905610, use_deci: true} ;; x6 = 2^1, a6 = e^(x6)
{x_pre: 100000000, a_pre: 271828183, use_deci: true} ;; x7 = 2^0, a7 = e^(x7)
{x_pre: 50000000, a_pre: 164872127, use_deci: true} ;; x8 = 2^-1, a8 = e^(x8)
{x_pre: 25000000, a_pre: 128402542, use_deci: true} ;; x9 = 2^-2, a9 = e^(x9)
{x_pre: 12500000, a_pre: 113314845, use_deci: true} ;; x10 = 2^-3, a10 = e^(x10)
{x_pre: 6250000, a_pre: 106449446, use_deci: true} ;; x11 = 2^-4, a11 = e^x(11)
))
(define-constant ERR-X-OUT-OF-BOUNDS (err u5009))
(define-constant ERR-Y-OUT-OF-BOUNDS (err u5010))
(define-constant ERR-PRODUCT-OUT-OF-BOUNDS (err u5011))
(define-constant ERR-INVALID-EXPONENT (err u5012))
(define-constant ERR-OUT-OF-BOUNDS (err u5013))
(define-private (ln-priv (a int))
  (let
    (
      (a_sum_no_deci (fold accumulate_division x_a_list_no_deci {a: a, sum: 0}))
      (a_sum (fold accumulate_division x_a_list {a: (get a a_sum_no_deci), sum: (get sum a_sum_no_deci)}))
      (out_a (get a a_sum))
      (out_sum (get sum a_sum))
      (z (/ (* (- out_a UNSIGNED_ONE_8) UNSIGNED_ONE_8) (+ out_a UNSIGNED_ONE_8)))
      (z_squared (/ (* z z) UNSIGNED_ONE_8))
      (div_list (list 3 5 7 9 11))
      (num_sum_zsq (fold rolling_sum_div div_list {num: z, seriesSum: z, z_squared: z_squared}))
      (seriesSum (get seriesSum num_sum_zsq))
    )
    (+ out_sum (* seriesSum 2))
  )
)
(define-private (accumulate_division (x_a_pre (tuple (x_pre int) (a_pre int) (use_deci bool))) (rolling_a_sum (tuple (a int) (sum int))))
  (let
    (
      (a_pre (get a_pre x_a_pre))
      (x_pre (get x_pre x_a_pre))
      (use_deci (get use_deci x_a_pre))
      (rolling_a (get a rolling_a_sum))
      (rolling_sum (get sum rolling_a_sum))
   )
    (if (>= rolling_a (if use_deci a_pre (* a_pre UNSIGNED_ONE_8)))
      {a: (/ (* rolling_a (if use_deci UNSIGNED_ONE_8 1)) a_pre), sum: (+ rolling_sum x_pre)}
      {a: rolling_a, sum: rolling_sum}
   )
 )
)
(define-private (rolling_sum_div (n int) (rolling (tuple (num int) (seriesSum int) (z_squared int))))
  (let
    (
      (rolling_num (get num rolling))
      (rolling_sum (get seriesSum rolling))
      (z_squared (get z_squared rolling))
      (next_num (/ (* rolling_num z_squared) UNSIGNED_ONE_8))
      (next_sum (+ rolling_sum (/ next_num n)))
   )
    {num: next_num, seriesSum: next_sum, z_squared: z_squared}
 )
)
(define-private (pow-priv (x uint) (y uint))
  (let
    (
      (x-int (to-int x))
      (y-int (to-int y))
      (lnx (ln-priv x-int))
      (logx-times-y (/ (* lnx y-int) UNSIGNED_ONE_8))
    )
    (asserts! (and (<= MIN_NATURAL_EXPONENT logx-times-y) (<= logx-times-y MAX_NATURAL_EXPONENT)) ERR-PRODUCT-OUT-OF-BOUNDS)
    (ok (to-uint (try! (exp-fixed logx-times-y))))
  )
)
(define-private (exp-pos (x int))
  (begin
    (asserts! (and (<= 0 x) (<= x MAX_NATURAL_EXPONENT)) ERR-INVALID-EXPONENT)
    (let
      (
        (x_product_no_deci (fold accumulate_product x_a_list_no_deci {x: x, product: 1}))
        (x_adj (get x x_product_no_deci))
        (firstAN (get product x_product_no_deci))
        (x_product (fold accumulate_product x_a_list {x: x_adj, product: UNSIGNED_ONE_8}))
        (product_out (get product x_product))
        (x_out (get x x_product))
        (seriesSum (+ UNSIGNED_ONE_8 x_out))
        (div_list (list 2 3 4 5 6 7 8 9 10 11 12))
        (term_sum_x (fold rolling_div_sum div_list {term: x_out, seriesSum: seriesSum, x: x_out}))
        (sum (get seriesSum term_sum_x))
     )
      (ok (* (/ (* product_out sum) UNSIGNED_ONE_8) firstAN))
   )
 )
)
(define-private (accumulate_product (x_a_pre (tuple (x_pre int) (a_pre int) (use_deci bool))) (rolling_x_p (tuple (x int) (product int))))
  (let
    (
      (x_pre (get x_pre x_a_pre))
      (a_pre (get a_pre x_a_pre))
      (use_deci (get use_deci x_a_pre))
      (rolling_x (get x rolling_x_p))
      (rolling_product (get product rolling_x_p))
   )
    (if (>= rolling_x x_pre)
      {x: (- rolling_x x_pre), product: (/ (* rolling_product a_pre) (if use_deci UNSIGNED_ONE_8 1))}
      {x: rolling_x, product: rolling_product}
   )
 )
)
(define-private (rolling_div_sum (n int) (rolling (tuple (term int) (seriesSum int) (x int))))
  (let
    (
      (rolling_term (get term rolling))
      (rolling_sum (get seriesSum rolling))
      (x (get x rolling))
      (next_term (/ (/ (* rolling_term x) UNSIGNED_ONE_8) n))
      (next_sum (+ rolling_sum next_term))
   )
    {term: next_term, seriesSum: next_sum, x: x}
 )
)
(define-private (pow-fixed (x uint) (y uint))
  (begin
    (asserts! (< x (pow u2 u127)) ERR-X-OUT-OF-BOUNDS)
    (asserts! (< y MILD_EXPONENT_BOUND) ERR-Y-OUT-OF-BOUNDS)
    (if (is-eq y u0) 
      (ok (to-uint UNSIGNED_ONE_8))
      (if (is-eq x u0) 
        (ok u0)
        (pow-priv x y)
      )
    )
  )
)
(define-private (exp-fixed (x int))
  (begin
    (asserts! (and (<= MIN_NATURAL_EXPONENT x) (<= x MAX_NATURAL_EXPONENT)) ERR-INVALID-EXPONENT)
    (if (< x 0)
      (ok (/ (* UNSIGNED_ONE_8 UNSIGNED_ONE_8) (try! (exp-pos (* -1 x)))))
      (exp-pos x)
    )
  )
)
(define-private (log-fixed (arg int) (base int))
  (let
    (
      (logBase (* (ln-priv base) UNSIGNED_ONE_8))
      (logArg (* (ln-priv arg) UNSIGNED_ONE_8))
   )
    (ok (/ (* logArg UNSIGNED_ONE_8) logBase))
 )
)
(define-private (ln-fixed (a int))
  (begin
    (asserts! (> a 0) ERR-OUT-OF-BOUNDS)
    (if (< a UNSIGNED_ONE_8)
      (ok (- 0 (ln-priv (/ (* UNSIGNED_ONE_8 UNSIGNED_ONE_8) a))))
      (ok (ln-priv a))
   )
 )
)
(set-contract-owner .executor-dao)
(map-set approved-contracts .collateral-rebalancing-pool true)