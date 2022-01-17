(define-constant owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-public (multi-transfer-two)
  (begin
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 transfer u1401 tx-sender 'SP1H6R0QXWNPRCG9Q6Z2V4S0Z9VNKW1Y2ZXNARBXH))
    (ok (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 transfer u1402 tx-sender 'SP1H6R0QXWNPRCG9Q6Z2V4S0Z9VNKW1Y2ZXNARBXH)))
  )
)