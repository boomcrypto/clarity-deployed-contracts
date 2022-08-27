(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait token-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.token-trait.token-trait)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)

(define-constant ERR-NOT-AUTHORIZED u404)
(define-constant ERR-MIGRATION-NOT-ALLOWED u301)
(define-data-var admin principal tx-sender)
(define-data-var migration-allowed bool false)

(define-public (allow-migration (switch bool))
  (if (is-eq tx-sender (var-get admin))
    (begin 
    (if switch
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking unstaking-fee-change (list u0 u0)))
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking unstaking-fee-change (list u3000000 u2000000)))
    )
    (ok (var-set migration-allowed switch)))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (migrate (fungible <token-trait>))
    (begin
        (asserts! (var-get migration-allowed) (err ERR-MIGRATION-NOT-ALLOWED))
        (try! (migrate-bulls 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls fungible))
        (try! (migrate-bears 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears fungible))
        (try! (migrate-whales 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales fungible))
        (try! (migrate-goats 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-goats fungible))
        (ok true)
    )
)

(define-private (migrate-bulls (collection principal) (fungible <token-trait>))
    (let (
        (to-collect (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking check-collect tx-sender))
    )        
        (if (> to-collect u0) (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking collect fungible)) true)
    (let (
        (staker (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking check-staker tx-sender)))
        (staked-nfts (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking get-staked-nfts tx-sender collection))
        (time (unwrap-panic (get stake-time staker)))
        (life-points (unwrap-panic (get lifetime-points staker)))
        (balance (unwrap-panic (get points-balance staker)))
        (multiplier (unwrap-panic (get total-multiplier staker)))
        (staking (> (len staked-nfts) u0))
        (indexer (if staking (- (len staked-nfts) u1) u0))
        (addresses (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup collection indexer))
        ) 

        (if staking 
            (begin 
                (try! (contract-call? .spaghettipunk-nfts-staking migrate-staker collection time life-points balance multiplier))
                (map migrate-bull addresses staked-nfts)
                true
            )
            true)
        (ok true)
    ))
)

(define-private (migrate-bull (collection principal) (item uint))
    (let (
        (custodial (get custodial (contract-call? .spaghettipunk-nfts-staking get-collection collection)))
    )
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking unstake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bull-multipliers item))
        (if (is-eq custodial true) (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls transfer item tx-sender .spaghettipunk-nfts-staking)) true)
        (try! (contract-call? .spaghettipunk-nfts-staking migrate-item collection item))
        (ok true)
    )
)

(define-private (migrate-bears (collection principal) (fungible <token-trait>))
    (let (
        (to-collect (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking check-collect tx-sender))
        )
        (if (> to-collect u0) (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking collect fungible)) true)
        (let (
            (staker (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking check-staker tx-sender)))
            (staked-nfts (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking get-staked-nfts tx-sender collection))
            (time (unwrap-panic (get stake-time staker)))
            (life-points (unwrap-panic (get lifetime-points staker)))
            (balance (unwrap-panic (get points-balance staker)))
            (multiplier (unwrap-panic (get total-multiplier staker)))
            (staking (> (len staked-nfts) u0))
            (indexer (if staking (- (len staked-nfts) u1) u0))
            (addresses (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup collection indexer))
            ) 
            (if staking 
            (begin 
                (try! (contract-call? .spaghettipunk-nfts-staking migrate-staker collection time life-points balance multiplier))
                (map migrate-bear addresses staked-nfts)
                true
            )
            true)

            (ok true)
        ))
)

(define-private (migrate-bear (collection principal) (item uint))
    (let (
        (custodial (get custodial (contract-call? .spaghettipunk-nfts-staking get-collection collection)))
    )
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking unstake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bear-multipliers item))
        (if (is-eq custodial true) (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears transfer item tx-sender .spaghettipunk-nfts-staking)) true)
        (try! (contract-call? .spaghettipunk-nfts-staking migrate-item collection item))
        (ok true)
    )
)

(define-private (migrate-whales (collection principal) (fungible <token-trait>))
    (let (
        (to-collect (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking check-collect tx-sender))
        )
        (if (> to-collect u0) (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking collect fungible)) true)
        (let (
            (staker (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking check-staker tx-sender)))
            (staked-nfts (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking get-staked-nfts tx-sender collection))
            (time (unwrap-panic (get stake-time staker)))
            (life-points (unwrap-panic (get lifetime-points staker)))
            (balance (unwrap-panic (get points-balance staker)))
            (multiplier (unwrap-panic (get total-multiplier staker)))
            (staking (> (len staked-nfts) u0))
            (indexer (if staking (- (len staked-nfts) u1) u0))
            (addresses (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup collection indexer))
            ) 
            (if staking 
            (begin 
                (try! (contract-call? .spaghettipunk-nfts-staking migrate-staker collection time life-points balance multiplier))
                (map migrate-whale addresses staked-nfts)
                true
            )
            true)
            (ok true)
        ))
)

(define-private (migrate-whale (collection principal) (item uint))
    (let (
        (custodial (get custodial (contract-call? .spaghettipunk-nfts-staking get-collection collection)))
    )
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking unstake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.whale-multipliers item))
        (if (is-eq custodial true) (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales transfer item tx-sender .spaghettipunk-nfts-staking)) true)
        (try! (contract-call? .spaghettipunk-nfts-staking migrate-item collection item))
        (ok true)
    )
)

(define-private (migrate-goats (collection principal) (fungible <token-trait>))
    (let (
        (to-collect (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking check-collect tx-sender))
        )
        (asserts! (var-get migration-allowed) (err ERR-MIGRATION-NOT-ALLOWED))
        (if (> to-collect u0) (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking collect fungible)) true)
        (let (
            (staker (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking check-staker tx-sender)))
            (staked-nfts (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking get-staked-nfts tx-sender collection))
            (time (unwrap-panic (get stake-time staker)))
            (life-points (unwrap-panic (get lifetime-points staker)))
            (balance (unwrap-panic (get points-balance staker)))
            (multiplier (unwrap-panic (get total-multiplier staker)))
            (staking (> (len staked-nfts) u0))
            (indexer (if staking (- (len staked-nfts) u1) u0))
            (addresses (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup collection indexer))
            ) 
            (if staking 
            (begin 
                (try! (contract-call? .spaghettipunk-nfts-staking migrate-staker collection time life-points balance multiplier))
                (map migrate-goat addresses staked-nfts)
                true
            )
            true)

            (ok true)
        ))
)

(define-private (migrate-goat (collection principal) (item uint))
    (let (
        (custodial (get custodial (contract-call? .spaghettipunk-nfts-staking get-collection collection)))
    )
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking unstake 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-goats 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.goat-multipliers item))
        (if (is-eq custodial true) (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-goats transfer item tx-sender .spaghettipunk-nfts-staking)) true)
        (try! (contract-call? .spaghettipunk-nfts-staking migrate-item collection item))
        (ok true)
    )
)

(try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking principal-add (as-contract tx-sender)))