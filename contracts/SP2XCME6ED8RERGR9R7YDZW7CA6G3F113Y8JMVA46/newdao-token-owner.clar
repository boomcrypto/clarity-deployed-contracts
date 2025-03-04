;; title: aibtcdev-token-owner
;; version: 1.0.0
;; summary: An extension that provides management functions for the dao token

;; traits
;;
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.extension)
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.token-owner)

;; constants
;;

(define-constant ERR_UNAUTHORIZED (err u7000))

;; public functions
;;

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    ;; check if caller is authorized
    (try! (is-dao-or-extension))
    ;; update token uri
    (try! (as-contract (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.newdao-stxcity set-token-uri value)))
    (ok true)
  )
)

(define-public (transfer-ownership (new-owner principal))
  (begin
    ;; check if caller is authorized
    (try! (is-dao-or-extension))
    ;; transfer ownership
    (try! (as-contract (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.newdao-stxcity transfer-ownership new-owner)))
    (ok true)
  )
)

;; private functions
;;

(define-private (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.newdao-base-dao)
    (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.newdao-base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)
