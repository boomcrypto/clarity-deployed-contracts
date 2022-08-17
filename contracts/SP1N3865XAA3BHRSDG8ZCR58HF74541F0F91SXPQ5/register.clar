;; register multi domains simultaneously

(define-public (register (info-list (list 30 { namespace: (buff 20), name: (buff 48), price: uint, address: principal })))
  (let
    (
      (sender tx-sender)
    )
    (try! (stx-transfer? (stx-get-balance tx-sender) sender (as-contract tx-sender)))
    (filter register-one info-list)
    (as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender sender))
  )
)

(define-private (register-one (info { namespace: (buff 20), name: (buff 48), price: uint, address: principal }))
  (as-contract
    (let
      (
        (namespace (get namespace info))
        (name (get name info))
      )
      (and (is-err (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name))
           (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder (hash160 (concat (concat (concat name 0x2e) namespace) 0x)) (get price info)))
           (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name 0x 0x))
           (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name (get address info) none))
      )
    )
  )
)
