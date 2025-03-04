
(define-private (transfer-pepe (recipient principal) (amountOrError (response uint uint)))
  (begin
    (match amountOrError amount 
      (begin
        (asserts! (is-ok (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz transfer amount contract-caller recipient none)) (err u1))
        (ok amount))
      error (err error))))

(define-public (airdrop-pepe (amount uint) (recipients (list 1000 principal)))
  (fold transfer-pepe recipients (ok amount)))