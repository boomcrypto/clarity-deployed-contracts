;; @contract Staking State
;; @version 1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_ABOVE_MAX (err u3201))

(define-constant max-cooldown-window u2592000)    ;; 30 days in seconds

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var cooldown-window uint u604800)    ;; 7 days in seconds

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map custom-cooldown
  { 
    principal: principal
  }
  {
    cooldown-window: uint
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-cooldown-window)
  (var-get cooldown-window)
)

(define-read-only (get-custom-cooldown (principal principal))
  (get cooldown-window
    (default-to
      { cooldown-window: (get-cooldown-window) }
      (map-get? custom-cooldown { principal: principal })
    )
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-cooldown-window (new-window uint))
  (begin
    (try! (contract-call? .test-hq-v1 check-is-protocol tx-sender))
    (asserts! (<= new-window max-cooldown-window ) ERR_ABOVE_MAX)
    (print {action: "set-cooldown-window", user: contract-caller, data: { old-value: (get-cooldown-window), new-value: new-window}})
    (ok (var-set cooldown-window new-window))
  )
)

(define-public (set-custom-cooldown (principal principal) (new-window uint))
  (begin
    (try! (contract-call? .test-hq-v1 check-is-admin tx-sender))
    (asserts! (<= new-window max-cooldown-window) ERR_ABOVE_MAX)
    (print {action: "set-custom-cooldown", user: contract-caller, data: { principal: principal, old-value: (get-custom-cooldown principal), new-value: new-window}})
    (ok (map-set custom-cooldown { principal: principal } { cooldown-window: new-window }))
  )
)
