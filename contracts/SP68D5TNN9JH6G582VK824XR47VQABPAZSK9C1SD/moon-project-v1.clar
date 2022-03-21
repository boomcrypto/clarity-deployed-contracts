;; mp
;; utility & admin contract for mp
;; in association with: [redacted, redacted, & redacted]
;; hi Jamil

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read Only Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc returns the user mint count for a specific principal
;; @param principal; the identifier here is for each wallet
(define-read-only (user-mint-count (user principal))
    (default-to {l-fs: u0, p-ms: u0, c-ms: u0} (map-get? user-mints tx-sender))
)

;;;;;;;;;;;;;;;;;;;;;
;; Utility Storage ;;
;;;;;;;;;;;;;;;;;;;;;

;; @desc map of all mints that a user made; this is *not* a live balance, it's tracker of total mints
;; @param principal; the identifier here is an individual wallet
(define-map user-mints principal
  {
    l-fs: uint,
    p-ms: uint,
    c-ms: uint
  }
)

;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; @desc utility function that updates the user-mint map when a user has called the lf contract
(define-public (update-user-l-f-mint-count)
  (let
    (
      (l-f-count (get l-fs (default-to {l-fs: u0, p-ms: u0, c-ms: u0} (map-get? user-mints tx-sender))))
      (p-m-count (get p-ms (default-to {l-fs: u0, p-ms: u0, c-ms: u0} (map-get? user-mints tx-sender))))
      (c-m-count (get c-ms (default-to {l-fs: u0, p-ms: u0, c-ms: u0} (map-get? user-mints tx-sender))))
    )
    ;; need to check called by X contract?
    ;;(asserts! (is-eq contract-caller tx-sender) (err u101))
    (ok (map-set user-mints tx-sender {l-fs: (+ u1 l-f-count), p-ms: p-m-count, c-ms: c-m-count}))
  )
)

;; @desc utility function that updates the user-mint map when a user has called the p-m contract
(define-public (update-user-p-ms-mint-count)
  (let
    (
      (l-f-count (get l-fs (default-to {l-fs: u0, p-ms: u0, c-ms: u0} (map-get? user-mints tx-sender))))
      (p-m-count (get p-ms (default-to {l-fs: u0, p-ms: u0, c-ms: u0} (map-get? user-mints tx-sender))))
      (c-m-count (get c-ms (default-to {l-fs: u0, p-ms: u0, c-ms: u0} (map-get? user-mints tx-sender))))
    )
    ;; need to check called by X contract
    ;;(asserts! (is-eq contract-caller tx-sender) (err u101))
    (ok (map-set user-mints tx-sender {l-fs: l-f-count, p-ms: (+ u1 p-m-count), c-ms: c-m-count}))
  )
)

;; @desc utility function that updates the user-mint map when a user has called the p-m contract
(define-public (update-user-c-ms-mint-count)
  (let
    (
      (l-f-count (get l-fs (default-to {l-fs: u0, p-ms: u0, c-ms: u0} (map-get? user-mints tx-sender))))
      (p-m-count (get p-ms (default-to {l-fs: u0, p-ms: u0, c-ms: u0} (map-get? user-mints tx-sender))))
      (c-m-count (get c-ms (default-to {l-fs: u0, p-ms: u0, c-ms: u0} (map-get? user-mints tx-sender))))
    )
    ;; need to check called by X contract
    ;;(asserts! (is-eq contract-caller tx-sender) (err u101))
    (ok (map-set user-mints tx-sender {l-fs: l-f-count, p-ms: p-m-count, c-ms: (+ u1 c-m-count)}))
  )
)

;; @desc utility function that takes in a unit & returns a string
;; @param value; the unit we're casting into a string to concatenate
;; thanks to Lnow for the guidance
(define-read-only (uint-to-ascii (value uint))
  (if (<= value u9)
    (unwrap-panic (element-at "0123456789" value))
    (get r (fold uint-to-ascii-inner
      0x000000000000000000000000000000000000000000000000000000000000000000000000000000
      {v: value, r: ""}
    ))
  )
)

(define-read-only (uint-to-ascii-inner (i (buff 1)) (d {v: uint, r: (string-ascii 39)}))
  (if (> (get v d) u0)
    {
      v: (/ (get v d) u10),
      r: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get v d) u10))) (get r d)) u39))
    }
    d
  )
)

;;;;;;;;;;;;;;;;;;;;;
;; Admin Functions ;;
;;;;;;;;;;;;;;;;;;;;;
