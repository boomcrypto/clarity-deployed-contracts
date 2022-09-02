;; claim fees and refund
(define-public (claim-refund (old-hashed-salted-fqn (buff 20)) (owner principal) (amount uint))
  (begin
    (try! (contract-call? .ryder-handles-controller-v1 claim-fees old-hashed-salted-fqn owner))
    (stx-transfer? amount tx-sender owner)))