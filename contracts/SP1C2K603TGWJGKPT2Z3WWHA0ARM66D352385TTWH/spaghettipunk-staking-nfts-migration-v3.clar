(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait token-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.token-trait.token-trait)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)

(define-constant ERR-NOT-AUTHORIZED u404)
(define-constant ERR-MIGRATION-NOT-ALLOWED u301)
(define-constant UNWRAP-ERR u202)

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
    (let (
        (to-collect (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking check-collect tx-sender))
    )
    (asserts! (var-get migration-allowed) (err ERR-MIGRATION-NOT-ALLOWED))
    (if (> to-collect u0) (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking collect fungible)) true)    
    (let (
        (staker (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking check-staker tx-sender)))
        (life-points (unwrap-panic (get lifetime-points staker)))
        )
        (try! (contract-call? .spaghettipunk-staking update-lifetime tx-sender life-points))
        (unwrap! (some (migrate-bulls 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls fungible)) (err UNWRAP-ERR))
        (unwrap! (some (migrate-bears 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears fungible)) (err UNWRAP-ERR))
        (unwrap! (some (migrate-whales 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales fungible)) (err UNWRAP-ERR))
        (unwrap! (some (migrate-goats .bitcoin-goats fungible)) (err UNWRAP-ERR))
        (ok true)
    ))
)

(define-private (migrate-bulls (collection principal) (fungible <token-trait>))
    (let (
        (staked-nfts (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking get-staked-nfts tx-sender collection))
        (staking (> (len staked-nfts) u0))
        ) 
        (if staking 
            (begin 
                (map migrate-bull staked-nfts)
                true
            )
            true)
    )
)

(define-private (migrate-bull (item uint))
    (begin
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking unstake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bull-multipliers item))
        (try! (contract-call? .spaghettipunk-staking-helper-v3 set-stake-pass 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls item true))
        (try! (contract-call? .spaghettipunk-staking-helper-v3 stake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bull-multipliers item))
        (ok true)
    )
)

(define-private (migrate-bears (collection principal) (fungible <token-trait>))
    (let (
        (staked-nfts (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking get-staked-nfts tx-sender collection))
        (staking (> (len staked-nfts) u0))
        ) 
        (if staking 
            (begin 
                (map migrate-bear staked-nfts)
                true
            )
            true)
    )
)

(define-private (migrate-bear (item uint))
    (begin
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking unstake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bear-multipliers item))
        (try! (contract-call? .spaghettipunk-staking-helper-v3 set-stake-pass 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears item true))
        (try! (contract-call? .spaghettipunk-staking-helper-v3 stake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bear-multipliers item))
        (ok true)
    )
)

(define-private (migrate-whales (collection principal) (fungible <token-trait>))
    (let (
        (staked-nfts (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking get-staked-nfts tx-sender collection))
        (staking (> (len staked-nfts) u0))
        ) 
        (if staking 
            (begin 
                (map migrate-whale staked-nfts)
                true
            )
            true)
    )
)

(define-private (migrate-whale (item uint))
    (begin
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking unstake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.whale-multipliers item))
        (try! (contract-call? .spaghettipunk-staking-helper-v3 set-stake-pass 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales item true))
        (try! (contract-call? .spaghettipunk-staking-helper-v3 stake 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.whale-multipliers item))
        (ok true)
    )
)

(define-private (migrate-goats (collection principal) (fungible <token-trait>))
    (let (
        (staked-nfts (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking get-staked-nfts tx-sender collection))
        (staking (> (len staked-nfts) u0))
        ) 
        (if staking 
            (begin 
                (map migrate-goat staked-nfts)
                true
            )
            true)
    )
)

(define-private (migrate-goat (item uint))
    (begin
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti-punk-nfts-staking unstake .bitcoin-goats 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.goat-multipliers item))
        (try! (contract-call? .spaghettipunk-staking-helper-v3 set-stake-pass .bitcoin-goats item true))
        (try! (contract-call? .spaghettipunk-staking-helper-v3 stake .bitcoin-goats 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.goat-multipliers item))
        (ok true)
    )
)

(define-public (migrate-redeem (fungible <token-trait>))
    (let (
        (to-collect (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-x-minotauri-staking check-collect tx-sender))
    )
    (asserts! (var-get migration-allowed) (err ERR-MIGRATION-NOT-ALLOWED))
    (if (> to-collect u0) (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-x-minotauri-staking collect fungible)) true)    
    (let (
        (staker (unwrap-panic (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-x-minotauri-staking check-staker tx-sender)))
        (life-points (unwrap-panic (get lifetime-points staker)))
        )
        (try! (contract-call? .spaghettipunk-staking update-lifetime tx-sender life-points))
        (try! (unwrap! (some (migrate-cavalry)) (err u202)))
        (ok true)
    ))
)

(define-private (migrate-cavalry)
    (let (
        (staked-nfts (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-x-minotauri-staking get-staked-nfts tx-sender))
        (staking (> (len staked-nfts) u0))
        ) 
        (if staking 
            (begin 
                (map unstake-item staked-nfts)
                (try! (contract-call? .the-cavalry redeem staked-nfts))
                (map stake-item staked-nfts)
                true
            )
            true)
        (ok true)
    )
)

(define-private (unstake-item (item uint))
    (begin
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-x-minotauri-staking unstake 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV.minotauri-multiplier item))
        (ok true)
    )
)

(define-private (stake-item (item uint))
    (let (
        (id (contract-call? .the-cavalry get-linked-id item))
    )
        (try! (contract-call? .spaghettipunk-staking-helper-v3 set-stake-pass .the-cavalry id true))
        (try! (contract-call? .spaghettipunk-staking-helper-v3 stake .the-cavalry .the-cavalry-multipliers id))
        (ok true)
    )
)

(try! (contract-call? .spaghettipunk-staking migration-change (as-contract tx-sender)))
(try! (allow-migration true))
(try! (contract-call? .spaghettipunk-staking-helper-v3 migration-change (as-contract tx-sender)))