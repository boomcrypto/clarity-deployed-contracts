;; register multi domains simultaneously

(define-public (register (info-list (list 30 { namespace: (buff 20), name: (buff 48), price: uint, address: principal })))
  (ok (filter loop info-list))
)

(define-private (loop (info { namespace: (buff 20), name: (buff 48), price: uint, address: principal }))
  (is-ok (register-one info))
)

(define-public (register-one (info { namespace: (buff 20), name: (buff 48), price: uint, address: principal }))
  (let
    (
      (namespace (get namespace info))
      (name (get name info))
    )
    (if (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns can-name-be-registered namespace name))
      (begin
        (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder (hash160 (concat (concat (concat name 0x2e) namespace) 0x6161616161626262626261616161616262626262)) (get price info)))
        (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name 0x6161616161626262626261616161616262626262 0x1122334455667788990011223344556677889900))
        (ok true)
      )
      (ok true)
    )
  )
)