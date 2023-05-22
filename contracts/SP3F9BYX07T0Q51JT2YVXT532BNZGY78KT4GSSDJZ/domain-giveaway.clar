(define-public (register (namespace (buff 20)) (name (buff 48)) (stx-to-burn uint) (zonefile-hash (buff 20)) (zone-hash (optional (buff 20))) (salt (buff 20)) (actual-owner principal))
  (let
    (
      (hashed-salted-fqn (hash160 (concat (concat (concat name 0x2e) namespace) salt)))
    )
    (begin
      (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder hashed-salted-fqn stx-to-burn))
      (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name salt zonefile-hash))
      (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name actual-owner zone-hash))
      (ok true)
    )
  )
)