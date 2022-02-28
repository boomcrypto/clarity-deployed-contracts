;; A simple protector

(define-constant ERR_NO_AUTHORITY 10001)
(define-constant ERR_INVALID_LEN 10002)
(define-constant ERR_RESOLVE_PRINCIPLE 10003)
(define-constant ERR_RESOLVE_NAME 10004)
(define-constant ERR_INVALID_PWD 10005)

(define-constant OWNER tx-sender)

(define-data-var m_hash_value (buff 32) 0x)

(define-public (deposit (hash_value (buff 32)))
  (let
    (
      (resolve_rsp_p (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal tx-sender) (err ERR_RESOLVE_PRINCIPLE)))
      (namespace (get namespace resolve_rsp_p))
      (name (get name resolve_rsp_p))
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
    )
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (asserts! (is-eq (len hash_value) u32) (err ERR_INVALID_LEN))
    (var-set m_hash_value hash_value)
    (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name (as-contract tx-sender) (some (get zonefile-hash resolve_rsp)))
  )
)

(define-public (withdraw (pwd (buff 32)) (new_owner (optional principal)))
  (let
    (
      (resolve_rsp_p (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (as-contract tx-sender)) (err ERR_RESOLVE_PRINCIPLE)))
      (namespace (get namespace resolve_rsp_p))
      (name (get name resolve_rsp_p))
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
    )
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (asserts! (is-eq (len pwd) u32) (err ERR_INVALID_LEN))
    (asserts! (is-eq (keccak256 pwd) (var-get m_hash_value)) (err ERR_INVALID_PWD))
    (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name (default-to OWNER new_owner) (some (get zonefile-hash resolve_rsp))))
  )
)

(define-public (renew (stx_to_burn uint))
  (let
    (
      (resolve_rsp_p (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (as-contract tx-sender)) (err ERR_RESOLVE_PRINCIPLE)))
      (namespace (get namespace resolve_rsp_p))
      (name (get name resolve_rsp_p))
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
    )
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-renewal namespace name stx_to_burn none none))
  )
)

(define-read-only (get_hash (pwd (buff 32)))
  (keccak256 pwd)
)

;; init deposit
(deposit 0xb80b7ce89aed53088d5a4912634248cc35027d73228c6d262e2552310a280819)