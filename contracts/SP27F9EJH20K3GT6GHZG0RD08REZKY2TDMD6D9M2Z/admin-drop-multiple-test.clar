(define-constant owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-public (admin-drop-ten)
  (begin
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP25VWGTPR19E344S4ENTHQT8651216EPNABRYE51 u405))
    (ok (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP25VWGTPR19E344S4ENTHQT8651216EPNABRYE51 u683)))
  )
)