(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)

(define-constant ERR-NOT-AUTHORIZED u404)

(define-data-var admin principal tx-sender)
(define-data-var migration-contract principal (as-contract tx-sender))
(define-data-var shutoff-valve bool false)

(define-public (stake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (try! (contract-call? .test-v4 stake collection lookup-table item))
        (try! (contract-call? .test-bonus-v2 check-bonuses tx-sender))
        (ok true)
    )
)

(define-public (admin-stake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (asserts! (or (is-eq contract-caller (var-get migration-contract)) (is-eq tx-sender (var-get admin))) (err ERR-NOT-AUTHORIZED))
        (try! (contract-call? .test-v4 admin-stake collection lookup-table item))
        (try! (contract-call? .test-bonus-v2 check-bonuses tx-sender))
        (ok true)
    )
)

(define-public (unstake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (try! (contract-call? .test-v4 unstake collection lookup-table item))
        (try! (contract-call? .test-bonus-v2 check-bonuses tx-sender))
        (ok true)
    )
)

(define-public (admin-unstake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (begin 
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (try! (contract-call? .test-v4 admin-unstake collection lookup-table item))
        (try! (contract-call? .test-bonus-v2 check-bonuses tx-sender))
        (ok true)
    )
)

(define-public (collect)
  (let (
      (block block-height)
      (owner tx-sender)
      (staker (contract-call? .test-v4 check-staker tx-sender))
      (collections (get collections staker))
      (bonus (contract-call? .test-bonus-v2 check-bonuses tx-sender))
      (bonus-balance (get points-balance (contract-call? .test-bonus-v2 get-staked-bonuses tx-sender)))      
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (try! (contract-call? .test-bonus-v2 bonus-collect tx-sender))
    (map collect-one collections)
    (if (> bonus-balance u0)
        (begin 
            (try! (contract-call? .test-v4 mint-sp .test-token bonus-balance tx-sender))
            (try! (contract-call? .test-v4 update-lifetime tx-sender bonus-balance))
            (ok true)
        )
        (ok false)
    )

  )
)

(define-private (collect-one (collection principal))
    (let (
        (to-collect (contract-call? .test-v4 check-collect collection tx-sender))
    ) 
        (if (> to-collect u0)
            (begin
                (try! (contract-call? .test-v4 collect collection .test-token))
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

(try! (contract-call? .test-v4 toggle-use-helper true))
(try! (contract-call? .test-v4 helper-change (as-contract tx-sender)))
(try! (contract-call? .test-bonus-v2 helper-change (as-contract tx-sender)))