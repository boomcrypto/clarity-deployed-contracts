
;; stableswap-core-v-1-1

(use-trait stableswap-pool-trait .stableswap-pool-trait-v-1-1.stableswap-pool-trait)
(use-trait sip-010-trait .sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_INVALID_PRINCIPAL (err u1003))
(define-constant ERR_ALREADY_ADMIN (err u2001))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u2002))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u2003))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u2004))
(define-constant ERR_NO_POOL_DATA (err u3001))
(define-constant ERR_POOL_NOT_CREATED (err u3002))
(define-constant ERR_POOL_DISABLED (err u3003))
(define-constant ERR_POOL_ALREADY_CREATED (err u3004))
(define-constant ERR_INVALID_POOL (err u3005))
(define-constant ERR_INVALID_POOL_URI (err u3006))
(define-constant ERR_INVALID_POOL_SYMBOL (err u3007))
(define-constant ERR_INVALID_POOL_NAME (err u3008))
(define-constant ERR_MATCHING_TOKEN_CONTRACTS (err u3010))
(define-constant ERR_INVALID_X_TOKEN (err u3011))
(define-constant ERR_INVALID_Y_TOKEN (err u3012))
(define-constant ERR_MINIMUM_X_AMOUNT (err u3013))
(define-constant ERR_MINIMUM_Y_AMOUNT (err u3014))
(define-constant ERR_MINIMUM_LP_AMOUNT (err u3015))
(define-constant ERR_UNEQUAL_POOL_BALANCES (err u3016))
(define-constant ERR_MINIMUM_D_VALUE (err u3017))
(define-constant ERR_INVALID_FEE (err u3018))
(define-constant ERR_MINIMUM_BURN_AMOUNT (err u3019))

(define-constant CONTRACT_DEPLOYER tx-sender)

(define-constant MATH_NUM_1 u1)
(define-constant MATH_NUM_2 u2)
(define-constant MATH_NUM_10 u10)
(define-constant MATH_NUM_10000 u10000)

(define-constant index-list (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100 u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150 u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200 u201 u202 u203 u204 u205 u206 u207 u208 u209 u210 u211 u212 u213 u214 u215 u216 u217 u218 u219 u220 u221 u222 u223 u224 u225 u226 u227 u228 u229 u230 u231 u232 u233 u234 u235 u236 u237 u238 u239 u240 u241 u242 u243 u244 u245 u246 u247 u248 u249 u250 u251 u252 u253 u254 u255 u256 u257 u258 u259 u260 u261 u262 u263 u264 u265 u266 u267 u268 u269 u270 u271 u272 u273 u274 u275 u276 u277 u278 u279 u280 u281 u282 u283 u284 u285 u286 u287 u288 u289 u290 u291 u292 u293 u294 u295 u296 u297 u298 u299 u300 u301 u302 u303 u304 u305 u306 u307 u308 u309 u310 u311 u312 u313 u314 u315 u316 u317 u318 u319 u320 u321 u322 u323 u324 u325 u326 u327 u328 u329 u330 u331 u332 u333 u334 u335 u336 u337 u338 u339 u340 u341 u342 u343 u344 u345 u346 u347 u348 u349 u350 u351 u352 u353 u354 u355 u356 u357 u358 u359 u360 u361 u362 u363 u364 u365 u366 u367 u368 u369 u370 u371 u372 u373 u374 u375 u376 u377 u378 u379 u380 u381 u382 u383 u384))

(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

(define-data-var last-pool-id uint u0)

(define-data-var minimum-total-shares uint u1000000)
(define-data-var minimum-burnt-shares uint u1)

(define-data-var public-pool-creation bool false)

(define-map pools uint {
    id: uint,
    name: (string-ascii 32),
    symbol: (string-ascii 32),
    pool-contract: principal
})

(define-read-only (get-admins)
    (ok (var-get admins))
)

(define-read-only (get-admin-helper)
    (ok (var-get admin-helper))
)

(define-read-only (get-last-pool-id)
    (ok (var-get last-pool-id))
)


(define-read-only (get-pool-by-id (id uint))
    (ok (map-get? pools id))
)

(define-read-only (get-minimum-total-shares)
    (ok (var-get minimum-total-shares))
)

(define-read-only (get-minimum-burnt-shares)
    (ok (var-get minimum-burnt-shares))
)

(define-read-only (get-public-pool-creation)
    (ok (var-get public-pool-creation))
)

(define-public (get-dy
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint)
    )
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (protocol-fee (get x-protocol-fee pool-data))
    (provider-fee (get x-provider-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (swap-amounts-scaled (scale-up-amounts x-amount u0 x-token-trait y-token-trait))
    (x-amount-scaled (get x-amount swap-amounts-scaled))
    (x-amount-fees-protocol-scaled (/ (* x-amount-scaled protocol-fee) MATH_NUM_10000))
    (x-amount-fees-provider-scaled (/ (* x-amount-scaled provider-fee) MATH_NUM_10000))
    (x-amount-fees-total-scaled (+ x-amount-fees-protocol-scaled x-amount-fees-provider-scaled))
    (dx-scaled (- x-amount-scaled x-amount-fees-total-scaled))
    (updated-y-balance-scaled (get-y dx-scaled x-balance-scaled y-balance-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (updated-y-balance (get y-amount (scale-down-amounts u0 updated-y-balance-scaled x-token-trait y-token-trait)))
    (dy (- y-balance updated-y-balance))
    )
    (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
    (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
    (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)
    (asserts! (and (> x-amount u0) (< x-amount (* x-balance MATH_NUM_10))) ERR_INVALID_AMOUNT)
    (ok dy)
    )
)

(define-public (get-dx
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (y-amount uint)
    )
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (protocol-fee (get y-protocol-fee pool-data))
    (provider-fee (get y-provider-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (swap-amounts-scaled (scale-up-amounts u0 y-amount x-token-trait y-token-trait))
    (y-amount-scaled (get y-amount swap-amounts-scaled))
    (y-amount-fees-protocol-scaled (/ (* y-amount-scaled protocol-fee) MATH_NUM_10000))
    (y-amount-fees-provider-scaled (/ (* y-amount-scaled provider-fee) MATH_NUM_10000))
    (y-amount-fees-total-scaled (+ y-amount-fees-protocol-scaled y-amount-fees-provider-scaled))
    (dy-scaled (- y-amount-scaled y-amount-fees-total-scaled))
    (updated-x-balance-scaled (get-x dy-scaled y-balance-scaled x-balance-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (updated-x-balance (get x-amount (scale-down-amounts updated-x-balance-scaled u0 x-token-trait y-token-trait)))
    (dx (- x-balance updated-x-balance))
    )
    (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
    (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
    (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)
    (asserts! (and (> y-amount u0) (< y-amount (* y-balance MATH_NUM_10))) ERR_INVALID_AMOUNT)
    (ok dx)
    )
)

(define-public (get-dlp
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (y-amount uint)
    )
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (total-shares (get total-shares pool-data))
    (liquidity-fee (get liquidity-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))
    (updated-x-balance (+ x-balance x-amount))
    (updated-y-balance (+ y-balance y-amount))
    (amounts-added-scaled (scale-up-amounts x-amount y-amount x-token-trait y-token-trait))
    (x-amount-scaled (get x-amount amounts-added-scaled))
    (y-amount-scaled (get y-amount amounts-added-scaled))
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (updated-pool-balances-scaled (scale-up-amounts updated-x-balance updated-y-balance x-token-trait y-token-trait))
    (updated-x-balance-scaled (get x-amount updated-pool-balances-scaled))
    (updated-y-balance-scaled (get y-amount updated-pool-balances-scaled))
    (d-a (get-d x-balance-scaled y-balance-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (d-b (get-d updated-x-balance-scaled updated-y-balance-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (ideal-x-balance-scaled (/ (* d-b x-balance-scaled) d-a))
    (ideal-y-balance-scaled (/ (* d-b y-balance-scaled) d-a))
    (x-difference (if (> ideal-x-balance-scaled updated-x-balance-scaled) (- ideal-x-balance-scaled updated-x-balance-scaled) (- updated-x-balance-scaled ideal-x-balance-scaled)))
    (y-difference (if (> ideal-y-balance-scaled updated-y-balance-scaled) (- ideal-y-balance-scaled updated-y-balance-scaled) (- updated-y-balance-scaled ideal-y-balance-scaled)))
    (ideal-x-amount-fee-liquidity-scaled (/ (* x-difference liquidity-fee) MATH_NUM_10000))
    (ideal-y-amount-fee-liquidity-scaled (/ (* y-difference liquidity-fee) MATH_NUM_10000))
    (x-amount-fee-liquidity-scaled (if (> x-amount-scaled ideal-x-amount-fee-liquidity-scaled) ideal-x-amount-fee-liquidity-scaled x-amount-scaled))
    (y-amount-fee-liquidity-scaled (if (> y-amount-scaled ideal-y-amount-fee-liquidity-scaled) ideal-y-amount-fee-liquidity-scaled y-amount-scaled))
    (updated-x-amount-scaled (- x-amount-scaled x-amount-fee-liquidity-scaled))
    (updated-y-amount-scaled (- y-amount-scaled y-amount-fee-liquidity-scaled))
    (updated-balance-x-post-fee-scaled (+ x-balance-scaled updated-x-amount-scaled))
    (updated-balance-y-post-fee-scaled (+ y-balance-scaled updated-y-amount-scaled))
    (updated-d (get-d updated-balance-x-post-fee-scaled updated-balance-y-post-fee-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (precise-fees-liquidity (scale-down-amounts x-amount-fee-liquidity-scaled y-amount-fee-liquidity-scaled x-token-trait y-token-trait))
    (x-amount-fees-liquidity (get x-amount precise-fees-liquidity))
    (y-amount-fees-liquidity (get y-amount precise-fees-liquidity))
    (amounts-added (scale-down-amounts updated-x-amount-scaled updated-y-amount-scaled x-token-trait y-token-trait))
    (updated-x-amount (get x-amount amounts-added))
    (updated-y-amount (get y-amount amounts-added))
    (updated-pool-balances-post-fee (scale-down-amounts updated-balance-x-post-fee-scaled updated-balance-y-post-fee-scaled x-token-trait y-token-trait))
    (updated-x-balance-post-fee (get x-amount updated-pool-balances-post-fee))
    (updated-y-balance-post-fee (get y-amount updated-pool-balances-post-fee))
    (dlp (/ (* total-shares (- updated-d d-a)) d-a))
    )
    (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
    (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
    (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)
    (asserts! (or (> updated-x-amount u0) (> updated-y-amount u0)) ERR_INVALID_AMOUNT)
    (asserts! (> updated-d d-a) ERR_MINIMUM_D_VALUE)
    (ok dlp)
    )
)

(define-read-only (get-x (y-amount uint) (y-bal uint) (x-bal uint) (ann uint) (threshold uint))
    (let (
    (updated-y-balance (+ y-bal y-amount))
    (current-d (get-d x-bal y-bal ann threshold))
    (c-a current-d)
    (c-b (/ (* c-a current-d) (* MATH_NUM_2 updated-y-balance)))
    (c-c (/ (* c-b current-d) (* ann MATH_NUM_2)))
    (b (+ updated-y-balance (/ current-d ann)))
    )
    (get converged (fold fold-x-for-loop index-list {x: current-d, c: c-c, b: b, d: current-d, threshold: threshold, converged: u0}))
    )
)

(define-read-only (get-y (x-amount uint) (x-bal uint) (y-bal uint) (ann uint) (threshold uint))
    (let (
    (updated-x-balance (+ x-bal x-amount))
    (current-d (get-d x-bal y-bal ann threshold))
    (c-a current-d)
    (c-b (/ (* c-a current-d) (* MATH_NUM_2 updated-x-balance)))
    (c-c (/ (* c-b current-d) (* ann MATH_NUM_2)))
    (b (+ updated-x-balance (/ current-d ann)))
    )
    (get converged (fold fold-y-for-loop index-list {y: current-d, c: c-c, b: b, d: current-d, threshold: threshold, converged: u0}))
    )
)

(define-read-only (get-d (x-bal uint) (y-bal uint) (ann uint) (threshold uint))
    (get converged (fold fold-d-for-loop index-list {x-bal: x-bal, y-bal: y-bal, d: (+ x-bal y-bal), ann: ann, threshold: threshold, converged: u0}))
)

(define-public (set-minimum-total-shares (amount uint))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (var-set minimum-total-shares amount)
        (print {action: "set-minimum-total-shares", caller: caller, data: {amount: amount}})
        (ok true)
    )
    )
)

(define-public (set-minimum-burnt-shares (amount uint))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
        (var-set minimum-burnt-shares amount)
        (print {action: "set-minimum-burnt-shares", caller: caller, data: {amount: amount}})
        (ok true)
    )
    )
)

(define-public (set-public-pool-creation (status bool))
    (let (
    (caller tx-sender)
    )
    (begin
        (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
        (var-set public-pool-creation status)
        (print {action: "set-public-pool-creation", caller: caller, data: {status: status}})
        (ok true)
    )
    )
)

(define-public (set-pool-uri (pool-trait <stableswap-pool-trait>) (uri (string-utf8 256)))
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
        (asserts! (> (len uri) u0) ERR_INVALID_POOL_URI)
        (try! (as-contract (contract-call? pool-trait set-pool-uri uri)))
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

(define-public (set-pool-status (pool-trait <stableswap-pool-trait>) (status bool))
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
        (try! (as-contract (contract-call? pool-trait set-pool-status status)))
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

(define-public (set-fee-address (pool-trait <stableswap-pool-trait>) (address principal))
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
        (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)
        (try! (as-contract (contract-call? pool-trait set-fee-address address)))
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

(define-public (set-x-fees (pool-trait <stableswap-pool-trait>) (protocol-fee uint) (provider-fee uint))
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
        (asserts! (<= (+ protocol-fee provider-fee) MATH_NUM_10000) ERR_INVALID_FEE)
        (try! (as-contract (contract-call? pool-trait set-x-fees protocol-fee provider-fee)))
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

(define-public (set-y-fees (pool-trait <stableswap-pool-trait>) (protocol-fee uint) (provider-fee uint))
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
        (asserts! (<= (+ protocol-fee provider-fee) MATH_NUM_10000) ERR_INVALID_FEE)
        (try! (as-contract (contract-call? pool-trait set-y-fees protocol-fee provider-fee)))
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

(define-public (set-liquidity-fee (pool-trait <stableswap-pool-trait>) (fee uint))
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
        (asserts! (<= fee MATH_NUM_10000) ERR_INVALID_FEE)
        (try! (as-contract (contract-call? pool-trait set-liquidity-fee fee)))
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

(define-public (set-amplification-coefficient (pool-trait <stableswap-pool-trait>) (coefficient uint))
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
        (try! (as-contract (contract-call? pool-trait set-amplification-coefficient coefficient)))
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

(define-public (set-convergence-threshold (pool-trait <stableswap-pool-trait>) (threshold uint))
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get pool-created pool-data) true) ERR_POOL_NOT_CREATED)
        (try! (as-contract (contract-call? pool-trait set-convergence-threshold threshold)))
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

(define-public (create-pool 
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (y-amount uint)
    (burn-amount uint)
    (x-protocol-fee uint) (x-provider-fee uint)
    (y-protocol-fee uint) (y-provider-fee uint)
    (liquidity-fee uint)
    (amplification-coefficient uint)
    (convergence-threshold uint)
    (fee-address principal) (uri (string-utf8 256)) (status bool)
    )
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-contract (contract-of pool-trait))
    (new-pool-id (+ (var-get last-pool-id) u1))
    (symbol (unwrap! (create-symbol x-token-trait y-token-trait) ERR_INVALID_POOL_SYMBOL))
    (name (concat symbol "-LP"))
    (x-token-contract (contract-of x-token-trait))
    (y-token-contract (contract-of y-token-trait))
    (pool-balances-scaled (scale-up-amounts x-amount y-amount x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (total-shares (+ x-balance-scaled y-balance-scaled))
    (min-burnt-shares (var-get minimum-burnt-shares))
    (caller tx-sender)
    )
    (begin
        (asserts! (or (is-some (index-of (var-get admins) caller)) (var-get public-pool-creation)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get pool-created pool-data) false) ERR_POOL_ALREADY_CREATED)
        (asserts! (not (is-eq x-token-contract y-token-contract)) ERR_MATCHING_TOKEN_CONTRACTS)
        (asserts! (is-standard x-token-contract) ERR_INVALID_PRINCIPAL)
        (asserts! (is-standard y-token-contract) ERR_INVALID_PRINCIPAL)
        (asserts! (is-standard fee-address) ERR_INVALID_PRINCIPAL)
        (asserts! (> x-amount u0) ERR_INVALID_AMOUNT)
        (asserts! (> y-amount u0) ERR_INVALID_AMOUNT)
        (asserts! (is-eq x-balance-scaled y-balance-scaled) ERR_UNEQUAL_POOL_BALANCES)
        (asserts! (>= total-shares (var-get minimum-total-shares)) ERR_MINIMUM_LP_AMOUNT)
        (asserts! (>= burn-amount min-burnt-shares) ERR_MINIMUM_BURN_AMOUNT)
        (asserts! (>= (- total-shares burn-amount) u0) ERR_MINIMUM_LP_AMOUNT)
        (asserts! (> (len uri) u0) ERR_INVALID_POOL_URI)
        (asserts! (> (len symbol) u0) ERR_INVALID_POOL_SYMBOL)
        (asserts! (> (len name) u0) ERR_INVALID_POOL_NAME)
        (asserts! (<= (+ x-protocol-fee x-provider-fee) MATH_NUM_10000) ERR_INVALID_FEE)
        (asserts! (<= (+ y-protocol-fee y-provider-fee) MATH_NUM_10000) ERR_INVALID_FEE)
        (asserts! (<= liquidity-fee MATH_NUM_10000) ERR_INVALID_FEE)
        (try! (as-contract (contract-call? pool-trait create-pool x-token-contract y-token-contract fee-address amplification-coefficient convergence-threshold new-pool-id name symbol uri status)))
        (try! (as-contract (contract-call? pool-trait set-x-fees x-protocol-fee x-provider-fee)))
        (try! (as-contract (contract-call? pool-trait set-y-fees y-protocol-fee y-provider-fee)))
        (try! (as-contract (contract-call? pool-trait set-liquidity-fee liquidity-fee)))
        (var-set last-pool-id new-pool-id)
        (map-set pools new-pool-id {id: new-pool-id, name: name, symbol: symbol, pool-contract: pool-contract})
        (try! (contract-call? x-token-trait transfer x-amount caller pool-contract none))
        (try! (contract-call? y-token-trait transfer y-amount caller pool-contract none))
        (try! (as-contract (contract-call? pool-trait update-pool-balances x-amount y-amount total-shares)))
        (try! (as-contract (contract-call? pool-trait pool-mint (- total-shares burn-amount) caller)))
        (try! (as-contract (contract-call? pool-trait pool-mint burn-amount pool-contract)))
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
            total-shares: total-shares,
            pool-symbol: symbol,
            pool-uri: uri,
            pool-status: status,
            creation-height: burn-block-height,
            fee-address: fee-address,
            amplification-coefficient: amplification-coefficient,
            convergence-threshold: convergence-threshold
        }
        })
        (ok true)
    )
    )
)

(define-public (swap-x-for-y
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (min-dy uint)
    )
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (pool-contract (contract-of pool-trait))
    (fee-address (get fee-address pool-data))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (protocol-fee (get x-protocol-fee pool-data))
    (provider-fee (get x-provider-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (swap-amounts-scaled (scale-up-amounts x-amount u0 x-token-trait y-token-trait))
    (x-amount-scaled (get x-amount swap-amounts-scaled))
    (x-amount-fees-protocol-scaled (/ (* x-amount-scaled protocol-fee) MATH_NUM_10000))
    (x-amount-fees-provider-scaled (/ (* x-amount-scaled provider-fee) MATH_NUM_10000))
    (x-amount-fees-total-scaled (+ x-amount-fees-protocol-scaled x-amount-fees-provider-scaled))
    (dx-scaled (- x-amount-scaled x-amount-fees-total-scaled))
    (updated-x-balance-scaled (+ x-balance-scaled dx-scaled))
    (updated-y-balance-scaled (get-y dx-scaled x-balance-scaled y-balance-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (updated-y-balance (get y-amount (scale-down-amounts u0 updated-y-balance-scaled x-token-trait y-token-trait)))
    (dy (- y-balance updated-y-balance))
    (x-amount-fees-protocol (get x-amount (scale-down-amounts x-amount-fees-protocol-scaled u0 x-token-trait y-token-trait)))
    (x-amount-fees-provider (get x-amount (scale-down-amounts x-amount-fees-provider-scaled u0 x-token-trait y-token-trait)))
    (x-amount-fees-total (+ x-amount-fees-protocol x-amount-fees-provider))
    (dx (- x-amount x-amount-fees-total))
    (updated-dx (+ dx x-amount-fees-provider))
    (updated-d (get-d updated-x-balance-scaled updated-y-balance-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
        (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
        (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)
        (asserts! (and (> x-amount u0) (< x-amount (* x-balance MATH_NUM_10))) ERR_INVALID_AMOUNT)
        (asserts! (> min-dy u0) ERR_INVALID_AMOUNT)
        (asserts! (>= dy min-dy) ERR_MINIMUM_Y_AMOUNT)
        (try! (contract-call? x-token-trait transfer updated-dx caller pool-contract none))
        (try! (as-contract (contract-call? pool-trait pool-transfer y-token-trait dy caller)))
        (if (> x-amount-fees-protocol u0)
        (try! (contract-call? x-token-trait transfer x-amount-fees-protocol caller fee-address none))
        false
        )
        (try! (as-contract (contract-call? pool-trait update-pool-balances (+ x-balance updated-dx) updated-y-balance updated-d)))
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
            dy: dy,
            min-dy: min-dy
        }
        })
        (ok dy)
    )
    )
)

(define-public (swap-y-for-x
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (y-amount uint) (min-dx uint)
    )
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (pool-contract (contract-of pool-trait))
    (fee-address (get fee-address pool-data))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (protocol-fee (get y-protocol-fee pool-data))
    (provider-fee (get y-provider-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (swap-amounts-scaled (scale-up-amounts u0 y-amount x-token-trait y-token-trait))
    (y-amount-scaled (get y-amount swap-amounts-scaled))
    (y-amount-fees-protocol-scaled (/ (* y-amount-scaled protocol-fee) MATH_NUM_10000))
    (y-amount-fees-provider-scaled (/ (* y-amount-scaled provider-fee) MATH_NUM_10000))
    (y-amount-fees-total-scaled (+ y-amount-fees-protocol-scaled y-amount-fees-provider-scaled))
    (dy-scaled (- y-amount-scaled y-amount-fees-total-scaled))
    (updated-y-balance-scaled (+ y-balance-scaled dy-scaled))
    (updated-x-balance-scaled (get-x dy-scaled y-balance-scaled x-balance-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (updated-x-balance (get x-amount (scale-down-amounts updated-x-balance-scaled u0 x-token-trait y-token-trait)))
    (dx (- x-balance updated-x-balance))
    (y-amount-fees-protocol (get y-amount (scale-down-amounts u0 y-amount-fees-protocol-scaled x-token-trait y-token-trait)))
    (y-amount-fees-provider (get y-amount (scale-down-amounts u0 y-amount-fees-provider-scaled x-token-trait y-token-trait)))
    (y-amount-fees-total (+ y-amount-fees-protocol y-amount-fees-provider))
    (dy (- y-amount y-amount-fees-total))
    (updated-dy (+ dy y-amount-fees-provider))
    (updated-d (get-d updated-x-balance-scaled updated-y-balance-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
        (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
        (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)
        (asserts! (and (> y-amount u0) (< y-amount (* y-balance MATH_NUM_10))) ERR_INVALID_AMOUNT)
        (asserts! (> min-dx u0) ERR_INVALID_AMOUNT)
        (asserts! (>= dx min-dx) ERR_MINIMUM_X_AMOUNT)
        (try! (contract-call? y-token-trait transfer updated-dy caller pool-contract none))
        (try! (as-contract (contract-call? pool-trait pool-transfer x-token-trait dx caller)))
        (if (> y-amount-fees-protocol u0)
        (try! (contract-call? y-token-trait transfer y-amount-fees-protocol caller fee-address none))
        false
        )
        (try! (as-contract (contract-call? pool-trait update-pool-balances updated-x-balance (+ y-balance updated-dy) updated-d)))
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
            dx: dx,
            min-dx: min-dx
        }
        })
        (ok dx)
    )
    )
)

(define-public (add-liquidity
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (y-amount uint) (min-dlp uint)
    )
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (pool-contract (contract-of pool-trait))
    (fee-address (get fee-address pool-data))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (total-shares (get total-shares pool-data))
    (liquidity-fee (get liquidity-fee pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))
    (updated-x-balance (+ x-balance x-amount))
    (updated-y-balance (+ y-balance y-amount))
    (amounts-added-scaled (scale-up-amounts x-amount y-amount x-token-trait y-token-trait))
    (x-amount-scaled (get x-amount amounts-added-scaled))
    (y-amount-scaled (get y-amount amounts-added-scaled))
    (pool-balances-scaled (scale-up-amounts x-balance y-balance x-token-trait y-token-trait))
    (x-balance-scaled (get x-amount pool-balances-scaled))
    (y-balance-scaled (get y-amount pool-balances-scaled))
    (updated-pool-balances-scaled (scale-up-amounts updated-x-balance updated-y-balance x-token-trait y-token-trait))
    (updated-x-balance-scaled (get x-amount updated-pool-balances-scaled))
    (updated-y-balance-scaled (get y-amount updated-pool-balances-scaled))
    (d-a (get-d x-balance-scaled y-balance-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (d-b (get-d updated-x-balance-scaled updated-y-balance-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (ideal-x-balance-scaled (/ (* d-b x-balance-scaled) d-a))
    (ideal-y-balance-scaled (/ (* d-b y-balance-scaled) d-a))
    (x-difference (if (> ideal-x-balance-scaled updated-x-balance-scaled) (- ideal-x-balance-scaled updated-x-balance-scaled) (- updated-x-balance-scaled ideal-x-balance-scaled)))
    (y-difference (if (> ideal-y-balance-scaled updated-y-balance-scaled) (- ideal-y-balance-scaled updated-y-balance-scaled) (- updated-y-balance-scaled ideal-y-balance-scaled)))
    (ideal-x-amount-fee-liquidity-scaled (/ (* x-difference liquidity-fee) MATH_NUM_10000))
    (ideal-y-amount-fee-liquidity-scaled (/ (* y-difference liquidity-fee) MATH_NUM_10000))
    (x-amount-fee-liquidity-scaled (if (> x-amount-scaled ideal-x-amount-fee-liquidity-scaled) ideal-x-amount-fee-liquidity-scaled x-amount-scaled))
    (y-amount-fee-liquidity-scaled (if (> y-amount-scaled ideal-y-amount-fee-liquidity-scaled) ideal-y-amount-fee-liquidity-scaled y-amount-scaled))
    (updated-x-amount-scaled (- x-amount-scaled x-amount-fee-liquidity-scaled))
    (updated-y-amount-scaled (- y-amount-scaled y-amount-fee-liquidity-scaled))
    (updated-balance-x-post-fee-scaled (+ x-balance-scaled updated-x-amount-scaled))
    (updated-balance-y-post-fee-scaled (+ y-balance-scaled updated-y-amount-scaled))
    (updated-d (get-d updated-balance-x-post-fee-scaled updated-balance-y-post-fee-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (precise-fees-liquidity (scale-down-amounts x-amount-fee-liquidity-scaled y-amount-fee-liquidity-scaled x-token-trait y-token-trait))
    (x-amount-fees-liquidity (get x-amount precise-fees-liquidity))
    (y-amount-fees-liquidity (get y-amount precise-fees-liquidity))
    (amounts-added (scale-down-amounts updated-x-amount-scaled updated-y-amount-scaled x-token-trait y-token-trait))
    (updated-x-amount (get x-amount amounts-added))
    (updated-y-amount (get y-amount amounts-added))
    (updated-pool-balances-post-fee (scale-down-amounts updated-balance-x-post-fee-scaled updated-balance-y-post-fee-scaled x-token-trait y-token-trait))
    (updated-x-balance-post-fee (get x-amount updated-pool-balances-post-fee))
    (updated-y-balance-post-fee (get y-amount updated-pool-balances-post-fee))
    (dlp (/ (* total-shares (- updated-d d-a)) d-a))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq (get pool-status pool-data) true) ERR_POOL_DISABLED)
        (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
        (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)
        (asserts! (or (> updated-x-amount u0) (> updated-y-amount u0)) ERR_INVALID_AMOUNT)
        (asserts! (> min-dlp u0) ERR_INVALID_AMOUNT)
        (asserts! (> updated-d d-a) ERR_MINIMUM_D_VALUE)
        (asserts! (>= dlp min-dlp) ERR_MINIMUM_LP_AMOUNT)
        (if (> updated-x-amount u0)
        (try! (contract-call? x-token-trait transfer updated-x-amount caller pool-contract none))
        false
        )
        (if (> updated-y-amount u0)
        (try! (contract-call? y-token-trait transfer updated-y-amount caller pool-contract none))
        false
        )
        (if (> x-amount-fees-liquidity u0)
        (try! (contract-call? x-token-trait transfer x-amount-fees-liquidity caller fee-address none))
        false
        )
        (if (> y-amount-fees-liquidity u0)
        (try! (contract-call? y-token-trait transfer y-amount-fees-liquidity caller fee-address none))
        false
        )
        (try! (as-contract (contract-call? pool-trait update-pool-balances updated-x-balance-post-fee updated-y-balance-post-fee updated-d)))
        (try! (as-contract (contract-call? pool-trait pool-mint dlp caller)))
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
            dlp: dlp,
            min-dlp: min-dlp
        }
        })
        (ok dlp)
    )
    )
)

(define-public (withdraw-liquidity
    (pool-trait <stableswap-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (amount uint) (min-x-amount uint) (min-y-amount uint)
    )
    (let (
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (pool-validity-check (asserts! (is-valid-pool (get pool-id pool-data) (contract-of pool-trait)) ERR_INVALID_POOL))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (total-shares (get total-shares pool-data))
    (convergence-threshold (get convergence-threshold pool-data))
    (amplification-coefficient (get amplification-coefficient pool-data))
    (x-amount (/ (* amount x-balance) total-shares))
    (y-amount (/ (* amount y-balance) total-shares))
    (updated-x-balance (- x-balance x-amount))
    (updated-y-balance (- y-balance y-amount))
    (updated-pool-balances-scaled (scale-up-amounts updated-x-balance updated-y-balance x-token-trait y-token-trait))
    (updated-x-balance-scaled (get x-amount updated-pool-balances-scaled))
    (updated-y-balance-scaled (get y-amount updated-pool-balances-scaled))
    (updated-d (get-d updated-x-balance-scaled updated-y-balance-scaled (* amplification-coefficient MATH_NUM_2) convergence-threshold))
    (caller tx-sender)
    )
    (begin
        (asserts! (is-eq (contract-of x-token-trait) x-token) ERR_INVALID_X_TOKEN)
        (asserts! (is-eq (contract-of y-token-trait) y-token) ERR_INVALID_Y_TOKEN)
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (asserts! (> (+ x-amount y-amount) u0) ERR_INVALID_AMOUNT)
        (asserts! (>= x-amount min-x-amount) ERR_MINIMUM_X_AMOUNT)
        (asserts! (>= y-amount min-y-amount) ERR_MINIMUM_Y_AMOUNT)
        (if (> x-amount u0)
        (try! (as-contract (contract-call? pool-trait pool-transfer x-token-trait x-amount caller)))
        false
        )
        (if (> y-amount u0)
        (try! (as-contract (contract-call? pool-trait pool-transfer y-token-trait y-amount caller)))
        false
        )
        (try! (as-contract (contract-call? pool-trait update-pool-balances updated-x-balance updated-y-balance updated-d)))
        (try! (as-contract (contract-call? pool-trait pool-burn amount caller)))
        (print {
        action: "withdraw-liquidity",
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
            min-y-amount: min-y-amount
        }
        })
        (ok {x-amount: x-amount, y-amount: y-amount})
    )
    )
)

(define-public (add-admin (admin principal))
    (let (
    (admins-list (var-get admins))
    (caller tx-sender)
    )
    (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (index-of admins-list admin)) ERR_ALREADY_ADMIN)
    (var-set admins (unwrap! (as-max-len? (append admins-list admin) u5) ERR_ADMIN_LIMIT_REACHED))
    (print {action: "add-admin", caller: caller, data: {admin: admin}})
    (ok true)
    )
)

(define-public (remove-admin (admin principal))
    (let (
    (admins-list (var-get admins))
    (caller tx-sender)
    )
    (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-some (index-of admins-list admin)) ERR_ADMIN_NOT_IN_LIST)
    (asserts! (not (is-eq admin CONTRACT_DEPLOYER)) ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER)
    (var-set admin-helper admin)
    (var-set admins (filter admin-not-removable admins-list))
    (print {action: "remove-admin", caller: caller, data: {admin: admin}})
    (ok true)
    )
)

(define-public (set-pool-uri-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (uris (list 120 (string-utf8 256)))
    )
    (ok (map set-pool-uri pool-traits uris))
)

(define-public (set-pool-status-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (statuses (list 120 bool))
    )
    (ok (map set-pool-status pool-traits statuses))
)

(define-public (set-fee-address-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (addresses (list 120 principal))
    )
    (ok (map set-fee-address pool-traits addresses))
)

(define-public (set-x-fees-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (protocol-fees (list 120 uint)) (provider-fees (list 120 uint))
    )
    (ok (map set-x-fees pool-traits protocol-fees provider-fees))
)

(define-public (set-y-fees-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (protocol-fees (list 120 uint)) (provider-fees (list 120 uint))
    )
    (ok (map set-y-fees pool-traits protocol-fees provider-fees))
)

(define-public (set-liquidity-fee-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (fees (list 120 uint))
    )
    (ok (map set-liquidity-fee pool-traits fees))
)

(define-public (set-amplification-coefficient-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (coefficients (list 120 uint))
    )
    (ok (map set-amplification-coefficient pool-traits coefficients))
)

(define-public (set-convergence-threshold-multi
    (pool-traits (list 120 <stableswap-pool-trait>))
    (thresholds (list 120 uint))
    )
    (ok (map set-convergence-threshold pool-traits thresholds))
)

(define-private (admin-not-removable (admin principal))
    (not (is-eq admin (var-get admin-helper)))
)

(define-private (create-symbol (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>))
    (let (
    (x-symbol (unwrap-panic (contract-call? x-token-trait get-symbol)))
    (y-symbol (unwrap-panic (contract-call? y-token-trait get-symbol)))
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
    (as-max-len? (concat x-truncated (concat "-" y-truncated)) u29)
    )
)

(define-private (is-valid-pool (id uint) (contract principal))
    (let (
    (pool-data (unwrap! (map-get? pools id) false))
    )
    (is-eq contract (get pool-contract pool-data))
    )
)

(define-private (fold-x-for-loop (n uint) (static-data {x: uint, c: uint, b: uint, d: uint, threshold: uint, converged: uint})) 
    (let (
    (current-x (get x static-data))
    (current-c (get c static-data))
    (current-b (get b static-data))
    (current-d (get d static-data))
    (current-threshold (get threshold static-data))
    (current-converged (get converged static-data))
    (x-numerator (+ (* current-x current-x) current-c))
    (x-denominator (- (+ (* MATH_NUM_2 current-x) current-b) current-d))
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

(define-private (fold-y-for-loop (n uint) (static-data {y: uint, c: uint, b: uint, d: uint, threshold: uint, converged: uint})) 
    (let (
    (current-y (get y static-data))
    (current-c (get c static-data))
    (current-b (get b static-data))
    (current-d (get d static-data))
    (current-threshold (get threshold static-data))
    (current-converged (get converged static-data))
    (y-numerator (+ (* current-y current-y) current-c))
    (y-denominator (- (+ (* MATH_NUM_2 current-y) current-b) current-d))
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

(define-private (fold-d-for-loop (n uint) (static-data {x-bal: uint, y-bal: uint, d: uint, ann: uint, threshold: uint, converged: uint})) 
    (let (
    (current-x-balance (get x-bal static-data))
    (current-y-balance (get y-bal static-data))
    (current-s (+ current-x-balance current-y-balance))
    (current-d-partial (get d static-data))
    (current-d (get d static-data))
    (current-ann (get ann static-data))
    (current-threshold (get threshold static-data))
    (current-converged (get converged static-data))
    (new-d-partial-x (/ (* current-d current-d-partial) (* MATH_NUM_2 current-x-balance)))
    (new-d-partial (/ (* current-d new-d-partial-x) (* MATH_NUM_2 current-y-balance)))
    (new-numerator (* (+ (* current-ann current-s) (* MATH_NUM_2 new-d-partial)) current-d))
    (new-denominator (+ (* (- current-ann MATH_NUM_1) current-d) (* (+ MATH_NUM_2 MATH_NUM_1) new-d-partial)))
    (new-d (/ new-numerator new-denominator))         
    )
    (if (is-eq current-converged u0)
        (if (> new-d current-d)
        (if (<= (- new-d current-d) current-threshold)
            {x-bal: current-x-balance, y-bal: current-y-balance, d: new-d, ann: current-ann, threshold: current-threshold, converged: new-d}
            {x-bal: current-x-balance, y-bal: current-y-balance, d: new-d, ann: current-ann, threshold: current-threshold, converged: u0}
        )
        (if (<= (- current-d new-d) current-threshold)
            {x-bal: current-x-balance, y-bal: current-y-balance, d: new-d, ann: current-ann, threshold: current-threshold, converged: new-d}
            {x-bal: current-x-balance, y-bal: current-y-balance, d: new-d, ann: current-ann, threshold: current-threshold, converged: u0}
        )
        )
        static-data
    )
    )
)

(define-private (scale-up-amounts (x-amount uint) (y-amount uint) (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>))
    (let (
    (x-decimals (unwrap-panic (contract-call? x-token-trait get-decimals)))
    (y-decimals (unwrap-panic (contract-call? y-token-trait get-decimals)))
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
    {x-amount: x-amount-scaled, y-amount: y-amount-scaled}
    )
)

(define-private (scale-down-amounts (x-amount uint) (y-amount uint) (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>))
    (let (
    (x-decimals (unwrap-panic (contract-call? x-token-trait get-decimals)))
    (y-decimals (unwrap-panic (contract-call? y-token-trait get-decimals)))
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
    {x-amount: x-amount-scaled, y-amount: y-amount-scaled}
    )
)