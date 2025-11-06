(define-constant ERR_ADMIN_ONLY (err u4911))

(define-data-var admin principal tx-sender)

(define-read-only (is-admin)
  (ok (asserts! (is-eq tx-sender (var-get admin)) ERR_ADMIN_ONLY))
)

(define-read-only (get-admin)
  (var-get admin)
)

(define-public (set-admin (new-admin principal))
  (begin
    (try! (is-admin))
    (print "updating ata admin")
    (ok (var-set admin new-admin))
  )
)
