(use-trait ft-trait .ft-trait.ft-trait)

(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S))
    (ok true)))

(define-public (pay-in-token (id uint) (price uint) (token-trait <ft-trait>))
  (begin
    (try! (contract-call? token-trait transfer (/ (* price u200) u10000) tx-sender 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S none))
    (ok true)))