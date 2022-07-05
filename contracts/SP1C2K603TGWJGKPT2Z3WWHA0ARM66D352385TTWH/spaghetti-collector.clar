;; spaghetti-collector
(use-trait token-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.token-trait.token-trait)

(define-public (collect-multi (fungible <token-trait>))
  (begin
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-x-minotauri-staking collect fungible))
    (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking collect fungible))
    (ok true)
  )
)