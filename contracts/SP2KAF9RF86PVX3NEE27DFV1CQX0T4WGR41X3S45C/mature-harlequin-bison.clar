(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)


(define-public (unstake-all)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
        (try! (contract-call? .bitcoin-monkeys-staking shutoff-switch false))
        (try! (contract-call? .bitcoin-monkeys-staking admin-unstake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys u1695))
        (try! (contract-call? .bitcoin-monkeys-staking admin-unstake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys u382))
        (try! (contract-call? .bitcoin-monkeys-staking shutoff-switch true))
    (ok true)
    )
)