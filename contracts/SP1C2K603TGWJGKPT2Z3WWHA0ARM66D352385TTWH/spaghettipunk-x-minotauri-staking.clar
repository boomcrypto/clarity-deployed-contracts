;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SpaghettiPunk x MinoTauri Staking ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait token-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.token-trait.token-trait)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)

;;;;;;;;;;;;;;;
;; constants ;;
;;;;;;;;;;;;;;;

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-TOO-HIGH-EMISSION-RATE u501)
(define-constant minotauri 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.minotauri-nft)

;;;;;;;;;;;;;;;;;;;;;;;;
;; data maps and vars ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(define-data-var admin principal tx-sender)
(define-data-var blocks-per-sp uint u29)
(define-data-var staking-fees (list 1000 uint) (list u2500000 u2500000))
(define-data-var unstaking-fees (list 1000 uint) (list u2500000 u2500000))
(define-data-var payout-addresses (list 1000 principal) (list 'SP23S6MAB11EVBRE04SFBF53ZV39S757PJY53VN53 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
(define-data-var multipliers principal 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.minotauri-multipliers)
(define-data-var token-address principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti)

(define-data-var staking-enabled bool false)
(define-data-var removing-item-id uint u0)

(define-map stakes { staker: principal, collection: principal, item: uint } { stake-time: uint, points: uint, multiplier: uint })
(define-map pool { staker: principal } { stake-time: uint, lifetime-points: uint, points-balance: uint, total-multiplier: uint })
(define-map staked-nfts { staker: principal } { ids: (list 2500 uint) })
(define-map owners { collection: principal, item: uint } { owner: principal })

;;;;;;;;;;;;;;;;;;;;;;;;;
;; read only functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (check-staker (staker principal))
    (ok (map-get? pool { staker: staker }))
)

(define-read-only (check-collect (staker principal))
    (let (
        (block block-height)
        (owner staker)
        (balance (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get points-balance (map-get? pool { staker: owner }))) u0))
        (lifetime (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get lifetime-points (map-get? pool { staker: owner }))) u0))
        (total-multiplier (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get total-multiplier (map-get? pool { staker: owner }))) u0))
        (prev-time (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get stake-time (map-get? pool { staker: owner }))) u0))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) (var-get blocks-per-sp)))
        (to-collect (+ balance points-added))
    )
    to-collect
    )
)

(define-read-only (get-multipliers)
    (ok (var-get multipliers))
)

(define-read-only (get-staking-fee)
    (ok (fold + (var-get staking-fees) u0))
)

(define-read-only (get-unstaking-fee)
    (ok (fold + (var-get unstaking-fees) u0))
)

(define-read-only (get-staked-nfts (staker principal))
  (default-to
    (list )
    (get ids (map-get? staked-nfts { staker: staker }))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;
;; private functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

(define-private (remove-item-id (item-id uint))
  (if (is-eq item-id (var-get removing-item-id))
    false
    true
  )
)

(define-private (pay (receiver principal) (price uint))
  (begin
    (try! (stx-transfer? price tx-sender receiver))
    (ok true)
  )
) 
;;;;;;;;;;;;;;;;;;;;;;
;; public functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-public (stake (lookup-table <lookup-trait>) (item uint))
    (let (
        (points (if (is-some (map-get? stakes { staker: tx-sender, collection: minotauri, item: item })) (unwrap-panic (get points (map-get? stakes { staker: tx-sender, collection: minotauri, item: item }))) u0))
        (balance (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get points-balance (map-get? pool { staker: tx-sender }))) u0))
        (lifetime (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get lifetime-points (map-get? pool { staker: tx-sender }))) u0))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (total-multiplier (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get total-multiplier (map-get? pool { staker: tx-sender }))) u0))
        (block block-height)
        (prev-time (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get stake-time (map-get? pool { staker: tx-sender }))) u0))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) (var-get blocks-per-sp)))
        (staked-ids (get-staked-nfts tx-sender))
    )
    (asserts! (is-eq (var-get staking-enabled) true) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get multipliers) (contract-of lookup-table)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.minotauri-nft get-owner item))) tx-sender) (err ERR-NOT-AUTHORIZED))
    (begin 
        (if (> (unwrap-panic (get-staking-fee)) u0)
          (begin
            (print (map pay (var-get payout-addresses) (var-get staking-fees)))
            (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.minotauri-nft transfer item tx-sender (as-contract tx-sender)))
          )
          (begin
            (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.minotauri-nft transfer item tx-sender (as-contract tx-sender)))
          )
        )
        (map-set stakes { staker: tx-sender, collection: minotauri, item: item } { stake-time: block, points: points, multiplier: multiplier })
        (map-set pool { staker: tx-sender } { stake-time: block, lifetime-points: (+ lifetime points-added), points-balance: (+ balance points-added), total-multiplier: (+ total-multiplier multiplier) })
        (map-set owners { collection: minotauri, item: item } { owner: tx-sender })
        (map-set staked-nfts { staker: tx-sender }
          { ids: (unwrap-panic (as-max-len? (append staked-ids item) u2500)) }
        )
        (print (map-get? pool { staker: tx-sender }))
        (print (map-get? stakes { staker: tx-sender, collection: minotauri, item: item }))
        (ok true)
    )
    )
)

(define-public (unstake (lookup-table <lookup-trait>) (item uint))
    (let (
        (owner (unwrap-panic (get owner (map-get? owners { collection: minotauri, item: item }))))
        (block block-height)
        (points (if (is-some (map-get? stakes { staker: tx-sender, collection: minotauri, item: item })) (unwrap-panic (get points (map-get? stakes { staker: tx-sender, collection: minotauri, item: item }))) u0))
        (balance (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get points-balance (map-get? pool { staker: tx-sender }))) u0))
        (lifetime (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get lifetime-points (map-get? pool { staker: tx-sender }))) u0))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (total-multiplier (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get total-multiplier (map-get? pool { staker: tx-sender }))) u0))
        (prev-time (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get stake-time (map-get? pool { staker: tx-sender }))) u0))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) (var-get blocks-per-sp)))
        (ids (get-staked-nfts tx-sender))
    )
    (asserts! (is-eq (var-get staking-enabled) true) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get multipliers) (contract-of lookup-table)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq owner tx-sender) (err ERR-NOT-AUTHORIZED))
    (var-set removing-item-id item)
    (begin 
        (print points)
        (if (> (unwrap-panic (get-unstaking-fee)) u0)
          (begin
            (print (map pay (var-get payout-addresses) (var-get unstaking-fees)))
            (try! (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.minotauri-nft transfer item (as-contract tx-sender) owner )))
          )
          (begin
            (try! (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.minotauri-nft transfer item (as-contract tx-sender) owner )))
          )
        )
        (map-set stakes { staker: tx-sender, collection: minotauri, item: item } { stake-time: block, points: points-added, multiplier: multiplier  })
        (map-set pool { staker: tx-sender } { stake-time: block, lifetime-points: (+ lifetime points-added), points-balance: (+ balance points-added), total-multiplier: (- total-multiplier multiplier) })
        (map-set staked-nfts { staker: tx-sender }
          { ids: (filter remove-item-id ids) }
        )
        (print (map-get? stakes { staker: tx-sender, collection: minotauri, item: item }))
        (print (map-get? pool { staker: tx-sender }))
        (ok true)
    )
    )
)

(define-public (collect (fungible <token-trait>))
    (let (
        (block block-height)
        (owner tx-sender)
        (balance (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get points-balance (map-get? pool { staker: tx-sender }))) u0))
        (lifetime (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get lifetime-points (map-get? pool { staker: tx-sender }))) u0))
        (total-multiplier (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get total-multiplier (map-get? pool { staker: tx-sender }))) u0))
        (prev-time (if (is-some (map-get? pool { staker: tx-sender })) (unwrap-panic (get stake-time (map-get? pool { staker: tx-sender }))) u0))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) (var-get blocks-per-sp)))
        (to-collect (+ balance points-added))
    )
    (asserts! (is-eq (var-get staking-enabled) true) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get token-address) (contract-of fungible)) (err ERR-NOT-AUTHORIZED))
    (begin 
        (try! (as-contract (contract-call? fungible collect owner to-collect)))
        (map-set pool { staker: tx-sender } { stake-time: block, lifetime-points: (+ lifetime points-added), points-balance: u0, total-multiplier: total-multiplier })
        (print (map-get? pool { staker: tx-sender }))
        (ok true)
    )
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; only admin functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (admin-unstake (lookup-table <lookup-trait>) (item uint))
    (let (
        (owner (unwrap-panic (get owner (map-get? owners { collection: minotauri, item: item }))))
        (block block-height)
        (points (if (is-some (map-get? stakes { staker: owner, collection: minotauri, item: item })) (unwrap-panic (get points (map-get? stakes { staker: owner, collection: minotauri, item: item }))) u0))
        (balance (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get points-balance (map-get? pool { staker: owner }))) u0))
        (lifetime (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get lifetime-points (map-get? pool { staker: owner }))) u0))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (total-multiplier (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get total-multiplier (map-get? pool { staker: owner }))) u0))
        (prev-time (if (is-some (map-get? pool { staker: owner })) (unwrap-panic (get stake-time (map-get? pool { staker: owner }))) u0))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) (var-get blocks-per-sp)))
        (ids (get-staked-nfts owner))
    )
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get multipliers) (contract-of lookup-table)) (err ERR-NOT-AUTHORIZED))
    (begin 
        (print points)
        (try! (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.minotauri-nft transfer item (as-contract tx-sender) owner )))
        (map-set stakes { staker: owner, collection: minotauri, item: item } { stake-time: block, points: points-added, multiplier: multiplier  })
        (map-set pool { staker: owner } { stake-time: block, lifetime-points: (+ lifetime points-added), points-balance: (+ balance points-added), total-multiplier: (- total-multiplier multiplier) })
        (map-set staked-nfts { staker: owner }
          { ids: (filter remove-item-id ids) }
        )
        (print (map-get? stakes { staker: owner, collection: minotauri, item: item }))
        (print (map-get? pool { staker: owner }))
        (ok true)
    )
    )
)

(define-public (token-change (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set token-address address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (change-multipliers (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set multipliers address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (change-emissions (blocks uint))
  (if (is-eq tx-sender (var-get admin))
    (begin
      (asserts! (>= blocks (var-get blocks-per-sp)) (err ERR-TOO-HIGH-EMISSION-RATE))
      (ok (var-set blocks-per-sp blocks))
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (change-admin (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set admin address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (payout-addresses-change (addresses (list 1000 principal)))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set payout-addresses addresses))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (staking-fee-change (amounts (list 1000 uint)))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set staking-fees amounts))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (unstaking-fee-change (amounts (list 1000 uint)))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set unstaking-fees amounts))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (toggle-staking (switch bool))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set staking-enabled switch))
    (err ERR-NOT-AUTHORIZED)
  )
)