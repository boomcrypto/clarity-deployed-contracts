;; Play at https://ata-game.space

(impl-trait .ata-resource-trait-v0.ata-resource-trait-v0)

(use-trait ata-ft-trait .ata-ft-trait-v0.ata-ft-trait-v0)

(define-data-var initial-mint uint u2048)

;; ERRORS
(define-constant ERR_NOT_REGISTERED (err u4211))
(define-constant ERR_INVALID_FACTORY_INDEX (err u4212))
(define-constant ERR_MAX_NB_OF_FACTORIES_REACHED (err u4213))
(define-constant ERR_CANT_EXCEED_ATA_MINER_LEVEL (err u4214))
(define-constant ERR_ATA_MINER_LEVEL_TOO_LOW (err u4215))

;; COSTS HANDLING
(define-data-var ata-costs uint u11)
(define-data-var cost-data-0 { base: uint, from: uint, pow: uint }
  { base: u44, from: u1, pow: u2 }
)
(define-data-var cost-data-1 { base: uint, from: uint, pow: uint }
  { base: u50, from: u1, pow: u5 }
)
(define-data-var cost-data-2 { base: uint, from: uint, pow: uint }
  { base: u60, from: u3, pow: u7 }
)
(define-data-var cost-data-3 { base: uint, from: uint, pow: uint }
  { base: u64, from: u6, pow: u10 }
)
(define-data-var cost-data-4 { base: uint, from: uint, pow: uint }
  { base: u65, from: u9, pow: u12 }
)
(define-data-var cost-data-5 { base: uint, from: uint, pow: uint }
  { base: u70, from: u15, pow: u14 }
)

(define-private (spend-upgrade-resources (lvl uint))
  (begin
    (try! (contract-call? .ata-spend-v0 spend-ata (var-get ata-costs) lvl))

    (try! (contract-call? .ata-spend-v0 spend-resource .stone-ft-v0 (var-get cost-data-0) lvl))
    (try! (contract-call? .ata-spend-v0 spend-resource .wood-ft-v0 (var-get cost-data-1) lvl))
    (try! (contract-call? .ata-spend-v0 spend-resource .sand-ft-v0 (var-get cost-data-2) lvl))
    (try! (contract-call? .ata-spend-v0 spend-resource .coal-ft-v0 (var-get cost-data-3) lvl))
    (try! (contract-call? .ata-spend-v0 spend-resource .gravel-ft-v0 (var-get cost-data-4) lvl))
    (try! (contract-call? .ata-spend-v0 spend-resource .clay-ft-v0 (var-get cost-data-5) lvl))
    (ok true)
  )
)

;; COLLECT HANDLING
(define-data-var base-production uint u18)

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
    (player (unwrap! (contract-call? .coal-store-v0 get-player tx-sender) ERR_NOT_REGISTERED))
    (to-mint (/ (get result (fold inner-collect (get factories player) {
      elapsed: (min (- (get-current-time) (get lma player)) u432000), ;; 5 days
      result: u0,
    })) u60))
  )
    (asserts! (> to-mint u0) (ok u0))
    (try! (contract-call? .coal-ft-v0 mint to-mint))
    (contract-call? .coal-store-v0 save-lma)
  )
)

(define-public (set-base-production (new-base uint))
  (begin
    (try! (contract-call? .ata-admin-v0 is-admin))
    (ok (var-set base-production new-base))
  )
)

;; BUILDING AND UPGRADING FACTORIES
;;; register to build the first factory
(define-public (register)
  (begin
    (try! (spend-upgrade-resources u1))
    (try! (contract-call? .coal-ft-v0 mint (var-get initial-mint)))
    (ok (try! (contract-call? .coal-store-v0 register-first-factory tx-sender)))
  )
)

;;; add a factory to the list
(define-public (add-factory)
  (let (
    (factories (unwrap! (contract-call? .coal-store-v0 get-factories tx-sender) ERR_NOT_REGISTERED))
    (ata-lvl (try! (contract-call? .ata-store-v0 get-ata-lvl tx-sender)))
    (nb-factories (len factories))
  )
    (asserts! (< nb-factories u16) ERR_MAX_NB_OF_FACTORIES_REACHED)
    (asserts! (<= (pow (+ u1 nb-factories) u2) ata-lvl) ERR_ATA_MINER_LEVEL_TOO_LOW)

    (try! (collect))
    (try! (spend-upgrade-resources u1))
    (contract-call?
      .coal-store-v0
      save-factories
      tx-sender
      (unwrap-panic (as-max-len? (append factories u1) u16))
    )
  )
)

;;; upgrade a factory level given its index
(define-public (upgrade-factory (index uint))
  (let (
    (factories (unwrap! (contract-call? .coal-store-v0 get-factories tx-sender) ERR_NOT_REGISTERED))
    (lvl (+ u1 (unwrap! (element-at? factories index) ERR_INVALID_FACTORY_INDEX)))
    (ata-lvl (try! (contract-call? .ata-store-v0 get-ata-lvl tx-sender)))
  )
    ;; make sure the next factory level is lower than the ATA miner level
    (asserts! (<= lvl ata-lvl) ERR_CANT_EXCEED_ATA_MINER_LEVEL)

    (try! (collect))
    (try! (spend-upgrade-resources lvl))
    (contract-call?
      .coal-store-v0
      save-factories
      tx-sender
      (unwrap-panic (replace-at? factories index lvl))
    )
  )
)

;; ADMIN
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
  (c4 { base: uint, from: uint, pow: uint })
  (c5 { base: uint, from: uint, pow: uint })
)
  (begin
    (try! (contract-call? .ata-admin-v0 is-admin))

    (var-set cost-data-0 c0)
    (var-set cost-data-1 c1)
    (var-set cost-data-2 c2)
    (var-set cost-data-3 c3)
    (var-set cost-data-4 c4)
    (var-set cost-data-5 c5)

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
