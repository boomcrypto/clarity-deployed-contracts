(define-constant OWNER tx-sender)
(define-data-var m_master_contract (optional principal) none)

(define-public (transfer (namespace (buff 20)) (name (buff 48)) (new_owner principal) (zonefile-hash (optional (buff 20))))
  (let
    ((resolve_rsp (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
    (asserts! (is-eq contract-caller (unwrap-panic (var-get m_master_contract))) (err 9001))
    (asserts! (is-ok resolve_rsp) (err 9002))
    (asserts! (is-eq (get owner (unwrap-panic resolve_rsp)) (as-contract tx-sender)) (err 9003))
    (as-contract (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name new_owner zonefile-hash)))
    (ok true)
  )
)

(define-public (set_master_contract (contract_owner principal))
  (begin
    (asserts! (is-eq tx-sender OWNER) (err 9001))
    (ok (and (is-none (var-get m_master_contract)) (var-set m_master_contract (some contract_owner))))
  )
)