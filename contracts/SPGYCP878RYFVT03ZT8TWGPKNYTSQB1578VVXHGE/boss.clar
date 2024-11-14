;; kraqen.btc

(define-private (strw1-wrapper)
  (match (contract-call? .profiterolv2 strw1 u50000000)
    success (ok true)
    failure (err failure)))

(define-private (strw2-wrapper)
  (match (contract-call? .profiterolv2 strw2 u50000000)
    success (ok true)
    failure (err failure)))

(define-private (strr1-wrapper)
  (match (contract-call? .profiterolv2 strr1 u50000000)
    success (ok true)
    failure (err failure)))

(define-private (strr2-wrapper)
  (match (contract-call? .profiterolv2 strr2 u50000000)
    success (ok true)
    failure (err failure)))

(define-private (perform1)
  (match (contract-call? .dex-helper-v999 perform-swap-1)
    success (ok true)
    failure (err failure)))

(define-public (call-all-wrappers)
  (begin
    (try! (strw1-wrapper))
    (try! (strw2-wrapper))
    (try! (strr1-wrapper))
    (try! (strr2-wrapper))
    (try! (perform1))
    (ok true)))