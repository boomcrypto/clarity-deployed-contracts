(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(let (
(amt-token-alex-token-wgus (get supply (try! (contract-call? .amm-pool-v2-01 create-pool .token-alex .token-wgus u100000000 .executor-dao u28869022210540 u120673526708796800))))
(approve-token-alex (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-alex true)))
(approve-token-wgus (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-wgus true)))
(oracle-enabled-0 (try! (contract-call? .amm-registry-v2-01 set-oracle-enabled .token-alex .token-wgus u100000000 true)))
(fee-rate-x-0 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-x .token-alex .token-wgus u100000000 u500000)))
(fee-rate-y-0 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-y .token-alex .token-wgus u100000000 u500000)))
(max-in-ratio-0 (try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wgus u100000000 u60000000)))
(max-out-ratio-0 (try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wgus u100000000 u60000000)))
(oracle-average-0 (try! (contract-call? .amm-registry-v2-01 set-oracle-average .token-alex .token-wgus u100000000 u99000000)))
(fee-rebate-0 (try! (contract-call? .amm-registry-v2-01 set-fee-rebate .token-alex .token-wgus u100000000 u50000000)))
(start-block-0 (try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wgus u100000000 u9007199254740991)))
(amt-token-alex-token-wpepe (get supply (try! (contract-call? .amm-pool-v2-01 create-pool .token-alex .token-wpepe u100000000 .executor-dao u10784760804070 u33888855694200000))))
(approve-token-wpepe (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-wpepe true)))
(oracle-enabled-1 (try! (contract-call? .amm-registry-v2-01 set-oracle-enabled .token-alex .token-wpepe u100000000 true)))
(fee-rate-x-1 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-x .token-alex .token-wpepe u100000000 u500000)))
(fee-rate-y-1 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-y .token-alex .token-wpepe u100000000 u500000)))
(max-in-ratio-1 (try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wpepe u100000000 u60000000)))
(max-out-ratio-1 (try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wpepe u100000000 u60000000)))
(oracle-average-1 (try! (contract-call? .amm-registry-v2-01 set-oracle-average .token-alex .token-wpepe u100000000 u99000000)))
(fee-rebate-1 (try! (contract-call? .amm-registry-v2-01 set-fee-rebate .token-alex .token-wpepe u100000000 u50000000)))
(start-block-1 (try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wpepe u100000000 u9007199254740991)))
(amt-token-alex-token-wlong (get supply (try! (contract-call? .amm-pool-v2-01 create-pool .token-alex .token-wlong u100000000 .executor-dao u30037185903320 u3459714184638793000))))
(approve-token-wlong (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-wlong true)))
(oracle-enabled-2 (try! (contract-call? .amm-registry-v2-01 set-oracle-enabled .token-alex .token-wlong u100000000 true)))
(fee-rate-x-2 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-x .token-alex .token-wlong u100000000 u500000)))
(fee-rate-y-2 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-y .token-alex .token-wlong u100000000 u500000)))
(max-in-ratio-2 (try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wlong u100000000 u60000000)))
(max-out-ratio-2 (try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wlong u100000000 u60000000)))
(oracle-average-2 (try! (contract-call? .amm-registry-v2-01 set-oracle-average .token-alex .token-wlong u100000000 u99000000)))
(fee-rebate-2 (try! (contract-call? .amm-registry-v2-01 set-fee-rebate .token-alex .token-wlong u100000000 u50000000)))
(start-block-2 (try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wlong u100000000 u9007199254740991)))
(amt-token-alex-token-wnot (get supply (try! (contract-call? .amm-pool-v2-01 create-pool .token-alex .token-wnot u100000000 .executor-dao u9184089858320 u47031667611700000000))))
(approve-token-wnot (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-wnot true)))
(oracle-enabled-3 (try! (contract-call? .amm-registry-v2-01 set-oracle-enabled .token-alex .token-wnot u100000000 true)))
(fee-rate-x-3 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-x .token-alex .token-wnot u100000000 u500000)))
(fee-rate-y-3 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-y .token-alex .token-wnot u100000000 u500000)))
(max-in-ratio-3 (try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wnot u100000000 u60000000)))
(max-out-ratio-3 (try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wnot u100000000 u60000000)))
(oracle-average-3 (try! (contract-call? .amm-registry-v2-01 set-oracle-average .token-alex .token-wnot u100000000 u99000000)))
(fee-rebate-3 (try! (contract-call? .amm-registry-v2-01 set-fee-rebate .token-alex .token-wnot u100000000 u50000000)))
(start-block-3 (try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wnot u100000000 u9007199254740991)))
(amt-token-alex-token-wmax (get supply (try! (contract-call? .amm-pool-v2-01 create-pool .token-alex .token-wmax u100000000 .executor-dao u10666587360560 u138303872883025700))))
(approve-token-wmax (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-wmax true)))
(oracle-enabled-4 (try! (contract-call? .amm-registry-v2-01 set-oracle-enabled .token-alex .token-wmax u100000000 true)))
(fee-rate-x-4 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-x .token-alex .token-wmax u100000000 u500000)))
(fee-rate-y-4 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-y .token-alex .token-wmax u100000000 u500000)))
(max-in-ratio-4 (try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wmax u100000000 u60000000)))
(max-out-ratio-4 (try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wmax u100000000 u60000000)))
(oracle-average-4 (try! (contract-call? .amm-registry-v2-01 set-oracle-average .token-alex .token-wmax u100000000 u99000000)))
(fee-rebate-4 (try! (contract-call? .amm-registry-v2-01 set-fee-rebate .token-alex .token-wmax u100000000 u50000000)))
(start-block-4 (try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wmax u100000000 u9007199254740991)))
(amt-token-alex-token-wmega (get supply (try! (contract-call? .amm-pool-v2-01 create-pool .token-alex .token-wmega u100000000 .executor-dao u5033425318340 u2338751000000))))
(approve-token-wmega (try! (contract-call? .amm-vault-v2-01 set-approved-token .token-wmega true)))
(oracle-enabled-5 (try! (contract-call? .amm-registry-v2-01 set-oracle-enabled .token-alex .token-wmega u100000000 true)))
(fee-rate-x-5 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-x .token-alex .token-wmega u100000000 u500000)))
(fee-rate-y-5 (try! (contract-call? .amm-registry-v2-01 set-fee-rate-y .token-alex .token-wmega u100000000 u500000)))
(max-in-ratio-5 (try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wmega u100000000 u60000000)))
(max-out-ratio-5 (try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wmega u100000000 u60000000)))
(oracle-average-5 (try! (contract-call? .amm-registry-v2-01 set-oracle-average .token-alex .token-wmega u100000000 u99000000)))
(fee-rebate-5 (try! (contract-call? .amm-registry-v2-01 set-fee-rebate .token-alex .token-wmega u100000000 u50000000)))
(start-block-5 (try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wmega u100000000 u9007199254740991))))
(ok true)))