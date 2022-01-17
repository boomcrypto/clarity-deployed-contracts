(define-public (mint-three)
  (begin
    (try! (contract-call? .fridas mint))
    (try! (contract-call? .fridas mint))
    (try! (contract-call? .fridas mint))
    (ok true)
  )
)

(define-public (mint-five)
  (begin
    (try! (contract-call? .fridas mint))
    (try! (contract-call? .fridas mint))
    (try! (contract-call? .fridas mint))
    (try! (contract-call? .fridas mint))
    (try! (contract-call? .fridas mint))
    (ok true)
  )
)

(define-public (burn-fridas (ids (list 200 uint)))
  (begin
    (map burn-frida ids)
    (ok true)
  )
)

(define-public (burn-frida (id uint))
  (contract-call? .fridas burn id)
)
