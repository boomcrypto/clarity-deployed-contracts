(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(begin
        (try! (contract-call? .bitcoin-monkeys-staking shutoff-switch false))
        (try! (contract-call? .bitcoin-monkeys-staking admin-unstake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys u100))
        (try! (contract-call? .bitcoin-monkeys-staking admin-unstake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys u1000))
        (try! (contract-call? .bitcoin-monkeys-staking shutoff-switch true))
        (ok true)
)