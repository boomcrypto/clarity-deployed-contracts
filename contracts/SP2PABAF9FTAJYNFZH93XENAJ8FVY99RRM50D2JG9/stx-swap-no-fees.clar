;; Implementation of no fees for the service

;; For information only.
(define-public (get-fees (ustx uint))
  (ok u0))

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (ustx uint))
  (ok true))

;; Release fees for the given amount if swap was canceled.
(define-public (release-fees (ustx uint))
  (ok true))

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (ustx uint))
  (ok true))
