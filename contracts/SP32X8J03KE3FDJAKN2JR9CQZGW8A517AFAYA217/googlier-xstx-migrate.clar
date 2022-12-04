(define-public (migrate-xstx)
  (let (
    (balance-v1 (unwrap-panic (contract-call? .xstx-token get-balance .googlier-sip10-reserve-v1-1)))
  )
    (try! (contract-call? .googlier-dao burn-token .xstx-token balance-v1 .googlier-sip10-reserve-v1-1))
    (try! (contract-call? .googlier-dao mint-token .xstx-token balance-v1 .googlier-sip10-reserve-v2-1))

    (ok true)
  )
)
