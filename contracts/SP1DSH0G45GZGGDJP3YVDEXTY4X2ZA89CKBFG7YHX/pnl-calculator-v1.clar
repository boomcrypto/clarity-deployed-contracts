(impl-trait .pnl-calculator-trait.pnl-calculator-trait)

;;-------------------------------------
;; Errors 
;;-------------------------------------

(define-constant ERR_VANILLA_CALL_STRIKE_ORDER_VIOLATED (err u4001))
(define-constant ERR_VANILLA_PUT_STRIKE_ORDER_VIOLATED (err u4002))
(define-constant ERR_VANILLA_CALLPUT_STRIKE_ORDER_VIOLATED (err u4003))
(define-constant ERR_KOKI_CALL_STRIKE_ORDER_VIOLATED (err u4004))
(define-constant ERR_KOKI_PUT_STRIKE_ORDER_VIOLATED (err u4005))
(define-constant ERR_KOKI_CALLPUT_STRIKE_ORDER_VIOLATED (err u4006))
(define-constant ERR_SPREAD_CALL_STRIKE_ORDER_VIOLATED (err u4007))
(define-constant ERR_SPREAD_PUT_STRIKE_ORDER_VIOLATED (err u4008))
(define-constant ERR_SPREAD_CALLPUT_STRIKE_ORDER_VIOLATED (err u4009))
(define-constant ERR_BINARY_CALL_STRIKE_ORDER_VIOLATED (err u4010))
(define-constant ERR_BINARY_PUT_STRIKE_ORDER_VIOLATED (err u4011))
(define-constant ERR_BINARY_CALLPUT_STRIKE_ORDER_VIOLATED (err u4012))
(define-constant ERR_BINARY_CALLSTRIP_STRIKE_ORDER_VIOLATED (err u4013))
(define-constant ERR_BINARY_PUTSTRIP_STRIKE_ORDER_VIOLATED (err u4014))
(define-constant ERR_BINARY_SHORTCALL_STRIKE_ORDER_VIOLATED (err u4014))
(define-constant ERR_BINARY_SHORTPUT_STRIKE_ORDER_VIOLATED (err u4015))

;;-------------------------------------
;; Variables 
;;-------------------------------------

(define-data-var pnl uint u0)

;;-------------------------------------
;; PNL  
;;-------------------------------------

;; @desc Checks for correct strike order
;; @param option-type: type of the option (u1 = vanilla, u2 = ERKO, u3 = ERKI, u4 = spread, u5 = binary)
;; @param strategy-type: type of the strategy (u1 = call, u2 = put, u3 = callput, u4 = callstrip, u5 = putstrip, u6 = shortcall, u7 = shortput)
;; @param strike-call: strike price in USD for call option (redstone format: 10**8) 
;; @param strike-put: strike price in USD for put option (redstone format: 10**8) 
;; @param barrier-up: upwards barrier in USD (redstone format: 10**8)
;; @param barrier-down: donwards barrier in USD (redstone format: 10**8)
(define-public (check-strike-order
  (option-type uint)
  (strategy-type uint)
  (strike-call (optional uint)) 
  (strike-put (optional uint))
  (barrier-up (optional uint))
  (barrier-down (optional uint)))
  (if (not (and (and (is-none strike-call) (is-none strike-put)) (and (is-none barrier-up) (is-none barrier-down))))
    (begin
      (if (is-eq option-type u1)
        (begin
          (if (is-eq strategy-type u1)
            (asserts! (and (is-none strike-put) (and (is-none barrier-up) (is-none barrier-down))) ERR_VANILLA_CALL_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u2)
            (asserts! (and (is-none strike-call) (and (is-none barrier-up) (is-none barrier-down))) ERR_VANILLA_PUT_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u3)
            (asserts! (and (is-none barrier-up) (is-none barrier-down)) ERR_VANILLA_CALLPUT_STRIKE_ORDER_VIOLATED)
            true
          )
        )
        true
      )
      (if (or (is-eq option-type u2) (is-eq option-type u3))
        (begin
          (if (is-eq strategy-type u1)
            (asserts! (and (< (unwrap-panic strike-call) (unwrap-panic barrier-up)) (and (is-none strike-put) (is-none barrier-down))) ERR_KOKI_CALL_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u2)
            (asserts! (and (and (is-none strike-call) (is-none barrier-up)) (> (unwrap-panic strike-put) (unwrap-panic barrier-down))) ERR_KOKI_PUT_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u3)
            (asserts! (and (< (unwrap-panic strike-call) (unwrap-panic barrier-up)) (> (unwrap-panic strike-put) (unwrap-panic barrier-down))) ERR_KOKI_CALLPUT_STRIKE_ORDER_VIOLATED)
            true
          )
        )
        true
      )
      (if (is-eq option-type u4) 
        (begin
          (if (is-eq strategy-type u1)
            (asserts! (and (< (unwrap-panic strike-call) (unwrap-panic barrier-up)) (and (is-none strike-put) (is-none barrier-down))) ERR_SPREAD_CALL_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u2)
            (asserts! (and (and (is-none strike-call) (is-none barrier-up)) (> (unwrap-panic strike-put) (unwrap-panic barrier-down))) ERR_SPREAD_PUT_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u3)
            (asserts! (and (< (unwrap-panic strike-call) (unwrap-panic barrier-up)) (> (unwrap-panic strike-put) (unwrap-panic barrier-down))) ERR_SPREAD_CALLPUT_STRIKE_ORDER_VIOLATED)
            true
          )
        )
        true
      )
      (if (is-eq option-type u5) 
        (begin
          (if (is-eq strategy-type u1)
            (asserts! (and (and (is-some strike-call) (is-some barrier-up)) (and (is-none strike-put) (is-none barrier-down))) ERR_BINARY_CALL_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u2)
            (asserts! (and (and (is-none strike-call) (is-none barrier-up)) (and (is-some strike-put) (is-some barrier-down))) ERR_BINARY_PUT_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u3)
            (asserts! (and (and (is-some strike-call) (is-some barrier-up)) (and (is-some strike-put) (is-some barrier-down))) ERR_BINARY_CALLPUT_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u4)
            (asserts! (and (< (unwrap-panic strike-call) (unwrap-panic strike-put)) (< (unwrap-panic barrier-up) (unwrap-panic barrier-down))) ERR_BINARY_CALLSTRIP_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u5)
            (asserts! (and (> (unwrap-panic strike-call) (unwrap-panic strike-put)) (> (unwrap-panic barrier-up) (unwrap-panic barrier-down))) ERR_BINARY_PUTSTRIP_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u6)
            (asserts! (and (and (is-some strike-call) (is-some barrier-up)) (and (is-none strike-put) (is-none barrier-down))) ERR_BINARY_SHORTCALL_STRIKE_ORDER_VIOLATED)
            true
          )
          (if (is-eq strategy-type u7)
            (asserts! (and (and (is-none strike-call) (is-none barrier-up)) (and (is-some strike-put) (is-some barrier-down))) ERR_BINARY_SHORTPUT_STRIKE_ORDER_VIOLATED)
            true
          )
        )
        true
      )
    (ok true))
    (ok true)))

;; @desc Determines option pnl and returns it
;; @param underlying-usd-rate: underlying price in USD (redstone format: 10**8)
;; @param option-type: type of the option (u1 = vanilla, u2 = ERKO, u3 = ERKI, u4 = spread, u5 = binary)
;; @param strategy-type: type of the strategy (u1 = call, u2 = put, u3 = callput, u4 = callstrip, u5 = putstrip, u6 = shortcall, u7 = shortput)
;; @param strike-call: strike price in USD for call option (redstone format: 10**8) 
;; @param strike-put: strike price in USD for put option (redstone format: 10**8) 
;; @param barrier-up: upwards barrier in USD (redstone format: 10**8)
;; @param barrier-down: donwards barrier in USD (redstone format: 10**8)
(define-public (calculate-pnl
  (underlying-usd-rate uint)
  (option-type uint)
  (strategy-type uint)
  (strike-call (optional uint))
  (strike-put (optional uint))
  (barrier-up (optional uint))
  (barrier-down (optional uint)))
  (begin
    (var-set pnl u0)
    (if (or (is-some strike-call) (is-some strike-put))
      (begin
        (if (is-eq option-type u1)
          (begin 
            (if (or (is-eq strategy-type u1) (is-eq strategy-type u3))
              (if (> underlying-usd-rate (unwrap-panic strike-call))
                (var-set pnl (- underlying-usd-rate (unwrap-panic strike-call)))
                true
              )
              true
            )
            (if (or (is-eq strategy-type u2) (is-eq strategy-type u3))
              (if (< underlying-usd-rate (unwrap-panic strike-put))
                (var-set pnl (- (unwrap-panic strike-put) underlying-usd-rate))
                true
              )
              true
            )
          )
          true
        )
        (if (is-eq option-type u2)
          (begin 
            (if (or (is-eq strategy-type u1) (is-eq strategy-type u3))
              (if (and (> underlying-usd-rate (unwrap-panic strike-call)) (< underlying-usd-rate (unwrap-panic barrier-up)))
                (var-set pnl (- underlying-usd-rate (unwrap-panic strike-call)))
                true
              )
              true
            )
            (if (or (is-eq strategy-type u2) (is-eq strategy-type u3))
              (if (and (< underlying-usd-rate (unwrap-panic strike-put)) (> underlying-usd-rate (unwrap-panic barrier-down)))
                (var-set pnl (- (unwrap-panic strike-put) underlying-usd-rate))
                true
              )
              true
            )
          )
          true
        )
        (if (is-eq option-type u3)
          (begin 
            (if (or (is-eq strategy-type u1) (is-eq strategy-type u3))
              (if (and (> underlying-usd-rate (unwrap-panic strike-call)) (>= underlying-usd-rate (unwrap-panic barrier-up)))
                (var-set pnl (- underlying-usd-rate (unwrap-panic strike-call)))
                true
              )
              true
            )
            (if (or (is-eq strategy-type u2) (is-eq strategy-type u3))
              (if (and (< underlying-usd-rate (unwrap-panic strike-put)) (<= underlying-usd-rate (unwrap-panic barrier-down)))
                (var-set pnl (- (unwrap-panic strike-put) underlying-usd-rate))
                true
              )
              true
            )
          )
          true
        )
        (if (is-eq option-type u4)
          (begin 
            (if (or (is-eq strategy-type u1) (is-eq strategy-type u3))
              (begin
                (if (and (> underlying-usd-rate (unwrap-panic strike-call)) (>= underlying-usd-rate (unwrap-panic barrier-up)))
                  (var-set pnl (- (unwrap-panic barrier-up) (unwrap-panic strike-call)))
                  true
                )
                (if (and (> underlying-usd-rate (unwrap-panic strike-call)) (< underlying-usd-rate (unwrap-panic barrier-up)))
                  (var-set pnl (- underlying-usd-rate (unwrap-panic strike-call)))
                  true
                )
              )
              true
            )
            (if (or (is-eq strategy-type u2) (is-eq strategy-type u3))
              (begin
                (if (and (< underlying-usd-rate (unwrap-panic strike-put)) (<= underlying-usd-rate (unwrap-panic barrier-down)))
                  (var-set pnl (- (unwrap-panic strike-call) (unwrap-panic strike-put)))
                  true
                )
                (if (and (< underlying-usd-rate (unwrap-panic strike-put)) (> underlying-usd-rate (unwrap-panic barrier-down)))
                  (var-set pnl (- (unwrap-panic strike-put) underlying-usd-rate))
                  true
                )
              )
              true
            )
          )
          true
        )
        (if (is-eq option-type u5)
          (begin 
            (if (or (is-eq strategy-type u1) (is-eq strategy-type u3))
              (if (>= underlying-usd-rate (unwrap-panic barrier-up))
                (var-set pnl (unwrap-panic strike-call))
                true
              )
              true
            )
            (if (or (is-eq strategy-type u2) (is-eq strategy-type u3))
              (if (<= underlying-usd-rate (unwrap-panic barrier-down))
                (var-set pnl (unwrap-panic strike-put))
                true
              )
              true
            )
            (if (is-eq strategy-type u4)
              (if (>= underlying-usd-rate (unwrap-panic barrier-down))
                (var-set pnl (unwrap-panic strike-put))
                (if (>= underlying-usd-rate (unwrap-panic barrier-up))
                  (var-set pnl (unwrap-panic strike-put))
                  true
                )
              )
              true
            )
            (if (is-eq strategy-type u5)
              (if (<= underlying-usd-rate (unwrap-panic barrier-down))
                (var-set pnl (unwrap-panic strike-put))
                (if (<= underlying-usd-rate (unwrap-panic barrier-up))
                  (var-set pnl (unwrap-panic strike-put))
                  true
                )
              )
              true
            )
            (if (is-eq strategy-type u6)
              (if (< underlying-usd-rate (unwrap-panic barrier-up))
                (var-set pnl (unwrap-panic strike-call))
                true
              )
              true
            )
            (if (is-eq strategy-type u7)
              (if (> underlying-usd-rate (unwrap-panic barrier-down))
                (var-set pnl (unwrap-panic strike-put))
                true
              )
              true
            )
          )
          true
        )
      )
      true
    )
    (ok (var-get pnl))))