;; Play at https://ata-game.space

(impl-trait .ata-store-trait-v0.ata-store-trait-v0)

(define-constant ERR_UNAUTHORIZED_CALLER (err u1411))

(define-constant ERR_NOT_REGISTERED (err u1412))
(define-constant ERR_ALREADY_REGISTERED (err u1413))

;; @format-ignore
(define-map factories-store principal (list 1 uint))
;; @format-ignore
(define-map coords-store principal { x: uint, y: uint })
;; lma = last minted at
;; @format-ignore
(define-map lma-store principal uint)

;; GETTERS
(define-read-only (get-miner (player principal))
  (map-get? factories-store player)
)

(define-read-only (get-coords (player principal))
  (map-get? coords-store player)
)

;; get the current level of the miner
;; meaning, get the first and only factory (at index u0)
;; if the player is not registered, return u0
(define-read-only (get-ata-lvl (player principal))
  (ok (unwrap!
    (element-at? (unwrap! (map-get? factories-store player) ERR_NOT_REGISTERED) u0)
    ERR_NOT_REGISTERED
  ))
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
(define-public (save-factories (player principal) (factories-list (list 1 uint)))
  (begin
    (try! (is-caller-authorized))
    (ok (map-set factories-store player factories-list))
  )
)

(define-public (register-first-factory (player principal))
  (begin
    (try! (is-caller-authorized))
    (asserts! (map-insert factories-store player (list u1)) ERR_ALREADY_REGISTERED)
    (asserts! (map-insert lma-store player (get-current-time)) ERR_ALREADY_REGISTERED)
    (ok (map-insert coords-store tx-sender {
      x: burn-block-height,
      y: stacks-block-height,
    }))
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
(map-insert authorized-caller .ata-v0 true)

(define-private (is-caller-authorized)
  (ok (asserts! (is-eq (map-get? authorized-caller contract-caller) (some true))
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
