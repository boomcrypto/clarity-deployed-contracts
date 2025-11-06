;; Play at https://ata-game.space

(impl-trait .ata-store-trait-v0.ata-store-trait-v0)

;; ERRORS
(define-constant ERR_UNAUTHORIZED_CALLER (err u4111))
(define-constant ERR_NOT_REGISTERED (err u4112))
(define-constant ERR_ALREADY_REGISTERED (err u4113))

;;; up to 16 factories, the level of each factory is stored in a list
(define-map factories-store principal (list 16 uint))
(define-map lma-store principal uint)

;; GETTERS
(define-read-only (get-factories (player principal))
  (map-get? factories-store player)
)

(define-read-only (get-lma (player principal))
  (map-get? lma-store player)
)

(define-read-only (get-player (player principal))
  (some {
    factories: (unwrap! (map-get? factories-store player) none),
    lma: (unwrap! (map-get? lma-store player) none),
  })
)

;; wrap get-player into a response to be compatible with the trait
(define-read-only (get-player-wrapper (player principal))
   (ok (get-player player))
)

;; FACTORIES
(define-public (save-factories (player principal) (factories-list (list 16 uint)))
  (begin
    (try! (is-caller-authorized))
    (ok (map-set factories-store player factories-list))
  )
)

(define-public (register-first-factory (player principal))
  (begin
    (try! (is-caller-authorized))
    (asserts! (map-insert factories-store player (list u1)) ERR_ALREADY_REGISTERED)
    (ok (asserts! (map-insert lma-store player (get-current-time)) ERR_ALREADY_REGISTERED))
  )
)

(define-public (save-lma)
  (let ((time (get-current-time)))
    (try! (is-caller-authorized))
    (asserts! (is-some (get-player tx-sender)) ERR_NOT_REGISTERED)
    (map-set lma-store tx-sender time)
    (ok time)
  )
)

;; ADMIN
(define-map authorized-caller principal bool)
(map-insert authorized-caller .gravel-v0 true)

(define-private (is-caller-authorized)
  (ok (asserts!
    (is-eq (map-get? authorized-caller contract-caller) (some true))
    ERR_UNAUTHORIZED_CALLER
  ))
)

(define-public (add-authorized-caller (contract principal))
  (begin
    (try! (contract-call? .ata-admin-v0 is-admin))
    (print "adding authorized contract")
    (ok (map-insert authorized-caller contract true))
  )
)

(define-public (remove-authorized-caller (contract principal))
  (begin
    (try! (contract-call? .ata-admin-v0 is-admin))
    (print "removing authorized contract")
    (ok (map-delete authorized-caller contract))
  )
)

;; HELPERS
(define-private (get-current-time)
  (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))
)
