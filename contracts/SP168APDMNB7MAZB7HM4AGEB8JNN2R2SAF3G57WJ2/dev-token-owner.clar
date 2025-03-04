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
    (try! (as-contract (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-stxcity set-token-uri value)))
    (ok true)
  )
)

(define-public (transfer-ownership (new-owner principal))
  (begin
    ;; check if caller is authorized
    (try! (is-dao-or-extension))
    ;; transfer ownership
    (try! (as-contract (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-stxcity transfer-ownership new-owner)))
    (ok true)
  )
)

;; private functions
;;

(define-private (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-base-dao)
    (contract-call? 'SP168APDMNB7MAZB7HM4AGEB8JNN2R2SAF3G57WJ2.dev-base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)
