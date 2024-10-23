(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-ext 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

;; ERRS
(define-constant ERR-NOT-AUTHORIZED (err u5009))



(define-data-var contract-owner principal tx-sender)

;; MANAGEMENT CALLS

;; @desc set-contract-owner: sets owner
;; @requirement only callable by current owner
;; @params owner
;; @returns (response boolean)
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)


(define-public (refund-user (token-launch-id uint) (addrs (list 200 principal)))
  (begin
    (try! (check-is-owner))
    (fold transfer-fund-iter addrs token-launch-id)
    (ok true)
  )
)


;; PRIVATE CALLS

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (transfer-fund-iter (addr principal) (token-launch-id uint))
	(let
    (
      (user-deposit (contract-call? .memegoat-launchpad-v1-4-ext get-user-deposits addr token-launch-id))
    )
    (unwrap-panic (contract-call? .memegoat-launchpad-vault-v2 transfer-stx user-deposit addr ))
    token-launch-id
  )
)