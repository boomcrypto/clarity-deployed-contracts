;; @contract Lydian DAO executor
;; @version 1

(use-trait lydian-dao-proposal-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u1503001)

;; ------------------------------------------
;; Maps
;; ------------------------------------------

(define-map caller-info
  { caller: principal }
  { enabled: bool }
)

(define-read-only (get-caller-enabled (caller principal))
  (default-to
    false
    (get enabled (map-get? caller-info { caller: caller }))
  )
)

(define-public (set-caller-enabled (caller principal) (enabled bool))
  (begin
    (asserts! (or (get-caller-enabled contract-caller) (is-eq tx-sender .lydian-dao)) (err ERR-NOT-AUTHORIZED))

    (map-set caller-info { caller: caller } { enabled: enabled })
    (ok true)
  )
)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute-proposal (proposal-trait <lydian-dao-proposal-trait>))
  (begin
    (asserts! (get-caller-enabled contract-caller) (err ERR-NOT-AUTHORIZED))
    (as-contract (contract-call? .lydian-dao execute-proposal proposal-trait))
  )
)

;; ---------------------------------------------------------
;; Init
;; ---------------------------------------------------------

(begin
  (map-set caller-info { caller: tx-sender } { enabled: true })
  (map-set caller-info { caller: .governance-v1-3 } { enabled: true })
)
