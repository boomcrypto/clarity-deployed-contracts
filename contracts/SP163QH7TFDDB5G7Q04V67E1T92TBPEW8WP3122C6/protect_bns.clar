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
    (asserts! (is-eq (keccak256 pwd) (var-get m_hash_value)) (err ERR_INVALID_PWD))
    (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name (default-to OWNER new_owner) (some (get zonefile-hash resolve_rsp))))
  )
)

;; init deposit
(deposit 0x57178e9f327e2a10d0380b6d33f90e8ae614fc1ee3f298309cf5bed0920240c3)
