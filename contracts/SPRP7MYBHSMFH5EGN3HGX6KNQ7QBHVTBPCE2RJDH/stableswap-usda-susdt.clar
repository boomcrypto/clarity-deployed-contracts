;; Bitflow Stableswap Core Contract
;; This contract handles the core logic of the Stableswap protocol.
;; The initial trading pair is sUSDT/USDA
;; USDA is 6 decimals
;; sUSDT is 8 decimals

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-trait og-sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait susdt-sip-010-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)
(use-trait lp-trait .lp-trait.lp-trait)

;;;;;;;;;;;;;;;
;; Constants ;;
;;;;;;;;;;;;;;;

;; This contract address
(define-constant this-contract (as-contract tx-sender))

;; Deployment height
(define-constant deployment-height block-height)

;; Cycle length in blocks (1 day = 144 blocks)
(define-constant cycle-length u144)

;; Index loop for using Newton-Raphson method to converge square root that goes up to u384
(define-constant index-list (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100 u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150 u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200 u201 u202 u203 u204 u205 u206 u207 u208 u209 u210 u211 u212 u213 u214 u215 u216 u217 u218 u219 u220 u221 u222 u223 u224 u225 u226 u227 u228 u229 u230 u231 u232 u233 u234 u235 u236 u237 u238 u239 u240 u241 u242 u243 u244 u245 u246 u247 u248 u249 u250 u251 u252 u253 u254 u255 u256 u257 u258 u259 u260 u261 u262 u263 u264 u265 u266 u267 u268 u269 u270 u271 u272 u273 u274 u275 u276 u277 u278 u279 u280 u281 u282 u283 u284 u285 u286 u287 u288 u289 u290 u291 u292 u293 u294 u295 u296 u297 u298 u299 u300 u301 u302 u303 u304 u305 u306 u307 u308 u309 u310 u311 u312 u313 u314 u315 u316 u317 u318 u319 u320 u321 u322 u323 u324 u325 u326 u327 u328 u329 u330 u331 u332 u333 u334 u335 u336 u337 u338 u339 u340 u341 u342 u343 u344 u345 u346 u347 u348 u349 u350 u351 u352 u353 u354 u355 u356 u357 u358 u359 u360 u361 u362 u363 u364 u365 u366 u367 u368 u369 u370 u371 u372 u373 u374 u375 u376 u377 u378 u379 u380 u381 u382 u383 u384))

;; Number of tokens per pair
(define-constant number-of-tokens u2)

;; Test Protocol Address
(define-constant protocol-address 'SP3GDP77BDSZ4VN2QQP057C9T6DRDDB6WGES6K9CP)

;; Convergence Threshold Constant
(define-constant convergence-threshold u2)

;; Contract for Stableswap Staking and Rewards
(define-data-var staking-and-rewards-contract principal (as-contract tx-sender))

;;;;;;;;;;;;
;; Errors ;;
;;;;;;;;;;;;


;;;;;;;;;;;;;;;
;; Variables ;;
;;;;;;;;;;;;;;;

;; Admin Governance List
(define-data-var admins (list 5 principal) (list tx-sender))

;; Swap Fees (5 total bps initialized, 3 bps to LPs, 2 bps to protocol)
(define-data-var swap-fees {lps: uint, protocol: uint} {lps: u3, protocol: u2})

;; Liquidity Fees (3 bps initialized, all to protocol)
(define-data-var liquidity-fees uint u3)

;; Helper var to remove admin
(define-data-var helper-principal principal tx-sender)


;;;;;;;;;;
;; Maps ;;
;;;;;;;;;;

(define-map PairsDataMap {x-token: principal, y-token: principal, lp-token: principal} {
    approval: bool,
    total-shares: uint,
    x-decimals: uint,
    y-decimals: uint,
    balance-x: uint,
    balance-y: uint,
    d: uint,
    amplification-coefficient: uint,
})

(define-map CycleDataMap {x-token: principal, y-token: principal, lp-token: principal, cycle-num: uint} {
    cycle-fee-balance-x: uint,
    cycle-fee-balance-y: uint,
})



;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Read-Only Functions ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get pair data
(define-read-only (get-pair-data (x-token <og-sip-010-trait>) (y-token <susdt-sip-010-trait>) (lp-token <og-sip-010-trait>)) 
    (map-get? PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)})
)

;; Get cycle data
(define-read-only (get-cycle-data (x-token principal) (y-token principal) (lp-token principal) (cycle-num uint)) 
    (map-get? CycleDataMap {x-token: x-token, y-token: y-token, lp-token: lp-token, cycle-num: cycle-num})
)

;; Get current cycle
(define-read-only (get-current-cycle) 
    (/ (- block-height deployment-height) cycle-length)
)

;; Get cycle from height
(define-read-only (get-cycle-from-height (height uint)) 
    (/ (- height deployment-height) cycle-length)
)

;; Get starting height from cycle
(define-read-only (get-starting-height-from-cycle (cycle uint)) 
    (+ deployment-height (* cycle cycle-length))
)

;; Get deployment height
(define-read-only (get-deployment-height) 
    deployment-height
)

;; Get up to last 120 cycle rewards -> nice to have
;; (define-read-only (get-cycle-rewards) body)

;; Get DX
(define-read-only (get-dx (y-token <susdt-sip-010-trait>) (x-token <og-sip-010-trait>) (lp-token <lp-trait>) (y-amount uint))
    (let 
        (
            (pair-data (unwrap! (map-get? PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)}) (err "err-no-pair-data")))
            (current-balance-x (get balance-x pair-data))
            (current-balance-y (get balance-y pair-data))
            (x-decimals (get x-decimals pair-data))
            (y-decimals (get y-decimals pair-data))
            (swap-fee-lps (get lps (var-get swap-fees)))
            (swap-fee-protocol (get protocol (var-get swap-fees)))
            (total-swap-fee (+ swap-fee-lps swap-fee-protocol))

            ;; Scale up balances to perform AMM calculations with get-x
            (scaled-up-balances (get-scaled-up-token-amounts current-balance-x current-balance-y x-decimals y-decimals))
            (current-balance-x-scaled (get scaled-x scaled-up-balances))
            (current-balance-y-scaled (get scaled-y scaled-up-balances))
            (scaled-up-swap-amount (get-scaled-up-token-amounts u0 y-amount x-decimals y-decimals))
            (y-amount-scaled (get scaled-y scaled-up-swap-amount))
            (y-amount-fees-lps-scaled (/ (* y-amount-scaled swap-fee-lps) u10000))
            (y-amount-fees-protocol-scaled (/ (* y-amount-scaled swap-fee-protocol) u10000))
            (y-amount-total-fees-scaled (/ (* y-amount total-swap-fee) u10000))
            (updated-y-amount-scaled (- y-amount-scaled y-amount-total-fees-scaled))
            (updated-y-balance-scaled (+ current-balance-y-scaled updated-y-amount-scaled))
            (new-x-scaled (get-x updated-y-balance-scaled current-balance-x-scaled updated-y-amount-scaled (* (get amplification-coefficient pair-data) number-of-tokens)))

            ;; Scale down to precise amounts for x and dx, as well as y-amount-fee-lps, and y-amount-fee-protocol
            (new-x (get scaled-x (get-scaled-down-token-amounts new-x-scaled u0 x-decimals y-decimals)))
            (dx (- current-balance-x new-x))
            (y-amount-fee-lps (get scaled-y (get-scaled-down-token-amounts u0 y-amount-fees-lps-scaled x-decimals y-decimals)))
            (y-amount-fee-protocol (get scaled-y (get-scaled-down-token-amounts u0 y-amount-fees-protocol-scaled x-decimals y-decimals)))
        )
        (ok dx)
    )
)

;; Get X
;; Maybe move into get-dx?
(define-read-only (get-x (y-bal uint) (x-bal uint) (y-amount uint) (ann uint))
    (let 
        (
            (y-bal-new (+ y-bal y-amount))
            (current-D (get-D x-bal y-bal ann))
            (c0 current-D)
            (c1 (/ (* c0 current-D) (* number-of-tokens y-bal-new)))
            (c2 (/ (* c1 current-D) (* ann number-of-tokens)))
            (b (+ y-bal-new (/ current-D ann)))
        )
        (get converged (fold x-for-loop index-list {x: current-D, c: c2, b: b, D: current-D, converged: u0}))
    )
)

;; Get X Helper
(define-private (x-for-loop (n uint) (x-info {x: uint, c: uint, b: uint, D: uint, converged: uint})) 
    (let
        (
            (current-x (get x x-info))
            (current-c (get c x-info))
            (current-b (get b x-info))
            (current-D (get D x-info))
            (current-converged (get converged x-info))
            (x-numerator (+ (* current-x current-x) current-c))
            (x-denominator (- (+ (* u2 current-x) current-b) current-D))
            (new-x (/ x-numerator x-denominator))
        )

        (if (is-eq current-converged u0)
            (if (> new-x  current-x)
                (if (<= (- new-x current-x) convergence-threshold)
                    {x: new-x, c: current-c, b: current-b, D: current-D, converged: new-x}
                    {x: new-x, c: current-c, b: current-b, D: current-D, converged: u0}
                )
                (if (<= (- current-x new-x) convergence-threshold)
                    {x: new-x, c: current-c, b: current-b, D: current-D, converged: new-x}
                    {x: new-x, c: current-c, b: current-b, D: current-D, converged: u0}
                )
            )
            x-info
        )


    )
)

;; Get DY
(define-read-only (get-dy (x-token <og-sip-010-trait>) (y-token <susdt-sip-010-trait>) (lp-token <lp-trait>) (x-amount uint))
    (let 
        (
            
            (pair-data (unwrap! (map-get? PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)}) (err "err-no-pair-data")))
            (current-balance-x (get balance-x pair-data))
            (current-balance-y (get balance-y pair-data))
            (x-decimals (get x-decimals pair-data))
            (y-decimals (get y-decimals pair-data))
            (swap-fee-lps (get lps (var-get swap-fees)))
            (swap-fee-protocol (get protocol (var-get swap-fees)))
            (total-swap-fee (+ swap-fee-lps swap-fee-protocol))


            ;; Scale up balances to perform AMM calculations with get-y
            (scaled-up-balances (get-scaled-up-token-amounts current-balance-x current-balance-y x-decimals y-decimals))
            (current-balance-x-scaled (get scaled-x scaled-up-balances))
            (current-balance-y-scaled (get scaled-y scaled-up-balances))
            (scaled-up-swap-amount (get-scaled-up-token-amounts x-amount u0 x-decimals y-decimals))
            (x-amount-scaled (get scaled-x scaled-up-swap-amount))
            (x-amount-fees-lps-scaled (/ (* x-amount-scaled swap-fee-lps) u10000))
            (x-amount-fees-protocol-scaled (/ (* x-amount-scaled swap-fee-protocol) u10000))
            (x-amount-total-fees-scaled (/ (* x-amount total-swap-fee) u10000))
            (updated-x-amount-scaled (- x-amount-scaled x-amount-total-fees-scaled))
            (updated-x-balance-scaled (+ current-balance-x-scaled updated-x-amount-scaled))
            (new-y-scaled (get-y updated-x-balance-scaled current-balance-y-scaled updated-x-amount-scaled (* (get amplification-coefficient pair-data) number-of-tokens)))
            
            ;; Scale down to precise amounts for y and dy, as well as x-amount-fee-lps, and x-amount-fee-protocol
            (new-y (get scaled-y (get-scaled-down-token-amounts u0 new-y-scaled x-decimals y-decimals)))
            (dy (- current-balance-y new-y))
            (x-amount-fee-lps (get scaled-x (get-scaled-down-token-amounts x-amount-fees-lps-scaled u0 x-decimals y-decimals)))
            (x-amount-fee-protocol (get scaled-x (get-scaled-down-token-amounts x-amount-fees-protocol-scaled u0 x-decimals y-decimals)))
        )
        (ok dy)
    )
)

;; Get Y
;; Maybe move into get-dy?
(define-read-only (get-y (x-bal uint) (y-bal uint) (x-amount uint) (ann uint))
    (let 
        (
            (x-bal-new (+ x-bal x-amount))
            (current-D (get-D x-bal y-bal ann))
            (c0 current-D)
            (c1 (/ (* c0 current-D) (* number-of-tokens x-bal-new)))
            (c2 (/ (* c1 current-D) (* ann number-of-tokens)))
            (b (+ x-bal-new (/ current-D ann)))
        )
        (get converged (fold y-for-loop index-list {y: current-D, c: c2, b: b, D: current-D, converged: u0}))
    )
)

;; Get Y Helper
(define-private (y-for-loop (n uint) (y-info {y: uint, c: uint, b: uint, D: uint, converged: uint})) 
    (let
        (
            (current-y (get y y-info))
            (current-c (get c y-info))
            (current-b (get b y-info))
            (current-D (get D y-info))
            (current-converged (get converged y-info))
            (y-numerator (+ (* current-y current-y) current-c))
            (y-denominator (- (+ (* u2 current-y) current-b) current-D))
            (new-y (/ y-numerator y-denominator))
        )

        (if (is-eq current-converged u0)
            (if (> new-y  current-y)
                (if (<= (- new-y current-y) convergence-threshold)
                    {y: new-y, c: current-c, b: current-b, D: current-D, converged: new-y}
                    {y: new-y, c: current-c, b: current-b, D: current-D, converged: u0}
                )
                (if (<= (- current-y new-y) convergence-threshold)
                    {y: new-y, c: current-c, b: current-b, D: current-D, converged: new-y}
                    {y: new-y, c: current-c, b: current-b, D: current-D, converged: u0}
                )
            )
            y-info
        )

    )
)



;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;
;;; Swap Functions ;;;
;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;

;; Swap X -> Y
;; @desc: Swaps X token for Y token
;; @params: x-token: principal, y-token: principal, lp-token: principal, x-amount: uint, min-y-amount: uint
(define-public (swap-x-for-y (x-token <og-sip-010-trait>) (y-token <susdt-sip-010-trait>) (lp-token <lp-trait>) (x-amount uint) (min-y-amount uint)) 
    (let 
        (
            (swapper tx-sender)
            (pair-data (unwrap! (map-get? PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)}) (err "err-no-pair-data")))
            (current-approval (get approval pair-data))
            (current-balance-x (get balance-x pair-data))
            (current-balance-y (get balance-y pair-data))
            (x-decimals (get x-decimals pair-data))
            (y-decimals (get y-decimals pair-data))
            (swap-fee-lps (get lps (var-get swap-fees)))
            (swap-fee-protocol (get protocol (var-get swap-fees)))
            (total-swap-fee (+ swap-fee-lps swap-fee-protocol))

            ;; Scale up balances and the swap amount to perform AMM calculations with get-y
            (scaled-up-balances (get-scaled-up-token-amounts current-balance-x current-balance-y x-decimals y-decimals))
            (current-balance-x-scaled (get scaled-x scaled-up-balances))
            (current-balance-y-scaled (get scaled-y scaled-up-balances))
            (scaled-up-swap-amount (get-scaled-up-token-amounts x-amount u0 x-decimals y-decimals))
            (x-amount-scaled (get scaled-x scaled-up-swap-amount))
            (x-amount-fees-lps-scaled (/ (* x-amount-scaled swap-fee-lps) u10000))
            (x-amount-fees-protocol-scaled (/ (* x-amount-scaled swap-fee-protocol) u10000))
            (updated-x-amount-scaled (- x-amount-scaled (+ x-amount-fees-lps-scaled x-amount-fees-protocol-scaled)))
            (updated-x-balance-scaled (+ current-balance-x-scaled updated-x-amount-scaled))
            (new-y-scaled (get-y updated-x-balance-scaled current-balance-y-scaled updated-x-amount-scaled (* (get amplification-coefficient pair-data) number-of-tokens)))
            
            ;; Scale down to precise amounts for y and dy, as well as x-amount-fee-lps, and x-amount-fee-protocol
            (new-y (get scaled-y (get-scaled-down-token-amounts u0 new-y-scaled x-decimals y-decimals)))
            (dy (- current-balance-y new-y))
            (x-amount-fee-lps (get scaled-x (get-scaled-down-token-amounts x-amount-fees-lps-scaled u0 x-decimals y-decimals)))
            (x-amount-fee-protocol (get scaled-x (get-scaled-down-token-amounts x-amount-fees-protocol-scaled u0 x-decimals y-decimals)))
            (updated-x-amount (- x-amount (+ x-amount-fee-lps x-amount-fee-protocol)))
            (updated-x-balance (+ current-balance-x updated-x-amount))
        )

        ;; Assert that pair is approved
        (asserts! current-approval (err "err-pair-not-approved"))

        ;; Assert that x-amount is less than x10 of current-balance-x
        (asserts! (< x-amount (* u10 current-balance-x)) (err "err-x-amount-too-high"))

        ;; Assert that dy is greater than min-y-amount
        (asserts! (> dy min-y-amount) (err "err-min-y-amount"))

        ;; Transfer updated-x-balance tokens from tx-sender to this contract
        (if (> updated-x-amount u0) 
            (unwrap! (contract-call? x-token transfer updated-x-amount swapper (as-contract tx-sender) none) (err "err-transferring-token-x"))
            false
        )

        ;; Transfer x-amount-fee-lps tokens from tx-sender to staking-and-rewards-contract
        (if (> x-amount-fee-lps u0) 
            (unwrap! (contract-call? x-token transfer x-amount-fee-lps swapper (var-get staking-and-rewards-contract) none) (err "err-transferring-token-x-fee"))
            false
        )

        ;; Transfer x-amount-fee-protocol tokens from tx-sender to protocol-address
        (if (> x-amount-fee-protocol u0) 
            (unwrap! (contract-call? x-token transfer x-amount-fee-protocol swapper protocol-address none) (err "err-transferring-token-x-fee-protocol"))
            false
        )

        ;; Transfer dy tokens from this contract to tx-sender
        (if (> dy u0) 
            (unwrap! (as-contract (contract-call? y-token transfer dy tx-sender swapper none)) (err "err-transferring-token-y")) 
            false
        )

        ;; Update all appropriate maps
        ;; Update PairsDataMap
        (map-set PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)} (merge 
            pair-data 
            {
                balance-x: updated-x-balance,
                balance-y: new-y,
                d: (get-D updated-x-balance-scaled new-y-scaled (* (get amplification-coefficient pair-data) number-of-tokens))
            }
        ))

        ;; Match if map-get? returns some for CycleDataMap
        (ok (match (map-get? CycleDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token), cycle-num: (get-current-cycle)})
            cycle-data
                ;; Update CycleDataMap
                (map-set CycleDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token), cycle-num: (get-current-cycle)} (merge 
                    cycle-data 
                    {
                        cycle-fee-balance-x: (+ (get cycle-fee-balance-x cycle-data) x-amount-fee-lps)
                    }
                ))
                ;; Create new CycleDataMap
                (map-set CycleDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token), cycle-num: (get-current-cycle)} {
                    cycle-fee-balance-x: x-amount-fee-lps,
                    cycle-fee-balance-y: u0,
                })
            
        ))

    )
)
;; Swap Y -> X
;; @desc: Swaps Y token for X token
;; @params: y-token: principal, x-token: principal, lp-token: principal, x-amount: uint, min-x-amount: uint
(define-public (swap-y-for-x (y-token <susdt-sip-010-trait>) (x-token <og-sip-010-trait>) (lp-token <lp-trait>) (y-amount uint) (min-x-amount uint)) 
    (let 
        (
            (swapper tx-sender)
            (pair-data (unwrap! (map-get? PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)}) (err "err-no-pair-data")))
            (current-approval (get approval pair-data))
            (current-balance-x (get balance-x pair-data))
            (current-balance-y (get balance-y pair-data))
            (x-decimals (get x-decimals pair-data))
            (y-decimals (get y-decimals pair-data))
            (swap-fee-lps (get lps (var-get swap-fees)))
            (swap-fee-protocol (get protocol (var-get swap-fees)))
            (total-swap-fee (+ swap-fee-lps swap-fee-protocol))

            ;; Scale up balances and the swap amount to perform AMM calculations with get-x
            (scaled-up-balances (get-scaled-up-token-amounts current-balance-x current-balance-y x-decimals y-decimals))
            (current-balance-x-scaled (get scaled-x scaled-up-balances))
            (current-balance-y-scaled (get scaled-y scaled-up-balances))
            (scaled-up-swap-amount (get-scaled-up-token-amounts u0 y-amount x-decimals y-decimals))
            (y-amount-scaled (get scaled-y scaled-up-swap-amount))
            (y-amount-fees-lps-scaled (/ (* y-amount-scaled swap-fee-lps) u10000))
            (y-amount-fees-protocol-scaled (/ (* y-amount-scaled swap-fee-protocol) u10000))
            (updated-y-amount-scaled (- y-amount-scaled (+ y-amount-fees-lps-scaled y-amount-fees-protocol-scaled)))
            (updated-y-balance-scaled (+ current-balance-y-scaled updated-y-amount-scaled))
            (new-x-scaled (get-x updated-y-balance-scaled current-balance-x-scaled updated-y-amount-scaled (* (get amplification-coefficient pair-data) number-of-tokens)))
            
            ;; Scale down to precise amounts for y and dy, as well as y-amount-fee-lps, and y-amount-fee-protocol
            (new-x (get scaled-x (get-scaled-down-token-amounts new-x-scaled u0 x-decimals y-decimals)))
            (dx (- current-balance-x new-x))
            (y-amount-fee-lps (get scaled-y (get-scaled-down-token-amounts u0 y-amount-fees-lps-scaled x-decimals y-decimals)))
            (y-amount-fee-protocol (get scaled-y (get-scaled-down-token-amounts u0 y-amount-fees-protocol-scaled x-decimals y-decimals)))
            (updated-y-amount (- y-amount (+ y-amount-fee-lps y-amount-fee-protocol)))
            (updated-y-balance (+ current-balance-y updated-y-amount))
        )

        ;; Assert that pair is approved
        (asserts! current-approval (err "err-pair-not-approved"))

        ;; Assert that y-amount is less than x10 of current-balance-y
        (asserts! (< y-amount (* u10 current-balance-y)) (err "err-y-amount-too-high"))

        ;; Assert that dx is greater than min-x-amount
        (asserts! (> dx min-x-amount) (err "err-min-x-amount"))

        ;; Transfer updated-y-balance tokens from tx-sender to this contract
        (if (> updated-y-amount u0) 
            (unwrap! (contract-call? y-token transfer updated-y-amount swapper (as-contract tx-sender) none) (err "err-transferring-token-y"))
            false
        )

        ;; Transfer y-amount-fee-lps tokens from tx-sender to staking-and-rewards-contract
        (if (> y-amount-fee-lps u0) 
            (unwrap! (contract-call? y-token transfer y-amount-fee-lps swapper (var-get staking-and-rewards-contract) none) (err "err-transferring-token-y-swap-fee"))
            false
        )

        ;; Transfer y-amount-fee-protocol tokens from tx-sender to protocol-address
        (if (> y-amount-fee-protocol u0) 
            (unwrap! (contract-call? y-token transfer y-amount-fee-protocol swapper protocol-address none) (err "err-transferring-token-y-protocol-fee"))
            false
        )

        ;; Transfer dx tokens from this contract to tx-sender
        (if (> dx u0) 
            (unwrap! (as-contract (contract-call? x-token transfer dx tx-sender swapper none)) (err "err-transferring-token-x"))
            false
        )

        ;; Update all appropriate maps
        ;; Update PairsDataMap
        (map-set PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)} (merge 
            pair-data 
            {
                balance-x: new-x,
                balance-y: updated-y-balance,
                d: (get-D new-x-scaled updated-y-balance-scaled (* (get amplification-coefficient pair-data) number-of-tokens))
            }
        ))

        ;; Match if map-get? returns some for CycleDataMap
        (ok (match (map-get? CycleDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token), cycle-num: (get-current-cycle)})
            cycle-data
                ;; Update CycleDataMap
                (map-set CycleDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token), cycle-num: (get-current-cycle)} (merge 
                    cycle-data 
                    {
                        cycle-fee-balance-y: (+ (get cycle-fee-balance-y cycle-data) y-amount-fee-lps)
                    }
                ))
                ;; Create new CycleDataMap
                (map-set CycleDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token), cycle-num: (get-current-cycle)} {
                    cycle-fee-balance-x: u0,
                    cycle-fee-balance-y: y-amount-fee-lps,
                })
            
        ))

    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Liquidity Functions ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add Liquidity
;; @desc: Adds liquidity to a pair, mints the appropriate amount of LP tokens
;; @params: x-token: principal, y-token: principal, lp-token: principal, x-amount-added: uint, y-amount-added: uint
(define-public (add-liquidity (x-token <og-sip-010-trait>) (y-token <susdt-sip-010-trait>) (lp-token <lp-trait>) (x-amount-added uint) (y-amount-added uint) (min-lp-amount uint) )
    (let 
        (
            ;; Grabbing all data from PairsDataMap
            (liquidity-provider tx-sender)
            (current-pair (unwrap! (map-get? PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)}) (err "err-no-pair-data")))
            (current-approval (get approval current-pair))
            (x-decimals (get x-decimals current-pair))
            (y-decimals (get y-decimals current-pair))
            (current-balance-x (get balance-x current-pair))
            (new-balance-x (+ current-balance-x x-amount-added))
            (current-balance-y (get balance-y current-pair))
            (new-balance-y (+ current-balance-y y-amount-added))
            (current-total-shares (get total-shares current-pair))
            (current-amplification-coefficient (get amplification-coefficient current-pair))
            
            ;; Scale up for AMM calculations depending on decimal places assigned to tokens
            (amounts-added-scaled (get-scaled-up-token-amounts x-amount-added y-amount-added x-decimals y-decimals))
            (x-amount-added-scaled (get scaled-x amounts-added-scaled))
            (y-amount-added-scaled (get scaled-y amounts-added-scaled))
            (current-balances-scaled (get-scaled-up-token-amounts current-balance-x current-balance-y x-decimals y-decimals))
            (current-balance-x-scaled (get scaled-x current-balances-scaled))
            (current-balance-y-scaled (get scaled-y current-balances-scaled))
            (new-balances-scaled (get-scaled-up-token-amounts new-balance-x new-balance-y x-decimals y-decimals))
            (new-balance-x-scaled (get scaled-x new-balances-scaled))
            (new-balance-y-scaled (get scaled-y new-balances-scaled))
            
            ;; Calculating the ideal balance
            (d0 (get-D current-balance-x-scaled current-balance-y-scaled current-amplification-coefficient))
            (d1 (get-D new-balance-x-scaled new-balance-y-scaled current-amplification-coefficient))
            (ideal-balance-x-scaled (/ (* d1 current-balance-x-scaled) d0))
            (ideal-balance-y-scaled (/ (* d1 current-balance-y-scaled) d0))
            (x-difference (if (> ideal-balance-x-scaled new-balance-x-scaled) (- ideal-balance-x-scaled new-balance-x-scaled) (- new-balance-x-scaled ideal-balance-x-scaled)))
            (y-difference (if (> ideal-balance-y-scaled new-balance-y-scaled) (- ideal-balance-y-scaled new-balance-y-scaled) (- new-balance-y-scaled ideal-balance-y-scaled)))
            
            ;; Fees applied if adding imbalanced liquidity
            (ideal-x-fee-scaled (/ (* x-difference (var-get liquidity-fees)) u10000))
            (ideal-y-fee-scaled (/ (* y-difference (var-get liquidity-fees)) u10000))
            (x-fee-scaled (if (> x-amount-added-scaled ideal-x-fee-scaled) ideal-x-fee-scaled x-amount-added-scaled))
            (y-fee-scaled (if (> y-amount-added-scaled ideal-y-fee-scaled) ideal-y-fee-scaled y-amount-added-scaled))
            (x-amount-added-updated-scaled (- x-amount-added-scaled x-fee-scaled))
            (y-amount-added-updated-scaled (- y-amount-added-scaled y-fee-scaled))
            (new-balance-x-post-fee-scaled (+ current-balance-x-scaled x-amount-added-updated-scaled))
            (new-balance-y-post-fee-scaled (+ current-balance-y-scaled y-amount-added-updated-scaled))
            (d2 (get-D new-balance-x-post-fee-scaled new-balance-y-post-fee-scaled current-amplification-coefficient))

            ;; Scale down for precise token balance updates and transfers
            (precise-fees (get-scaled-down-token-amounts x-fee-scaled y-fee-scaled x-decimals y-decimals))
            (x-fee (get scaled-x precise-fees))
            (y-fee (get scaled-y precise-fees))
            (amounts-added-scaled-down (get-scaled-down-token-amounts x-amount-added-updated-scaled y-amount-added-updated-scaled x-decimals y-decimals))
            (x-amount-added-updated (get scaled-x amounts-added-scaled-down))
            (y-amount-added-updated (get scaled-y amounts-added-scaled-down))
            (balances-post-fee-scaled-down (get-scaled-down-token-amounts new-balance-x-post-fee-scaled new-balance-y-post-fee-scaled x-decimals y-decimals))
            (new-balance-x-post-fee (get scaled-x balances-post-fee-scaled-down))
            (new-balance-y-post-fee (get scaled-y balances-post-fee-scaled-down))
        )

        ;; Assert that pair is approved
        (asserts! current-approval (err "err-pair-not-approved"))

        ;; Assert that either x-amount-added or y-amount-added is greater than 0
        (asserts! (or (> x-amount-added u0) (> y-amount-added u0)) (err "err-x-or-y-amount-added-zero"))

        ;; Assert that d2 is greater than d0
        (asserts! (> d2 d0) (err "err-d2-less-than-d0"))

        ;; Assert that derived mint amount is greater than min-lp-amount
        (asserts! (> (/ (* current-total-shares (- d2 d0)) d0) min-lp-amount) (err "err-derived-amount-less-than-lp"))

        ;; ;; Transfer x-amount-added tokens from tx-sender to this contract
        (if (> x-amount-added-updated u0) 
            (unwrap! (contract-call? x-token transfer x-amount-added-updated liquidity-provider (as-contract tx-sender) none) (err "err-transferring-token-x-escrow"))
            false
        )

        ;; Transfer y-amount-added tokens from tx-sender to this contract
        (if (> y-amount-added-updated u0)
            (unwrap! (contract-call? y-token transfer y-amount-added-updated liquidity-provider (as-contract tx-sender) none) (err "err-transferring-token-y"))
            false
        )
        
        ;; Transfer x-fees tokens from tx-sender to protocol-address
        (if (> x-fee u0)
            (unwrap! (contract-call? x-token transfer x-fee liquidity-provider protocol-address none) (err "err-transferring-token-x-protocol"))
            false
        )
         ;; Transfer y-fees tokens from tx-sender to protocol-address
        (if (> y-fee u0)
            (unwrap! (contract-call? y-token transfer y-fee liquidity-provider protocol-address none) (err "err-transferring-token-y-protocol"))
            false
        )

        ;; Mint LP tokens to tx-sender
        (unwrap! (as-contract (contract-call? lp-token mint liquidity-provider (/ (* current-total-shares (- d2 d0)) d0))) (err "err-minting-lp-tokens"))

        ;; Update all appropriate maps
        ;; Update PairsDataMap
        (ok (map-set PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)} 
            (merge 
                current-pair 
                {
                    balance-x: new-balance-x-post-fee,
                    balance-y: new-balance-y-post-fee,
                    total-shares: (+ current-total-shares (/ (* current-total-shares (- d2 d0)) d0)),
                    d: d2
                }
            ))
        )
    )
)

;; Withdraw Liquidity
;; @desc: Withdraws liquidity from both pairs & burns the appropriate amount of LP tokens
;; @params: x-token: principal, y-token: principal, lp-token: principal, lp-amount: uint, min-x-amount: uint, min-y-amount: uint
(define-public (withdraw-liquidity (x-token <og-sip-010-trait>) (y-token <susdt-sip-010-trait>) (lp-token <lp-trait>) (lp-amount uint) (min-x-amount uint) (min-y-amount uint))
    (let 
        (
            ;; Grabbing all data from PairsDataMap
            (current-pair (unwrap! (map-get? PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)}) (err "err-no-pair-data")))
            (current-approval (get approval current-pair))
            (x-decimals (get x-decimals current-pair))
            (y-decimals (get y-decimals current-pair))
            (current-balance-x (get balance-x current-pair))
            (current-balance-y (get balance-y current-pair))
            (current-total-shares (get total-shares current-pair))
            (current-amplification-coefficient (get amplification-coefficient current-pair))
            (withdrawal-balance-x (/ (* current-balance-x lp-amount) current-total-shares))
            (withdrawal-balance-y (/ (* current-balance-y lp-amount) current-total-shares))
            (new-balance-x (- current-balance-x withdrawal-balance-x))
            (new-balance-y (- current-balance-y withdrawal-balance-y))
            (liquidity-remover tx-sender)
            ;; get-D using the new-balance-x and new-balance-y
            (new-balances-scaled (get-scaled-up-token-amounts new-balance-x new-balance-y x-decimals y-decimals))
            (new-balance-x-scaled (get scaled-x new-balances-scaled))
            (new-balance-y-scaled (get scaled-y new-balances-scaled))
            (new-d (get-D new-balance-x-scaled new-balance-y-scaled current-amplification-coefficient))
        )

        ;; Assert that withdrawal-balance-x is greater than min-x-amount
        (asserts! (> withdrawal-balance-x min-x-amount) (err "err-withdrawal-balance-x-less-than-min-x-amount"))

        ;; Assert that withdrawal-balance-y is greater than min-y-amount
        (asserts! (> withdrawal-balance-y min-y-amount) (err "err-withdrawal-balance-y-less-than-min-y-amount"))

        ;; Burn LP tokens from tx-sender
        (unwrap! (contract-call? lp-token burn liquidity-remover lp-amount) (err "err-burning-lp-tokens"))

        ;; Transfer withdrawal-balance-x tokens from this contract to liquidity-taker
        (unwrap! (as-contract (contract-call? x-token transfer withdrawal-balance-x tx-sender liquidity-remover none)) (err "err-transferring-token-x"))

        ;; Transfer withdrawal-balance-y tokens from this contract to liquidity-taker
        (unwrap! (as-contract (contract-call? y-token transfer withdrawal-balance-y tx-sender liquidity-remover none)) (err "err-transferring-token-y"))

        ;; Update all appropriate maps
        ;; Update PairsDataMap
        (ok (map-set PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)} (merge 
            current-pair 
            {
                balance-x: new-balance-x,
                balance-y: new-balance-y,
                total-shares: (- current-total-shares lp-amount),
                d: new-d
            }
        )))
    )
)


;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;
;;; AMM Functions ;;;
;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;

;; D for loop
;; Get D
(define-read-only (get-D (x-bal uint) (y-bal uint) (ann uint))
    (get converged (fold D-for-loop index-list {D: (+ x-bal y-bal), x-bal: x-bal, y-bal: y-bal, ann: ann, converged: u0}))
)

;; Get D Helper
(define-private (D-for-loop (n uint) (D-info {D: uint, x-bal: uint, y-bal: uint, ann: uint, converged: uint})) 
    (let 
        (
            ;; Grabbing everything from D-info
            (current-D-partial (get D D-info))
            (current-D (get D D-info))
            (current-x-bal (get x-bal D-info))
            (current-y-bal (get y-bal D-info))
            (current-S (+ current-x-bal current-y-bal))
            (current-ann (get ann D-info))
            (current-converged (get converged D-info))

            ;; Start logic for calculating new D
            ;; Calculate new partial D with respect to x
            (new-D-partial-x (/ (* current-D current-D-partial) (* u2 current-x-bal)))
            ;; Calculate new partial D with respect to now x & y
            (new-D-partial (/ (* current-D new-D-partial-x ) (* u2 current-y-bal)))

            (new-numerator (* (+ (* current-ann current-S) (* number-of-tokens new-D-partial)) current-D))
            (new-denominator (+ (* (- current-ann u1) current-D) (* (+ number-of-tokens u1 ) new-D-partial)))

            (new-D (/ new-numerator new-denominator))
            
        )
        
        ;; Check if converged value / new D was already found
        (if (is-eq current-converged u0)
            (if (> new-D  current-D)
                (if (<= (- new-D current-D) convergence-threshold)
                    {D: new-D, x-bal: current-x-bal, y-bal: current-y-bal, ann: current-ann, converged: new-D}
                    {D: new-D, x-bal: current-x-bal, y-bal: current-y-bal, ann: current-ann, converged: u0}
                )
                (if (<= (- current-D new-D) convergence-threshold)
                    {D: new-D, x-bal: current-x-bal, y-bal: current-y-bal, ann: current-ann, converged: new-D}
                    {D: new-D, x-bal: current-x-bal, y-bal: current-y-bal, ann: current-ann, converged: u0}
                )
            )
            D-info
        )
    
    )
)

;; Scale up the token amounts to the same level of precision before performing AMM calculations
;; @params: x-amount-unscaled: uint, y-amount-unscaled:uint, x-num-decimals: uint, y-num-decimals: uint
(define-private (get-scaled-up-token-amounts (x-amount-unscaled uint) (y-amount-unscaled uint) (x-num-decimals uint) (y-num-decimals uint))
    (let 
        (
            (scaled-x 
                ;; if same number of decimals, set to x-amount-unscaled
                (if (is-eq x-num-decimals y-num-decimals)
                    x-amount-unscaled
                    ;; if x has more decimals, set to x-amount-unscaled; otherwise scale up by the difference in decimals
                    (if (> x-num-decimals y-num-decimals) x-amount-unscaled (* x-amount-unscaled (pow u10 (- y-num-decimals x-num-decimals))))
                )
            )
            (scaled-y 
                ;; if same number of decimals, set to y-amount-unscaled
                (if (is-eq x-num-decimals y-num-decimals)
                    y-amount-unscaled
                    ;; if y has more decimals, set to y-amount-unscaled; otherwise scale up by the difference in decimals
                    (if (> y-num-decimals x-num-decimals) y-amount-unscaled (* y-amount-unscaled (pow u10 (- x-num-decimals y-num-decimals))))
                )
            )
        )
        {scaled-x: scaled-x, scaled-y: scaled-y}
    )
)

;; Scale down the token amounts to their respective levels of precision before performing any transfers
;; @params: x-amount-scaled: uint, y-amount-scaled:uint, x-num-decimals: uint, y-num-decimals: uint
(define-private (get-scaled-down-token-amounts (x-amount-scaled uint) (y-amount-scaled uint) (x-num-decimals uint) (y-num-decimals uint))
    (let 
        (
            (scaled-x 
                ;; if same number of decimals, set to x-amount-scaled
                (if (is-eq x-num-decimals y-num-decimals)
                    x-amount-scaled
                    ;; if x has more decimals, set to x-amount-scaled; otherwise scale down by the difference in decimals
                    (if (> x-num-decimals y-num-decimals) x-amount-scaled (/ x-amount-scaled (pow u10 (- y-num-decimals x-num-decimals))))
                )
            )
            (scaled-y 
                ;; if same number of decimals, set to y-amount-scaled
                (if (is-eq x-num-decimals y-num-decimals)
                    y-amount-scaled
                    ;; if y has more decimals, set to y-amount-scaled; otherwise scale down by the difference in decimals
                    (if (> y-num-decimals x-num-decimals) y-amount-scaled (/ y-amount-scaled (pow u10 (- x-num-decimals y-num-decimals))))
                )
            )
        )
        {scaled-x: scaled-x, scaled-y: scaled-y}
    )
)

;; @desc - Helper function for removing a admin
(define-private (is-not-removeable (admin principal))
  (not (is-eq admin (var-get helper-principal)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Goverance Functions ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Create Pair
;; @desc: Creates a new pair for trading
;; @params: x-token: principal, y-token: principal, lp-token: principal, amplification-coefficient: uint, pair-name: string, x-balance: uint, y-balance: uint
;; initial-balance param is for TOTAL balance of x + y tokens (aka 2x or 2y or (x + y))
(define-public (create-pair (x-token <og-sip-010-trait>) (y-token <susdt-sip-010-trait>) (lp-token <lp-trait>) (amplification-coefficient uint) (pair-name (string-ascii 32)) (initial-x-bal uint) (initial-y-bal uint))
    (let 
        (
            (lp-owner tx-sender)
            (x-decimals (unwrap! (contract-call? x-token get-decimals) (err "err-getting-x-decimals")))
            (y-decimals (unwrap! (contract-call? y-token get-decimals) (err "err-getting-y-decimals")))
            (scaled-up-balances (get-scaled-up-token-amounts initial-x-bal initial-y-bal x-decimals y-decimals))
            (initial-x-bal-scaled (get scaled-x scaled-up-balances))
            (initial-y-bal-scaled (get scaled-y scaled-up-balances))
        )

        ;; Assert that tx-sender is an admin using is-some & index-of with the admins var
        (asserts! (is-some (index-of (var-get admins) tx-sender )) (err "err-not-admin"))

        ;; Assert using and that the pair does not already exist using is-none & map-get?
        (asserts! (and 
            (is-none (map-get? PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)}))
            (is-none (map-get? PairsDataMap {x-token: (contract-of y-token), y-token: (contract-of x-token), lp-token: (contract-of lp-token)}))
        )  (err "err-pair-xy-or-yx-exists"))

        ;; Assert that both initial balances are greater than 0
        (asserts! (or (> initial-x-bal u0) (> initial-y-bal u0)) (err "err-initial-bal-zero"))

        ;; Assert that x & y tokens are the same
        (asserts! (is-eq initial-x-bal-scaled initial-y-bal-scaled) (err "err-initial-bal-odd"))

        ;; Mint LP tokens to tx-sender
        (unwrap! (as-contract (contract-call? lp-token mint lp-owner (+ initial-x-bal-scaled initial-y-bal-scaled))) (err "err-minting-lp-tokens"))

        ;; Transfer token x liquidity to this contract
        (unwrap! (contract-call? x-token transfer initial-x-bal tx-sender (as-contract tx-sender) none) (err "err-transferring-token-x"))

        ;; Transfer token y liquidity to this contract
        (unwrap! (contract-call? y-token transfer initial-y-bal tx-sender (as-contract tx-sender) none) (err "err-transferring-token-y"))

        ;; Update all appropriate maps
        (ok (map-set PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)} {
            approval: true,
            total-shares: (+ initial-x-bal-scaled initial-y-bal-scaled),
            x-decimals: x-decimals,
            y-decimals: y-decimals,
            balance-x: initial-x-bal,
            balance-y: initial-y-bal,
            d: (+ initial-x-bal-scaled initial-y-bal-scaled),
            amplification-coefficient: amplification-coefficient,
        }))
    )
)


;; Setting Pair Approval
;; @desc: Sets the approval of a pair
;; @params: x-token: principal, y-token: principal, lp-token: principal, approval: bool
(define-public (set-pair-approval (x-token <og-sip-010-trait>) (y-token <susdt-sip-010-trait>) (lp-token <lp-trait>) (approval bool))
    (let 
        (
            (current-pair (unwrap! (map-get? PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)}) (err "err-no-pair-data")))
        )

        ;; Assert that tx-sender is an admin using is-some & index-of with the admins var
        (asserts! (is-some (index-of (var-get admins) tx-sender)) (err "err-not-admin"))

        ;; Update all appropriate maps
        (ok (map-set PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)} (merge 
            current-pair
            {
                approval: approval
            }
        )))
    )
)

;; Add Admin
;; @desc: Adds an admin to the admins var list
;; @params: admin: principal
(define-public (add-admin (admin principal))
    (let 
        (
            (current-admins (var-get admins))
            ;;(new-admins (unwrap! (as-max-len? (append current-admins admin) u5) ("err-add-admin-overflow")))
        )

        ;; Assert that tx-sender is an admin using is-some & index-of with the admins var
        (asserts! (is-some (index-of current-admins tx-sender)) (err "err-not-admin"))

        ;; Assert that admin is not already an admin using is-none & index-of with the admins var
        (asserts! (is-none (index-of current-admins admin)) (err "err-already-admin"))

        ;; Update all appropriate maps
        (ok (var-set admins (unwrap! (as-max-len? (append current-admins admin) u5) (err "err-admin-overflow"))))
    )
)

;; Remove admin
(define-public (remove-admin (admin principal))
  (let
    (
      (current-admin-list (var-get admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (removeable-principal-position-in-list (index-of current-admin-list admin))
    )

    ;; asserts tx-sender is an existing whitelist address
    (asserts! (is-some caller-principal-position-in-list) (err "err-not-auth"))

    ;; asserts param principal (removeable whitelist) already exist
    (asserts! (is-eq removeable-principal-position-in-list) (err "err-not-whitelisted"))

    ;; temporary var set to help remove param principal
    (var-set helper-principal admin)

    ;; filter existing whitelist address
    (ok 
      (var-set admins (filter is-not-removeable current-admin-list))
    )
  )
)

;; Change Swap Fee
(define-public (change-swap-fee (new-lps-fee uint) (new-protocol-fee uint)) 
    (let 
        (
            (current-admins (var-get admins))
        )
        ;; Assert that tx-sender is an admin using is-some & index-of with the admins var
        (asserts! (is-some (index-of current-admins tx-sender)) (err "err-not-admin"))

        (ok (var-set swap-fees {lps: new-lps-fee, protocol: new-protocol-fee}))
    )
)

;; Change Liquidity Fee
(define-public (change-liquidity-fee (new-liquidity-fee uint)) 
    (let 
        (
            (current-admins (var-get admins))
        )
        ;; Assert that tx-sender is an admin using is-some & index-of with the admins var
        (asserts! (is-some (index-of current-admins tx-sender)) (err "err-not-admin"))

        (ok (var-set liquidity-fees new-liquidity-fee))
    )
)

;; Admins can change the amplification coefficient in PairsDataMap
;; @params: x-token: principal, y-token: principal, lp-token: principal, amplification-coefficient: uint
(define-public (change-amplification-coefficient (x-token <og-sip-010-trait>) (y-token <susdt-sip-010-trait>) (lp-token <lp-trait>) (amplification-coefficient uint))
    (let 
        (
            (current-pair (unwrap! (map-get? PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)}) (err "err-no-pair-data")))
            (current-admins (var-get admins))
        )

        ;; Assert that tx-sender is an admin using is-some & index-of with the admins var
        (asserts! (is-some (index-of current-admins tx-sender)) (err "err-not-admin"))

        ;; Update all appropriate maps
        (ok (map-set PairsDataMap {x-token: (contract-of x-token), y-token: (contract-of y-token), lp-token: (contract-of lp-token)} (merge 
            current-pair
            {
                amplification-coefficient: amplification-coefficient
            }
        )))
    )
)

;; Admins can set the contract for handling staking and rewards
;; @params: staking-contract: principal
(define-public (set-staking-contract (staking-contract principal))
    (let 
        (
            (current-admins (var-get admins))
        )

        ;; Assert that tx-sender is an admin using is-some & index-of with the admins var
        (asserts! (is-some (index-of current-admins tx-sender)) (err "err-not-admin"))

        ;; Set contract for handling staking and rewards
        (ok (var-set staking-and-rewards-contract staking-contract))
    )
)

