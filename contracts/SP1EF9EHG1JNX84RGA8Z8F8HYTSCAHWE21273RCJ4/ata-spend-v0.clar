(use-trait ata-ft-trait .ata-ft-trait-v0.ata-ft-trait-v0)

;;  10% of the ATA cost is sent to the ATA treasury
(define-public (spend-ata
  (ata-costs uint)
  (lvl uint)
)
  (let (
    (cost (* ata-costs lvl (+ (log2 lvl) u1)))
    (fees (/ cost u10))
  )
    (try! (contract-call? .ata-ft-v0 burn (- cost fees)))
    (if (> fees u0)
      (contract-call? .ata-ft-v0 transfer fees tx-sender .ata-ft-v0 none)
      (ok false)
    )
  )
)

(define-public (spend-resource
  (resource-ft <ata-ft-trait>)
  (resource-costs { base: uint, from: uint, pow: uint })
  (lvl uint)
)
  (if (>= lvl (get from resource-costs))
    ;; lvl * base * (log2(lvl^pow) + 1)
    (contract-call? resource-ft burn (*
      lvl
      (get base resource-costs)
      (+ (log2 (pow lvl (get pow resource-costs))) u1)
    ))
    (ok false)
  )
)
