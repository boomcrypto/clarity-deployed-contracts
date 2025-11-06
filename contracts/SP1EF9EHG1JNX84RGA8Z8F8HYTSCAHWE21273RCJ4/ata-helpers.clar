(use-trait resource-trait .ata-resource-trait-v0.ata-resource-trait-v0)
(use-trait store-trait .ata-store-trait-v0.ata-store-trait-v0)
(define-constant ERR_NO_RESOURCE_COLLECTED (err u250))

(define-private (collect-one (resource <resource-trait>))
  (contract-call? resource collect)
)

(define-private (is-ok-response (response (response uint uint)))
  (is-ok response)
)

(define-public (collect-all (resources (list 16 <resource-trait>)))
  (let ((responses (map collect-one resources)))
    (if (> (len (filter is-ok-response responses)) u0)
      (ok responses)
      (err responses)
    )
  )
)

(define-private (get-player-resource (resource <store-trait>))
  (unwrap! (contract-call? resource get-player-wrapper tx-sender) none)
)

(define-public (get-player-data (resources (list 16 <store-trait>)))
  (ok (map get-player-resource resources))
)
