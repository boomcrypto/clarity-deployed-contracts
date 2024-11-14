---
title: "Trait energy-storage"
draft: true
---
```
;; Energy Storage
;; This contract handles energy storage functionality, authorized by the DAO or extensions

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))

;; Data vars and maps
(define-map stored-energy principal uint)

;; Authorization check
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
    (ok (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED))
)

(define-read-only (get-stored-energy (user principal))
  (default-to u0 (map-get? stored-energy user))
)

;; Public energy storage functions

(define-public (store-energy (user principal) (amount uint))
  (begin
    (try! (is-authorized))
    (ok (map-set stored-energy user (+ (get-stored-energy user) amount)))
  )
)

(define-public (use-energy (user principal) (amount uint))
  (let (
    (current-stored (get-stored-energy user))
    (energy-to-use (min amount current-stored))
  )
    (try! (is-authorized))
    (map-set stored-energy user (- current-stored energy-to-use))
    (ok energy-to-use)
  )
)

;; Utility functions

(define-private (min (a uint) (b uint))
  (if (<= a b) a b)
)
```
