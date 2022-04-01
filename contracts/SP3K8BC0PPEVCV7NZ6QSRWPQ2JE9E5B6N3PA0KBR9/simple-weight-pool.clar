(impl-trait .trait-ownable.ownable-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)

;; simple-weight-pool
;; simple-weight-pool implements 50:50 fixed-weight-pool-v1-01 (i.e. uniswap)
;; simple-weight-pool is anchored to STX (and routes other tokens)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-POOL (err u2001))
(define-constant ERR-INVALID-LIQUIDITY (err u2003))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-POOL-ALREADY-EXISTS (err u2000))
(define-constant ERR-TOO-MANY-POOLS (err u2004))
(define-constant ERR-PERCENT-GREATER-THAN-ONE (err u5000))
(define-constant ERR-EXCEEDS-MAX-SLIPPAGE (err u2020))
(define-constant ERR-ORACLE-NOT-ENABLED (err u7002))
(define-constant ERR-ORACLE-ALREADY-ENABLED (err u7003))
(define-constant ERR-ORACLE-AVERAGE-BIGGER-THAN-ONE (err u7004))
(define-constant ERR-INVALID-TOKEN (err u2026))

(define-data-var contract-owner principal tx-sender)

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

;; data maps and vars
(define-map pools-map
  { pool-id: uint }
  {
    token-x: principal,
    token-y: principal
  }
)

(define-map pools-data-map
  {
    token-x: principal,
    token-y: principal
  }
  {
    total-supply: uint,
    balance-x: uint,
    balance-y: uint,
    fee-to-address: principal,
    pool-token: principal,
    fee-rate-x: uint,
    fee-rate-y: uint,
    fee-rebate: uint,
    oracle-enabled: bool,
    oracle-average: uint,
    oracle-resilient: uint,
    start-block: uint,
    end-block: uint
  }
)

(define-data-var pool-count uint u0)
(define-data-var pools-list (list 500 uint) (list))

;; @desc get-pool-count
;; @returns uint
(define-read-only (get-pool-count)
    (var-get pool-count)
)

;; @desc get-pool-contracts
;; @param pool-id; pool-id
;; @returns (response (tutple) uint)
(define-read-only (get-pool-contracts (pool-id uint))
    (ok (unwrap! (map-get? pools-map {pool-id: pool-id}) ERR-INVALID-POOL))
)

;; @desc get-pools
;; @returns map of get-pool-contracts
(define-read-only (get-pools)
    (ok (map get-pool-contracts (var-get pools-list)))
)

;; immunefi-4384
(define-read-only (get-pools-by-ids (pool-ids (list 26 uint)))
  (ok (map get-pool-contracts pool-ids))
)

;; @desc get-pool-details
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @returns (response (tuple) uint)
(define-read-only (get-pool-details (token-x principal) (token-y principal))
    (ok (unwrap! (get-pool-exists token-x token-y) ERR-INVALID-POOL))
)

;; @desc get-pool-exists
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @returns (optional (tuple))
(define-read-only (get-pool-exists (token-x principal) (token-y principal))
    (map-get? pools-data-map { token-x: token-x, token-y: token-y }) 
)

;; @desc get-balances ({balance-x, balance-y})
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @returns (response (tuple uint uint) uint)
(define-read-only (get-balances (token-x principal) (token-y principal))
  (let
    (
      (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
    )
    (ok {balance-x: (get balance-x pool), balance-y: (get balance-y pool)})
  )
)

(define-read-only (get-start-block (token-x principal) (token-y principal))
    (ok (get start-block (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL)))
)

(define-public (set-start-block (token-x principal) (token-y principal) (new-start-block uint))
    (let
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (try! (check-is-owner))
        (ok
            (map-set 
                pools-data-map 
                { token-x: token-x, token-y: token-y } 
                (merge pool {start-block: new-start-block})
            )
        )    
    )
)

(define-read-only (get-end-block (token-x principal) (token-y principal))
    (ok (get end-block (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL)))
)

(define-public (set-end-block (token-x principal) (token-y principal) (new-end-block uint))
    (let
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (try! (check-is-owner))
        (ok
            (map-set 
                pools-data-map 
                { token-x: token-x, token-y: token-y } 
                (merge pool {end-block: new-end-block})
            )
        )    
    )
)

(define-private (check-pool-status (token-x principal) (token-y principal))
    (let
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (ok (asserts! (and (>= block-height (get start-block pool)) (<= block-height (get end-block pool))) ERR-NOT-AUTHORIZED))
    )
)

;; @desc get-oracle-enabled
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @returns (response bool uint)
(define-read-only (get-oracle-enabled (token-x principal) (token-y principal))
    (ok 
        (get 
            oracle-enabled 
            (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y}) ERR-INVALID-POOL)
        )
    )
)

;; @desc set-oracle-enabled
;; @desc oracle can only be enabled
;; @restricted contract-owner
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @returns (response bool uint)
(define-public (set-oracle-enabled (token-x principal) (token-y principal))
    (let
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (try! (check-is-owner))
        (asserts! (not (get oracle-enabled pool)) ERR-ORACLE-ALREADY-ENABLED)
        (ok
            (map-set 
                pools-data-map 
                { token-x: token-x, token-y: token-y } 
                (merge pool {oracle-enabled: true})
            )
        )
    )    
)

;; @desc get-oracle-average
;; @desc returns the moving average used to determine oracle price
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @returns (response uint uint)
(define-read-only (get-oracle-average (token-x principal) (token-y principal))
    (ok 
        (get 
            oracle-average 
            (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL)
        )
    )
)

;; @desc set-oracle-average
;; @restricted contract-owner
;; @param token-x; token-x principal
;; @param token-y; token-y principal

;; @returns (response bool uint)
(define-public (set-oracle-average (token-x principal) (token-y principal) (new-oracle-average uint))
    (let
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (try! (check-is-owner))
        (asserts! (get oracle-enabled pool) ERR-ORACLE-NOT-ENABLED)
        (asserts! (< new-oracle-average ONE_8) ERR-ORACLE-AVERAGE-BIGGER-THAN-ONE)
        (ok 
            (map-set 
                pools-data-map 
                { token-x: token-x, token-y: token-y } 
                (merge pool 
                    {
                    oracle-average: new-oracle-average,
                    oracle-resilient: (try! (get-oracle-instant token-x token-y))
                    }
                )
            )
        )
    )    
)

;; @desc get-oracle-resilient
;; @desc price-oracle that is less up to date but more resilient to manipulation
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @returns (response uint uint)
(define-read-only (get-oracle-resilient (token-x principal) (token-y principal))
    (if (or (is-eq token-x .token-wstx) (is-eq token-y .token-wstx))
        (get-oracle-resilient-internal token-x token-y)
        (ok
            (div-down                
                (try! (get-oracle-resilient-internal .token-wstx token-y))
                (try! (get-oracle-resilient-internal .token-wstx token-x))                
            )
        )
    )
)

(define-private (get-oracle-resilient-internal (token-x principal) (token-y principal))
    (let
        (
            (pool 
                (if (is-some (get-pool-exists token-x token-y))
                    (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL)
                    (unwrap! (map-get? pools-data-map { token-x: token-y, token-y: token-x }) ERR-INVALID-POOL)
                )
            )
        )
        (asserts! (get oracle-enabled pool) ERR-ORACLE-NOT-ENABLED)
        (ok (+ (mul-down (- ONE_8 (get oracle-average pool)) (try! (get-oracle-instant-internal token-x token-y))) 
            (mul-down (get oracle-average pool) (get oracle-resilient pool)))
        )           
    )
)

;; @desc get-oracle-instant
;; price of token-x in terms of token-y
;; @desc price-oracle that is more up to date but less resilient to manipulation
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @returns (response uint uint)
(define-read-only (get-oracle-instant (token-x principal) (token-y principal))
    (if (or (is-eq token-x .token-wstx) (is-eq token-y .token-wstx))
        (get-oracle-instant-internal token-x token-y)
        (ok
            (div-down                
                (try! (get-oracle-instant-internal .token-wstx token-y))
                (try! (get-oracle-instant-internal .token-wstx token-x))                
            )
        )
    )
)

(define-private (get-oracle-instant-internal (token-x principal) (token-y principal))
    (begin                
        (if (is-some (get-pool-exists token-x token-y))
            (let
                (
                    (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
                )
                (asserts! (get oracle-enabled pool) ERR-ORACLE-NOT-ENABLED)
                (ok (div-down (get balance-y pool) (get balance-x pool)))
            )
            (let
                (
                    (pool (unwrap! (map-get? pools-data-map { token-x: token-y, token-y: token-x }) ERR-INVALID-POOL))
                )
                (asserts! (get oracle-enabled pool) ERR-ORACLE-NOT-ENABLED)
                (ok (div-down (get balance-x pool) (get balance-y pool)))
            )
        )
    )
)

(define-private (add-approved-token-to-vault (token principal))
    (contract-call? .alex-vault add-approved-token token)
)

;; @desc check-err
;; @params result 
;; @params prior
;; @returns (response bool uint)
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior 
        ok-value result
        err-value (err err-value)
    )
)

;; @desc create-pool
;; @restricted contract-owner
;; @param token-x-trait; token-x
;; @param token-y-trait; token-y
;; @param pool-token; pool token representing ownership of the pool
;; @param multisig-vote; DAO used by pool token holers
;; @param dx; amount of token-x added
;; @param dy; amount of token-y added
;; @returns (response bool uint)
(define-public (create-pool (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (pool-token-trait <ft-trait>) (multisig-vote principal) (dx uint) (dy uint)) 
    (let
        (
            (token-x (contract-of token-x-trait))
            (token-y (contract-of token-y-trait))
            (pool-id (+ (var-get pool-count) u1))
            (pool-data {
                total-supply: u0,
                balance-x: u0,
                balance-y: u0,
                fee-to-address: multisig-vote,
                pool-token: (contract-of pool-token-trait),
                fee-rate-x: u0,
                fee-rate-y: u0,
                fee-rebate: u0,
                oracle-enabled: false,
                oracle-average: u0,
                oracle-resilient: u0,
                start-block: u340282366920938463463374607431768211455,
                end-block: u340282366920938463463374607431768211455
            })
        )

        (try! (check-is-owner))        

        (asserts!
            (and
                (is-none (map-get? pools-data-map { token-x: token-x, token-y: token-y }))
                (is-none (map-get? pools-data-map { token-x: token-y, token-y: token-x }))
            )
            ERR-POOL-ALREADY-EXISTS
        )             

        (map-set pools-map { pool-id: pool-id } { token-x: token-x, token-y: token-y })
        (map-set pools-data-map { token-x: token-x, token-y: token-y } pool-data)
        
        (var-set pools-list (unwrap! (as-max-len? (append (var-get pools-list) pool-id) u500) ERR-TOO-MANY-POOLS))
        (var-set pool-count pool-id)
        
        (try! (fold check-err (map add-approved-token-to-vault (list token-x token-y (contract-of pool-token-trait))) (ok true)))

        (try! (add-to-position token-x-trait token-y-trait pool-token-trait dx (some dy)))
        (print { object: "pool", action: "created", data: pool-data })
        (ok true)
    )
)

;; @desc add-to-position
;; @desc returns units of pool tokens minted, dx and dy added
;; @param token-x-trait; token-x
;; @param token-y-trait; token-y
;; @param pool-token; pool token representing ownership of the pool
;; @param dx; amount of token-x added
;; @param dy; amount of token-y added
;; @returns (response (tuple uint uint uint) uint)
(define-public (add-to-position (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (pool-token-trait <ft-trait>) (dx uint) (max-dy (optional uint)))
    (begin
        (asserts! (> dx u0) ERR-INVALID-LIQUIDITY)
        (let
            (
                (token-x (contract-of token-x-trait))
                (token-y (contract-of token-y-trait))
                (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
                (balance-x (get balance-x pool))
                (balance-y (get balance-y pool))
                (total-supply (get total-supply pool))
                (add-data (try! (get-token-given-position token-x token-y dx max-dy)))
                (new-supply (get token add-data))
                (dy (get dy add-data))
                (pool-updated (merge pool {
                    total-supply: (+ new-supply total-supply),
                    balance-x: (+ balance-x dx),
                    balance-y: (+ balance-y dy)
                }))
                (sender tx-sender)
            )
            (asserts! (> dy u0) ERR-INVALID-LIQUIDITY)
            ;; CR-01
            (asserts! (>= (default-to u340282366920938463463374607431768211455 max-dy) dy) ERR-EXCEEDS-MAX-SLIPPAGE)
            (asserts! (is-eq (get pool-token pool) (contract-of pool-token-trait)) ERR-INVALID-TOKEN)

            (unwrap! (contract-call? token-x-trait transfer-fixed dx sender .alex-vault none) ERR-TRANSFER-FAILED)
            (unwrap! (contract-call? token-y-trait transfer-fixed dy sender .alex-vault none) ERR-TRANSFER-FAILED)

            ;; mint pool token and send to tx-sender
            (map-set pools-data-map { token-x: token-x, token-y: token-y } pool-updated)
            (as-contract (try! (contract-call? pool-token-trait mint-fixed new-supply sender)))
            
            (print { object: "pool", action: "liquidity-added", data: pool-updated })
            (ok {supply: new-supply, dx: dx, dy: dy})
        )
    )
)

;; @desc reduce-position
;; @desc returns dx and dy due to the position
;; @param token-x-trait; token-x
;; @param token-y-trait; token-y
;; @param pool-token; pool token representing ownership of the pool
;; @param percent; percentage of pool token held to reduce
;; @returns (response (tuple uint uint) uint)
(define-public (reduce-position (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (pool-token-trait <ft-trait>) (percent uint))
    (begin
        (asserts! (<= percent ONE_8) ERR-PERCENT-GREATER-THAN-ONE)
        (let
            (
                (token-x (contract-of token-x-trait))
                (token-y (contract-of token-y-trait))
                (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
                (balance-x (get balance-x pool))
                (balance-y (get balance-y pool))
                (total-shares (unwrap-panic (contract-call? pool-token-trait get-balance-fixed tx-sender)))
                (shares (if (is-eq percent ONE_8) total-shares (mul-down total-shares percent)))
                (total-supply (get total-supply pool))
                (reduce-data (try! (get-position-given-burn token-x token-y shares)))
                (dx (get dx reduce-data))
                (dy (get dy reduce-data))
                (pool-updated (merge pool {
                    total-supply: (if (<= total-supply shares) u0 (- total-supply shares)),
                    balance-x: (if (<= balance-x dx) u0 (- balance-x dx)),
                    balance-y: (if (<= balance-y dy) u0 (- balance-y dy))
                    })
                )
                (sender tx-sender)
            )

            (asserts! (is-eq (get pool-token pool) (contract-of pool-token-trait)) ERR-INVALID-TOKEN)            

            (as-contract (try! (contract-call? .alex-vault transfer-ft-two token-x-trait dx token-y-trait dy sender)))

            (map-set pools-data-map { token-x: token-x, token-y: token-y } pool-updated)

            (as-contract (try! (contract-call? pool-token-trait burn-fixed shares sender)))

            (print { object: "pool", action: "liquidity-removed", data: pool-updated })
            (ok {dx: dx, dy: dy})
        )
    )
)

;; @desc swap-wstx-for-y
;; @params token-y-trait; ft-trait
;; @params dx 
;; @params min-dy 
;; @returns (ok (tuple))
(define-public (swap-wstx-for-y (token-y-trait <ft-trait>) (dx uint) (min-dy (optional uint)))    
    (begin
        (try! (check-pool-status .token-wstx (contract-of token-y-trait)))
        (asserts! (> dx u0) ERR-INVALID-LIQUIDITY)      
        (let
            (
                (token-y (contract-of token-y-trait))
                (pool (unwrap! (map-get? pools-data-map { token-x: .token-wstx, token-y: token-y }) ERR-INVALID-POOL))
                (balance-x (get balance-x pool))
                (balance-y (get balance-y pool))

                ;; fee = dx * fee-rate-x
                (fee (mul-up dx (get fee-rate-x pool)))
                (dx-net-fees (if (<= dx fee) u0 (- dx fee)))
                (fee-rebate (mul-down fee (get fee-rebate pool)))
    
                (dy (try! (get-y-given-wstx token-y dx-net-fees)))                

                (pool-updated
                    (merge pool
                        {
                        balance-x: (+ balance-x dx-net-fees fee-rebate),
                        balance-y: (if (<= balance-y dy) u0 (- balance-y dy)),
                        oracle-resilient:   (if (get oracle-enabled pool) 
                                                (try! (get-oracle-resilient .token-wstx token-y))
                                                u0
                                            )
                        }
                    )
                )
                (sender tx-sender)             
            )

            ;; a / b <= c / d == ad <= bc for b, d >=0
            (asserts! (<= (mul-down dy balance-x) (mul-down dx-net-fees balance-y)) ERR-INVALID-LIQUIDITY)
            (asserts! (<= (default-to u0 min-dy) dy) ERR-EXCEEDS-MAX-SLIPPAGE)
        
            (unwrap! (contract-call? .token-wstx transfer-fixed dx sender .alex-vault none) ERR-TRANSFER-FAILED)
            (and (> dy u0) (as-contract (try! (contract-call? .alex-vault transfer-ft token-y-trait dy sender))))
            (as-contract (try! (contract-call? .alex-reserve-pool add-to-balance .token-wstx (- fee fee-rebate))))

            ;; post setting
            (map-set pools-data-map { token-x: .token-wstx, token-y: token-y } pool-updated)
            (print { object: "pool", action: "swap-x-for-y", data: pool-updated })
            (ok {dx: dx-net-fees, dy: dy})
        )
    )
)

;; @desc swap-y-for-wstx 
;; @params token-y-trait
;; @params dy
;; @params dx
;; @returns (response tuple)
(define-public (swap-y-for-wstx (token-y-trait <ft-trait>) (dy uint) (min-dx (optional uint)))
    (begin
        (try! (check-pool-status .token-wstx (contract-of token-y-trait)))
        (asserts! (> dy u0) ERR-INVALID-LIQUIDITY)
        (let
            (
                (token-y (contract-of token-y-trait))
                (pool (unwrap! (map-get? pools-data-map { token-x: .token-wstx, token-y: token-y }) ERR-INVALID-POOL))
                (balance-x (get balance-x pool))
                (balance-y (get balance-y pool))

                ;; fee = dy * fee-rate-y
                (fee (mul-up dy (get fee-rate-y pool)))
                (dy-net-fees (if (<= dy fee) u0 (- dy fee)))
                (fee-rebate (mul-down fee (get fee-rebate pool)))

                (dx (try! (get-wstx-given-y token-y dy-net-fees)))

                (pool-updated
                    (merge pool
                        {
                        balance-x: (if (<= balance-x dx) u0 (- balance-x dx)),
                        balance-y: (+ balance-y dy-net-fees fee-rebate),
                        oracle-resilient:   (if (get oracle-enabled pool) 
                                                (try! (get-oracle-resilient .token-wstx token-y))
                                                u0
                                            )
                        }
                    )
                )
                (sender tx-sender)
            )
            ;; a / b >= c / d == ac >= bc for b, d >= 0
            (asserts! (>= (mul-down dy-net-fees balance-x) (mul-down dx balance-y)) ERR-INVALID-LIQUIDITY)
            (asserts! (<= (default-to u0 min-dx) dx) ERR-EXCEEDS-MAX-SLIPPAGE)
        
            (and (> dx u0) (as-contract (try! (contract-call? .alex-vault transfer-ft .token-wstx dx sender))))
            (unwrap! (contract-call? token-y-trait transfer-fixed dy sender .alex-vault none) ERR-TRANSFER-FAILED)
            (as-contract (try! (contract-call? .alex-reserve-pool add-to-balance token-y (- fee fee-rebate))))

            ;; post setting
            (map-set pools-data-map { token-x: .token-wstx, token-y: token-y } pool-updated)
            (print { object: "pool", action: "swap-y-for-x", data: pool-updated })
            (ok {dx: dx, dy: dy-net-fees})
        )
    )
)

;; @desc swap-x-for-y
;; @param token-x-trait; token-x
;; @param token-y-trait; token-y
;; @param dx; amount of token-x to swap
;; @param min-dy; optional, min amount of token-y to receive
;; @returns (response (tuple uint uint) uint)
(define-public (swap-x-for-y (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dx uint) (min-dy (optional uint)))
    (ok 
        {
            dx: dx, 
            dy: 
                (if (is-eq (contract-of token-x-trait) .token-wstx)
                    (get dy (try! (swap-wstx-for-y token-y-trait dx min-dy)))
                    (if (is-eq (contract-of token-y-trait) .token-wstx)
                        (get dx (try! (swap-y-for-wstx token-x-trait dx min-dy)))
                        (get dy (try! (swap-wstx-for-y token-y-trait (get dx (try! (swap-y-for-wstx token-x-trait dx none))) min-dy)))
                    )
                )
        }
    )
)

;; @desc swap-y-for-x
;; @param token-x-trait; token-x
;; @param token-y-trait; token-y
;; @param dy; amount of token-y to swap
;; @param min-dx; optional, min amount of token-x to receive
;; @returns (response (tuple uint uint) uint)
(define-public (swap-y-for-x (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dy uint) (min-dx (optional uint)))
    (ok 
        {
            dx:
                (if (is-eq (contract-of token-x-trait) .token-wstx)
                    (get dx (try! (swap-y-for-wstx token-y-trait dy min-dx)))
                    (if (is-eq (contract-of token-y-trait) .token-wstx)
                        (get dy (try! (swap-wstx-for-y token-x-trait dy min-dx)))
                        (get dy (try! (swap-wstx-for-y token-x-trait (get dx (try! (swap-y-for-wstx token-y-trait dy none))) min-dx)))
                    )
                ),
            dy: dy
        }
    )
)

;; @desc get-fee-rebate
;; @param token-x; token-x principal
;; @param token-y; token-y principal

;; @returns (response uint uint)
(define-read-only (get-fee-rebate (token-x principal) (token-y principal))
    (ok (get fee-rebate (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL)))
)

;; @desc set-fee-rebate
;; @restricted contract-owner
;; @param token-x; token-x principal
;; @param token-y; token-y principal

;; @param fee-rebate; new fee-rebate
;; @returns (response bool uint)
(define-public (set-fee-rebate (token-x principal) (token-y principal) (fee-rebate uint))
    (let 
        (            
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (try! (check-is-owner))

        (map-set pools-data-map 
            { 
                token-x: token-x, token-y: token-y 
            }
            (merge pool { fee-rebate: fee-rebate })
        )
        (ok true)     
    )
)

;; @desc get-fee-rate-x
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @returns (response uint uint)
(define-read-only (get-fee-rate-x (token-x principal) (token-y principal))
    (ok (get fee-rate-x (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL)))
)

;; @desc get-fee-rate-y
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @returns (response uint uint)
(define-read-only (get-fee-rate-y (token-x principal) (token-y principal))
    (ok (get fee-rate-y (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL)))
)

;; @desc set-fee-rate-x
;; @restricted fee-to-address
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @param fee-rate-x; new fee-rate-x
;; @returns (response bool uint)
(define-public (set-fee-rate-x (token-x principal) (token-y principal) (fee-rate-x uint))
    (let 
        (        
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (asserts! (or (is-eq tx-sender (get fee-to-address pool)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)

        (map-set pools-data-map 
            { 
                token-x: token-x, token-y: token-y 
            }
            (merge pool { fee-rate-x: fee-rate-x })
        )
        (ok true)     
    )
)

;; @desc set-fee-rate-y
;; @restricted fee-to-address
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @param fee-rate-y; new fee-rate-y
;; @returns (response bool uint)
(define-public (set-fee-rate-y (token-x principal) (token-y principal) (fee-rate-y uint))
    (let 
        (    
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (asserts! (or (is-eq tx-sender (get fee-to-address pool)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)

        (map-set pools-data-map 
            { 
                token-x: token-x, token-y: token-y 
            }
            (merge pool { fee-rate-y: fee-rate-y })
        )
        (ok true)     
    )
)

;; @desc get-fee-to-address
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @returns (response principal uint)
(define-read-only (get-fee-to-address (token-x principal) (token-y principal))
    (ok (get fee-to-address (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL)))
)

(define-public (set-fee-to-address (token-x principal) (token-y principal) (fee-to-address principal))
    (let 
        (
            (pool (try! (get-pool-details token-x token-y)))
        )
        (try! (check-is-owner))

        (map-set pools-data-map 
            { 
                token-x: token-x, token-y: token-y 
            }
            (merge pool { fee-to-address: fee-to-address })
        )
        (ok true)     
    )
)

;; @desc get-y-given-wstx
;; @params token-y-trait; ft-trait 
;; @params dx 
;; @returns (respons uint uint)
(define-read-only (get-y-given-wstx (token-y principal) (dx uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: .token-wstx, token-y: token-y }) ERR-INVALID-POOL))
        )
        (contract-call? .simple-equation get-y-given-x (get balance-x pool) (get balance-y pool) dx)        
    )
)

;; @desc get-wstx-given-y
;; @params token-y-trait; ft-trait 
;; @params dy
;; @returns (respons uint uint)
(define-read-only (get-wstx-given-y (token-y principal) (dy uint)) 
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: .token-wstx, token-y: token-y }) ERR-INVALID-POOL))
        )
        (contract-call? .simple-equation get-x-given-y (get balance-x pool) (get balance-y pool) dy)
    )
)

;; @desc units of token-y given units of token-x
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @param dx; amount of token-x being added
;; @returns (response uint uint)
(define-read-only (get-y-given-x (token-x principal) (token-y principal) (dx uint))
    (if (is-eq token-x .token-wstx)
        (get-y-given-wstx token-y dx)
        (if (is-eq token-y .token-wstx)
            (get-wstx-given-y token-x dx)
            (get-y-given-wstx token-y (try! (get-wstx-given-y token-x dx)))
        )
    )
)

;; @desc units of token-x given units of token-y
;; @param token-x; token-x principal
;; @param token-y; token-y principal
;; @param dy; amount of token-y being added
;; @returns (response uint uint)
(define-read-only (get-x-given-y (token-x principal) (token-y principal) (dy uint)) 
    (if (is-eq token-x .token-wstx)
        (get-wstx-given-y token-y dy)
        (if (is-eq token-y .token-wstx)
            (get-y-given-wstx token-x dy)
            (get-y-given-wstx token-x (try! (get-wstx-given-y token-y dy)))
        )
    )
)

(define-read-only (get-y-in-given-wstx-out (token-y principal) (dx uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: .token-wstx, token-y: token-y }) ERR-INVALID-POOL))
        )
        (contract-call? .simple-equation get-y-in-given-x-out (get balance-x pool) (get balance-y pool) dx)        
    )
)

(define-read-only (get-wstx-in-given-y-out (token-y principal) (dy uint)) 
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: .token-wstx, token-y: token-y }) ERR-INVALID-POOL))
        )
        (contract-call? .simple-equation get-x-in-given-y-out (get balance-x pool) (get balance-y pool) dy)
    )
)

(define-read-only (get-y-in-given-x-out (token-x principal) (token-y principal) (dx uint))
    (if (is-eq token-x .token-wstx)
        (get-y-in-given-wstx-out token-y dx)
        (if (is-eq token-y .token-wstx)
            (get-wstx-in-given-y-out token-x dx)
            (get-y-in-given-wstx-out token-y (try! (get-wstx-in-given-y-out token-x dx)))
        )
    )
)

(define-read-only (get-x-in-given-y-out (token-x principal) (token-y principal) (dy uint)) 
    (if (is-eq token-x .token-wstx)
        (get-wstx-in-given-y-out token-y dy)
        (if (is-eq token-y .token-wstx)
            (get-y-in-given-wstx-out token-x dy)
            (get-y-in-given-wstx-out token-x (try! (get-wstx-in-given-y-out token-y dy)))
        )
    )
)

;; @desc units of token-x required for a target price
;; @param token-x; token-x principal
;; @param token-y; token-y principal

;; @param price; target price
;; @returns (response uint uint)
(define-read-only (get-x-given-price (token-x principal) (token-y principal) (price uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (contract-call? .simple-equation get-x-given-price (get balance-x pool) (get balance-y pool) price)
    )
)

;; @desc units of token-y required for a target price
;; @param token-x; token-x principal
;; @param token-y; token-y principal

;; @param price; target price
;; @returns (response uint uint)
(define-read-only (get-y-given-price (token-x principal) (token-y principal) (price uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (contract-call? .simple-equation get-y-given-price (get balance-x pool) (get balance-y pool) price)
    )
)

;; @desc units of pool token to be minted given amount of token-x and token-y being added
;; @param token-x; token-x principal
;; @param token-y; token-y principal

;; @param dx; amount of token-x added
;; @param dy; amount of token-y added
;; @returns (response (tuple uint uint) uint)
(define-read-only (get-token-given-position (token-x principal) (token-y principal) (dx uint) (max-dy (optional uint)))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (contract-call? .simple-equation get-token-given-position (get balance-x pool) (get balance-y pool) (get total-supply pool) dx (default-to u340282366920938463463374607431768211455 max-dy))
    )
)

;; @desc units of token-x/token-y required to mint given units of pool-token
;; @param token-x; token-x principal
;; @param token-y; token-y principal

;; @param token; units of pool token to be minted
;; @returns (response (tuple uint uint) uint)
(define-read-only (get-position-given-mint (token-x principal) (token-y principal) (token uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (contract-call? .simple-equation get-position-given-mint (get balance-x pool) (get balance-y pool) (get total-supply pool) token)
    )
)

;; @desc units of token-x/token-y to be returned after burning given units of pool-token
;; @param token-x; token-x principal
;; @param token-y; token-y principal

;; @param token; units of pool token to be burnt
;; @returns (response (tuple uint uint) uint)
(define-read-only (get-position-given-burn (token-x principal) (token-y principal) (token uint))
    (let 
        (
            (pool (unwrap! (map-get? pools-data-map { token-x: token-x, token-y: token-y }) ERR-INVALID-POOL))
        )
        (contract-call? .simple-equation get-position-given-burn (get balance-x pool) (get balance-y pool) (get total-supply pool) token)
    )
)

;; @desc swap
;; @params token-x-trait; ft-trait
;; @params token-y-trait; ft-trait
;; @params dx
;; @params mi-dy
;; @returns (response uint)
(define-public (swap-helper (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dx uint) (min-dy (optional uint)))
    (ok (get dy (try! (swap-x-for-y token-x-trait token-y-trait dx min-dy))))
)

;; @desc get-x-y
;; @params token-x-trait; ft-trait
;; @params token-y-trait; ft-trait
;; @params dy
;; @returns (response uint uint)
(define-read-only (get-helper (token-x principal) (token-y principal) (dx uint))
    (get-y-given-x token-x token-y dx)
)



;; math-fixed-point
;; Fixed Point Math
;; following https://github.com/balancer-labs/balancer-monorepo/blob/master/pkg/solidity-utils/contracts/math/FixedPoint.sol

;; constants
;;
(define-constant ONE_8 u100000000) ;; 8 decimal places

;; TODO: this needs to be reviewed/updated
;; With 8 fixed digits you would have a maximum error of 0.5 * 10^-8 in each entry, 
;; which could aggregate to about 8 x 0.5 * 10^-8 = 4 * 10^-8 relative error 
;; (i.e. the last digit of the result may be completely lost to this error).
(define-constant MAX_POW_RELATIVE_ERROR u4) 

;; public functions
;;

;; @desc scale-up
;; @params a 
;; @returns uint
(define-read-only (scale-up (a uint))
    (* a ONE_8)
)

;; @desc scale-down
;; @params a 
;; @returns uint
(define-read-only (scale-down (a uint))
    (/ a ONE_8)
)

;; @desc mul-down
;; @params a 
;; @params b
;; @returns uint
(define-read-only (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)

;; @desc mul-up
;; @params a 
;; @params b
;; @returns uint
(define-read-only (mul-up (a uint) (b uint))
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

;; @desc div-down
;; @params a 
;; @params b
;; @returns uint
(define-read-only (div-down (a uint) (b uint))
    (if (is-eq a u0)
        u0
        (/ (* a ONE_8) b)
   )
)

;; @desc div-up
;; @params a 
;; @params b
;; @returns uint
(define-read-only (div-up (a uint) (b uint))
    (if (is-eq a u0)
        u0
        (+ u1 (/ (- (* a ONE_8) u1) b))
    )
)

;; @desc pow-down
;; @params a 
;; @params b
;; @returns uint
(define-read-only (pow-down (a uint) (b uint))    
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

;; @desc pow-up
;; @params a 
;; @params b
;; @returns uint
(define-read-only (pow-up (a uint) (b uint))
    (let
        (
            (raw (unwrap-panic (pow-fixed a b)))
            (max-error (+ u1 (mul-up raw MAX_POW_RELATIVE_ERROR)))
        )
        (+ raw max-error)
    )
)

;; math-log-exp
;; Exponentiation and logarithm functions for 8 decimal fixed point numbers (both base and exponent/argument).
;; Exponentiation and logarithm with arbitrary bases (x^y and log_x(y)) are implemented by conversion to natural 
;; exponentiation and logarithm (where the base is Euler's number).
;; Reference: https://github.com/balancer-labs/balancer-monorepo/blob/master/pkg/solidity-utils/contracts/math/LogExpMath.sol
;; MODIFIED: because we use only 128 bits instead of 256, we cannot do 20 decimal or 36 decimal accuracy like in Balancer. 

;; constants
;;
;; All fixed point multiplications and divisions are inlined. This means we need to divide by ONE when multiplying
;; two numbers, and multiply by ONE when dividing them.
;; All arguments and return values are 8 decimal fixed point numbers.
(define-constant UNSIGNED_ONE_8 (pow 10 8))

;; The domain of natural exponentiation is bound by the word size and number of decimals used.
;; The largest possible result is (2^127 - 1) / 10^8, 
;; which makes the largest exponent ln((2^127 - 1) / 10^8) = 69.6090111872.
;; The smallest possible result is 10^(-8), which makes largest negative argument ln(10^(-8)) = -18.420680744.
;; We use 69.0 and -18.0 to have some safety margin.
(define-constant MAX_NATURAL_EXPONENT (* 69 UNSIGNED_ONE_8))
(define-constant MIN_NATURAL_EXPONENT (* -18 UNSIGNED_ONE_8))

(define-constant MILD_EXPONENT_BOUND (/ (pow u2 u126) (to-uint UNSIGNED_ONE_8)))

;; Because largest exponent is 69, we start from 64
;; The first several a_n are too large if stored as 8 decimal numbers, and could cause intermediate overflows.
;; Instead we store them as plain integers, with 0 decimals.

(define-constant x_a_list_no_deci (list 
{x_pre: 6400000000, a_pre: 62351490808116168829, use_deci: false} ;; x1 = 2^6, a1 = e^(x1)
))

;; 8 decimal constants
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

;; private functions
;;

;; Internal natural logarithm (ln(a)) with signed 8 decimal fixed point argument.

;; @desc ln-priv
;; @params a
;; @ returns (response uint)
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

;; @desc accumulate_division
;; @params x_a_pre ; tuple(x_pre a_pre use_deci)
;; @params rolling_a_sum ; tuple (a sum)
;; @returns uint
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

;; @desc rolling_sum_div
;; @params n
;; @params rolling ; tuple (num seriesSum z_squared)
;; @Sreturns tuple
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

;; Instead of computing x^y directly, we instead rely on the properties of logarithms and exponentiation to
;; arrive at that result. In particular, exp(ln(x)) = x, and ln(x^y) = y * ln(x). This means
;; x^y = exp(y * ln(x)).
;; Reverts if ln(x) * y is smaller than `MIN_NATURAL_EXPONENT`, or larger than `MAX_NATURAL_EXPONENT`.

;; @desc pow-priv
;; @params x
;; @params y
;; @returns (response uint)
(define-read-only (pow-priv (x uint) (y uint))
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

;; @desc exp-pos
;; @params x
;; @returns (response uint)
(define-read-only (exp-pos (x int))
  (begin
    (asserts! (and (<= 0 x) (<= x MAX_NATURAL_EXPONENT)) ERR-INVALID-EXPONENT)
    (let
      (
        ;; For each x_n, we test if that term is present in the decomposition (if x is larger than it), and if so deduct
        ;; it and compute the accumulated product.
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

;; @desc accumulate_product
;; @params x_a_pre ; tuple (x_pre a_pre use_deci)
;; @params rolling_x_p ; tuple (x product)
;; @returns tuple
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

;; @desc rolling_div_sum
;; @params n
;; @params rolling ; tuple (term seriesSum x)
;; @returns tuple
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

;; public functions
;;

;; Exponentiation (x^y) with unsigned 8 decimal fixed point base and exponent.
;; @desc pow-fixed
;; @params x
;; @params y
;; @returns (response uint)
(define-read-only (pow-fixed (x uint) (y uint))
  (begin
    ;; The ln function takes a signed value, so we need to make sure x fits in the signed 128 bit range.
    (asserts! (< x (pow u2 u127)) ERR-X-OUT-OF-BOUNDS)

    ;; This prevents y * ln(x) from overflowing, and at the same time guarantees y fits in the signed 128 bit range.
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

;; Natural exponentiation (e^x) with signed 8 decimal fixed point exponent.
;; Reverts if `x` is smaller than MIN_NATURAL_EXPONENT, or larger than `MAX_NATURAL_EXPONENT`.

;; @desc exp-fixed
;; @params x
;; @returns (response uint)
(define-read-only (exp-fixed (x int))
  (begin
    (asserts! (and (<= MIN_NATURAL_EXPONENT x) (<= x MAX_NATURAL_EXPONENT)) ERR-INVALID-EXPONENT)
    (if (< x 0)
      ;; We only handle positive exponents: e^(-x) is computed as 1 / e^x. We can safely make x positive since it
      ;; fits in the signed 128 bit range (as it is larger than MIN_NATURAL_EXPONENT).
      ;; Fixed point division requires multiplying by UNSIGNED_ONE_8.
      (ok (/ (* UNSIGNED_ONE_8 UNSIGNED_ONE_8) (try! (exp-pos (* -1 x)))))
      (exp-pos x)
    )
  )
)

;; Logarithm (log(arg, base), with signed 8 decimal fixed point base and argument.
;; @desc log-fixed
;; @params arg
;; @params base
;; @returns (response uint)
(define-read-only (log-fixed (arg int) (base int))
  ;; This performs a simple base change: log(arg, base) = ln(arg) / ln(base).
  (let
    (
      (logBase (* (ln-priv base) UNSIGNED_ONE_8))
      (logArg (* (ln-priv arg) UNSIGNED_ONE_8))
   )
    (ok (/ (* logArg UNSIGNED_ONE_8) logBase))
 )
)

;; Natural logarithm (ln(a)) with signed 8 decimal fixed point argument.

;; @desc ln-fixed
;; @params a
;; @returns (response uint)
(define-read-only (ln-fixed (a int))
  (begin
    (asserts! (> a 0) ERR-OUT-OF-BOUNDS)
    (if (< a UNSIGNED_ONE_8)
      ;; Since ln(a^k) = k * ln(a), we can compute ln(a) as ln(a) = ln((1/a)^(-1)) = - ln((1/a)).
      ;; If a is less than one, 1/a will be greater than one.
      ;; Fixed point division requires multiplying by UNSIGNED_ONE_8.
      (ok (- 0 (ln-priv (/ (* UNSIGNED_ONE_8 UNSIGNED_ONE_8) a))))
      (ok (ln-priv a))
   )
 )
)

;; contract initialisation
;; (set-contract-owner .executor-dao)