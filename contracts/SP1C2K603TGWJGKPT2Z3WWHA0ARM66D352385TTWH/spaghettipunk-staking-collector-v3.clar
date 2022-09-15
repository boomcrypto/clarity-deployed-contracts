;; spaghettipunk-staking-collector-v3
(use-trait token-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.token-trait.token-trait)

(define-public (collect-multi (fungible <token-trait>))
  (let (
    (to-collect-spaghettipunk-staking (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking check-collect tx-sender))
    (to-collect-minotauri-staking (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-x-minotauri-staking check-collect tx-sender))
  )
  (if (> to-collect-spaghettipunk-staking u0)
    (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking collect fungible))
    true
  )
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-staking-helper-v3 collect))
    
  (if (> to-collect-minotauri-staking u0)
    (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-x-minotauri-staking collect fungible))
    true
  )
  (ok true)
  )
)