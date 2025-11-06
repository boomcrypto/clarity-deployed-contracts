;; dlmm-swap-router-v-0-0

;; Use DLMM pool trait and SIP 010 trait
(use-trait dlmm-pool-trait .dlmm-pool-trait-v-0-0.dlmm-pool-trait)
(use-trait sip-010-trait .sip-010-trait-ft-standard-v-0-0.sip-010-trait)

;; Error constants
(define-constant ERR_NO_RESULT_DATA (err u2001))
(define-constant ERR_BIN_SLIPPAGE (err u2002))
(define-constant ERR_MINIMUM_RECEIVED (err u2003))
(define-constant ERR_MINIMUM_X_AMOUNT (err u2004))
(define-constant ERR_MINIMUM_Y_AMOUNT (err u2005))
(define-constant ERR_NO_ACTIVE_BIN_DATA (err u2006))
(define-constant ERR_EMPTY_SWAPS_LIST (err u2007))
(define-constant ERR_RESULTS_LIST_OVERFLOW (err u2008))
(define-constant ERR_INVALID_BIN_ID (err u2009))

;; Minimum and maximum bin IDs as signed ints
(define-constant MIN_BIN_ID -500)
(define-constant MAX_BIN_ID 500)

;; List used to swap through up to 350 bins via swap-x-for-y-simple-multi and swap-y-for-x-simple-multi
(define-constant BIN_INDEX_RANGE (list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27
                                 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53
                                 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79
                                 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104
                                 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124
                                 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144
                                 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164
                                 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184
                                 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204
                                 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224
                                 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244
                                 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264
                                 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284
                                 285 286 287 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304
                                 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324
                                 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344
                                 345 346 347 348 349))


;; Swap through multiple bins in multiple pools
(define-public (swap-multi
    (swaps (list 350 {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, expected-bin-id: int, amount: uint, min-received: uint, x-for-y: bool}))
    (max-unfavorable-bins uint)
  )
  (let (
    (swap-result (try! (fold fold-swap-multi swaps (ok {results: (list ), unfavorable: u0}))))
  )
    (asserts! (> (len swaps) u0) ERR_EMPTY_SWAPS_LIST)
    (asserts! (<= (get unfavorable swap-result) max-unfavorable-bins) ERR_BIN_SLIPPAGE)
    (ok swap-result)
  )
)

;; Swap through multiple bins in multiple pools using the same token pair and X for Y direction
(define-public (swap-x-for-y-same-multi
    (swaps (list 350 {pool-trait: <dlmm-pool-trait>, expected-bin-id: int, min-received: uint}))
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (amount uint) (min-y-amount-total uint) (max-unfavorable-bins uint)
  )
  (let (
    (swap-result (try! (fold fold-swap-x-for-y-same-multi swaps (ok {x-token-trait: x-token-trait, y-token-trait: y-token-trait, results: (list ), x-amount-for-swap: amount, y-amount: u0, unfavorable: u0}))))
    (y-amount-total (get y-amount swap-result))
    (unfavorable (get unfavorable swap-result))
 )
    (asserts! (> (len swaps) u0) ERR_EMPTY_SWAPS_LIST)
    (asserts! (<= unfavorable max-unfavorable-bins) ERR_BIN_SLIPPAGE)
    (asserts! (>= y-amount-total min-y-amount-total) ERR_MINIMUM_Y_AMOUNT)
    (ok {results: (get results swap-result), y-amount: y-amount-total, unfavorable: unfavorable})
  )
)

;; Swap through multiple bins in multiple pools using the same token pair and Y for X direction
(define-public (swap-y-for-x-same-multi
    (swaps (list 350 {pool-trait: <dlmm-pool-trait>, expected-bin-id: int, min-received: uint}))
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (amount uint) (min-x-amount-total uint) (max-unfavorable-bins uint)
  )
  (let (
    (swap-result (try! (fold fold-swap-y-for-x-same-multi swaps (ok {x-token-trait: x-token-trait, y-token-trait: y-token-trait, results: (list ), y-amount-for-swap: amount, x-amount: u0, unfavorable: u0}))))
    (x-amount-total (get x-amount swap-result))
    (unfavorable (get unfavorable swap-result))
 )
    (asserts! (> (len swaps) u0) ERR_EMPTY_SWAPS_LIST)
    (asserts! (<= unfavorable max-unfavorable-bins) ERR_BIN_SLIPPAGE)
    (asserts! (>= x-amount-total min-x-amount-total) ERR_MINIMUM_X_AMOUNT)
    (ok {results: (get results swap-result), x-amount: x-amount-total, unfavorable: unfavorable})
  )
)

;; Swap through up to 350 bins in a single pool using the same token pair and X for Y direction
(define-public (swap-x-for-y-simple-multi
    (pool-trait <dlmm-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (x-amount uint) (min-dy uint)
  )
  (let (
    (swap-result (try! (fold fold-swap-x-for-y-simple-multi BIN_INDEX_RANGE (ok {pool-trait: pool-trait, x-token-trait: x-token-trait, y-token-trait: y-token-trait, x-amount-for-swap: x-amount, y-amount: u0}))))
    (y-amount (get y-amount swap-result))
  )
    (asserts! (>= y-amount min-dy) ERR_MINIMUM_RECEIVED)
    (ok {in: (- x-amount (get x-amount-for-swap swap-result)), out: y-amount})
  )
)

;; Swap through up to 350 bins in a single pool using the same token pair and Y for X direction
(define-public (swap-y-for-x-simple-multi
    (pool-trait <dlmm-pool-trait>)
    (x-token-trait <sip-010-trait>) (y-token-trait <sip-010-trait>)
    (y-amount uint) (min-dx uint)
  )
  (let (
    (swap-result (try! (fold fold-swap-y-for-x-simple-multi BIN_INDEX_RANGE (ok {pool-trait: pool-trait, x-token-trait: x-token-trait, y-token-trait: y-token-trait, y-amount-for-swap: y-amount, x-amount: u0}))))
    (x-amount (get x-amount swap-result))
  )
    (asserts! (>= x-amount min-dx) ERR_MINIMUM_RECEIVED)
    (ok {in: (- y-amount (get y-amount-for-swap swap-result)), out: x-amount})
  )
)

;; Fold function to swap through multiple bins in multiple pools
(define-private (fold-swap-multi
    (swap {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, expected-bin-id: int, amount: uint, min-received: uint, x-for-y: bool})
    (result (response {results: (list 350 {in: uint, out: uint}), unfavorable: uint} uint))
  )
  (let (
    (result-data (unwrap! result ERR_NO_RESULT_DATA))
    (pool-trait (get pool-trait swap))
    (x-token-trait (get x-token-trait swap))
    (y-token-trait (get y-token-trait swap))
    (expected-bin-id (get expected-bin-id swap))
    (expected-bin-id-check (asserts! (and (>= expected-bin-id MIN_BIN_ID) (<= expected-bin-id MAX_BIN_ID)) ERR_INVALID_BIN_ID))
    (amount (get amount swap))
    (x-for-y (get x-for-y swap))
    (active-bin-id (unwrap! (contract-call? pool-trait get-active-bin-id) ERR_NO_ACTIVE_BIN_DATA))
    (bin-id-delta (- active-bin-id expected-bin-id))
    (is-unfavorable (if x-for-y (< bin-id-delta 0) (> bin-id-delta 0)))
    (swap-result (if x-for-y
                     (try! (contract-call? .dlmm-core-v-0-0 swap-x-for-y pool-trait x-token-trait y-token-trait active-bin-id amount))
                     (try! (contract-call? .dlmm-core-v-0-0 swap-y-for-x pool-trait x-token-trait y-token-trait active-bin-id amount))))
    (updated-results (unwrap! (as-max-len? (append (get results result-data) swap-result) u350) ERR_RESULTS_LIST_OVERFLOW))
  )
    (asserts! (>= (get out swap-result) (get min-received swap)) ERR_MINIMUM_RECEIVED)
    (ok {
      results: updated-results,
      unfavorable: (+ (get unfavorable result-data) (if is-unfavorable (abs-int bin-id-delta) u0))
    })
  )
)

;; Fold function to swap through multiple bins in multiple pools using the same token pair and X for Y direction
(define-private (fold-swap-x-for-y-same-multi
    (swap {pool-trait: <dlmm-pool-trait>, expected-bin-id: int, min-received: uint})
    (result (response {x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, results: (list 350 {in: uint, out: uint}), x-amount-for-swap: uint, y-amount: uint, unfavorable: uint} uint))
  )
  (let (
      (result-data (unwrap! result ERR_NO_RESULT_DATA))
      (pool-trait (get pool-trait swap))
      (expected-bin-id (get expected-bin-id swap))
      (expected-bin-id-check (asserts! (and (>= expected-bin-id MIN_BIN_ID) (<= expected-bin-id MAX_BIN_ID)) ERR_INVALID_BIN_ID))
      (x-token-trait (get x-token-trait result-data))
      (y-token-trait (get y-token-trait result-data))
      (x-amount-for-swap (get x-amount-for-swap result-data))
  )
    (if (> x-amount-for-swap u0)
        (let (
          (active-bin-id (unwrap! (contract-call? pool-trait get-active-bin-id) ERR_NO_ACTIVE_BIN_DATA))
          (bin-id-delta (- active-bin-id expected-bin-id))
          (is-unfavorable (< bin-id-delta 0))
          (swap-result (try! (contract-call? .dlmm-core-v-0-0 swap-x-for-y pool-trait x-token-trait y-token-trait active-bin-id x-amount-for-swap)))
          (out (get out swap-result))
          (updated-results (unwrap! (as-max-len? (append (get results result-data) swap-result) u350) ERR_RESULTS_LIST_OVERFLOW))
          (updated-x-amount-for-swap (- x-amount-for-swap (get in swap-result)))
          (updated-y-amount (+ (get y-amount result-data) out))
        )
          (asserts! (>= out (get min-received swap)) ERR_MINIMUM_RECEIVED)
          (ok {
            x-token-trait: x-token-trait,
            y-token-trait: y-token-trait,
            results: updated-results,
            x-amount-for-swap: updated-x-amount-for-swap,
            y-amount: updated-y-amount,
            unfavorable: (+ (get unfavorable result-data) (if is-unfavorable (abs-int bin-id-delta) u0))
          })
        )
        (ok result-data))
  )
)

;; Fold function to swap through multiple bins in multiple pools using the same token pair and Y for X direction
(define-private (fold-swap-y-for-x-same-multi
    (swap {pool-trait: <dlmm-pool-trait>, expected-bin-id: int, min-received: uint})
    (result (response {x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, results: (list 350 {in: uint, out: uint}), y-amount-for-swap: uint, x-amount: uint, unfavorable: uint} uint))
  )
  (let (
      (result-data (unwrap! result ERR_NO_RESULT_DATA))
      (pool-trait (get pool-trait swap))
      (expected-bin-id (get expected-bin-id swap))
      (expected-bin-id-check (asserts! (and (>= expected-bin-id MIN_BIN_ID) (<= expected-bin-id MAX_BIN_ID)) ERR_INVALID_BIN_ID))
      (x-token-trait (get x-token-trait result-data))
      (y-token-trait (get y-token-trait result-data))
      (y-amount-for-swap (get y-amount-for-swap result-data))
  )
    (if (> y-amount-for-swap u0)
        (let (
          (active-bin-id (unwrap! (contract-call? pool-trait get-active-bin-id) ERR_NO_ACTIVE_BIN_DATA))
          (bin-id-delta (- active-bin-id expected-bin-id))
          (is-unfavorable (> bin-id-delta 0))
          (swap-result (try! (contract-call? .dlmm-core-v-0-0 swap-y-for-x pool-trait x-token-trait y-token-trait active-bin-id y-amount-for-swap)))
          (out (get out swap-result))
          (updated-results (unwrap! (as-max-len? (append (get results result-data) swap-result) u350) ERR_RESULTS_LIST_OVERFLOW))
          (updated-y-amount-for-swap (- y-amount-for-swap (get in swap-result)))
          (updated-x-amount (+ (get x-amount result-data) out))
        )
          (asserts! (>= out (get min-received swap)) ERR_MINIMUM_RECEIVED)
          (ok {
            x-token-trait: x-token-trait,
            y-token-trait: y-token-trait,
            results: updated-results,
            y-amount-for-swap: updated-y-amount-for-swap,
            x-amount: updated-x-amount,
            unfavorable: (+ (get unfavorable result-data) (if is-unfavorable (abs-int bin-id-delta) u0))
          })
        )
        (ok result-data))
  )
)

;; Fold function to swap through up to 350 bins in a single pool using the same token pair and X for Y direction
(define-private (fold-swap-x-for-y-simple-multi
    (bin-id int)
    (result (response {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, x-amount-for-swap: uint, y-amount: uint} uint))
  )
  (let (
      (bin-id-check (asserts! (and (>= bin-id MIN_BIN_ID) (<= bin-id MAX_BIN_ID)) ERR_INVALID_BIN_ID))
      (result-data (unwrap! result ERR_NO_RESULT_DATA))
      (pool-trait (get pool-trait result-data))
      (x-token-trait (get x-token-trait result-data))
      (y-token-trait (get y-token-trait result-data))
      (x-amount-for-swap (get x-amount-for-swap result-data))
  )
    (if (> x-amount-for-swap u0)
        (let (
          (active-bin-id (unwrap! (contract-call? pool-trait get-active-bin-id) ERR_NO_ACTIVE_BIN_DATA))
          (swap-result (try! (contract-call? .dlmm-core-v-0-0 swap-x-for-y pool-trait x-token-trait y-token-trait active-bin-id x-amount-for-swap)))
          (updated-x-amount-for-swap (- x-amount-for-swap (get in swap-result)))
          (updated-y-amount (+ (get y-amount result-data) (get out swap-result)))
        )
          (ok {
            pool-trait: pool-trait,
            x-token-trait: x-token-trait,
            y-token-trait: y-token-trait,
            x-amount-for-swap: updated-x-amount-for-swap,
            y-amount: updated-y-amount
          })
        )
        (ok result-data))
  )
)

;; Fold function to swap through up to 350 bins in a single pool using the same token pair and Y for X direction
(define-private (fold-swap-y-for-x-simple-multi
    (bin-id int)
    (result (response {pool-trait: <dlmm-pool-trait>, x-token-trait: <sip-010-trait>, y-token-trait: <sip-010-trait>, y-amount-for-swap: uint, x-amount: uint} uint))
  )
  (let (
      (bin-id-check (asserts! (and (>= bin-id MIN_BIN_ID) (<= bin-id MAX_BIN_ID)) ERR_INVALID_BIN_ID))
      (result-data (unwrap! result ERR_NO_RESULT_DATA))
      (pool-trait (get pool-trait result-data))
      (x-token-trait (get x-token-trait result-data))
      (y-token-trait (get y-token-trait result-data))
      (y-amount-for-swap (get y-amount-for-swap result-data))
  )
    (if (> y-amount-for-swap u0)
        (let (
          (active-bin-id (unwrap! (contract-call? pool-trait get-active-bin-id) ERR_NO_ACTIVE_BIN_DATA))
          (swap-result (try! (contract-call? .dlmm-core-v-0-0 swap-y-for-x pool-trait x-token-trait y-token-trait active-bin-id y-amount-for-swap)))
          (updated-y-amount-for-swap (- y-amount-for-swap (get in swap-result)))
          (updated-x-amount (+ (get x-amount result-data) (get out swap-result)))
        )
          (ok {
            pool-trait: pool-trait,
            x-token-trait: x-token-trait,
            y-token-trait: y-token-trait,
            y-amount-for-swap: updated-y-amount-for-swap,
            x-amount: updated-x-amount
          })
        )
        (ok result-data))
  )
)

;; Get absolute value of a signed int as uint
(define-private (abs-int (value int))
  (to-uint (if (>= value 0) value (- value)))
)