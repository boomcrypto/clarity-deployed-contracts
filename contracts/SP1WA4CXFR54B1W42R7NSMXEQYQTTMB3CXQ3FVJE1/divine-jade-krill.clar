;; divine-jade-krill

;; Use Stableswap pool trait and SIP 010 trait
(use-trait stableswap-pool-trait .fun-plum-tarantula.stableswap-pool-trait)
(use-trait sip-010-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_INVALID_PRINCIPAL (err u1003))
(define-constant ERR_ALREADY_ADMIN (err u1004))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u1005))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u1006))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u1007))
(define-constant ERR_NO_POOL_DATA (err u1008))
(define-constant ERR_POOL_NOT_CREATED (err u1009))
(define-constant ERR_POOL_DISABLED (err u1010))
(define-constant ERR_POOL_ALREADY_CREATED (err u1011))
(define-constant ERR_INVALID_POOL (err u1012))
(define-constant ERR_INVALID_POOL_URI (err u1013))
(define-constant ERR_INVALID_POOL_SYMBOL (err u1014))
(define-constant ERR_INVALID_POOL_NAME (err u1015))
(define-constant ERR_MATCHING_TOKEN_CONTRACTS (err u1016))
(define-constant ERR_INVALID_X_TOKEN (err u1017))
(define-constant ERR_INVALID_Y_TOKEN (err u1018))
(define-constant ERR_MINIMUM_X_AMOUNT (err u1019))
(define-constant ERR_MINIMUM_Y_AMOUNT (err u1020))
(define-constant ERR_MINIMUM_LP_AMOUNT (err u1021))
(define-constant ERR_MAXIMUM_LP_AMOUNT (err u1022))
(define-constant ERR_MINIMUM_D_VALUE (err u1023))
(define-constant ERR_INVALID_FEE (err u1024))
(define-constant ERR_MINIMUM_BURN_AMOUNT (err u1025))
(define-constant ERR_INVALID_MIN_BURNT_SHARES (err u1026))
(define-constant ERR_INVALID_MIDPOINT_NUMERATOR (err u1027))
(define-constant ERR_INVALID_MIDPOINT_DENOMINATOR (err u1028))
(define-constant ERR_IMBALANCED_WITHDRAWS_DISABLED (err u1029))
(define-constant ERR_WITHDRAW_COOLDOWN (err u1030))
(define-constant ERR_MIDPOINT_MANAGER_FROZEN (err u1031))
(define-constant ERR_UNEQUAL_POOL_BALANCES (err u1032))

;; Contract deployer address
(define-constant CONTRACT_DEPLOYER tx-sender)

;; Number of tokens per pair
(define-constant NUM_OF_TOKENS u2)

;; Multiplier used in swaps to check if amount is less than x10 of balance
(define-constant MAX_AMOUNT_PER_BALANCE_MULTIPLIER u10)

;; Maximum BPS
(define-constant BPS u10000)

;; Index loop for using Newton-Raphson method to converge square root that goes up to u384
(define-constant index-list (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100 u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150 u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200 u201 u202 u203 u204 u205 u206 u207 u208 u209 u210 u211 u212 u213 u214 u215 u216 u217 u218 u219 u220 u221 u222 u223 u224 u225 u226 u227 u228 u229 u230 u231 u232 u233 u234 u235 u236 u237 u238 u239 u240 u241 u242 u243 u244 u245 u246 u247 u248 u249 u250 u251 u252 u253 u254 u255 u256 u257 u258 u259 u260 u261 u262 u263 u264 u265 u266 u267 u268 u269 u270 u271 u272 u273 u274 u275 u276 u277 u278 u279 u280 u281 u282 u283 u284 u285 u286 u287 u288 u289 u290 u291 u292 u293 u294 u295 u296 u297 u298 u299 u300 u301 u302 u303 u304 u305 u306 u307 u308 u309 u310 u311 u312 u313 u314 u315 u316 u317 u318 u319 u320 u321 u322 u323 u324 u325 u326 u327 u328 u329 u330 u331 u332 u333 u334 u335 u336 u337 u338 u339 u340 u341 u342 u343 u344 u345 u346 u347 u348 u349 u350 u351 u352 u353 u354 u355 u356 u357 u358 u359 u360 u361 u362 u363 u364 u365 u366 u367 u368 u369 u370 u371 u372 u373 u374 u375 u376 u377 u378 u379 u380 u381 u382 u383 u384))

;; Admins list and helper var used to remove admins
(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

;; ID of last created pool
(define-data-var last-pool-id uint u0)

;; Minimum shares required to mint when creating a pool
(define-data-var minimum-total-shares uint u10000)

;; Minimum shares required to burn when creating a pool
(define-data-var minimum-burnt-shares uint u1000)

;; Data var used to enable or disable pool creation by anyone
(define-data-var public-pool-creation bool false)

;; Data var used to enable or disable imbalanced withdraws for all pools
(define-data-var global-imbalanced-withdraws bool false)

;; Define pools map
(define-map pools uint {
  id: uint,
  name: (string-ascii 32),
  symbol: (string-ascii 32),
  pool-contract: principal
})

;; Get admins list
(define-read-only (get-admins)
  (ok (var-get admins))
)

;; Get admin helper var
(define-read-only (get-admin-helper)
  (ok (var-get admin-helper))
)

;; Get ID of last created pool
(define-read-only (get-last-pool-id)
  (ok (var-get last-pool-id))
)

;; Get a pool by pool ID
(define-read-only (get-pool-by-id (id uint))
  (ok (map-get? pools id))
)

;; Get minimum shares required to mint when creating a pool
(define-read-only (get-minimum-total-shares)
  (ok (var-get minimum-total-shares))
)

;; Get minimum shares required to burn when creating a pool
(define-read-only (get-minimum-burnt-shares)
  (ok (var-get minimum-burnt-shares))
)

;; Get public pool creation status
(define-read-only (get-public-pool-creation)
  (ok (var-get public-pool-creation))
)

;; Get global imbalanced withdraws status
(define-read-only (get-global-imbalanced-withdraws)
  (ok (var-get global-imbalanced-withdraws))
)

;; Get DY
(define-public (get-dy
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (midpoint-numerator (get midpoint-primary-numerator pool-data))
    (midpoint-denominator (get midpoint-primary-denominator pool-data))
    (protocol-fee (get x-protocol-fee pool-data))
    (provider-fee (get x-provider-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))

    ;; Scale up pool balances and swap amounts to perform AMM calculations with get-y
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (swap-amounts-scaled (scale-up-amounts x-amount u0 x-token-trait y-token-trait))
    (x-amount-scaled (get x-amount swap-amounts-scaled))
    (x-amount-fees-protocol-scaled (/ (* x-amount-scaled protocol-fee) BPS))
    (x-amount-fees-provider-scaled (/ (* x-amount-scaled provider-fee) BPS))
    (x-amount-fees-total-scaled (+ x-amount-fees-protocol-scaled x-amount-fees-provider-scaled))
    (dx-scaled (- x-amount-scaled x-amount-fees-total-scaled))

    ;; Calculate updated pool balances using midpoint
    (dx-midpoint-scaled (/ (* dx-scaled midpoint-numerator) midpoint-denominator))
    (x-balance-midpoint-scaled (/ (* x-balance-scaled midpoint-numerator) midpoint-denominator))
    (updated-y-balance-scaled (get-y dx-midpoint-scaled x-balance-midpoint-scaled y-balance-scaled amplification-coefficient convergence-threshold))

    ;; Scale down to precise amounts for y and dy
    (updated-y-balance (get y-amount (scale-down-amounts u0 updated-y-balance-scaled x-token-trait y-token-trait)))
    (dy (- y-balance updated-y-balance))
  )
    ;; Assert that pool-status is true and correct token traits are used
    (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
    (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
    (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

    ;; Assert that x-amount is greater than 0 and less than x10 of x-balance
    (asserts! (and (> x-amount u0) (< x-amount (* x-balance MAX_AMOUNT_PER_BALANCE_MULTIPLIER))) ERR_INVALID_AMOUNT)
    
    ;; Return number of y tokens the caller would receive
    (ok dy)
  )
)

;; Get DX
(define-public (get-dx
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (y-amount uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (midpoint-numerator (get midpoint-primary-numerator pool-data))
    (midpoint-denominator (get midpoint-primary-denominator pool-data))
    (protocol-fee (get y-protocol-fee pool-data))
    (provider-fee (get y-provider-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))

    ;; Scale up pool balances and swap amounts to perform AMM calculations with get-x
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (swap-amounts-scaled (scale-up-amounts u0 y-amount x-token-trait y-token-trait))
    (y-amount-scaled (get y-amount swap-amounts-scaled))
    (y-amount-fees-protocol-scaled (/ (* y-amount-scaled protocol-fee) BPS))
    (y-amount-fees-provider-scaled (/ (* y-amount-scaled provider-fee) BPS))
    (y-amount-fees-total-scaled (+ y-amount-fees-protocol-scaled y-amount-fees-provider-scaled))
    (dy-scaled (- y-amount-scaled y-amount-fees-total-scaled))

    ;; Calculate updated pool balances using midpoint
    (dy-midpoint-scaled (/ (* dy-scaled midpoint-denominator) midpoint-numerator))
    (y-balance-midpoint-scaled (/ (* y-balance-scaled midpoint-denominator) midpoint-numerator))
    (updated-x-balance-scaled (get-x dy-midpoint-scaled y-balance-midpoint-scaled x-balance-scaled amplification-coefficient convergence-threshold))

    ;; Scale down to precise amounts for x and dx
    (updated-x-balance (get x-amount (scale-down-amounts updated-x-balance-scaled u0 x-token-trait y-token-trait)))
    (dx (- x-balance updated-x-balance))
  )
    ;; Assert that pool-status is true and correct token traits are used
    (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
    (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
    (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

    ;; Assert that y-amount is greater than 0 and less than x10 of y-balance
    (asserts! (and (> y-amount u0) (< y-amount (* y-balance MAX_AMOUNT_PER_BALANCE_MULTIPLIER))) ERR_INVALID_AMOUNT)
    
    ;; Return number of x tokens the caller would receive
    (ok dx)
  )
)

;; Get DLP
(define-public (get-dlp
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (y-amount uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (midpoint-numerator (get midpoint-primary-numerator pool-data))
    (midpoint-denominator (get midpoint-primary-denominator pool-data))
    (total-shares (get total-shares pool-data))
    (liquidity-fee (get liquidity-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))
    (updated-x-balance (+ x-balance x-amount))
    (updated-y-balance (+ y-balance y-amount))
    
    ;; Scale up for AMM calculations depending on decimal places assigned to tokens
    (amounts-added-scaled (scale-up-amounts x-amount y-amount x-token-trait y-token-trait))
    (x-amount-scaled (get x-amount amounts-added-scaled))
    (y-amount-scaled (get y-amount amounts-added-scaled))
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (updated-pool-balances-scaled (scale-up-amounts updated-x-balance updated-y-balance x-token-trait y-token-trait))
    (updated-x-balance-scaled (get x-amount updated-pool-balances-scaled))
    (updated-y-balance-scaled (get y-amount updated-pool-balances-scaled))

    ;; Calculate midpoint offset and scale values
    (midpoint-offset-reversed (> midpoint-numerator midpoint-denominator))
    (midpoint-offset-value (calculate-midpoint-offset midpoint-numerator midpoint-denominator midpoint-offset-reversed))
    (midpoint-scale-value (if midpoint-offset-reversed midpoint-denominator midpoint-numerator))

    ;; Calculate offset pool balances
    (x-balance-offset-scaled (if midpoint-offset-reversed u0 (/ (* x-balance-scaled midpoint-offset-value) midpoint-scale-value)))
    (x-balance-post-offset-scaled (- x-balance-scaled x-balance-offset-scaled))
    (y-balance-offset-scaled (if midpoint-offset-reversed (/ (* y-balance-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (y-balance-post-offset-scaled (- y-balance-scaled y-balance-offset-scaled))

    ;; Calculate offset pool balances after adding x and y amounts
    (updated-x-balance-offset-scaled (if midpoint-offset-reversed u0 (/ (* updated-x-balance-scaled midpoint-offset-value) midpoint-scale-value)))
    (updated-x-balance-post-offset-scaled (- updated-x-balance-scaled updated-x-balance-offset-scaled))
    (updated-y-balance-offset-scaled (if midpoint-offset-reversed (/ (* updated-y-balance-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (updated-y-balance-post-offset-scaled (- updated-y-balance-scaled updated-y-balance-offset-scaled))
    
    ;; Calculate ideal pool balances
    (d-a (get-d x-balance-post-offset-scaled y-balance-post-offset-scaled amplification-coefficient convergence-threshold))
    (d-b (get-d updated-x-balance-post-offset-scaled updated-y-balance-post-offset-scaled amplification-coefficient convergence-threshold))
    (ideal-x-balance-scaled (/ (* d-b x-balance-scaled) d-a))
    (ideal-y-balance-scaled (/ (* d-b y-balance-scaled) d-a))
    (x-difference (if (> ideal-x-balance-scaled updated-x-balance-scaled) (- ideal-x-balance-scaled updated-x-balance-scaled) (- updated-x-balance-scaled ideal-x-balance-scaled)))
    (y-difference (if (> ideal-y-balance-scaled updated-y-balance-scaled) (- ideal-y-balance-scaled updated-y-balance-scaled) (- updated-y-balance-scaled ideal-y-balance-scaled)))
    
    ;; Calculate fees to apply if adding imbalanced liquidity
    (ideal-x-amount-fee-liquidity-scaled (/ (* x-difference liquidity-fee) BPS))
    (ideal-y-amount-fee-liquidity-scaled (/ (* y-difference liquidity-fee) BPS))
    (x-amount-fee-liquidity-scaled (if (> x-amount-scaled ideal-x-amount-fee-liquidity-scaled) ideal-x-amount-fee-liquidity-scaled x-amount-scaled))
    (y-amount-fee-liquidity-scaled (if (> y-amount-scaled ideal-y-amount-fee-liquidity-scaled) ideal-y-amount-fee-liquidity-scaled y-amount-scaled))
    (updated-x-amount-scaled (- x-amount-scaled x-amount-fee-liquidity-scaled))
    (updated-y-amount-scaled (- y-amount-scaled y-amount-fee-liquidity-scaled))
    (updated-balance-x-post-fee-scaled (+ x-balance-scaled updated-x-amount-scaled))
    (updated-balance-y-post-fee-scaled (+ y-balance-scaled updated-y-amount-scaled))

    ;; Calculate offset pool balances post fees and then get d
    (updated-balance-x-post-fee-offset-scaled (if midpoint-offset-reversed u0 (/ (* updated-balance-x-post-fee-scaled midpoint-offset-value) midpoint-scale-value)))
    (updated-balance-x-post-fee-and-offset-scaled (- updated-balance-x-post-fee-scaled updated-balance-x-post-fee-offset-scaled))
    (updated-balance-y-post-fee-offset-scaled (if midpoint-offset-reversed (/ (* updated-balance-y-post-fee-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (updated-balance-y-post-fee-and-offset-scaled (- updated-balance-y-post-fee-scaled updated-balance-y-post-fee-offset-scaled))
    (updated-d (get-d updated-balance-x-post-fee-and-offset-scaled updated-balance-y-post-fee-and-offset-scaled amplification-coefficient convergence-threshold))

    ;; Check that updated-d is greater than d-a and calculate dlp
    (minimum-d-check (asserts! (> updated-d d-a) ERR_MINIMUM_D_VALUE))
    (dlp (/ (* total-shares (- updated-d d-a)) d-a))
  )
    ;; Assert that pool-status is true and correct token traits are used
    (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
    (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
    (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

    ;; Assert that x-amount + y-amount is greater than 0
    (asserts! (> (+ x-amount y-amount) u0) ERR_INVALID_AMOUNT)
    
    ;; Assert that x-amount and y-amount are less than x10 of x-balance and y-balance
    (asserts! (< x-amount (* x-balance MAX_AMOUNT_PER_BALANCE_MULTIPLIER)) ERR_INVALID_AMOUNT)
    (asserts! (< y-amount (* y-balance MAX_AMOUNT_PER_BALANCE_MULTIPLIER)) ERR_INVALID_AMOUNT)

    ;; Return number of LP tokens caller would receive
    (ok dlp)
  )
)

;; Get x using fold-x-for-loop
(define-read-only (get-x (y-amount uint) (y-bal uint) (x-bal uint) (amp uint) (threshold uint))
  (let (
    (an (* amp NUM_OF_TOKENS))
    (updated-y-balance (+ y-bal y-amount))
    (current-d (get-d x-bal y-bal amp threshold))
    (c-a current-d)
    (c-b (/ (* c-a current-d) (* NUM_OF_TOKENS updated-y-balance)))
    (c-c (/ (* c-b current-d) (* an NUM_OF_TOKENS)))
    (b (+ updated-y-balance (/ current-d an)))
  )
    (get converged (fold fold-x-for-loop index-list {x: current-d, c: c-c, b: b, d: current-d, threshold: threshold, converged: u0}))
  )
)

;; Get y using fold-y-for-loop
(define-read-only (get-y (x-amount uint) (x-bal uint) (y-bal uint) (amp uint) (threshold uint))
  (let (
    (an (* amp NUM_OF_TOKENS))
    (updated-x-balance (+ x-bal x-amount))
    (current-d (get-d x-bal y-bal amp threshold))
    (c-a current-d)
    (c-b (/ (* c-a current-d) (* NUM_OF_TOKENS updated-x-balance)))
    (c-c (/ (* c-b current-d) (* an NUM_OF_TOKENS)))
    (b (+ updated-x-balance (/ current-d an)))
  )
    (get converged (fold fold-y-for-loop index-list {y: current-d, c: c-c, b: b, d: current-d, threshold: threshold, converged: u0}))
  )
)

;; Get d using fold-d-for-loop
(define-read-only (get-d (x-bal uint) (y-bal uint) (amp uint) (threshold uint))
  (get converged (fold fold-d-for-loop index-list {x-bal: x-bal, y-bal: y-bal, d: (+ x-bal y-bal), an: (* amp NUM_OF_TOKENS), threshold: threshold, converged: u0}))
)

;; Set minimum shares required to mint and burn when creating a pool
(define-public (set-minimum-shares (min-total uint) (min-burnt uint))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and amounts are greater than 0
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (and (> min-total u0) (> min-burnt u0)) ERR_INVALID_AMOUNT)
      
      ;; Assert that min-total is greater than min-burnt
      (asserts! (> min-total min-burnt) ERR_INVALID_MIN_BURNT_SHARES)

      ;; Update minimum-total-shares and minimum-burnt-shares
      (var-set minimum-total-shares min-total)
      (var-set minimum-burnt-shares min-burnt)

      ;; Print function data and return true
      (print {
        action: "set-minimum-shares",
        caller: caller,
        data: {
          min-total: min-total,
          min-burnt: min-burnt
        }
      })
      (ok true)
    )
  )
)

;; Enable or disable public pool creation
(define-public (set-public-pool-creation (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Set public-pool-creation to status
      (var-set public-pool-creation status)

      ;; Print function data and return true
      (print {action: "set-public-pool-creation", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

;; Enable or disable global imbalanced withdraws
(define-public (set-global-imbalanced-withdraws (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Set global-imbalanced-withdraws to status
      (var-set global-imbalanced-withdraws status)

      ;; Print function data and return true
      (print {action: "set-global-imbalanced-withdraws", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

;; Set pool uri for a pool
(define-public (set-pool-uri (pool-trait <stableswap-pool-trait>) (uri (string-utf8 256)))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      
      ;; Assert that uri length is greater than 0
      (asserts! (> (len uri) u0) ERR_INVALID_POOL_URI)
      
      ;; Set pool uri for pool
      (try! (contract-call? pool-trait set-pool-uri uri))
      
      ;; Print function data and return true
      (print {
        action: "set-pool-uri",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          uri: uri
        }
      })
      (ok true)
    )
  )
)

;; Set pool status for a pool
(define-public (set-pool-status (pool-trait <stableswap-pool-trait>) (status bool))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      
      ;; Set pool status for pool
      (try! (contract-call? pool-trait set-pool-status status))
      
      ;; Print function data and return true
      (print {
        action: "set-pool-status",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          status: status
        }
      })
      (ok true)
    )
  )
)

;; Set midpoint manager for a pool
(define-public (set-midpoint-manager (pool-trait <stableswap-pool-trait>) (manager principal))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (freeze-midpoint-manager (get freeze-midpoint-manager pool-data))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      
      ;; Assert that midpoint manager is not frozen
      (asserts! (not freeze-midpoint-manager) ERR_MIDPOINT_MANAGER_FROZEN)

      ;; Assert that address is standard principal
      (asserts! (is-standard manager) ERR_INVALID_PRINCIPAL) 
      
      ;; Set midpoint manager for pool
      (try! (contract-call? pool-trait set-midpoint-manager manager))
      
      ;; Print function data and return true
      (print {
        action: "set-midpoint-manager",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          manager: manager
        }
      })
      (ok true)
    )
  )
)

;; Set fee address for a pool
(define-public (set-fee-address (pool-trait <stableswap-pool-trait>) (address principal))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      
      ;; Assert that address is standard principal
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)
      
      ;; Set fee address for pool
      (try! (contract-call? pool-trait set-fee-address address))
      
      ;; Print function data and return true
      (print {
        action: "set-fee-address",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          address: address
        }
      })
      (ok true)
    )
  )
)

;; Set midpoint for a pool
(define-public (set-midpoint
    (pool-trait <stableswap-pool-trait>)
    (primary-numerator uint) (primary-denominator uint)
    (withdraw-numerator uint) (withdraw-denominator uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (midpoint-manager (get midpoint-manager pool-data))
    (freeze-midpoint-manager (get freeze-midpoint-manager pool-data))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin or midpoint manager and pool is created and valid
      (asserts! (or (is-some (index-of (var-get admins) caller)) (is-eq midpoint-manager caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)

      ;; Assert that caller is midpoint manager if midpoint manager is frozen
      (asserts! (or (is-eq midpoint-manager caller) (not freeze-midpoint-manager)) ERR_NOT_AUTHORIZED)

      ;; Assert that primary-numerator and primary-denominator are greater than 0
      (asserts! (> primary-numerator u0) ERR_INVALID_MIDPOINT_NUMERATOR)
      (asserts! (> primary-denominator u0) ERR_INVALID_MIDPOINT_DENOMINATOR)

      ;; Assert that withdraw-numerator and withdraw-denominator are greater than 0
      (asserts! (> withdraw-numerator u0) ERR_INVALID_MIDPOINT_NUMERATOR)
      (asserts! (> withdraw-denominator u0) ERR_INVALID_MIDPOINT_DENOMINATOR)

      ;; Set midpoint for pool
      (try! (contract-call? pool-trait set-midpoint primary-numerator primary-denominator withdraw-numerator withdraw-denominator))
      
      ;; Print function data and return true
      (print {
        action: "set-midpoint",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          primary-numerator: primary-numerator,
          primary-denominator: primary-denominator,
          withdraw-numerator: withdraw-numerator,
          withdraw-denominator: withdraw-denominator
        }
      })
      (ok true)
    )
  )
)

;; Set x fees for a pool
(define-public (set-x-fees (pool-trait <stableswap-pool-trait>) (protocol-fee uint) (provider-fee uint))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      
      ;; Assert protocol-fee and provider-fee is less than maximum BPS
      (asserts! (< (+ protocol-fee provider-fee) BPS) ERR_INVALID_FEE)
      
      ;; Set x fees for pool
      (try! (contract-call? pool-trait set-x-fees protocol-fee provider-fee))
      
      ;; Print function data and return true
      (print {
        action: "set-x-fees",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          protocol-fee: protocol-fee,
          provider-fee: provider-fee
        }
      })
      (ok true)
    )
  )
)

;; Set y fees for a pool
(define-public (set-y-fees (pool-trait <stableswap-pool-trait>) (protocol-fee uint) (provider-fee uint))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      
      ;; Assert protocol-fee and provider-fee is less than maximum BPS
      (asserts! (< (+ protocol-fee provider-fee) BPS) ERR_INVALID_FEE)
      
      ;; Set y fees for pool
      (try! (contract-call? pool-trait set-y-fees protocol-fee provider-fee))
      
      ;; Print function data and return true
      (print {
        action: "set-y-fees",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          protocol-fee: protocol-fee,
          provider-fee: provider-fee
        }
      })
      (ok true)
    )
  )
)

;; Set liquidity fee for a pool
(define-public (set-liquidity-fee (pool-trait <stableswap-pool-trait>) (fee uint))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)

      ;; Assert fee is less than maximum BPS
      (asserts! (< fee BPS) ERR_INVALID_FEE)

      ;; Set liquidity fee for pool
      (try! (contract-call? pool-trait set-liquidity-fee fee))

      ;; Print function data and return true
      (print {
        action: "set-liquidity-fee",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          fee: fee
        }
      })
      (ok true)
    )
  )
)

;; Set amplification coefficient for a pool
(define-public (set-amplification-coefficient (pool-trait <stableswap-pool-trait>) (coefficient uint))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)

      ;; Set amplification coefficient for pool
      (try! (contract-call? pool-trait set-amplification-coefficient coefficient))

      ;; Print function data and return true
      (print {
        action: "set-amplification-coefficient",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          coefficient: coefficient
        }
      })
      (ok true)
    )
  )
)

;; Set convergence threshold for a pool
(define-public (set-convergence-threshold (pool-trait <stableswap-pool-trait>) (threshold uint))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)

      ;; Set convergence threshold for pool
      (try! (contract-call? pool-trait set-convergence-threshold threshold))

      ;; Print function data and return true
      (print {
        action: "set-convergence-threshold",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          threshold: threshold
        }
      })
      (ok true)
    )
  )
)

;; Set imbalanced withdraws for a pool
(define-public (set-imbalanced-withdraws (pool-trait <stableswap-pool-trait>) (status bool))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      
      ;; Set imbalanced withdraws for pool
      (try! (contract-call? pool-trait set-imbalanced-withdraws status))
      
      ;; Print function data and return true
      (print {
        action: "set-imbalanced-withdraws",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          status: status
        }
      })
      (ok true)
    )
  )
)

;; Set withdraw cooldown for a pool
(define-public (set-withdraw-cooldown (pool-trait <stableswap-pool-trait>) (cooldown uint))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      
      ;; Set withdraw cooldown for pool
      (try! (contract-call? pool-trait set-withdraw-cooldown cooldown))
      
      ;; Print function data and return true
      (print {
        action: "set-withdraw-cooldown",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          cooldown: cooldown
        }
      })
      (ok true)
    )
  )
)

;; Set freeze midpoint manager for a pool
(define-public (set-freeze-midpoint-manager (pool-trait <stableswap-pool-trait>))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (freeze-midpoint-manager (get freeze-midpoint-manager pool-data))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin and pool is created and valid
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL)
      (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
      
      ;; Assert that midpoint manager is not frozen
      (asserts! (not freeze-midpoint-manager) ERR_MIDPOINT_MANAGER_FROZEN)

      ;; Set freeze midpoint manager for pool
      (try! (contract-call? pool-trait set-freeze-midpoint-manager))
      
      ;; Print function data and return true
      (print {
        action: "set-freeze-midpoint-manager",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait)
        }
      })
      (ok true)
    )
  )
)

;; Create a new pool
(define-public (create-pool 
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (y-amount uint) (burn-amount uint)
    (midpoint-primary-numerator uint) (midpoint-primary-denominator uint)
    (midpoint-withdraw-numerator uint) (midpoint-withdraw-denominator uint)
    (x-protocol-fee uint) (x-provider-fee uint)
    (y-protocol-fee uint) (y-provider-fee uint)
    (liquidity-fee uint)
    (amplification-coefficient uint) (convergence-threshold uint)
    (imbalanced-withdraws bool) (withdraw-cooldown uint) (freeze-midpoint-manager bool)
    (fee-address principal)
    (uri (string-utf8 256)) (status bool)
  )
  (let (
    ;; Gather all pool data and pool contract
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-contract (contract-of pool-trait))
    
    ;; Get pool ID and create pool symbol and name 
    (new-pool-id (+ (var-get last-pool-id) u1))
    (symbol (unwrap! (create-symbol x-token-trait y-token-trait) ERR_INVALID_POOL_SYMBOL))
    (name (concat symbol "-LP"))
    (x-token-contract (contract-of x-token-trait))
    (y-token-contract (contract-of y-token-trait))
    
    ;; Scale up pool balances and calculate total shares
    (pool-balances-scaled (scale-up-amounts x-amount y-amount x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))

    ;; Calculate midpoint offset and scale values
    (midpoint-offset-reversed (> midpoint-primary-numerator midpoint-primary-denominator))
    (midpoint-offset-value (calculate-midpoint-offset midpoint-primary-numerator midpoint-primary-denominator midpoint-offset-reversed))
    (midpoint-scale-value (if midpoint-offset-reversed midpoint-primary-denominator midpoint-primary-numerator))

    ;; Calculate offset initial pool balances
    (x-balance-offset-scaled (if midpoint-offset-reversed u0 (/ (* x-balance-scaled midpoint-offset-value) midpoint-scale-value)))
    (x-balance-post-offset-scaled (- x-balance-scaled x-balance-offset-scaled))
    (y-balance-offset-scaled (if midpoint-offset-reversed (/ (* y-balance-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (y-balance-post-offset-scaled (- y-balance-scaled y-balance-offset-scaled))

    ;; Calculate total shares uses offset pool balances
    (total-shares (+ x-balance-post-offset-scaled y-balance-post-offset-scaled))
    (min-burnt-shares (var-get minimum-burnt-shares))
    (caller tx-sender)
  )
    (begin
      ;; Assert that caller is an admin or public-pool-creation is true
      (asserts! (or (is-some (index-of (var-get admins) caller)) (var-get public-pool-creation)) ERR_NOT_AUTHORIZED)
      
      ;; Assert that pool is not created
      (asserts! (is-eq (get pool-created pool-data) false) ERR_POOL_ALREADY_CREATED)

      ;; Assert that x-token-contract and y-token-contract are not matching
      (asserts! (not (is-eq x-token-contract y-token-contract)) ERR_MATCHING_TOKEN_CONTRACTS)

      ;; Assert that addresses are standard principals
      (asserts! (is-standard x-token-contract) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard y-token-contract) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard fee-address) ERR_INVALID_PRINCIPAL)
      
      ;; Assert that x and y amount is greater than 0
      (asserts! (and (> x-amount u0) (> y-amount u0)) ERR_INVALID_AMOUNT)

      ;; Assert that balances are equal if midpoint is not used
      (if (and
            (is-eq midpoint-primary-numerator midpoint-primary-denominator)
            (is-eq midpoint-withdraw-numerator midpoint-withdraw-denominator))
        (asserts! (is-eq x-balance-scaled y-balance-scaled) ERR_UNEQUAL_POOL_BALANCES)
        false
      )

      ;; Assert that total shares minted meets minimum total shares required
      (asserts! (>= total-shares (var-get minimum-total-shares)) ERR_MINIMUM_LP_AMOUNT)

      ;; Assert that burn amount meets minimum shares required to burn
      (asserts! (>= burn-amount min-burnt-shares) ERR_MINIMUM_BURN_AMOUNT)
      
      ;; Assert that total shares is greater than or equal to 0 after subtracting burn amount
      (asserts! (>= (- total-shares burn-amount) u0) ERR_MINIMUM_LP_AMOUNT)

      ;; Assert that length of pool uri, symbol, and name is greater than 0
      (asserts! (> (len uri) u0) ERR_INVALID_POOL_URI)
      (asserts! (> (len symbol) u0) ERR_INVALID_POOL_SYMBOL)
      (asserts! (> (len name) u0) ERR_INVALID_POOL_NAME)

      ;; Assert that midpoint-primary-numerator and midpoint-primary-denominator are greater than 0
      (asserts! (> midpoint-primary-numerator u0) ERR_INVALID_MIDPOINT_NUMERATOR)
      (asserts! (> midpoint-primary-denominator u0) ERR_INVALID_MIDPOINT_DENOMINATOR)

      ;; Assert that midpoint-withdraw-numerator and midpoint-withdraw-denominator are greater than 0
      (asserts! (> midpoint-withdraw-numerator u0) ERR_INVALID_MIDPOINT_NUMERATOR)
      (asserts! (> midpoint-withdraw-denominator u0) ERR_INVALID_MIDPOINT_DENOMINATOR)

      ;; Assert that fees are less than maximum BPS
      (asserts! (< (+ x-protocol-fee x-provider-fee) BPS) ERR_INVALID_FEE)
      (asserts! (< (+ y-protocol-fee y-provider-fee) BPS) ERR_INVALID_FEE)
      (asserts! (< liquidity-fee BPS) ERR_INVALID_FEE)

      ;; Create pool, set midpoint, set fees, set imbalanced withdraws, and set withdraw cooldown
      (try! (contract-call? pool-trait create-pool x-token-contract y-token-contract CONTRACT_DEPLOYER fee-address caller amplification-coefficient convergence-threshold new-pool-id name symbol uri status))
      (try! (contract-call? pool-trait set-midpoint midpoint-primary-numerator midpoint-primary-denominator midpoint-withdraw-numerator midpoint-withdraw-denominator))
      (try! (contract-call? pool-trait set-x-fees x-protocol-fee x-provider-fee))
      (try! (contract-call? pool-trait set-y-fees y-protocol-fee y-provider-fee))
      (try! (contract-call? pool-trait set-liquidity-fee liquidity-fee))
      (try! (contract-call? pool-trait set-imbalanced-withdraws imbalanced-withdraws))
      (try! (contract-call? pool-trait set-withdraw-cooldown withdraw-cooldown))

      ;; Freeze midpoint manager if freeze-midpoint-manager is true
      (if freeze-midpoint-manager (try! (contract-call? pool-trait set-freeze-midpoint-manager)) false)
      
      ;; Update ID of last created pool and add pool to pools map
      (var-set last-pool-id new-pool-id)
      (map-set pools new-pool-id {id: new-pool-id, name: name, symbol: symbol, pool-contract: pool-contract})
      
      ;; Transfer x-amount x tokens and y-amount y tokens from caller to pool-contract
      (try! (contract-call? x-token-trait transfer x-amount caller pool-contract none))
      (try! (contract-call? y-token-trait transfer y-amount caller pool-contract none))

      ;; Update pool balances and d value
      (try! (contract-call? pool-trait update-pool-balances x-amount y-amount total-shares))

      ;; Mint LP tokens to caller 
      (try! (contract-call? pool-trait pool-mint (- total-shares burn-amount) caller))
      
      ;; Mint burn amount LP tokens to pool-contract
      (try! (contract-call? pool-trait pool-mint burn-amount pool-contract))
      
      ;; Print create pool data and return true
      (print {
        action: "create-pool",
        caller: caller,
        data: {
          pool-id: new-pool-id,
          pool-name: name,
          pool-contract: pool-contract,
          x-token: x-token-contract,
          y-token: y-token-contract,
          x-protocol-fee: x-protocol-fee,
          x-provider-fee: x-provider-fee,
          y-protocol-fee: y-protocol-fee,
          y-provider-fee: y-provider-fee,
          liquidity-fee: liquidity-fee,
          x-amount: x-amount,
          y-amount: y-amount,
          burn-amount: burn-amount,
          midpoint-primary-numerator: midpoint-primary-numerator,
          midpoint-primary-denominator: midpoint-primary-denominator,
          midpoint-withdraw-numerator: midpoint-withdraw-numerator,
          midpoint-withdraw-denominator: midpoint-withdraw-denominator,
          midpoint-offset-value: midpoint-offset-value,
          total-shares: total-shares,
          pool-symbol: symbol,
          pool-uri: uri,
          pool-status: status,
          creation-height: burn-block-height,
          midpoint-manager: CONTRACT_DEPLOYER,
          fee-address: fee-address,
          amplification-coefficient: amplification-coefficient,
          convergence-threshold: convergence-threshold,
          imbalanced-withdraws: imbalanced-withdraws,
          withdraw-cooldown: withdraw-cooldown,
          freeze-midpoint-manager: freeze-midpoint-manager
        }
      })
      (ok true)
    )
  )
)

;; Swap x token for y token via a pool
(define-public (swap-x-for-y
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (min-dy uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (pool-contract (contract-of pool-trait))
    (fee-address (get fee-address pool-data))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (midpoint-numerator (get midpoint-primary-numerator pool-data))
    (midpoint-denominator (get midpoint-primary-denominator pool-data))
    (protocol-fee (get x-protocol-fee pool-data))
    (provider-fee (get x-provider-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))
    
    ;; Scale up pool balances and swap amounts to perform AMM calculations with get-y
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (swap-amounts-scaled (scale-up-amounts x-amount u0 x-token-trait y-token-trait))
    (x-amount-scaled (get x-amount swap-amounts-scaled))
    (x-amount-fees-protocol-scaled (/ (* x-amount-scaled protocol-fee) BPS))
    (x-amount-fees-provider-scaled (/ (* x-amount-scaled provider-fee) BPS))
    (x-amount-fees-total-scaled (+ x-amount-fees-protocol-scaled x-amount-fees-provider-scaled))
    (dx-scaled (- x-amount-scaled x-amount-fees-total-scaled))
    (updated-x-balance-scaled (+ x-balance-scaled dx-scaled x-amount-fees-provider-scaled))

    ;; Calculate updated pool balances using midpoint
    (dx-midpoint-scaled (/ (* dx-scaled midpoint-numerator) midpoint-denominator))
    (x-balance-midpoint-scaled (/ (* x-balance-scaled midpoint-numerator) midpoint-denominator))
    (updated-y-balance-scaled (get-y dx-midpoint-scaled x-balance-midpoint-scaled y-balance-scaled amplification-coefficient convergence-threshold))

    ;; Scale down to precise amounts for y and dy, as well as x-amount-fees-protocol and x-amount-fees-provider
    (updated-y-balance (get y-amount (scale-down-amounts u0 updated-y-balance-scaled x-token-trait y-token-trait)))
    (dy (- y-balance updated-y-balance))
    (x-amount-fees-protocol (get x-amount (scale-down-amounts x-amount-fees-protocol-scaled u0 x-token-trait y-token-trait)))
    (x-amount-fees-provider (get x-amount (scale-down-amounts x-amount-fees-provider-scaled u0 x-token-trait y-token-trait)))
    (x-amount-fees-total (+ x-amount-fees-protocol x-amount-fees-provider))
    (dx (- x-amount x-amount-fees-total))
    (updated-dx (+ dx x-amount-fees-provider))

    ;; Calculate midpoint offset and scale values
    (midpoint-offset-reversed (> midpoint-numerator midpoint-denominator))
    (midpoint-offset-value (calculate-midpoint-offset midpoint-numerator midpoint-denominator midpoint-offset-reversed))
    (midpoint-scale-value (if midpoint-offset-reversed midpoint-denominator midpoint-numerator))
    
    ;; Calculate offset pool balances and then get d
    (updated-x-balance-offset-scaled (if midpoint-offset-reversed u0 (/ (* updated-x-balance-scaled midpoint-offset-value) midpoint-scale-value)))
    (updated-x-balance-post-offset-scaled (- updated-x-balance-scaled updated-x-balance-offset-scaled))
    (updated-y-balance-offset-scaled (if midpoint-offset-reversed (/ (* updated-y-balance-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (updated-y-balance-post-offset-scaled (- updated-y-balance-scaled updated-y-balance-offset-scaled))
    (updated-d (get-d updated-x-balance-post-offset-scaled updated-y-balance-post-offset-scaled amplification-coefficient convergence-threshold))
    (caller tx-sender)
  )
    (begin
      ;; Assert that pool-status is true and correct token traits are used
      (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

      ;; Assert that x-amount is greater than 0 and less than x10 of x-balance
      (asserts! (and (> x-amount u0) (< x-amount (* x-balance MAX_AMOUNT_PER_BALANCE_MULTIPLIER))) ERR_INVALID_AMOUNT)
      
      ;; Assert that min-dy is greater than 0 and dy is greater than or equal to min-dy
      (asserts! (> min-dy u0) ERR_INVALID_AMOUNT)
      (asserts! (>= dy min-dy) ERR_MINIMUM_Y_AMOUNT)

      ;; Transfer updated-dx x tokens from caller to pool-contract
      (try! (contract-call? x-token-trait transfer updated-dx caller pool-contract none))

      ;; Transfer dy y tokens from pool contract to caller
      (try! (contract-call? pool-trait pool-transfer y-token-trait dy caller))

      ;; Transfer x-amount-fees-protocol x tokens from caller to fee-address
      (if (> x-amount-fees-protocol u0)
        (try! (contract-call? x-token-trait transfer x-amount-fees-protocol caller fee-address none))
        false
      )

      ;; Update pool balances and d value
      (try! (contract-call? pool-trait update-pool-balances (+ x-balance updated-dx) updated-y-balance updated-d))

      ;; Print swap data and return number of y tokens the caller received
      (print {
        action: "swap-x-for-y",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          x-amount: x-amount,
          x-amount-fees-protocol: x-amount-fees-protocol,
          x-amount-fees-provider: x-amount-fees-provider,
          midpoint-numerator: midpoint-numerator,
          midpoint-denominator: midpoint-denominator,
          dy: dy,
          min-dy: min-dy
        }
      })
      (ok dy)
    )
  )
)

;; Swap y token for x token via a pool
(define-public (swap-y-for-x
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (y-amount uint) (min-dx uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (pool-contract (contract-of pool-trait))
    (fee-address (get fee-address pool-data))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (midpoint-numerator (get midpoint-primary-numerator pool-data))
    (midpoint-denominator (get midpoint-primary-denominator pool-data))
    (protocol-fee (get y-protocol-fee pool-data))
    (provider-fee (get y-provider-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))

    ;; Scale up pool balances and swap amounts to perform AMM calculations with get-x
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (swap-amounts-scaled (scale-up-amounts u0 y-amount x-token-trait y-token-trait))
    (y-amount-scaled (get y-amount swap-amounts-scaled))
    (y-amount-fees-protocol-scaled (/ (* y-amount-scaled protocol-fee) BPS))
    (y-amount-fees-provider-scaled (/ (* y-amount-scaled provider-fee) BPS))
    (y-amount-fees-total-scaled (+ y-amount-fees-protocol-scaled y-amount-fees-provider-scaled))
    (dy-scaled (- y-amount-scaled y-amount-fees-total-scaled))
    (updated-y-balance-scaled (+ y-balance-scaled dy-scaled y-amount-fees-provider-scaled))

    ;; Calculate updated pool balances using midpoint
    (dy-midpoint-scaled (/ (* dy-scaled midpoint-denominator) midpoint-numerator))
    (y-balance-midpoint-scaled (/ (* y-balance-scaled midpoint-denominator) midpoint-numerator))
    (updated-x-balance-scaled (get-x dy-midpoint-scaled y-balance-midpoint-scaled x-balance-scaled amplification-coefficient convergence-threshold))

    ;; Scale down to precise amounts for x and dx, as well as y-amount-fees-protocol and y-amount-fees-provider
    (updated-x-balance (get x-amount (scale-down-amounts updated-x-balance-scaled u0 x-token-trait y-token-trait)))
    (dx (- x-balance updated-x-balance))
    (y-amount-fees-protocol (get y-amount (scale-down-amounts u0 y-amount-fees-protocol-scaled x-token-trait y-token-trait)))
    (y-amount-fees-provider (get y-amount (scale-down-amounts u0 y-amount-fees-provider-scaled x-token-trait y-token-trait)))
    (y-amount-fees-total (+ y-amount-fees-protocol y-amount-fees-provider))
    (dy (- y-amount y-amount-fees-total))
    (updated-dy (+ dy y-amount-fees-provider))

    ;; Calculate midpoint offset and scale values
    (midpoint-offset-reversed (> midpoint-numerator midpoint-denominator))
    (midpoint-offset-value (calculate-midpoint-offset midpoint-numerator midpoint-denominator midpoint-offset-reversed))
    (midpoint-scale-value (if midpoint-offset-reversed midpoint-denominator midpoint-numerator))
    
    ;; Calculate offset pool balances and then get d
    (updated-x-balance-offset-scaled (if midpoint-offset-reversed u0 (/ (* updated-x-balance-scaled midpoint-offset-value) midpoint-scale-value)))
    (updated-x-balance-post-offset-scaled (- updated-x-balance-scaled updated-x-balance-offset-scaled))
    (updated-y-balance-offset-scaled (if midpoint-offset-reversed (/ (* updated-y-balance-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (updated-y-balance-post-offset-scaled (- updated-y-balance-scaled updated-y-balance-offset-scaled))
    (updated-d (get-d updated-x-balance-post-offset-scaled updated-y-balance-post-offset-scaled amplification-coefficient convergence-threshold))
    (caller tx-sender)
  )
    (begin
      ;; Assert that pool-status is true and correct token traits are used
      (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

      ;; Assert that y-amount is greater than 0 and less than x10 of y-balance
      (asserts! (and (> y-amount u0) (< y-amount (* y-balance MAX_AMOUNT_PER_BALANCE_MULTIPLIER))) ERR_INVALID_AMOUNT)
      
      ;; Assert that min-dx is greater than 0 and dx is greater than or equal to min-dx
      (asserts! (> min-dx u0) ERR_INVALID_AMOUNT)
      (asserts! (>= dx min-dx) ERR_MINIMUM_X_AMOUNT)

      ;; Transfer updated-dy y tokens from caller to pool-contract
      (try! (contract-call? y-token-trait transfer updated-dy caller pool-contract none))

      ;; Transfer dx x tokens from pool contract to caller
      (try! (contract-call? pool-trait pool-transfer x-token-trait dx caller))

      ;; Transfer y-amount-fees-protocol y tokens from caller to fee-address
      (if (> y-amount-fees-protocol u0)
        (try! (contract-call? y-token-trait transfer y-amount-fees-protocol caller fee-address none))
        false
      )

      ;; Update pool balances and d value
      (try! (contract-call? pool-trait update-pool-balances updated-x-balance (+ y-balance updated-dy) updated-d))

      ;; Print swap data and return number of x tokens the caller received
      (print {
        action: "swap-y-for-x",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          y-amount: y-amount,
          y-amount-fees-protocol: y-amount-fees-protocol,
          y-amount-fees-provider: y-amount-fees-provider,
          midpoint-numerator: midpoint-numerator,
          midpoint-denominator: midpoint-denominator,
          dx: dx,
          min-dx: min-dx
        }
      })
      (ok dx)
    )
  )
)

;; Add liquidity to a pool
(define-public (add-liquidity
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (y-amount uint) (min-dlp uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (pool-contract (contract-of pool-trait))
    (fee-address (get fee-address pool-data))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (midpoint-numerator (get midpoint-primary-numerator pool-data))
    (midpoint-denominator (get midpoint-primary-denominator pool-data))
    (total-shares (get total-shares pool-data))
    (liquidity-fee (get liquidity-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))

    ;; Calculated updated pool balances
    (updated-x-balance (+ x-balance x-amount))
    (updated-y-balance (+ y-balance y-amount))

    ;; Scale up for AMM calculations depending on decimal places assigned to tokens
    (amounts-added-scaled (scale-up-amounts x-amount y-amount x-token-trait y-token-trait))
    (x-amount-scaled (get x-amount amounts-added-scaled))
    (y-amount-scaled (get y-amount amounts-added-scaled))
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (updated-pool-balances-scaled (scale-up-amounts updated-x-balance updated-y-balance x-token-trait y-token-trait))
    (updated-x-balance-scaled (get x-amount updated-pool-balances-scaled))
    (updated-y-balance-scaled (get y-amount updated-pool-balances-scaled))
    
    ;; Calculate midpoint offset and scale values
    (midpoint-offset-reversed (> midpoint-numerator midpoint-denominator))
    (midpoint-offset-value (calculate-midpoint-offset midpoint-numerator midpoint-denominator midpoint-offset-reversed))
    (midpoint-scale-value (if midpoint-offset-reversed midpoint-denominator midpoint-numerator))

    ;; Calculate offset pool balances
    (x-balance-offset-scaled (if midpoint-offset-reversed u0 (/ (* x-balance-scaled midpoint-offset-value) midpoint-scale-value)))
    (x-balance-post-offset-scaled (- x-balance-scaled x-balance-offset-scaled))
    (y-balance-offset-scaled (if midpoint-offset-reversed (/ (* y-balance-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (y-balance-post-offset-scaled (- y-balance-scaled y-balance-offset-scaled))

    ;; Calculate offset pool balances after adding x and y amounts
    (updated-x-balance-offset-scaled (if midpoint-offset-reversed u0 (/ (* updated-x-balance-scaled midpoint-offset-value) midpoint-scale-value)))
    (updated-x-balance-post-offset-scaled (- updated-x-balance-scaled updated-x-balance-offset-scaled))
    (updated-y-balance-offset-scaled (if midpoint-offset-reversed (/ (* updated-y-balance-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (updated-y-balance-post-offset-scaled (- updated-y-balance-scaled updated-y-balance-offset-scaled))
    
    ;; Calculate ideal pool balances
    (d-a (get-d x-balance-post-offset-scaled y-balance-post-offset-scaled amplification-coefficient convergence-threshold))
    (d-b (get-d updated-x-balance-post-offset-scaled updated-y-balance-post-offset-scaled amplification-coefficient convergence-threshold))
    (ideal-x-balance-scaled (/ (* d-b x-balance-scaled) d-a))
    (ideal-y-balance-scaled (/ (* d-b y-balance-scaled) d-a))
    (x-difference (if (> ideal-x-balance-scaled updated-x-balance-scaled) (- ideal-x-balance-scaled updated-x-balance-scaled) (- updated-x-balance-scaled ideal-x-balance-scaled)))
    (y-difference (if (> ideal-y-balance-scaled updated-y-balance-scaled) (- ideal-y-balance-scaled updated-y-balance-scaled) (- updated-y-balance-scaled ideal-y-balance-scaled)))
    
    ;; Calculate fees to apply if adding imbalanced liquidity
    (ideal-x-amount-fee-liquidity-scaled (/ (* x-difference liquidity-fee) BPS))
    (ideal-y-amount-fee-liquidity-scaled (/ (* y-difference liquidity-fee) BPS))
    (x-amount-fee-liquidity-scaled (if (> x-amount-scaled ideal-x-amount-fee-liquidity-scaled) ideal-x-amount-fee-liquidity-scaled x-amount-scaled))
    (y-amount-fee-liquidity-scaled (if (> y-amount-scaled ideal-y-amount-fee-liquidity-scaled) ideal-y-amount-fee-liquidity-scaled y-amount-scaled))
    (updated-x-amount-scaled (- x-amount-scaled x-amount-fee-liquidity-scaled))
    (updated-y-amount-scaled (- y-amount-scaled y-amount-fee-liquidity-scaled))
    (updated-balance-x-post-fee-scaled (+ x-balance-scaled updated-x-amount-scaled))
    (updated-balance-y-post-fee-scaled (+ y-balance-scaled updated-y-amount-scaled))

    ;; Calculate offset pool balances post fees and then get d
    (updated-balance-x-post-fee-offset-scaled (if midpoint-offset-reversed u0 (/ (* updated-balance-x-post-fee-scaled midpoint-offset-value) midpoint-scale-value)))
    (updated-balance-x-post-fee-and-offset-scaled (- updated-balance-x-post-fee-scaled updated-balance-x-post-fee-offset-scaled))
    (updated-balance-y-post-fee-offset-scaled (if midpoint-offset-reversed (/ (* updated-balance-y-post-fee-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (updated-balance-y-post-fee-and-offset-scaled (- updated-balance-y-post-fee-scaled updated-balance-y-post-fee-offset-scaled))
    (updated-d (get-d updated-balance-x-post-fee-and-offset-scaled updated-balance-y-post-fee-and-offset-scaled amplification-coefficient convergence-threshold))
    
    ;; Scale down for precise token balance updates and transfers
    (precise-fees-liquidity (scale-down-amounts x-amount-fee-liquidity-scaled y-amount-fee-liquidity-scaled x-token-trait y-token-trait))
    (x-amount-fees-liquidity (get x-amount precise-fees-liquidity))
    (y-amount-fees-liquidity (get y-amount precise-fees-liquidity))
    (amounts-added (scale-down-amounts updated-x-amount-scaled updated-y-amount-scaled x-token-trait y-token-trait))
    (updated-x-amount (get x-amount amounts-added))
    (updated-y-amount (get y-amount amounts-added))
    (updated-pool-balances-post-fee (scale-down-amounts updated-balance-x-post-fee-scaled updated-balance-y-post-fee-scaled x-token-trait y-token-trait))
    (updated-x-balance-post-fee (get x-amount updated-pool-balances-post-fee))
    (updated-y-balance-post-fee (get y-amount updated-pool-balances-post-fee))

    ;; Check that updated-d is greater than d-a and calculate dlp
    (minimum-d-check (asserts! (> updated-d d-a) ERR_MINIMUM_D_VALUE))
    (dlp (/ (* total-shares (- updated-d d-a)) d-a))
    (caller tx-sender)
  )
    (begin
      ;; Assert that pool-status is true and correct token traits are used
      (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

      ;; Assert that x-amount + y-amount is greater than 0
      (asserts! (> (+ x-amount y-amount) u0) ERR_INVALID_AMOUNT)

      ;; Assert that x-amount and y-amount are less than x10 of x-balance and y-balance
      (asserts! (< x-amount (* x-balance MAX_AMOUNT_PER_BALANCE_MULTIPLIER)) ERR_INVALID_AMOUNT)
      (asserts! (< y-amount (* y-balance MAX_AMOUNT_PER_BALANCE_MULTIPLIER)) ERR_INVALID_AMOUNT)

      ;; Assert that min-dlp is greater than 0 and dlp is greater than or equal to min-dlp
      (asserts! (> min-dlp u0) ERR_INVALID_AMOUNT)
      (asserts! (>= dlp min-dlp) ERR_MINIMUM_LP_AMOUNT)

      ;; Transfer updated-x-amount x tokens from caller to pool-contract
      (if (> updated-x-amount u0)
        (try! (contract-call? x-token-trait transfer updated-x-amount caller pool-contract none))
        false
      )

      ;; Transfer updated-y-amount y tokens from caller to pool-contract
      (if (> updated-y-amount u0)
        (try! (contract-call? y-token-trait transfer updated-y-amount caller pool-contract none))
        false
      )

      ;; Transfer x-amount-fees-liquidity x tokens from caller to fee-address
      (if (> x-amount-fees-liquidity u0)
        (try! (contract-call? x-token-trait transfer x-amount-fees-liquidity caller fee-address none))
        false
      )

      ;; Transfer y-amount-fees-liquidity y tokens from caller to fee-address
      (if (> y-amount-fees-liquidity u0)
        (try! (contract-call? y-token-trait transfer y-amount-fees-liquidity caller fee-address none))
        false
      )

      ;; Update pool balances and d value
      (try! (contract-call? pool-trait update-pool-balances updated-x-balance-post-fee updated-y-balance-post-fee updated-d))
      
      ;; Mint LP tokens to caller
      (try! (contract-call? pool-trait pool-mint dlp caller))

      ;; Print add liquidity data and return number of LP tokens caller received
      (print {
        action: "add-liquidity",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: pool-contract,
          x-token: x-token,
          y-token: y-token,
          x-amount: updated-x-amount,
          y-amount: updated-y-amount,
          x-amount-fees-liquidity: x-amount-fees-liquidity,
          y-amount-fees-liquidity: y-amount-fees-liquidity,
          midpoint-numerator: midpoint-numerator,
          midpoint-denominator: midpoint-denominator,
          midpoint-offset-value: midpoint-offset-value,
          dlp: dlp,
          min-dlp: min-dlp
        }
      })
      (ok dlp)
    )
  )
)

;; Withdraw proportional liquidity from a pool
(define-public (withdraw-proportional-liquidity
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (amount uint) (min-x-amount uint) (min-y-amount uint)
  )
  (let (
    ;; Gather all pool data and check if pool is valid
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (midpoint-numerator (get midpoint-withdraw-numerator pool-data))
    (midpoint-denominator (get midpoint-withdraw-denominator pool-data))
    (total-shares (get total-shares pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))
    (last-midpoint-update (get last-midpoint-update pool-data))
    (withdraw-cooldown (get withdraw-cooldown pool-data))

    ;; Calculate midpoint offset and scale values
    (midpoint-offset-reversed (> midpoint-numerator midpoint-denominator))
    (midpoint-offset-value (calculate-midpoint-offset midpoint-numerator midpoint-denominator midpoint-offset-reversed))
    (midpoint-scale-value (if midpoint-offset-reversed midpoint-denominator midpoint-numerator))

    ;; Calculate offset pool balances
    (x-balance-offset (if midpoint-offset-reversed u0 (/ (* x-balance midpoint-offset-value) midpoint-scale-value)))
    (x-balance-post-offset (- x-balance x-balance-offset))
    (y-balance-offset (if midpoint-offset-reversed (/ (* y-balance midpoint-offset-value) midpoint-scale-value) u0))
    (y-balance-post-offset (- y-balance y-balance-offset))

    ;; Calculate x and y amounts
    (x-amount (/ (* amount x-balance-post-offset) total-shares))
    (y-amount (/ (* amount y-balance-post-offset) total-shares))

    ;; Calculate updated pool balances
    (updated-x-balance (- x-balance x-amount))
    (updated-y-balance (- y-balance y-amount))

    ;; Calculate offset pool balances and then get d
    (updated-x-balance-offset (if midpoint-offset-reversed u0 (/ (* updated-x-balance midpoint-offset-value) midpoint-scale-value)))
    (updated-x-balance-post-offset (- updated-x-balance updated-x-balance-offset))
    (updated-y-balance-offset (if midpoint-offset-reversed (/ (* updated-y-balance midpoint-offset-value) midpoint-scale-value) u0))
    (updated-y-balance-post-offset (- updated-y-balance updated-y-balance-offset))

    ;; Scale up updated offset pool balances and calculate updated-d
    (updated-pool-balances-post-offset-scaled (scale-up-amounts updated-x-balance-post-offset updated-y-balance-post-offset x-token-trait y-token-trait))
    (updated-x-balance-post-offset-scaled (get x-amount updated-pool-balances-post-offset-scaled))
    (updated-y-balance-post-offset-scaled (get y-amount updated-pool-balances-post-offset-scaled))
    (updated-d (get-d updated-x-balance-post-offset-scaled updated-y-balance-post-offset-scaled amplification-coefficient convergence-threshold))
    (caller tx-sender)
  )
    (begin
      ;; Assert that correct token traits are used
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

      ;; Assert that amount is greater than 0
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)

      ;; Assert that x-amount + y-amount is greater than 0
      (asserts! (> (+ x-amount y-amount) u0) ERR_INVALID_AMOUNT)

      ;; Assert that x-amount is greater than or equal to min-x-amount
      (asserts! (>= x-amount min-x-amount) ERR_MINIMUM_X_AMOUNT)

      ;; Assert that y-amount is greater than or equal to min-y-amount
      (asserts! (>= y-amount min-y-amount) ERR_MINIMUM_Y_AMOUNT)

      ;; Assert that withdraw cooldown period has passed
      (asserts! (>= stacks-block-height (+ last-midpoint-update withdraw-cooldown)) ERR_WITHDRAW_COOLDOWN)

      ;; Transfer x-amount x tokens from pool contract to caller
      (if (> x-amount u0)
        (try! (contract-call? pool-trait pool-transfer x-token-trait x-amount caller))
        false
      )
      
      ;; Transfer y-amount y tokens from pool contract to caller
      (if (> y-amount u0)
        (try! (contract-call? pool-trait pool-transfer y-token-trait y-amount caller))
        false
      )

      ;; Update pool balances and d value
      (try! (contract-call? pool-trait update-pool-balances updated-x-balance updated-y-balance updated-d))
      
      ;; Burn LP tokens from caller
      (try! (contract-call? pool-trait pool-burn amount caller))
      
      ;; Print withdraw liquidity data and return number of x and y tokens caller received
      (print {
        action: "withdraw-proportional-liquidity",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          x-token: x-token,
          y-token: y-token,
          amount: amount,
          x-amount: x-amount,
          y-amount: y-amount,
          min-x-amount: min-x-amount,
          min-y-amount: min-y-amount,
          midpoint-numerator: midpoint-numerator,
          midpoint-denominator: midpoint-denominator,
          midpoint-offset-value: midpoint-offset-value
        }
      })
      (ok {x-amount: x-amount, y-amount: y-amount})
    )
  )
)

;; Withdraw imbalanced liquidity from a pool
(define-public (withdraw-imbalanced-liquidity
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (y-amount uint) (max-dlp uint)
  )
  (let (
    ;; Gather all pool data, check if pool is valid, and check if imbalanced withdraws are enabled
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (imbalanced-withdraws-check (asserts! (and (var-get global-imbalanced-withdraws) (get imbalanced-withdraws pool-data)) ERR_IMBALANCED_WITHDRAWS_DISABLED))
    (fee-address (get fee-address pool-data))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (midpoint-numerator (get midpoint-withdraw-numerator pool-data))
    (midpoint-denominator (get midpoint-withdraw-denominator pool-data))
    (total-shares (get total-shares pool-data))
    (liquidity-fee (get liquidity-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))
    (last-midpoint-update (get last-midpoint-update pool-data))
    (withdraw-cooldown (get withdraw-cooldown pool-data))

    ;; Assert that x-amount and y-amount are less than x-balance and y-balance
    (x-amount-check (asserts! (< x-amount x-balance) ERR_INVALID_AMOUNT))
    (y-amount-check (asserts! (< y-amount y-balance) ERR_INVALID_AMOUNT))

    ;; Calculate updated pool balances
    (updated-x-balance (- x-balance x-amount))
    (updated-y-balance (- y-balance y-amount))

    ;; Scale up for AMM calculations depending on decimal places assigned to tokens
    (amounts-withdrawn-scaled (scale-up-amounts x-amount y-amount x-token-trait y-token-trait))
    (x-amount-scaled (get x-amount amounts-withdrawn-scaled))
    (y-amount-scaled (get y-amount amounts-withdrawn-scaled))
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (updated-pool-balances-scaled (scale-up-amounts updated-x-balance updated-y-balance x-token-trait y-token-trait))
    (updated-x-balance-scaled (get x-amount updated-pool-balances-scaled))
    (updated-y-balance-scaled (get y-amount updated-pool-balances-scaled))

    ;; Calculate midpoint offset and scale values
    (midpoint-offset-reversed (> midpoint-numerator midpoint-denominator))
    (midpoint-offset-value (calculate-midpoint-offset midpoint-numerator midpoint-denominator midpoint-offset-reversed))
    (midpoint-scale-value (if midpoint-offset-reversed midpoint-denominator midpoint-numerator))

    ;; Calculate offset pool balances
    (x-balance-offset-scaled (if midpoint-offset-reversed u0 (/ (* x-balance-scaled midpoint-offset-value) midpoint-scale-value)))
    (x-balance-post-offset-scaled (- x-balance-scaled x-balance-offset-scaled))
    (y-balance-offset-scaled (if midpoint-offset-reversed (/ (* y-balance-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (y-balance-post-offset-scaled (- y-balance-scaled y-balance-offset-scaled))

    ;; Calculate offset pool balances after withdrawing x and y amounts
    (updated-x-balance-offset-scaled (if midpoint-offset-reversed u0 (/ (* updated-x-balance-scaled midpoint-offset-value) midpoint-scale-value)))
    (updated-x-balance-post-offset-scaled (- updated-x-balance-scaled updated-x-balance-offset-scaled))
    (updated-y-balance-offset-scaled (if midpoint-offset-reversed (/ (* updated-y-balance-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (updated-y-balance-post-offset-scaled (- updated-y-balance-scaled updated-y-balance-offset-scaled))

    ;; Calculate ideal pool balances
    (d-a (get-d x-balance-post-offset-scaled y-balance-post-offset-scaled amplification-coefficient convergence-threshold))
    (d-b (get-d updated-x-balance-post-offset-scaled updated-y-balance-post-offset-scaled amplification-coefficient convergence-threshold))
    (ideal-x-balance-scaled (/ (* d-b x-balance-scaled) d-a))
    (ideal-y-balance-scaled (/ (* d-b y-balance-scaled) d-a))
    (x-difference (if (> ideal-x-balance-scaled updated-x-balance-scaled) (- ideal-x-balance-scaled updated-x-balance-scaled) (- updated-x-balance-scaled ideal-x-balance-scaled)))
    (y-difference (if (> ideal-y-balance-scaled updated-y-balance-scaled) (- ideal-y-balance-scaled updated-y-balance-scaled) (- updated-y-balance-scaled ideal-y-balance-scaled)))
    
    ;; Calculate fees to apply if withdrawing imbalanced liquidity
    (ideal-x-amount-fee-liquidity-scaled (/ (* x-difference liquidity-fee) BPS))
    (ideal-y-amount-fee-liquidity-scaled (/ (* y-difference liquidity-fee) BPS))
    (x-amount-fee-liquidity-scaled (if (> x-amount-scaled ideal-x-amount-fee-liquidity-scaled) ideal-x-amount-fee-liquidity-scaled x-amount-scaled))
    (y-amount-fee-liquidity-scaled (if (> y-amount-scaled ideal-y-amount-fee-liquidity-scaled) ideal-y-amount-fee-liquidity-scaled y-amount-scaled))
    (updated-x-amount-scaled (- x-amount-scaled x-amount-fee-liquidity-scaled))
    (updated-y-amount-scaled (- y-amount-scaled y-amount-fee-liquidity-scaled))
    (updated-balance-x-post-fee-scaled (- x-balance-scaled x-amount-scaled))
    (updated-balance-y-post-fee-scaled (- y-balance-scaled y-amount-scaled))

    ;; Calculate offset pool balances post fees and then get d
    (updated-balance-x-post-fee-offset-scaled (if midpoint-offset-reversed u0 (/ (* updated-balance-x-post-fee-scaled midpoint-offset-value) midpoint-scale-value)))
    (updated-balance-x-post-fee-and-offset-scaled (- updated-balance-x-post-fee-scaled updated-balance-x-post-fee-offset-scaled))
    (updated-balance-y-post-fee-offset-scaled (if midpoint-offset-reversed (/ (* updated-balance-y-post-fee-scaled midpoint-offset-value) midpoint-scale-value) u0))
    (updated-balance-y-post-fee-and-offset-scaled (- updated-balance-y-post-fee-scaled updated-balance-y-post-fee-offset-scaled))
    (updated-d (get-d updated-balance-x-post-fee-and-offset-scaled updated-balance-y-post-fee-and-offset-scaled amplification-coefficient convergence-threshold))

    ;; Scale down for precise token balance updates and transfers
    (precise-fees-liquidity (scale-down-amounts x-amount-fee-liquidity-scaled y-amount-fee-liquidity-scaled x-token-trait y-token-trait))
    (x-amount-fees-liquidity (get x-amount precise-fees-liquidity))
    (y-amount-fees-liquidity (get y-amount precise-fees-liquidity))
    (amounts-withdrawn (scale-down-amounts updated-x-amount-scaled updated-y-amount-scaled x-token-trait y-token-trait))
    (updated-x-amount (get x-amount amounts-withdrawn))
    (updated-y-amount (get y-amount amounts-withdrawn))
    (updated-pool-balances-post-fee (scale-down-amounts updated-balance-x-post-fee-scaled updated-balance-y-post-fee-scaled x-token-trait y-token-trait))
    (updated-x-balance-post-fee (get x-amount updated-pool-balances-post-fee))
    (updated-y-balance-post-fee (get y-amount updated-pool-balances-post-fee))

    ;; Check that d-a is greater than updated-d and calculate number of LP tokens to burn
    (minimum-d-check (asserts! (> d-a updated-d) ERR_MINIMUM_D_VALUE))
    (dlp (/ (+ (* total-shares (- d-a updated-d)) (- d-a u1)) d-a))
    (caller tx-sender)
  )
    (begin
      ;; Assert that correct token traits are used
      (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
      (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)

      ;; Assert that x-amount + y-amount is greater than 0
      (asserts! (> (+ x-amount y-amount) u0) ERR_INVALID_AMOUNT)

      ;; Assert that max-dlp is greater than 0 and dlp is less than or equal to max-dlp
      (asserts! (> max-dlp u0) ERR_INVALID_AMOUNT)
      (asserts! (<= dlp max-dlp) ERR_MAXIMUM_LP_AMOUNT)

      ;; Assert that dlp is less than total-shares
      (asserts! (< dlp total-shares) ERR_INVALID_AMOUNT)

      ;; Assert that withdraw cooldown period has passed
      (asserts! (>= stacks-block-height (+ last-midpoint-update withdraw-cooldown)) ERR_WITHDRAW_COOLDOWN)

      ;; Transfer updated-x-amount x tokens from pool contract to caller
      (if (> updated-x-amount u0)
        (try! (contract-call? pool-trait pool-transfer x-token-trait updated-x-amount caller))
        false
      )
      
      ;; Transfer updated-y-amount y tokens from pool contract to caller
      (if (> updated-y-amount u0)
        (try! (contract-call? pool-trait pool-transfer y-token-trait updated-y-amount caller))
        false
      )

      ;; Transfer x-amount-fees-liquidity x tokens from pool contract to fee-address
      (if (> x-amount-fees-liquidity u0)
        (try! (contract-call? pool-trait pool-transfer x-token-trait x-amount-fees-liquidity fee-address))
        false
      )

      ;; Transfer y-amount-fees-liquidity y tokens from pool contract to fee-address
      (if (> y-amount-fees-liquidity u0)
        (try! (contract-call? pool-trait pool-transfer y-token-trait y-amount-fees-liquidity fee-address))
        false
      )

      ;; Update pool balances and d value
      (try! (contract-call? pool-trait update-pool-balances updated-x-balance-post-fee updated-y-balance-post-fee updated-d))
      
      ;; Burn LP tokens from caller
      (try! (contract-call? pool-trait pool-burn dlp caller))
      
      ;; Print withdraw liquidity data and return number of x and y tokens caller received and number of LP tokens burnt
      (print {
        action: "withdraw-imbalanced-liquidity",
        caller: caller,
        data: {
          pool-id: (get pool-id pool-data),
          pool-name: (get pool-name pool-data),
          pool-contract: (contract-of pool-trait),
          x-token: x-token,
          y-token: y-token,
          x-amount: x-amount,
          y-amount: y-amount,
          dlp: dlp,
          max-dlp: max-dlp,
          x-amount-fees-liquidity: x-amount-fees-liquidity,
          y-amount-fees-liquidity: y-amount-fees-liquidity,
          midpoint-numerator: midpoint-numerator,
          midpoint-denominator: midpoint-denominator,
          midpoint-offset-value: midpoint-offset-value
        }
      })
      (ok {x-amount: updated-x-amount, y-amount: updated-y-amount, dlp: dlp})
    )
  )
)

;; Add an admin to the admins list
(define-public (add-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    ;; Assert caller is an existing admin and new admin is not in admins-list
    (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (index-of admins-list admin)) ERR_ALREADY_ADMIN)
    
    ;; Add admin to list with max length of 5
    (var-set admins (unwrap! (as-max-len? (append admins-list admin) u5) ERR_ADMIN_LIMIT_REACHED))
    
    ;; Print add admin data and return true
    (print {action: "add-admin", caller: caller, data: {admin: admin}})
    (ok true)
  )
)

;; Remove an admin from the admins list
(define-public (remove-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    ;; Assert caller is an existing admin and admin to remove is in admins-list
    (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-some (index-of admins-list admin)) ERR_ADMIN_NOT_IN_LIST)

    ;; Assert contract deployer cannot be removed
    (asserts! (not (is-eq admin CONTRACT_DEPLOYER)) ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER)

    ;; Set admin-helper to admin to remove and filter admins-list to remove admin
    (var-set admin-helper admin)
    (var-set admins (filter admin-not-removable admins-list))

    ;; Print remove admin data and return true
    (print {action: "remove-admin", caller: caller, data: {admin: admin}})
    (ok true)
  )
)

;; Set pool uri for multiple pools
(define-public (set-pool-uri-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (uris (list 120 (string-utf8 256)))
  )
  (ok (map set-pool-uri pool-traits uris))
)

;; Set pool status for multiple pools
(define-public (set-pool-status-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (statuses (list 120 bool))
  )
  (ok (map set-pool-status pool-traits statuses))
)

;; Set midpoint manager for multiple pools
(define-public (set-midpoint-manager-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (managers (list 120 principal))
  )
  (ok (map set-midpoint-manager pool-traits managers))
)

;; Set fee address for multiple pools
(define-public (set-fee-address-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (addresses (list 120 principal))
  )
  (ok (map set-fee-address pool-traits addresses))
)

;; Set midpoint for multiple pools
(define-public (set-midpoint-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (primary-numerators (list 120 uint)) (primary-denominators (list 120 uint))
    (withdraw-numerators (list 120 uint)) (withdraw-denominators (list 120 uint))
  )
  (ok (map set-midpoint pool-traits primary-numerators primary-denominators withdraw-numerators withdraw-denominators))
)

;; Set x fees for multiple pools
(define-public (set-x-fees-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (protocol-fees (list 120 uint)) (provider-fees (list 120 uint))
  )
  (ok (map set-x-fees pool-traits protocol-fees provider-fees))
)

;; Set y fees for multiple pools
(define-public (set-y-fees-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (protocol-fees (list 120 uint)) (provider-fees (list 120 uint))
  )
  (ok (map set-y-fees pool-traits protocol-fees provider-fees))
)

;; Set liquidity fee for multiple pools
(define-public (set-liquidity-fee-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (fees (list 120 uint))
  )
  (ok (map set-liquidity-fee pool-traits fees))
)

;; Set amplification coefficient for multiple pools
(define-public (set-amplification-coefficient-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (coefficients (list 120 uint))
  )
  (ok (map set-amplification-coefficient pool-traits coefficients))
)

;; Set convergence threshold for multiple pools
(define-public (set-convergence-threshold-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (thresholds (list 120 uint))
  )
  (ok (map set-convergence-threshold pool-traits thresholds))
)

;; Set imbalanced withdraws for multiple pools
(define-public (set-imbalanced-withdraws-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (statuses (list 120 bool))
  )
  (ok (map set-imbalanced-withdraws pool-traits statuses))
)

;; Set withdraw cooldown for multiple pools
(define-public (set-withdraw-cooldown-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (cooldowns (list 120 uint))
  )
  (ok (map set-withdraw-cooldown pool-traits cooldowns))
)

;; Set freeze midpoint manager for multiple pools
(define-public (set-freeze-midpoint-manager-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
  )
  (ok (map set-freeze-midpoint-manager pool-traits))
)

;; Helper function for removing an admin
(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

;; Create pool symbol using x token and y token symbols
(define-private (create-symbol (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>))
  (let (
    ;; Get x token and y token symbols
    (x-symbol (unwrap-panic (contract-call? x-token-trait get-symbol)))
    (y-symbol (unwrap-panic (contract-call? y-token-trait get-symbol)))
    
    ;; Truncate symbols if length exceeds 14
    (x-truncated 
      (if (> (len x-symbol) u14)
        (unwrap-panic (slice? x-symbol u0 u14))
        x-symbol
      )
    )
    (y-truncated
      (if (> (len y-symbol) u14)
        (unwrap-panic (slice? y-symbol u0 u14))
        y-symbol
      )
    )
  )
    ;; Return pool symbol with max length of 29
    (as-max-len? (concat x-truncated (concat "-" y-truncated)) u29)
  )
)

;; Check if a pool is valid
(define-private (is-valid-pool (id uint) (contract principal))
  (let (
    (pool-data (unwrap! (map-get? pools id) false))
  )
    (is-eq contract (get pool-contract pool-data))
  )
)

;; Helper for get x
(define-private (fold-x-for-loop (n uint) (static-data {x: uint, c: uint, b: uint, d: uint, threshold: uint, converged: uint})) 
  (let (
    (current-x (get x static-data))
    (current-c (get c static-data))
    (current-b (get b static-data))
    (current-d (get d static-data))
    (current-threshold (get threshold static-data))
    (current-converged (get converged static-data))
    (x-numerator (+ (* current-x current-x) current-c))
    (x-denominator (- (+ (* NUM_OF_TOKENS current-x) current-b) current-d))
    (new-x (/ x-numerator x-denominator))
  )
    (if (is-eq current-converged u0)
      (if (> new-x  current-x)
        (if (<= (- new-x current-x) current-threshold)
          {x: new-x, c: current-c, b: current-b, d: current-d, threshold: current-threshold, converged: new-x}
          {x: new-x, c: current-c, b: current-b, d: current-d, threshold: current-threshold, converged: u0}
        )
        (if (<= (- current-x new-x) current-threshold)
          {x: new-x, c: current-c, b: current-b, d: current-d, threshold: current-threshold, converged: new-x}
          {x: new-x, c: current-c, b: current-b, d: current-d, threshold: current-threshold, converged: u0}
        )
      )
      static-data
    )
  )
)

;; Helper for get y
(define-private (fold-y-for-loop (n uint) (static-data {y: uint, c: uint, b: uint, d: uint, threshold: uint, converged: uint})) 
  (let (
    (current-y (get y static-data))
    (current-c (get c static-data))
    (current-b (get b static-data))
    (current-d (get d static-data))
    (current-threshold (get threshold static-data))
    (current-converged (get converged static-data))
    (y-numerator (+ (* current-y current-y) current-c))
    (y-denominator (- (+ (* NUM_OF_TOKENS current-y) current-b) current-d))
    (new-y (/ y-numerator y-denominator))
  )
    (if (is-eq current-converged u0)
      (if (> new-y current-y)
        (if (<= (- new-y current-y) current-threshold)
          {y: new-y, c: current-c, b: current-b, d: current-d, threshold: current-threshold, converged: new-y}
          {y: new-y, c: current-c, b: current-b, d: current-d, threshold: current-threshold, converged: u0}
        )
        (if (<= (- current-y new-y) current-threshold)
          {y: new-y, c: current-c, b: current-b, d: current-d, threshold: current-threshold, converged: new-y}
          {y: new-y, c: current-c, b: current-b, d: current-d, threshold: current-threshold, converged: u0}
        )
      )
      static-data
    )
  )
)

;; Helper for get-d
(define-private (fold-d-for-loop (n uint) (static-data {x-bal: uint, y-bal: uint, d: uint, an: uint, threshold: uint, converged: uint})) 
  (let (
    ;; Gather all data from static-data
    (current-x-balance (get x-bal static-data))
    (current-y-balance (get y-bal static-data))
    (current-s (+ current-x-balance current-y-balance))
    (current-d-partial (get d static-data))
    (current-d (get d static-data))
    (current-an (get an static-data))
    (current-threshold (get threshold static-data))
    (current-converged (get converged static-data))

    ;; Start logic for calculating new d
    ;; Calculate new partial d with respect to x
    (new-d-partial-x (/ (* current-d current-d-partial) (* NUM_OF_TOKENS current-x-balance)))
    
    ;; Calculate new partial d with respect to new x and y
    (new-d-partial (/ (* current-d new-d-partial-x) (* NUM_OF_TOKENS current-y-balance)))
    (new-numerator (* (+ (* current-an current-s) (* NUM_OF_TOKENS new-d-partial)) current-d))
    (new-denominator (+ (* (- current-an u1) current-d) (* (+ NUM_OF_TOKENS u1) new-d-partial)))
    (new-d (/ new-numerator new-denominator))         
  )
    ;; Check if converged value or new d was already found
    (if (is-eq current-converged u0)
      (if (> new-d current-d)
        (if (<= (- new-d current-d) current-threshold)
          {x-bal: current-x-balance, y-bal: current-y-balance, d: new-d, an: current-an, threshold: current-threshold, converged: new-d}
          {x-bal: current-x-balance, y-bal: current-y-balance, d: new-d, an: current-an, threshold: current-threshold, converged: u0}
        )
        (if (<= (- current-d new-d) current-threshold)
          {x-bal: current-x-balance, y-bal: current-y-balance, d: new-d, an: current-an, threshold: current-threshold, converged: new-d}
          {x-bal: current-x-balance, y-bal: current-y-balance, d: new-d, an: current-an, threshold: current-threshold, converged: u0}
        )
      )
      static-data
    )
  )
)

;; Scale up token amounts to the same level of precision before performing AMM calculations
(define-private (scale-up-amounts (x-amount uint) (y-amount uint) (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>))
  (let (
    ;; Get decimals for x and y tokens
    (x-decimals (unwrap-panic (contract-call? x-token-trait get-decimals)))
    (y-decimals (unwrap-panic (contract-call? y-token-trait get-decimals)))

    ;; Scale x amount and y amounts
    (x-amount-scaled
      (if (is-eq x-decimals y-decimals)
        x-amount
        (if (> x-decimals y-decimals)
          x-amount
          (* x-amount (pow u10 (- y-decimals x-decimals)))
        )
      )
    )
    (y-amount-scaled
      (if (is-eq x-decimals y-decimals)
        y-amount
        (if (> y-decimals x-decimals)
          y-amount
          (* y-amount (pow u10 (- x-decimals y-decimals)))
        )
      )
    )
  )
    ;; Return scaled x and y amounts
    {x-amount: x-amount-scaled, y-amount: y-amount-scaled}
  )
)

;; Scale down token amounts to their respective levels of precision before performing any transfers
(define-private (scale-down-amounts (x-amount uint) (y-amount uint) (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>))
  (let (
    ;; Get decimals for x and y tokens
    (x-decimals (unwrap-panic (contract-call? x-token-trait get-decimals)))
    (y-decimals (unwrap-panic (contract-call? y-token-trait get-decimals)))
    
    ;; Scale x and y amounts
    (x-amount-scaled
      (if (is-eq x-decimals y-decimals)
        x-amount
        (if (> x-decimals y-decimals)
          x-amount
          (/ x-amount (pow u10 (- y-decimals x-decimals)))
        )
      )
    )
    (y-amount-scaled
      (if (is-eq x-decimals y-decimals)
        y-amount
        (if (> y-decimals x-decimals)
          y-amount
          (/ y-amount (pow u10 (- x-decimals y-decimals)))
        )
      )
    )
  )
    ;; Return scaled x and y amounts
    {x-amount: x-amount-scaled, y-amount: y-amount-scaled}
  )
)

;; Calculates the midpoint offset used in core functions
(define-private (calculate-midpoint-offset (numerator uint) (denominator uint) (reversed bool))
  (if reversed
    (- denominator (/ (* denominator denominator) numerator))
    (- numerator (/ (* numerator numerator) denominator))
  )
)