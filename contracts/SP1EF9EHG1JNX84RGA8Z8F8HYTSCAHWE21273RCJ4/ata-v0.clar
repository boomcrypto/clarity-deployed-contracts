;; Play at https://ata-game.space

;; ATA - contract manager
;; The ATA resource is similar to other resources.
;; Except that the player can only have one "factory". Called the ATA miner.
;; So the data structure is a bit different

(impl-trait .ata-resource-trait-v0.ata-resource-trait-v0)

(use-trait ata-ft-trait .ata-ft-trait-v0.ata-ft-trait-v0)

(define-data-var initial-mint uint u1000)

;; CONSTANTS
(define-constant ERR_OWNER_ONLY (err u2411))
(define-constant ERR_NOT_TOKEN_OWNER (err u2412))

(define-constant ERR_NOT_REGISTERED (err u2413))

;; COSTS HANDLING
(define-data-var ata-costs uint u16)
(define-data-var cost-data-0 { base: uint, from: uint, pow: uint }
  { base: u33, from: u1, pow: u2 }
)
(define-data-var cost-data-1 { base: uint, from: uint, pow: uint }
  { base: u44, from: u3, pow: u3 }
)
(define-data-var cost-data-2 { base: uint, from: uint, pow: uint }
  { base: u55, from: u9, pow: u7 }
)
(define-data-var cost-data-3 { base: uint, from: uint, pow: uint }
  { base: u66, from: u18, pow: u10 }
)

(define-private (spend-upgrade-resources (lvl uint))
  (begin
    (try! (contract-call? .ata-spend-v0 spend-ata (var-get ata-costs) lvl))

    (try! (contract-call? .ata-spend-v0 spend-resource .wood-ft-v0 (var-get cost-data-0) lvl))
    (try! (contract-call? .ata-spend-v0 spend-resource .coal-ft-v0 (var-get cost-data-1) lvl))
    (try! (contract-call? .ata-spend-v0 spend-resource .sand-ft-v0 (var-get cost-data-2) lvl))
    (try! (contract-call? .ata-spend-v0 spend-resource .clay-ft-v0 (var-get cost-data-3) lvl))
    (ok true)
  )
)

;; COLLECT
(define-data-var base-production uint u1)
(define-private (inner-collect
    (lvl uint)
    (acc { elapsed: uint, result: uint })
  )
  {
    elapsed: (get elapsed acc),
    result: (+
      (get result acc)
      (*
        (get elapsed acc)
        ;; growth formula is `base-production * (lvl + log2(lvl^2))`
        (* (var-get base-production) (+ lvl (log2 (pow lvl u2))))
      )
    )
  }
)

(define-public (collect)
  (let (
      (player (unwrap! (contract-call? .ata-store-v0 get-player tx-sender) ERR_NOT_REGISTERED))
      (to-mint (/ (get result
        (inner-collect (unwrap! (element-at? (get factories player) u0) ERR_NOT_REGISTERED) {
          elapsed: (min (- (get-current-time) (get lma player)) u259200), ;; 3 days
          result: u0,
        })
      ) u60))
    )
    (asserts! (> to-mint u0) (ok u0))
    (try! (contract-call? .ata-ft-v0 mint to-mint))
    (contract-call? .ata-store-v0 save-lma)
  )
)

;;; register to build the first factory
(define-public (register)
  (begin
    (try! (contract-call? .ata-ft-v0 mint (var-get initial-mint)))
    (contract-call? .ata-store-v0 register-first-factory tx-sender)
  )
)

(define-public (upgrade-factory)
  (let ((lvl (+ u1 (try! (contract-call? .ata-store-v0 get-ata-lvl tx-sender)))))
    (try! (collect))
    (try! (spend-upgrade-resources lvl))
    (contract-call? .ata-store-v0 save-factories tx-sender (list lvl))
  )
)

;; ADMIN
(define-public (set-base-production (new-base uint))
  (begin
    (try! (contract-call? .ata-admin-v0 is-admin))
    (ok (var-set base-production new-base))
  )
)

(define-public (set-ata-cost (cost uint))
  (begin
    (try! (contract-call? .ata-admin-v0 is-admin))
    (ok (var-set ata-costs cost))
  )
)

(define-public (set-costs
  (c0 { base: uint, from: uint, pow: uint })
  (c1 { base: uint, from: uint, pow: uint })
  (c2 { base: uint, from: uint, pow: uint })
  (c3 { base: uint, from: uint, pow: uint })
)
  (begin
    (try! (contract-call? .ata-admin-v0 is-admin))

    (var-set cost-data-0 c0)
    (var-set cost-data-1 c1)
    (var-set cost-data-2 c2)
    (var-set cost-data-3 c3)

    (ok true)
  )
)

;; HELPERS
(define-private (min (a uint) (b uint))
  (if (< a b) a b)
)

(define-private (get-current-time)
  (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))
)
