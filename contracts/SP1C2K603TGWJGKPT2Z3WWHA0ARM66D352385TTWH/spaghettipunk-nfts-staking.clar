(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait token-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.token-trait.token-trait)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)

(define-constant ERR-NOT-AUTHORIZED u404)
(define-constant ERR-PAYOUT-LEN-MISMATCH u402)
(define-constant ERR-EMISSION-TOO-HIGH u403)
(define-constant ERR-ITEM-LISTED u405)
(define-constant ERR-NOT-WHITELISTED u401)
(define-constant ERR-NOT-VALID-BONUS u406)
(define-constant ERR-FEES-TOO-HIGH u504)
(define-constant ERR-MIGRATION-NOT-AUTHORIZED u500)
(define-constant ERR-BLACKLISTED u666)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant EMISSION-LIMIT u29)

(define-data-var admin principal tx-sender)
(define-data-var blocks-per-token-bonus uint u288)
(define-data-var prev-blocks-per-token-bonus uint u288)
(define-data-var collections-whitelist (list 100 principal) (list ))
(define-data-var multipliers-whitelist (list 100 principal) (list ))
(define-data-var blacklist (list 1000 principal) (list ))
(define-data-var shutoff-valve bool false)
(define-data-var removing-item-id uint u0)
(define-data-var removing-collection principal (as-contract tx-sender))
(define-data-var prev-bonus-check (list 1000 principal) (list ))
(define-data-var token-address principal .token)
(define-data-var migration-contract principal tx-sender)
(define-data-var bonuses (list 1000 uint) (list ))

(define-map collection-pool { staker: principal, collection: principal } { stake-time: uint, points-balance: uint, total-multiplier: uint })
(define-map staker-info { staker: principal } { collections: (list 1000 principal), stake-time: uint, lifetime-points: uint, points-balance: uint })
(define-map staked-nfts { staker: principal, collection: principal } { ids: (list 2500 uint) })
(define-map owners { collection: principal, item: uint } { owner: principal })
(define-map approved-collections { collection: principal} { staking-fees: (list 1000 uint), unstaking-fees: (list 1000 uint), addresses: (list 1000 principal), blocks-per-token: uint, multiplier: principal, custodial: bool, prev-blocks-per-token: uint, halve-block: uint})
(define-map payout-addresses  { collection: principal} { addresses: (list 1000 principal) })
(define-map listed { collection: principal, item: uint } { listing: bool })
(define-map bonus { id: uint } { blocks-per-token: uint, bonus-check: (list 10 principal),  bonus-start-block: uint, bonus-end-block: uint })

;;read-only functions
(define-read-only (get-collection (collection principal))
    (default-to 
      { staking-fees: (list ), unstaking-fees: (list ), addresses: (list ), blocks-per-token: u0, multiplier: (as-contract tx-sender), custodial: false , prev-blocks-per-token: u0, halve-block: u0}
      (some (unwrap-panic (map-get? approved-collections { collection: collection })))
    )
)

(define-read-only (get-collection-whitelist)
    (ok (var-get collections-whitelist))
)

(define-read-only (get-multiplier-whitelist)
    (ok (var-get multipliers-whitelist))
)

(define-read-only (get-staker-info (staker principal))
    (default-to 
      {collections: (list ), stake-time: u0, lifetime-points: u0,  points-balance: u0} 
      (map-get? staker-info { staker: staker })
    )
)
(define-read-only (get-bonus (bonus-id uint))
    (default-to 
      {blocks-per-token: u0, bonus-check: (list ),  bonus-start-block: u0, bonus-end-block: u0} 
      (map-get? bonus { id: bonus-id })
    )
)
(define-read-only (get-staking-fee (collection principal))
    (default-to u0 (some (fold + (get staking-fees (get-collection collection)) u0)))
)

(define-read-only (get-unstaking-fee (collection principal))
    (default-to u0 (some (fold + (get unstaking-fees (get-collection collection)) u0)))
)

(define-read-only (get-payout-addresses (collection principal))
    (default-to (list ) (some (get addresses (get-collection collection))))
)

(define-read-only (get-blocks-per-token (collection principal))
    (default-to u0 (some (get blocks-per-token (get-collection collection))))
)

(define-read-only (get-pool (staker principal) (collection principal))
    (default-to 
    { stake-time: u0, points-balance: u0, total-multiplier: u0 }
    (map-get? collection-pool  { staker: tx-sender, collection: collection })
    )
)

(define-read-only (bonus-check-all (addresses (list 1000 principal)) (id uint))
  (let (
    (the-bonus (get-bonus id))
    (bonus-checks (get bonus-check the-bonus))
  )
    (if (is-some (index-of (map bonus-check-one addresses bonus-checks) false))
      false
      true
    ))
)

(define-read-only (check-collect (staker principal))
  (let (
      (info (get-staker-info staker))
      (staker-collections (get collections info))
      (staker-indexer (- (len staker-collections) u1))
      (staker-addresses (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup staker staker-indexer))
      (to-collect (fold + (map check-collect-single staker-collections staker-addresses ) u0))
      (bonus-indexer (if (> (len (var-get bonuses)) u0) (- (len (var-get bonuses)) u1) u0))
      (bonus-addresses (if (> bonus-indexer u0) (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup tx-sender bonus-indexer) (list )))
      (bonus-points (if (> (len bonus-addresses) u0) (fold + (map get-bonus-points (var-get bonuses) bonus-addresses ) u0) u0))
    )
    (+ to-collect bonus-points)
  )
)

(define-read-only (check-collect-single (collection principal) (staker principal))
    (let (
        (pool (get-pool tx-sender collection))
        (block block-height)
        (owner staker)
        (balance (get points-balance pool))
        (total-multiplier (get total-multiplier pool))
        (prev-time (get stake-time pool))
        (blocks-per-token (get-blocks-per-token collection))
        (halve (get halve-block (get-collection collection)))
        (prev-blocks-per-token (get prev-blocks-per-token (get-collection collection)))
        (points-added (if (> halve prev-time) 
        (+ (/ (/ (* u1000000 (* total-multiplier (- halve prev-time))) u10000) prev-blocks-per-token) (/ (/ (* u1000000 (* total-multiplier (- block halve))) u10000) blocks-per-token))        
        (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-token)
        ))
        (to-collect (+ balance points-added))       
    )
        to-collect
  )
)

(define-read-only (check-staker (staker principal))
    (ok (map-get? staker-info { staker: staker }))
)

(define-read-only (get-staked-nfts (staker principal) (collection principal))
  (default-to
    (list )
    (get ids (map-get? staked-nfts { staker: staker, collection: collection }))
  )
)

(define-read-only (bonus-check-one (address principal) (collection principal))
  (if (> (len (get-staked-nfts address collection)) u0)
    true
    false
  )
)

(define-read-only (get-listed (collection principal) (item uint))
  (default-to false
    (get listing (map-get? listed {collection: collection, item: item}))
  )
)

;;public functions
(define-public (whitelist-collection 
  (collection principal) (staking-fees (list 1000 uint)) (unstaking-fees (list 1000 uint)) (payouts (list 1000 principal)) (blocks-per-token uint) (multiplier principal) (custodial bool)
  )
  (begin 
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (asserts! (<= (fold + staking-fees u0) u10000000) (err ERR-FEES-TOO-HIGH))
    (asserts! (<= (fold + unstaking-fees u0) u10000000) (err ERR-FEES-TOO-HIGH))
    (asserts! (>= blocks-per-token EMISSION-LIMIT) (err ERR-EMISSION-TOO-HIGH))
    (try! (approve-collection collection))
    (try! (approve-multiplier multiplier))
    (map-set approved-collections 
      { collection: collection } 
      {staking-fees: staking-fees, unstaking-fees: unstaking-fees, addresses: payouts, blocks-per-token: blocks-per-token, multiplier: multiplier, custodial: custodial, prev-blocks-per-token: u0, halve-block: u0})
    (print {
      action: "whitelist-collection",
      collection: (get-collection collection),
      whitelist: (var-get collections-whitelist)
    })
    (ok true))
)

(define-public (stake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (collection-contract (contract-of collection))
        (pool (get-pool tx-sender collection-contract))
        (balance (get points-balance pool))
        (total-multiplier (get total-multiplier pool))
        (prev-time (get stake-time pool))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (block block-height)
        (blocks-per-token (get-blocks-per-token collection-contract))
        (halve (get halve-block (get-collection collection-contract)))
        (prev-blocks-per-token (get prev-blocks-per-token (get-collection collection-contract)))
        (points-added (if (> halve prev-time) 
        (+ (/ (/ (* u1000000 (* total-multiplier (- halve prev-time))) u10000) prev-blocks-per-token) (/ (/ (* u1000000 (* total-multiplier (- block halve))) u10000) blocks-per-token))        
        (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-token)
        ))
        (bonus-indexer (if (> (len (var-get bonuses)) u0) (- (len (var-get bonuses)) u1) u0))
        (bonus-addresses (if (> bonus-indexer u0) (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup tx-sender bonus-indexer) (list )))
        (bonus-points (if (> (len bonus-addresses) u0) (fold + (map get-bonus-points (var-get bonuses) bonus-addresses ) u0) u0))
        (ids (get-staked-nfts tx-sender collection-contract))
        (fees (get-staking-fee collection-contract))
        (payouts (get-payout-addresses collection-contract))
        (custodial (get custodial (get-collection collection-contract)))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (index-of (var-get collections-whitelist) collection-contract)) (err ERR-NOT-WHITELISTED))
    (asserts! (is-some (index-of (var-get multipliers-whitelist) (contract-of lookup-table))) (err ERR-NOT-WHITELISTED))
    (asserts! (not (is-some (index-of (var-get blacklist) collection-contract))) (err ERR-BLACKLISTED))
    (asserts! (not (is-some (index-of (var-get blacklist) tx-sender))) (err ERR-BLACKLISTED))
    (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? collection get-owner item))) tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq false (get-listed (contract-of collection) item)) (err ERR-ITEM-LISTED))
    (begin 
        (if (> fees u0)
          (begin
            (print (map pay payouts (get staking-fees (get-collection collection-contract ))))
          )
          (list (ok true))
        )
        (if (is-eq custodial true) (try! (contract-call? collection transfer item tx-sender (as-contract tx-sender))) true)
        (set-staker-collections tx-sender collection-contract)
        (begin
          (map-set staker-info { staker: tx-sender} (merge (get-staker-info tx-sender) {stake-time: block, points-balance: (+ (+ (get points-balance (get-staker-info tx-sender)) points-added) bonus-points)}))
          (map-set collection-pool { staker: tx-sender, collection: collection-contract } { stake-time: block, points-balance: (+ balance points-added), total-multiplier: (+ total-multiplier multiplier) })
        )
        (map-set owners { collection: collection-contract, item: item } { owner: tx-sender })
        (map-set staked-nfts { staker: tx-sender, collection: collection-contract}
          { ids: (unwrap-panic (as-max-len? (append ids item) u2500)) }
        )
        (print {
          action: "stake",
          staker: (get-staker-info tx-sender),
          collection-pool: (map-get? collection-pool { staker: tx-sender, collection: collection-contract })
        })
        (ok true)
    )
    )
)

(define-public (unstake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (collection-contract (contract-of collection))
        (pool (get-pool tx-sender collection-contract))
        (owner (unwrap-panic (get owner (map-get? owners { collection: collection-contract, item: item }))))
        (block block-height)
        (balance (get points-balance pool))
        (total-multiplier (get total-multiplier pool))
        (prev-time (get stake-time pool))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (blocks-per-token (get-blocks-per-token collection-contract))
        (halve (get halve-block (get-collection collection-contract)))
        (prev-blocks-per-token (get prev-blocks-per-token (get-collection collection-contract)))
        (points-added (if (> halve prev-time) 
        (+ (/ (/ (* u1000000 (* total-multiplier (- halve prev-time))) u10000) prev-blocks-per-token) (/ (/ (* u1000000 (* total-multiplier (- block halve))) u10000) blocks-per-token))        
        (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-token)
        ))
        (bonus-indexer (if (> (len (var-get bonuses)) u0) (- (len (var-get bonuses)) u1) u0))
        (bonus-addresses (if (> bonus-indexer u0) (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup tx-sender bonus-indexer) (list )))
        (bonus-points (if (> (len bonus-addresses) u0) (fold + (map get-bonus-points (var-get bonuses) bonus-addresses ) u0) u0))
        (ids (get-staked-nfts owner collection-contract))
        (fees (get-unstaking-fee collection-contract))
        (payouts (get-payout-addresses collection-contract))
        (staker-collections (get collections (get-staker-info tx-sender)))
        (custodial (get custodial (get-collection collection-contract)))        
    )
    (asserts! (is-some (index-of (var-get collections-whitelist) collection-contract)) (err ERR-NOT-WHITELISTED))
    (asserts! (is-some (index-of (var-get multipliers-whitelist) (contract-of lookup-table))) (err ERR-NOT-WHITELISTED))
    (if custodial
      (asserts! (is-eq owner tx-sender) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? collection get-owner item))) tx-sender) (err ERR-NOT-AUTHORIZED))
    )
    (var-set removing-item-id item)
    (var-set removing-collection collection-contract)
    (begin 
        (if (> fees u0)
          (begin
            (print (map pay payouts (get unstaking-fees (get-collection collection-contract ))))
          )
          (list (ok true))
        )
        (if (is-eq custodial true) (try! (as-contract (contract-call? collection transfer item (as-contract tx-sender) owner ))) true)
          (begin
            (map-set staker-info { staker: tx-sender} (merge (get-staker-info tx-sender) {stake-time: block, points-balance: (+ (+ (get points-balance (get-staker-info tx-sender)) points-added) bonus-points)}))
            (map-set collection-pool { staker: tx-sender, collection: collection-contract } { stake-time: block, points-balance: (+ balance points-added), total-multiplier: (- total-multiplier multiplier) })
          )
        (map-set staked-nfts { staker: tx-sender, collection: collection-contract }
          { ids: (filter remove-item-id ids) }
        )
        (if (is-eq (len ids) u0)
          (map-set staker-info { staker: tx-sender}
          (merge (get-staker-info tx-sender) { collections: (filter remove-collection staker-collections) })
          )
          true
        )
        (print {
          action: "unstake",
          staker: (get-staker-info tx-sender),
          collection-pool: (map-get? collection-pool { staker: tx-sender, collection: collection-contract })
        })
        (ok true)
    )
    )
)

(define-public (collect (fungible <token-trait>))
  (let (
      (block block-height)
      (owner tx-sender)
      (info (get-staker-info tx-sender))
      (staker-collection (get collections info))
      (staker-prev-time (get stake-time info))
      (to-collect (check-collect tx-sender))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get token-address) (contract-of fungible)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (is-some (index-of (var-get blacklist) tx-sender))) (err ERR-BLACKLISTED))
    (begin
      (try! (as-contract (contract-call? fungible collect owner to-collect)))
      (map-set staker-info { staker: tx-sender} (merge (get-staker-info tx-sender) {stake-time: block, lifetime-points: (+ (get lifetime-points info) to-collect) , points-balance: u0}))
      (map collect-single staker-collection)
    )
    (print {
      action: "collect",
      staker: (get-staker-info tx-sender)
    })
   (ok true)
  )
)

(define-public (pay (receiver principal) (price uint))
  (begin
    (try! (stx-transfer? price tx-sender receiver))
    (ok true)
  )
)

(define-public (set-listed (collection principal) (item uint))
  (begin
    (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
    (asserts! (is-eq contract-caller collection) (err ERR-NOT-AUTHORIZED))
    (map-set listed { collection: collection, item: item } { listing: true })
    (ok true)
  )
)

(define-public (set-unlisted (collection principal) (item uint))
  (begin
    (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
    (asserts! (is-eq contract-caller collection) (err ERR-NOT-AUTHORIZED))
    (map-set listed { collection: collection, item: item } { listing: false })
    (ok true)
  )
)

;;admin-only functions
(define-public (admin-unstake (collection <nft-trait>) (lookup-table <lookup-trait>) (item uint))
    (let (
        (collection-contract (contract-of collection))
        (owner (unwrap-panic (get owner (map-get? owners { collection: collection-contract, item: item }))))
        (pool (get-pool owner collection-contract))
        (block block-height)
        (balance (get points-balance pool))
        (total-multiplier (get total-multiplier pool))
        (prev-time (get stake-time pool))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (blocks-per-token (get-blocks-per-token collection-contract))
        (halve (get halve-block (get-collection collection-contract)))
        (prev-blocks-per-token (get prev-blocks-per-token (get-collection collection-contract)))
        (points-added (if (> halve prev-time) 
        (+ (/ (/ (* u1000000 (* total-multiplier (- halve prev-time))) u10000) prev-blocks-per-token) (/ (/ (* u1000000 (* total-multiplier (- block halve))) u10000) blocks-per-token))        
        (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-token)
        ))
        (bonus-indexer (if (> (len (var-get bonuses)) u0) (- (len (var-get bonuses)) u1) u0))
        (bonus-addresses (if (> bonus-indexer u0) (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup tx-sender bonus-indexer) (list )))
        (bonus-points (if (> (len bonus-addresses) u0) (fold + (map get-bonus-points (var-get bonuses) bonus-addresses ) u0) u0))
        (ids (get-staked-nfts owner collection-contract))
        (custodial (get custodial (get-collection collection-contract)))
        (staker-collections (get collections (get-staker-info owner)))
    )
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (var-set removing-item-id item)
    (var-set removing-collection (contract-of collection))
    (begin 
        (if (is-eq custodial true) (try! (as-contract (contract-call? collection transfer item (as-contract tx-sender) owner ))) true)
        (begin
          (map-set staker-info { staker: owner} (merge (get-staker-info owner) {stake-time: block, points-balance: (+ (+ (get points-balance (get-staker-info owner)) points-added) bonus-points)}))
          (map-set collection-pool { staker: owner, collection: collection-contract } { stake-time: block, points-balance: (+ balance points-added), total-multiplier: (- total-multiplier multiplier) })
        )
        (map-set staked-nfts { staker: owner, collection: collection-contract }
          { ids: (filter remove-item-id ids) }
        )
        (if (is-eq (len ids) u0)
          (map-set staker-info { staker: owner}
          (merge (get-staker-info owner) { collections: (filter remove-collection staker-collections) })
          )
          true
        )
        (print {
          action: "admin-unstake",
          staker: (get-staker-info owner),
          collection-pool: (map-get? collection-pool { staker: owner, collection: collection-contract })
        })
        (ok true)
    )
    )
)
;; halve the emission for all collections
(define-public (halving)
    (let (
          (collections (unwrap-panic (get-collection-whitelist)))
        ) 
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (map halve-emission collections)
        (ok (print { action: "halving" }))
    )
)
;; approve a collection contract for staking
(define-public (approve-collection (collection principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set collections-whitelist (unwrap-panic (as-max-len? (append (var-get collections-whitelist) collection) u100))))
    (err ERR-NOT-AUTHORIZED)
  )
)
;; approve a multiplier contract for staking
(define-public (approve-multiplier (multiplier principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set multipliers-whitelist (unwrap-panic (as-max-len? (append (var-get multipliers-whitelist) multiplier) u100))))
    (err ERR-NOT-AUTHORIZED)
  )
)
;; add a new bonus, max bonus emission is 50 tokens per day
(define-public (bonus-add (addresses (list 10 principal)) ( blocks-x-token-bonus uint) (start-block uint) (bonus-period uint))
  (let (
    (bonus-id (+ (len (var-get bonuses)) u1))
    ) 
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (asserts! (>= blocks-x-token-bonus u288) (err ERR-EMISSION-TOO-HIGH))
    (map-set bonus {id: bonus-id} {blocks-per-token: blocks-x-token-bonus, bonus-check: addresses,  bonus-start-block: start-block, bonus-end-block: (+ start-block bonus-period)})
    (var-set bonuses (unwrap-panic (as-max-len? (append (var-get bonuses) bonus-id) u1000)))
    (ok (print {bonus: (map-get? bonus {id: bonus-id}), bonuses: (var-get bonuses)}))
  )
)
;; can change the emission and the duration of an existing bonus
(define-public (bonus-change (bonus-id uint) ( blocks-x-token-bonus uint) (bonus-period uint))
  (begin 
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (asserts! (>= blocks-x-token-bonus u288) (err ERR-EMISSION-TOO-HIGH))
    (asserts! (is-some (index-of (var-get bonuses) bonus-id)) (err ERR-NOT-VALID-BONUS))
    (let (
      (the-bonus (unwrap-panic (map-get? bonus {id: bonus-id})))
    )
    (map-set bonus {id: bonus-id} (merge the-bonus  {blocks-per-token: blocks-x-token-bonus, bonus-end-block: (+ (get bonus-start-block the-bonus) bonus-period)}))
    (ok (print {bonus: (map-get? bonus {id: bonus-id}), bonuses: (var-get bonuses)}))
  ))
)
;;change contract admin
(define-public (change-admin (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set admin address))
    (err ERR-NOT-AUTHORIZED)
  )
)
;; security function: admins can turn off stake and collect functions for all collections
(define-public (shutoff-switch (switch bool))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set shutoff-valve switch))
    (err ERR-NOT-AUTHORIZED)
  )
)
;; change staking fees for a specific collection
(define-public (staking-fee-change (collection principal) (amounts (list 1000 uint)))
    (let (
          (payouts (get-payout-addresses collection))
        ) 
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (len payouts) (len amounts)) (err ERR-PAYOUT-LEN-MISMATCH))
        (asserts! (<= (fold + amounts u0) u10000000) (err ERR-FEES-TOO-HIGH))
        (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
        (map-set approved-collections { collection: collection} (merge (get-collection collection) {staking-fees: amounts}))
        (ok     
        (print {
          action: "staking-fee-change",
          collection: (get-collection collection)
        }))
    )
)
;; change unstaking fees for a specific collection
(define-public (unstaking-fee-change (collection principal) (amounts (list 1000 uint)))
    (let (
          (payouts (get-payout-addresses collection))
        ) 
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (len payouts) (len amounts)) (err ERR-PAYOUT-LEN-MISMATCH))
        (asserts! (<= (fold + amounts u0) u10000000) (err ERR-FEES-TOO-HIGH))
        (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
        (map-set approved-collections { collection: collection} (merge (get-collection collection) {unstaking-fees: amounts}))
        (ok
        (print {
          action: "unstaking-fee-change",
          collection: (get-collection collection)
        }))
    )
)
;; change the payouts for a specific collection
(define-public (payout-addresses-change (collection principal) (addresses (list 1000 principal)))
    (let (
          (amounts (get staking-fees (get-collection collection)))
        ) 
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (len addresses) (len amounts)) (err ERR-PAYOUT-LEN-MISMATCH))
        (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
        (ok (map-set approved-collections { collection: collection} (merge (get-collection collection) {addresses: addresses})))
    )
)
;; change the emission for a specific collection
(define-public (blocks-per-token-change (collection principal) (blocks uint))
    (begin 
        (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
        (asserts! (>= blocks EMISSION-LIMIT) (err ERR-EMISSION-TOO-HIGH))
        (asserts! (is-some (index-of (var-get collections-whitelist) collection)) (err ERR-NOT-WHITELISTED))
        (ok (map-set approved-collections { collection: collection} (merge (get-collection collection) {blocks-per-token: blocks, prev-blocks-per-token: (get blocks-per-token (get-collection collection)), halve-block: block-height})))
    )
)
;; change the authorized staking token
(define-public (token-change (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set token-address address))
    (err ERR-NOT-AUTHORIZED)
  )
)
;; change the authorized migration contract
(define-public (migration-change (migration principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set migration-contract migration))
    (err ERR-NOT-AUTHORIZED)
  )
)
;; add an address or collection from blacklist
(define-public (blacklist-address (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set blacklist (unwrap-panic (as-max-len? (append (var-get blacklist) address) u1000))))
    (err ERR-NOT-AUTHORIZED)
  )
)

;; remove an address or collection from blacklist
(define-public (unblacklist-address (address principal))
  (begin 
    (var-set removing-collection address)
    (if (is-eq tx-sender (var-get admin))
      (ok (var-set blacklist (filter remove-collection (var-get blacklist))))
      (err ERR-NOT-AUTHORIZED)
    ))
)

;;private functions
(define-private (halve-emission (collection principal))
    (let (
          (stakable (get-collection collection))
          (blocks (get blocks-per-token stakable))
        ) 
        (map-set approved-collections {collection: collection} (merge stakable { blocks-per-token: (* blocks u2), prev-blocks-per-token: blocks, halve-block: block-height}))
    )
)

(define-private (set-staker-collections (staker principal) (collection principal))
  (let (
    (info (get-staker-info staker))
    (staker-collections (get collections info)) 
    )
    (if (not (is-some (index-of staker-collections collection)))
      (map-set staker-info { staker: staker } (merge info { collections: (unwrap-panic (as-max-len? (append staker-collections collection) u1000)) }))   
      true
    )
  )
)

(define-private (get-bonus-points (bonus-id uint) (staker principal))
    (let (
        (the-bonus (get-bonus bonus-id))
        (bonus-checks (get bonus-check the-bonus))
        (block-end (get bonus-end-block the-bonus))
        (block-start (get bonus-start-block the-bonus))
        (bonus-blocks-per-token (get blocks-per-token the-bonus))
        (indexer (if (> (len bonus-checks) u0 ) (- (len bonus-checks) u1)  u0))
        (addresses (if (> indexer u0) (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup staker indexer) (list staker)))
        (check (if (> (len addresses) u0) (bonus-check-all addresses bonus-id) false))
        (info (get-staker-info staker))
        (prev-time (get stake-time info))
        (active-bonus (> block-height block-start))
        ) 
        (if (and check active-bonus)
          (if (and (> (len bonus-checks) u0 ) (< prev-time block-end)) 
            (if (> block-height block-end) 
                (if (> prev-time block-start) (/ (* u100000000 (- block-end prev-time)) bonus-blocks-per-token) (/ (* u100000000 (- block-end block-start)) bonus-blocks-per-token))
                (if (> prev-time block-start) (/ (* u100000000 (- block-height prev-time)) bonus-blocks-per-token) (/ (* u100000000 (- block-height block-start)) bonus-blocks-per-token))
            ) 
            u0
          )
          u0
        )        
    )
)

(define-private (remove-item-id (item-id uint))
  (if (is-eq item-id (var-get removing-item-id))
    false
    true
  )
)

(define-private (remove-collection (collection principal))
  (if (is-eq collection (var-get removing-collection))
      false
      true  
    )
)

(define-private (collect-single (collection principal))
  (begin 
    (if (not (is-some (index-of (var-get blacklist) collection)))
    (map-set collection-pool { staker: tx-sender, collection: collection }  (merge (unwrap-panic (map-get? collection-pool { staker: tx-sender, collection: collection })) { stake-time: block-height, points-balance: u0}))
    true
    )) 
)

;;migration functions
(define-public (migrate-item (collection principal) (item uint))
    (let (
        (ids (get-staked-nfts tx-sender collection))
        (custodial (get custodial (get-collection collection)))
    )
    (asserts! (is-eq contract-caller (var-get migration-contract)) (err ERR-MIGRATION-NOT-AUTHORIZED))
    (begin 
      (set-staker-collections tx-sender collection)
      (map-set owners { collection: collection, item: item } { owner: tx-sender })
      (map-set staked-nfts { staker: tx-sender, collection: collection}
        { ids: (unwrap-panic (as-max-len? (append ids item) u2500)) }
      )
      (print {
        action: "migrate-item",
        staked-nfts: (get-staked-nfts tx-sender collection),
        owners: (map-get? owners { collection: collection, item: item })
      })
      (ok true))
    )
)

(define-public (migrate-staker (collection principal) (stake-time uint) (lifetime-points uint) (points-balance uint) (total-multiplier uint))
  (begin 
    (asserts! (is-eq contract-caller (var-get migration-contract)) (err ERR-MIGRATION-NOT-AUTHORIZED))
    (map-set collection-pool {staker: tx-sender, collection: collection}
    {stake-time: stake-time, points-balance: points-balance, total-multiplier: total-multiplier})
    (set-staker-collections tx-sender collection)
    (map-set staker-info {staker: tx-sender}
    (merge (unwrap-panic (map-get? staker-info {staker: tx-sender})) {stake-time: stake-time, lifetime-points: lifetime-points, points-balance: points-balance}))
    (print {
        action: "migrate-staker",
        staker: (get-staker-info tx-sender),
        collection-pool: (map-get? collection-pool { staker: tx-sender, collection: collection})
      })
    (ok true)
  )
)

;;init actions
(whitelist-collection 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls (list u5000000) (list u5000000) (list 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u29 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bull-multipliers true)
(whitelist-collection 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears (list u5000000) (list u5000000) (list 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u29 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bear-multipliers true)
(whitelist-collection 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales (list u5000000) (list u5000000) (list 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u29 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.whale-multipliers true)
(whitelist-collection 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.bitcoin-goats (list u5000000) (list u5000000) (list 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u29 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.goat-multipliers true)
(print (bonus-add (list 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales) u288 block-height u4608))