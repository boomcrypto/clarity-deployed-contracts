;; by price.btc.us

(define-public (register (namespace (buff 20)) (name (buff 48)) (price uint))
  (begin
    (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder (hash160 (concat (concat (concat name 0x2e) namespace) 0x6161616161626262626261616161616262626262)) price))
    (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name 0x6161616161626262626261616161616262626262 0x1122334455667788990011223344556677889900))
    (ok true)
  )
)
