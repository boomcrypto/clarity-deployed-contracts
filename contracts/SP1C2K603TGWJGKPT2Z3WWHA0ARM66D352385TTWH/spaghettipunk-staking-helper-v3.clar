(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait token-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.token-trait.token-trait)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)

(define-map stake-pass { collection: principal, item: uint } bool)

(define-constant ERR-NOT-AUTHORIZED u404)

(define-data-var admin principal tx-sender)
(define-data-var migration-contract principal (as-contract tx-sender))
(define-data-var shutoff-valve bool false)

(define-read-only (get-stake-pass (collection principal) (item uint))
    (default-to false (map-get? stake-pass {collection: collection, item: item})))

(define-public (set-stake-pass (collection principal) (item uint) (switch bool))
    (begin 
        (asserts! (or (is-eq contract-caller (var-get migration-contract)) (is-eq tx-sender (var-get admin))) (err ERR-NOT-AUTHORIZED))
        (map-set stake-pass {collection: collection, item: item} switch)
        (ok true)))

(define-public (stake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (stakable (contract-call? .spaghettipunk-staking get-collection (contract-of collection)))
        (custodial (get custodial stakable))
        (multiplier (get multiplier stakable))        
    ) 
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (contract-of lookup-table) multiplier) (err ERR-NOT-AUTHORIZED))
    (if (not custodial) 
        (try! (stake-non-custodial collection lookup-table item)) 
        (try! (stake-custodial collection lookup-table item)))
    (ok true)))

(define-public (unstake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (stakable (contract-call? .spaghettipunk-staking get-collection (contract-of collection)))
        (custodial (get custodial stakable))
        (multiplier (get multiplier stakable))
    )   
    (asserts! (is-eq (contract-of lookup-table) multiplier) (err ERR-NOT-AUTHORIZED))
    (if (not custodial) 
        (try! (unstake-non-custodial collection lookup-table item)) 
        (try! (unstake-custodial collection lookup-table item)))
    (ok true)))

(define-private (stake-custodial (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (pass (get-stake-pass (contract-of collection) item))
    )
    (if pass 
        (try! (admin-stake collection lookup-table item))          
        (try! (contract-call? .spaghettipunk-staking stake collection lookup-table item))
    )       
    (try! (contract-call? .spaghettipunk-staking-bonuses check-bonuses tx-sender))
    (ok true)))

(define-private (stake-non-custodial (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (pass (get-stake-pass (contract-of collection) item))
    )
    (if pass 
        (try! (admin-stake collection lookup-table item))          
        (try! (contract-call? .spaghettipunk-staking stake collection lookup-table item))
    ) 
    (if (is-eq (contract-of collection) .the-cavalry)
        (try! (contract-call? .the-cavalry set-transferable (as-contract tx-sender) item false))
        true     
    )      
    (try! (contract-call? .spaghettipunk-staking-bonuses check-bonuses tx-sender))
    (ok true)))

(define-private (admin-stake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (try! (contract-call? .spaghettipunk-staking admin-stake collection lookup-table item))
        (if (get-stake-pass (contract-of collection) item) (map-set stake-pass {collection: (contract-of collection), item: item} false) true)
        (ok true)))

(define-private (unstake-custodial (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (pass (get-stake-pass (contract-of collection) item))
    )
    (try! (contract-call? .spaghettipunk-staking unstake collection lookup-table item))
    (try! (contract-call? .spaghettipunk-staking-bonuses check-bonuses tx-sender))
    (ok true)
    )
)

(define-private (unstake-non-custodial (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (pass (get-stake-pass (contract-of collection) item))
    )
    (try! (contract-call? .spaghettipunk-staking unstake collection lookup-table item))
    (if (is-eq (contract-of collection) .the-cavalry)
        (try! (contract-call? .the-cavalry set-transferable (as-contract tx-sender) item true))
        true     
    )      
    (try! (contract-call? .spaghettipunk-staking-bonuses check-bonuses tx-sender))
    (ok true)
    )
)

(define-public (admin-unstake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (try! (contract-call? .spaghettipunk-staking admin-unstake collection lookup-table item))
        (try! (contract-call? .spaghettipunk-staking-bonuses check-bonuses tx-sender))
        (ok true)
    )
)

(define-public (collect)
  (let (
      (block block-height)
      (owner tx-sender)
      (staker (contract-call? .spaghettipunk-staking check-staker tx-sender))
      (collections (get collections staker))
      (bonus (contract-call? .spaghettipunk-staking-bonuses check-bonuses tx-sender))
      (bonus-balance (get points-balance (contract-call? .spaghettipunk-staking-bonuses get-staked-bonuses tx-sender)))      
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (try! (contract-call? .spaghettipunk-staking-bonuses bonus-collect tx-sender))
    (map collect-one collections)
    (if (> bonus-balance u0)
        (begin 
            (try! (contract-call? .spaghettipunk-staking mint-sp 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti bonus-balance tx-sender))
            (try! (contract-call? .spaghettipunk-staking update-lifetime tx-sender bonus-balance))
            (ok true)
        )
        (ok false))))

(define-private (collect-one (collection principal))
    (let (
        (to-collect (contract-call? .spaghettipunk-staking check-collect collection tx-sender))
    ) 
        (if (> to-collect u0)
            (begin
                (try! (contract-call? .spaghettipunk-staking collect collection 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti))
                (ok true)
            )
            (ok false))))

(define-public (migration-change (migration principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set migration-contract migration))
    (err ERR-NOT-AUTHORIZED)))

;;change contract admin
(define-public (change-admin (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set admin address))
    (err ERR-NOT-AUTHORIZED)))

;; security function
(define-public (shutoff-switch (switch bool))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set shutoff-valve switch))
    (err ERR-NOT-AUTHORIZED)))

(try! (contract-call? .spaghettipunk-staking helper-change (as-contract tx-sender)))
(try! (contract-call? .spaghettipunk-staking-bonuses helper-change (as-contract tx-sender)))
(try! (contract-call? .the-cavalry change-staking (as-contract tx-sender)))
(try! (contract-call? .spaghettipunk-staking whitelist-collection .the-cavalry (list u5000000) (list u5000000) (list 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u144 .the-cavalry-multipliers false))