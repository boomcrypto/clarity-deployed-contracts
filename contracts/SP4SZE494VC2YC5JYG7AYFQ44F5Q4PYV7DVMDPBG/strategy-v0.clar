;; @contract Stacking Strategy
;; @version 0
;;
;; The strategy contract is used to manage stacking using the stacker contracts.
;; Every cycle there is either an inflow or outflow of STX.
;; The way the inflow or outflow affects the stacker contracts is calculated off chain.

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_CYCLE_ALREADY_PREPARED u12001)

;;-------------------------------------
;; Track cycles
;;-------------------------------------

(define-data-var last-cycle-performed uint u0)

(define-read-only (get-last-cycle-performed)
  (var-get last-cycle-performed)
)

;;-------------------------------------
;; Reward address
;;-------------------------------------

(define-data-var pox-reward-address { version: (buff 1), hashbytes: (buff 32) } { version: 0x04, hashbytes: 0x2fffa9a09bb7fa7dced44834d77ee81c49c5f0cc })

(define-read-only (get-pox-reward-address)
  (var-get pox-reward-address)
)

(define-public (set-pox-reward-address (new-address { version: (buff 1), hashbytes: (buff 32) }))
  (begin
    (try! (contract-call? .dao check-is-protocol tx-sender))

    (var-set pox-reward-address new-address)
    (ok true)
  )
)

;;-------------------------------------
;; PoX info 
;;-------------------------------------

(define-read-only (get-pox-cycle)
  (contract-call? 'SP000000000000000000002Q6VF78.pox-3 current-pox-reward-cycle)
)

(define-read-only (get-next-cycle-start-burn-height)
  (contract-call? 'SP000000000000000000002Q6VF78.pox-3 reward-cycle-to-burn-height (+ (get-pox-cycle) u1))
)

;;-------------------------------------
;; Inflow/outflow info 
;;-------------------------------------

(define-read-only (get-total-stacking)
  (unwrap-panic (contract-call? .reserve-v1 get-stx-stacking))
)

;; Calculate STX outflow or inflow for next cycle.
(define-read-only (get-outflow-inflow)
  (let (
    (total-withdrawals (unwrap-panic (contract-call? .reserve-v1 get-stx-for-withdrawals)))
    (total-idle (unwrap-panic (contract-call? .reserve-v1 get-stx-balance)))

    (outflow 
      (if (> total-withdrawals total-idle)
        (- total-withdrawals total-idle)
        u0
      )
    )

    (inflow 
      (if (> total-idle total-withdrawals )
        (- total-idle total-withdrawals )
        u0
      )
    )
  )
    { outflow: outflow, inflow: inflow, total-stacking: (get-total-stacking), total-idle: total-idle, total-withdrawals: total-withdrawals }
  )
)

;;-------------------------------------
;; Inflow
;;-------------------------------------

;; Provide list where each element is amount to increase
;; List index corresponds to stacker id + 1
(define-public (perform-inflow (stacking-amounts (list 10 uint)))
  (let (
    (next-cycle (+ (get-pox-cycle) u1))
  )
    (try! (contract-call? .dao check-is-protocol tx-sender))
    (asserts! (< (var-get last-cycle-performed) next-cycle) (err ERR_CYCLE_ALREADY_PREPARED))

    (try! (perform-inflow-for-stacker u1 (unwrap-panic (element-at stacking-amounts u0))))
    (try! (perform-inflow-for-stacker u2 (unwrap-panic (element-at stacking-amounts u1))))
    (try! (perform-inflow-for-stacker u3 (unwrap-panic (element-at stacking-amounts u2))))
    (try! (perform-inflow-for-stacker u4 (unwrap-panic (element-at stacking-amounts u3))))
    (try! (perform-inflow-for-stacker u5 (unwrap-panic (element-at stacking-amounts u4))))
    (try! (perform-inflow-for-stacker u6 (unwrap-panic (element-at stacking-amounts u5))))
    (try! (perform-inflow-for-stacker u7 (unwrap-panic (element-at stacking-amounts u6))))
    (try! (perform-inflow-for-stacker u8 (unwrap-panic (element-at stacking-amounts u7))))
    (try! (perform-inflow-for-stacker u9 (unwrap-panic (element-at stacking-amounts u8))))
    (try! (perform-inflow-for-stacker u10 (unwrap-panic (element-at stacking-amounts u9))))

    (var-set last-cycle-performed next-cycle)
    (ok true)
  )
)

(define-private (perform-inflow-for-stacker (stacker-id uint) (amount uint))
  (let (
    (current-stacking-amount (stackers-get-total-stacking stacker-id))
  )
    (if (is-eq amount u0)
      (if (is-eq current-stacking-amount u0)
        ;; Not stacking so nothing to do
        u0
        ;; Nothing to stack, just extend
        (try! (stackers-stack-extend stacker-id))
      )

      (if (is-eq current-stacking-amount u0)
        ;; Not stacking yet, initiate
        (try! (stackers-initiate-stacking stacker-id amount))

        ;; Already stacking, increase and extend
        (begin
          (try! (stackers-stack-increase stacker-id amount))
          (try! (stackers-stack-extend stacker-id))
        )
      )
    )
    (ok true)
  )
)

;;-------------------------------------
;; Outflow
;;-------------------------------------

;; Provide list where each element is a boolean (false to continue stacking, true to stop)
;; List index corresponds to stacker id + 1
(define-public (perform-outflow (stackers-to-stop (list 10 bool)))
  (let (
    (next-cycle (+ (get-pox-cycle) u1))
  )
    (try! (contract-call? .dao check-is-protocol tx-sender))
    (asserts! (< (var-get last-cycle-performed) next-cycle) (err ERR_CYCLE_ALREADY_PREPARED))

    (try! (perform-outflow-for-stacker u1 (unwrap-panic (element-at stackers-to-stop u0))))
    (try! (perform-outflow-for-stacker u2 (unwrap-panic (element-at stackers-to-stop u1))))
    (try! (perform-outflow-for-stacker u3 (unwrap-panic (element-at stackers-to-stop u2))))
    (try! (perform-outflow-for-stacker u4 (unwrap-panic (element-at stackers-to-stop u3))))
    (try! (perform-outflow-for-stacker u5 (unwrap-panic (element-at stackers-to-stop u4))))
    (try! (perform-outflow-for-stacker u6 (unwrap-panic (element-at stackers-to-stop u5))))
    (try! (perform-outflow-for-stacker u7 (unwrap-panic (element-at stackers-to-stop u6))))
    (try! (perform-outflow-for-stacker u8 (unwrap-panic (element-at stackers-to-stop u7))))
    (try! (perform-outflow-for-stacker u9 (unwrap-panic (element-at stackers-to-stop u8))))
    (try! (perform-outflow-for-stacker u10 (unwrap-panic (element-at stackers-to-stop u9))))

    (var-set last-cycle-performed next-cycle)
    (ok true)
  )
)

(define-private (perform-outflow-for-stacker (stacker-id uint) (stop bool))
  (let (
    (current-stacking-amount (stackers-get-total-stacking stacker-id))
  )
    ;; Extend if should not stop and was stacking
    (if (and (is-eq stop false) (> current-stacking-amount u0))
      (try! (stackers-stack-extend stacker-id))
      u0
    )
    (ok true)
  )
)

;;-------------------------------------
;; Stacker Actions 
;;-------------------------------------

(define-read-only (stackers-get-total-stacking (stacker-id uint))
  (if (is-eq stacker-id u1) (contract-call? .stacker-1 get-stx-stacked)
  (if (is-eq stacker-id u2) (contract-call? .stacker-2 get-stx-stacked)
  (if (is-eq stacker-id u3) (contract-call? .stacker-3 get-stx-stacked)
  (if (is-eq stacker-id u4) (contract-call? .stacker-4 get-stx-stacked)
  (if (is-eq stacker-id u5) (contract-call? .stacker-5 get-stx-stacked)
  (if (is-eq stacker-id u6) (contract-call? .stacker-6 get-stx-stacked)
  (if (is-eq stacker-id u7) (contract-call? .stacker-7 get-stx-stacked)
  (if (is-eq stacker-id u8) (contract-call? .stacker-8 get-stx-stacked)
  (if (is-eq stacker-id u9) (contract-call? .stacker-9 get-stx-stacked)
  (if (is-eq stacker-id u10) (contract-call? .stacker-10 get-stx-stacked)
   u0
  ))))))))))
)

(define-public (stackers-return-stx)
  (begin
    (try! (contract-call? .stacker-1 return-stx .reserve-v1))
    (try! (contract-call? .stacker-2 return-stx .reserve-v1))
    (try! (contract-call? .stacker-3 return-stx .reserve-v1))
    (try! (contract-call? .stacker-4 return-stx .reserve-v1))
    (try! (contract-call? .stacker-5 return-stx .reserve-v1))
    (try! (contract-call? .stacker-6 return-stx .reserve-v1))
    (try! (contract-call? .stacker-7 return-stx .reserve-v1))
    (try! (contract-call? .stacker-8 return-stx .reserve-v1))
    (try! (contract-call? .stacker-9 return-stx .reserve-v1))
    (try! (contract-call? .stacker-10 return-stx .reserve-v1))
    (ok true)
  )
)

(define-private (stackers-initiate-stacking (stacker-id uint) (amount uint))
  (if (is-eq stacker-id u1) (contract-call? .stacker-1 initiate-stacking .reserve-v1 (var-get pox-reward-address) amount burn-block-height u1)
  (if (is-eq stacker-id u2) (contract-call? .stacker-2 initiate-stacking .reserve-v1 (var-get pox-reward-address) amount burn-block-height u1)
  (if (is-eq stacker-id u3) (contract-call? .stacker-3 initiate-stacking .reserve-v1 (var-get pox-reward-address) amount burn-block-height u1)
  (if (is-eq stacker-id u4) (contract-call? .stacker-4 initiate-stacking .reserve-v1 (var-get pox-reward-address) amount burn-block-height u1)
  (if (is-eq stacker-id u5) (contract-call? .stacker-5 initiate-stacking .reserve-v1 (var-get pox-reward-address) amount burn-block-height u1)
  (if (is-eq stacker-id u6) (contract-call? .stacker-6 initiate-stacking .reserve-v1 (var-get pox-reward-address) amount burn-block-height u1)
  (if (is-eq stacker-id u7) (contract-call? .stacker-7 initiate-stacking .reserve-v1 (var-get pox-reward-address) amount burn-block-height u1)
  (if (is-eq stacker-id u8) (contract-call? .stacker-8 initiate-stacking .reserve-v1 (var-get pox-reward-address) amount burn-block-height u1)
  (if (is-eq stacker-id u9) (contract-call? .stacker-9 initiate-stacking .reserve-v1 (var-get pox-reward-address) amount burn-block-height u1)
  (if (is-eq stacker-id u10) (contract-call? .stacker-10 initiate-stacking .reserve-v1 (var-get pox-reward-address) amount burn-block-height u1)
    (ok u0)
  ))))))))))
)

(define-private (stackers-stack-increase (stacker-id uint) (additional-amount uint))
  (if (is-eq stacker-id u1) (contract-call? .stacker-1 stack-increase .reserve-v1 additional-amount)
  (if (is-eq stacker-id u2) (contract-call? .stacker-2 stack-increase .reserve-v1 additional-amount)
  (if (is-eq stacker-id u3) (contract-call? .stacker-3 stack-increase .reserve-v1 additional-amount)
  (if (is-eq stacker-id u4) (contract-call? .stacker-4 stack-increase .reserve-v1 additional-amount)
  (if (is-eq stacker-id u5) (contract-call? .stacker-5 stack-increase .reserve-v1 additional-amount)
  (if (is-eq stacker-id u6) (contract-call? .stacker-6 stack-increase .reserve-v1 additional-amount)
  (if (is-eq stacker-id u7) (contract-call? .stacker-7 stack-increase .reserve-v1 additional-amount)
  (if (is-eq stacker-id u8) (contract-call? .stacker-8 stack-increase .reserve-v1 additional-amount)
  (if (is-eq stacker-id u9) (contract-call? .stacker-9 stack-increase .reserve-v1 additional-amount)
  (if (is-eq stacker-id u10) (contract-call? .stacker-10 stack-increase .reserve-v1 additional-amount)
   (ok u0)
  ))))))))))
)

(define-private (stackers-stack-extend (stacker-id uint))
  (if (is-eq stacker-id u1) (contract-call? .stacker-1 stack-extend u1 (var-get pox-reward-address))
  (if (is-eq stacker-id u2) (contract-call? .stacker-2 stack-extend u1 (var-get pox-reward-address))
  (if (is-eq stacker-id u3) (contract-call? .stacker-3 stack-extend u1 (var-get pox-reward-address))
  (if (is-eq stacker-id u4) (contract-call? .stacker-4 stack-extend u1 (var-get pox-reward-address))
  (if (is-eq stacker-id u5) (contract-call? .stacker-5 stack-extend u1 (var-get pox-reward-address))
  (if (is-eq stacker-id u6) (contract-call? .stacker-6 stack-extend u1 (var-get pox-reward-address))
  (if (is-eq stacker-id u7) (contract-call? .stacker-7 stack-extend u1 (var-get pox-reward-address))
  (if (is-eq stacker-id u8) (contract-call? .stacker-8 stack-extend u1 (var-get pox-reward-address))
  (if (is-eq stacker-id u9) (contract-call? .stacker-9 stack-extend u1 (var-get pox-reward-address))
  (if (is-eq stacker-id u10) (contract-call? .stacker-10 stack-extend u1 (var-get pox-reward-address))
   (ok u0)
  ))))))))))
)
