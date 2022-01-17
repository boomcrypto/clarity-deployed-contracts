;; Implementation of fixed fees of 1% for the service
;; by the charging-ctr. On that contract can call the public functions.

(define-constant fee-receiver tx-sender)
(define-constant charging-ctr 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.stx-ft-swap-v1)

;; For information only.
(define-public (get-fees (ustx uint))
  (ok (/ ustx u100)))

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (ustx uint))
  (begin
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (stx-transfer? (/ ustx u100) tx-sender (as-contract tx-sender))))

;; Release fees for the given amount if swap was canceled.
;; It relies on the logic of the charging-ctr that this contract.
(define-public (release-fees (ustx uint))
  (let ((user tx-sender))
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (as-contract (stx-transfer? (/ ustx u100) tx-sender user))))

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (ustx uint))
  (let ((fee (/ ustx u100)))
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (if (> fee u0)
      (as-contract (stx-transfer? fee tx-sender fee-receiver))
      (ok true))))

(define-constant ERR_NOT_AUTH (err u404))
