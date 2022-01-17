;; Implementation of proof of hodl during mia cycle 2 for any service.

;; For information only.
(define-public (get-fees (ustx uint))
  (ok u0))

(define-read-only (hodls-mia (user principal))
  (> (unwrap! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token
            get-balance user) false) u1000))

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (ustx uint))
  (begin
    (asserts! (and (< block-height u30797) (hodls-mia tx-sender)) ERR_NOT_AUTH)
    (ok true)))

;; Release fees for the given amount if swap was canceled.
;; It relies on the logic of the charging-ctr that this contract.
(define-public (release-fees (ustx uint))
  (ok true))

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (ustx uint))
  (ok true))

(define-constant ERR_NOT_AUTH (err u404))
