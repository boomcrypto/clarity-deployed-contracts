(impl-trait .owned-profiles-v1.commission-trait)
(use-trait ownable-trait .owned-profiles-v1.ownable-trait)

(define-public (pay (contract <ownable-trait>) (id uint))
    (ok true))
