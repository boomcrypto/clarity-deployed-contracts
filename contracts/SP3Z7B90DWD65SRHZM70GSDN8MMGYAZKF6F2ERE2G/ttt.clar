(define-constant ERR_NO_AUTHORITY 10001)
(define-constant ERR_RESOLVE_PRINCIPLE 10003)

(define-constant OWNER tx-sender)

(define-public (test_transfer)
  (let
    (
      (resolve_rsp_p (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal tx-sender) (err ERR_RESOLVE_PRINCIPLE)))
      (namespace (get namespace resolve_rsp_p))
      (name (get name resolve_rsp_p))
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
    )
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name 'SP3Z7B90DWD65SRHZM70GSDN8MMGYAZKF6F2ERE2G.A (some (get zonefile-hash resolve_rsp))))
  )
)
