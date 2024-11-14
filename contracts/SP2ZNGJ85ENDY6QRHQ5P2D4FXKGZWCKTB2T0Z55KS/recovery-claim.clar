(define-constant err-already-claimed (err u400))

(define-map claimed principal bool)
(define-map red-pill principal bool)

(define-data-var last-id uint u0)

(define-read-only (get-last-claim-id)
  (var-get last-id)
)

(define-read-only (has-claimed (address principal))
  (default-to false (map-get? claimed address))
)

(define-public (claim (choice bool))
  (begin
    (asserts! (not (has-claimed tx-sender)) err-already-claimed)
    (map-set claimed tx-sender true)
    (map-set red-pill tx-sender choice)
    (var-set last-id (+ (var-get last-id) u1))
    (if choice
      (try! (contract-call? .the-red-pill claim))
      (try! (contract-call? .the-blue-pill claim))
    )
    (ok {
      last-id: (var-get last-id),
      red-pill: choice
    })
  )
)