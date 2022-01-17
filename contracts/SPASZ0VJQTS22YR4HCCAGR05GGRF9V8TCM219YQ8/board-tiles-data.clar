
;; maps
(define-map token-to-tile { token-id: uint } { tile-id: uint })
(define-map tile-to-token { tile-id: uint } { token-id: uint })

(define-map tiles-info { tile-id: uint } { mints-left: uint, points: uint })

(define-map tokens-first-version { token-id: uint } { first-version: bool })
(define-map tokens-levels { token-id: uint } { level: uint })
(define-map tokens-backgrounds { token-id: uint } { background: uint })

;; constants
(define-constant MAX-TILES u11352)
(define-constant ERR-NOT-AUTHORIZED (err u6001))


;; 
;; Get
;; 

(define-read-only (get-token-to-tile (token-id uint))
  (unwrap-panic (get tile-id (map-get? token-to-tile { token-id: token-id})))
)

(define-read-only (get-tile-to-token (tile-id uint))
  (unwrap-panic (get token-id (map-get? tile-to-token { tile-id: tile-id})))
)

(define-read-only (get-tiles-info (tile-id uint))
  (map-get? tiles-info { tile-id: tile-id})
)

(define-read-only (get-tile-mints-left (tile-id uint))
  (unwrap-panic (get mints-left (map-get? tiles-info { tile-id: tile-id })))
)

(define-read-only (get-tile-points (tile-id uint))
 (unwrap-panic  (get points (map-get? tiles-info { tile-id: tile-id })))
)

(define-read-only (get-token-first-version (token-id uint))
  (unwrap-panic (get first-version (map-get? tokens-first-version { token-id: token-id})))
)

(define-read-only (get-token-level (token-id uint))
  (unwrap-panic (get level (map-get? tokens-levels { token-id: token-id})))
)

(define-read-only (get-token-background (token-id uint))
  (unwrap-panic (get background (map-get? tokens-backgrounds { token-id: token-id})))
)

;; 
;; Get helpers
;; 

(define-read-only (get-token-points (token-id uint))
  (let (
    (tile-id (unwrap-panic (get tile-id (map-get? token-to-tile { token-id: token-id }))))
  )
    (get-tile-points tile-id)
  )
)

(define-read-only (get-all-token-info (token-id uint))
  (let (
    (tile-id (get-token-to-tile token-id))
    (tile-points (get-tile-points tile-id))
    (tile-level (get-token-level token-id))
    (tile-first-version (get-token-first-version token-id))
    (tile-background (get-token-background token-id))
  )
    {tile-id: tile-id, tile-first-version: tile-first-version, tile-points: tile-points, tile-level: tile-level, tile-background: tile-background}
  )
)

;; 
;; Set
;; 

(define-public (create-tile (token-id uint) (tile-id uint) (first-version bool) (level uint) (background uint))
  (let (
    (tile-id-info (unwrap-panic (map-get? tiles-info { tile-id: tile-id })))
    (token-id-amount (get mints-left tile-id-info))
  )
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .board-main get-qualified-name-by-name "board-tiles-manager"))) ERR-NOT-AUTHORIZED)
    (if (is-eq token-id-amount u0)
      true
      (map-set tiles-info { tile-id: tile-id } (merge tile-id-info { mints-left: (- token-id-amount u1) }))
    )
    (map-set token-to-tile { token-id: token-id } { tile-id: tile-id })
    (map-set tile-to-token { tile-id: tile-id } { token-id: token-id })

    (map-set tokens-first-version {token-id: token-id} { first-version: first-version} )
    (map-set tokens-levels {token-id: token-id} { level: level} )
    (map-set tokens-backgrounds {token-id: token-id} { background: background} )
    (ok true)
  )
)

(define-public (upgrade-tile (token-id uint) (level uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .board-main get-qualified-name-by-name "board-tiles-manager"))) ERR-NOT-AUTHORIZED)
    (map-set tokens-levels {token-id: token-id} { level: level} )
    (ok level)
  )
)

(define-public (set-tile-background (token-id uint) (background uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .board-main get-qualified-name-by-name "board-tiles-manager"))) ERR-NOT-AUTHORIZED)
    (map-set tokens-backgrounds {token-id: token-id} { background: background} )
    (ok background)
  )
)

;;
;; Initialise
;;

;; probabilities
(map-set tiles-info { tile-id: u0 } { mints-left: u1000, points: u1 }) ;;a
(map-set tiles-info { tile-id: u1 } { mints-left: u111, points: u3 }) ;;b
(map-set tiles-info { tile-id: u2 } { mints-left: u111, points: u3 }) ;;c
(map-set tiles-info { tile-id: u3 } { mints-left: u250, points: u2 }) ;;d
(map-set tiles-info { tile-id: u4 } { mints-left: u1000, points: u1 }) ;;e
(map-set tiles-info { tile-id: u5 } { mints-left: u63, points: u4}) ;;f
(map-set tiles-info { tile-id: u6 } { mints-left: u250, points: u2}) ;;g
(map-set tiles-info { tile-id: u7 } { mints-left: u63, points: u4}) ;;h
(map-set tiles-info { tile-id: u8 } { mints-left: u1000, points: u1}) ;;i
(map-set tiles-info { tile-id: u9 } { mints-left: u16, points: u8}) ;;j
(map-set tiles-info { tile-id: u10 } { mints-left: u40, points: u5}) ;;k
(map-set tiles-info { tile-id: u11 } { mints-left: u1000, points: u1}) ;;l
(map-set tiles-info { tile-id: u12 } { mints-left: u111, points: u3}) ;;m
(map-set tiles-info { tile-id: u13 } { mints-left: u1000, points: u1}) ;;n
(map-set tiles-info { tile-id: u14 } { mints-left: u1000, points: u1}) ;;o
(map-set tiles-info { tile-id: u15 } { mints-left: u111, points: u3}) ;;p
(map-set tiles-info { tile-id: u16 } { mints-left: u10, points: u10}) ;;q
(map-set tiles-info { tile-id: u17 } { mints-left: u1000, points: u1}) ;;r
(map-set tiles-info { tile-id: u18 } { mints-left: u1000, points: u1}) ;;s
(map-set tiles-info { tile-id: u19 } { mints-left: u1000, points: u1}) ;;t
(map-set tiles-info { tile-id: u20 } { mints-left: u1000, points: u1}) ;;u
(map-set tiles-info { tile-id: u21 } { mints-left: u63, points: u4}) ;;v
(map-set tiles-info { tile-id: u22 } { mints-left: u63, points: u4}) ;;w
(map-set tiles-info { tile-id: u23 } { mints-left: u16, points: u8}) ;;x
(map-set tiles-info { tile-id: u24 } { mints-left: u63, points: u4}) ;;y
(map-set tiles-info { tile-id: u25 } { mints-left: u10, points: u10}) ;;z
(map-set tiles-info { tile-id: u26 } { mints-left: u1, points: u12}) ;;joker

