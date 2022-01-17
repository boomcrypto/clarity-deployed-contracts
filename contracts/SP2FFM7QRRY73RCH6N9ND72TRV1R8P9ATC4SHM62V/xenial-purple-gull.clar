(define-constant contract-owner tx-sender)
(define-public (admin-test)
  (begin
    (asserts! (is-eq tx-sender 'SP1N35KMK3EX3SXRAEZ89J2YX23Q1F7P9J640QHX4) (err u101))
    (unwrap! (stx-transfer? u100000 tx-sender contract-owner) (err u102))
    (ok
      (unwrap! (as-contract (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 transfer u80 (as-contract tx-sender) 'SP25VWGTPR19E344S4ENTHQT8651216EPNABRYE51)) (err u103))
    )
  )
)