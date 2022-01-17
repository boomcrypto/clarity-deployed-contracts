;; send-airdrop-practice-v0
;; practice contract for sending multiple stx txs out in an airdrop
(define-public (load-up)
  (ok (unwrap! (stx-transfer? u1000 tx-sender (as-contract tx-sender)) (err u101)))
)
(define-public (pay-out)
  (begin
    (asserts! (is-eq tx-sender 'SP1N35KMK3EX3SXRAEZ89J2YX23Q1F7P9J640QHX4) (err u102))
    (unwrap! (stx-transfer? u500 tx-sender 'SP25VWGTPR19E344S4ENTHQT8651216EPNABRYE51) (err u103))
    (ok (unwrap! (stx-transfer? u500 tx-sender 'SP1VA9HEH5VJFBCGJ6F8VF9BGS8WF6DJE9AD7856) (err u104)))
  )
)