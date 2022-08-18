(define-public (register (info-list (list 30 { namespace: (buff 20), name: (buff 48), price: uint, address: principal })))
  (let
    (
      (sender tx-sender)
    )
    (filter register-one info-list)
    (ok true)
  )
)

(define-private (register-one (info { namespace: (buff 20), name: (buff 48), price: uint, address: principal }))
  (let
    (
      (namespace (get namespace info))
      (name (get name info))
    )
    (and (is-err (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name))
          (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder (hash160 (concat (concat (concat name 0x2e) namespace) 0x6161616161626262626261616161616262626262)) (get price info)))
          (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name 0x6161616161626262626261616161616262626262 0x1122334455667788990011223344556677889900))
          (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name (get address info) none))
    )
  )
)