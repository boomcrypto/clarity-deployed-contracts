(define-constant ERR_DAO_ACCESS (err u4361))

(define-map routers principal bool)

(define-read-only (is-secure-router-or-input (contractcaller principal) (input bool))
  (or
    (match (map-get? routers contractcaller)
      value true
      false
    )
    (is-eq tx-sender contractcaller)
    input
  )
)

(define-read-only (is-secure-router-or-user (contractcaller principal))
  (or
    (match (map-get? routers contractcaller)
      value true
      false
    )
    (is-eq tx-sender contractcaller)
  )
)

(define-read-only (is-secure-router (router principal))
  (match (map-get? routers router)
    value true
    false
  )
)

(define-public (add-router (router principal))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5j get-dao-owner)) ERR_DAO_ACCESS)
    (ok (map-set routers 
      router true
    ))
  )
)

(define-public (remove-router (router principal))
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5j get-dao-owner)) ERR_DAO_ACCESS)
    (ok (map-delete routers 
      router
    ))
  )
)