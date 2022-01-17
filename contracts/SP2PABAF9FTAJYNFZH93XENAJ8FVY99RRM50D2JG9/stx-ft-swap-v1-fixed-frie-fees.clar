;; Implementation of fixed fees of 1% for the service
;; by the charging-ctr. Only that contract can call the public functions.
;; the ft is exchanged 1:1 to STX

(define-constant fee-receiver tx-sender)
(define-constant charging-ctr 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.stx-ft-swap-v1)

;; For information only.
(define-public (get-fees (ustx uint))
  (ok (to-ft-fee ustx)))

(define-read-only (to-ft-fee (ustx uint))
  (/ ustx u100))

(define-private (ft-transfer-to (amount uint) (recipient principal) (memo (optional (buff 34))))
  (begin
    (and (> amount u0) (try! (contract-call? 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X.friedger-token-v1 transfer amount tx-sender recipient memo)))
    (ok true)))


;; Hold fees for the given amount in escrow.
(define-public (hold-fees (ustx uint))
  (begin
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (ft-transfer-to (to-ft-fee ustx) (as-contract tx-sender) none)))

;; Release fees for the given amount if swap was canceled.
;; It relies on the logic of the charging-ctr that this contract.
(define-public (release-fees (ustx uint))
  (let ((user tx-sender))
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (as-contract (ft-transfer-to (to-ft-fee ustx) user none))))

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (ustx uint))
  (begin
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (as-contract (ft-transfer-to (to-ft-fee ustx) fee-receiver none))))

(define-constant ERR_NOT_AUTH (err u404))
