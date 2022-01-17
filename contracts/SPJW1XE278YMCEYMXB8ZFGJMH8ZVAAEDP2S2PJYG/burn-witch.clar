(define-public (mint-witch)
  (begin
    (try! (contract-call? .belles-witches mint))
    (try! (contract-call? .belles-witches mint))
    (try! (contract-call? .belles-witches mint))
    (try! (contract-call? .belles-witches mint))
    (try! (contract-call? .belles-witches mint))
    (ok true)
  )
)

(define-public (burn-witches (ids (list 200 uint)))
  (begin
    (map burn-witch ids)
    (ok true)
  )
)

(define-public (burn-witch (id uint))
  (contract-call? .belles-witches burn id)
)
