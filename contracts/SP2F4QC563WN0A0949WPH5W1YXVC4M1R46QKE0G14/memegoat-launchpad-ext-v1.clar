(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

;; ERRS
(define-constant ERR-NOT-AUTHORIZED (err u5009))
(define-constant ERR-NOT-PARTICIPANT (err u7004))
(define-constant ERR-ALREADY-CLAIMED (err u7005))
(define-constant ERR-CLAIM-NOT-STARTED (err u9001))
(define-constant ONE_8 u100000000)
(define-constant ONE_6 u1000000)

;; DATA MAPS AND VARS
;; set caller as contract owner
(define-data-var contract-owner principal tx-sender)

;; set claim status
(define-data-var claim-started bool false)

(define-map user-claimed 
  { user-addr : principal }
  bool
)

;; MANAGEMENT CALLS
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)

(define-public (start-claim (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set claim-started true))
  )
)

;; READ ONLY CALLS
(define-read-only (check-if-claimed (user-addr principal)) 
  (default-to false (map-get? user-claimed { user-addr: user-addr }))
)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

;; PRIVATE CALLS
(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (decimals-to-fixed (amount uint)) 
  (/ (* amount ONE_8) ONE_6)
)

;; claim memegoat
(define-public (claim-token)
  (begin
    (asserts! (var-get claim-started) ERR-CLAIM-NOT-STARTED)
    (let
      (
        (sender tx-sender)
        (user-deposits (contract-call? .memegoat-launchpad-v1 get-user-deposits sender))
        (user-allocation (contract-call? .memegoat-launchpad-v1 calculate-allocation sender))
        (claimed (check-if-claimed sender))
      )

      (asserts! (>= user-deposits u20000000) ERR-NOT-PARTICIPANT)
      (asserts! (not claimed) ERR-ALREADY-CLAIMED)
          
      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-vault-v1 transfer-ft .memegoatstx (decimals-to-fixed user-allocation) sender)))      
      
      ;; set user status to claimed 
      (map-set user-claimed { user-addr: sender } true)
    )
    (ok true)
  )
)

