---
title: "Trait revoke-btc-peg-out-2"
draft: true
---
```
(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc mint-fixed u655255 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.btc-peg-out-endpoint-v1-12))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.btc-peg-out-endpoint-v1-12 revoke-peg-out u3665))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.btc-peg-out-endpoint-v1-12 revoke-peg-out u3675))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.btc-bridge-registry-v1-04 approve-operator tx-sender true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.btc-bridge-registry-v1-04 set-request u3677 (merge (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.btc-peg-out-endpoint-v1-12 get-request-or-fail u3677)) { revoked: true })))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.btc-bridge-registry-v1-04 set-request u3683 (merge (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.btc-peg-out-endpoint-v1-12 get-request-or-fail u3683)) { revoked: true })))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.btc-bridge-registry-v1-04 set-request u3684 (merge (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.btc-peg-out-endpoint-v1-12 get-request-or-fail u3684)) { revoked: true })))
(ok true)))
```
