(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)

(define-constant ERR-NOT-AUTHORIZED u404)

(define-data-var admin principal tx-sender)
(define-data-var migration-contract principal .spaghettipunk-staking-nfts-migration)
(define-data-var shutoff-valve bool false)

(define-public (stake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (try! (contract-call? .spaghettipunk-staking stake collection lookup-table item))
        (try! (contract-call? .spaghettipunk-staking-bonuses check-bonuses tx-sender))
        (ok true)
    )
)

(define-public (admin-stake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (asserts! (or (is-eq contract-caller (var-get migration-contract)) (is-eq tx-sender (var-get admin))) (err ERR-NOT-AUTHORIZED))
        (try! (contract-call? .spaghettipunk-staking admin-stake collection lookup-table item))
        (try! (contract-call? .spaghettipunk-staking-bonuses check-bonuses tx-sender))
        (ok true)
    )
)

(define-public (unstake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (try! (contract-call? .spaghettipunk-staking unstake collection lookup-table item))
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
        (ok false)
    )
  )
)

(define-private (collect-one (collection principal))
    (let (
        (to-collect (contract-call? .spaghettipunk-staking check-collect collection tx-sender))
    ) 
        (if (> to-collect u0)
            (begin
                (try! (contract-call? .spaghettipunk-staking collect collection 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti))
                (ok true)
            )
            (ok false)
        )       
    )
)

(define-public (migration-change (migration principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set migration-contract migration))
    (err ERR-NOT-AUTHORIZED)
  )
)

;;change contract admin
(define-public (change-admin (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set admin address))
    (err ERR-NOT-AUTHORIZED)
  )
)
;; security function
(define-public (shutoff-switch (switch bool))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set shutoff-valve switch))
    (err ERR-NOT-AUTHORIZED)
  )
)

(try! (contract-call? .spaghettipunk-staking toggle-use-helper true))
(try! (contract-call? .spaghettipunk-staking helper-change (as-contract tx-sender)))
(try! (contract-call? .spaghettipunk-staking-bonuses helper-change (as-contract tx-sender)))