(define-constant owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-public (admin-drop-catchup)
  (begin
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP1PN944TZY06602036V2MQM1WEDX9JPMPN521TEE u884))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP1PN944TZY06602036V2MQM1WEDX9JPMPN521TEE u899))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP1PN944TZY06602036V2MQM1WEDX9JPMPN521TEE u799))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP1PN944TZY06602036V2MQM1WEDX9JPMPN521TEE u765))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP1PN944TZY06602036V2MQM1WEDX9JPMPN521TEE u587))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP1PN944TZY06602036V2MQM1WEDX9JPMPN521TEE u131))
    (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP1PN944TZY06602036V2MQM1WEDX9JPMPN521TEE u113))
    (ok (try! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 admin-mint-drop 'SP1PN944TZY06602036V2MQM1WEDX9JPMPN521TEE u972)))
  )
)