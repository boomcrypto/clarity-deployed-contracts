(define-constant ERR-EMISSION-TOO-HIGH u403)
(define-constant ERR-CONTRACT-NOT-AUTHORIZED u407)
(define-constant ERR-NOT-AUTHORIZED u404)
(define-constant ERR-NOT-VALID-BONUS u406)
(define-constant BONUS-LIMIT u3)

(define-data-var admin principal tx-sender)
(define-data-var staking-helper principal (as-contract tx-sender))
(define-data-var removing-bonus-id uint u0)
(define-data-var shutoff-valve bool false)
(define-data-var bonuses (list 3 uint) (list ))

(define-map bonus { id: uint } { blocks-per-token: uint, bonus-check: (list 10 principal),  bonus-start-block: uint, bonus-end-block: uint })
(define-map staker-bonus {staker: principal, bonus-id: uint} {stake-time: uint} )
(define-map staked-bonuses { staker: principal} { bonus-ids: (list 3 uint) , points-balance: uint })

(define-read-only (get-bonus (bonus-id uint))
    (default-to 
      {blocks-per-token: u0, bonus-check: (list ),  bonus-start-block: u0, bonus-end-block: u0} 
      (map-get? bonus { id: bonus-id })
    )
)

(define-read-only (get-bonuses)
    (var-get bonuses)
)

(define-read-only (get-staker-bonus (staker principal) (bonus-id uint))
    (default-to 
      { stake-time: block-height} 
      (map-get? staker-bonus { staker: staker , bonus-id: bonus-id })
    )
)

(define-read-only (get-staked-bonuses (staker principal))
    (default-to 
      { bonus-ids: (list ) , points-balance: u0} 
      (map-get? staked-bonuses { staker: staker })
    )
)

(define-read-only (bonus-check-all (staker principal))
  (let (
       (all-bonuses (get-bonuses))
       (valid-bonuses (filter bonus-check-by-id all-bonuses))
  )
    valid-bonuses
  )
)

(define-read-only (bonus-check-by-id (id uint))
  (let (
    (the-bonus (get-bonus id))
    (bonus-checks (get bonus-check the-bonus))
    (bonus-exist (> (len bonus-checks) u0 ))
    (indexer (if bonus-exist (- (len bonus-checks) u1)  u0))
    (addresses (if bonus-exist (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup tx-sender indexer) (list )))
  )
    (if (is-some (index-of (map bonus-check-one addresses bonus-checks) false))
      false
      true
    ))
)

(define-read-only (bonus-check-one (address principal) (collection principal))
  (if (> (len (contract-call? .spaghettipunk-staking get-staked-nfts address collection)) u0)
    true
    false
  )
)

(define-public (check-bonuses (staker principal))
    (let (
      (valid-bonuses (bonus-check-all staker))
      (stakedBonuses (get-staked-bonuses staker))
      (stakerBonuses (get bonus-ids stakedBonuses))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq contract-caller (var-get staking-helper)) (err ERR-CONTRACT-NOT-AUTHORIZED))
    (if (> (len stakerBonuses) u0)
      (let (
        (ge-zero (> (len stakerBonuses) u0))
        (indexer (if ge-zero (- (len stakerBonuses) u1) u0))
        (addresses (if ge-zero (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup staker indexer) (list )))
      )
        (map check-bonus-one stakerBonuses addresses)
        true
      )
      true
    )
    (if (> (len valid-bonuses) u0)
      (let (
        (ge-zero (> (len valid-bonuses) u0))
        (indexer (if ge-zero (- (len valid-bonuses) u1) u0))
        (addresses (if ge-zero (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup staker indexer) (list )))
      )
        (map set-stake-time valid-bonuses addresses)
        true
      )
      true
    )
    (map-set staked-bonuses { staker: staker} (merge (get-staked-bonuses staker) {bonus-ids: valid-bonuses}))
    (ok true)
    )
)

(define-private (set-stake-time (bonus-id uint) (staker principal))
  (map-set staker-bonus { staker: staker, bonus-id: bonus-id } {stake-time: block-height})
)

(define-public (activate-bonuses (staker principal))
    (let (
      (valid-bonuses (bonus-check-all staker))
      (stakedBonuses (get-staked-bonuses staker))
      (stakerBonuses (get bonus-ids stakedBonuses))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq contract-caller (var-get staking-helper)) (err ERR-CONTRACT-NOT-AUTHORIZED))
    (if (> (len stakerBonuses) u0)
      (let (
        (ge-zero (> (len stakerBonuses) u0))
        (indexer (if ge-zero (- (len stakerBonuses) u1) u0))
        (addresses (if ge-zero (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup staker indexer) (list )))
      )
        (map check-bonus-one stakerBonuses addresses)
        true
      )
      true
    )
    (if (> (len valid-bonuses) (len stakerBonuses))
      (let (
        (ge-zero (> (len valid-bonuses) u0))
        (indexer (if ge-zero (- (len valid-bonuses) u1) u0))
        (addresses (if ge-zero (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.principal-lists lookup staker indexer) (list )))
      )
        (map set-stake-time valid-bonuses addresses)
        true
      )
      true
    )
    (map-set staked-bonuses { staker: staker} (merge (get-staked-bonuses staker) {bonus-ids: valid-bonuses}))
    (ok true)
    )
)

(define-read-only (check-collect-bonus (bonus-id uint) (staker principal))
    (let (
        (height block-height)
        (the-bonus (get-bonus bonus-id))
        (bonus-checks (get bonus-check the-bonus))
        (block-end (get bonus-end-block the-bonus))
        (block-start (get bonus-start-block the-bonus))
        (bonus-blocks-per-token (get blocks-per-token the-bonus))
        (bonus-exist (> (len bonus-checks) u0 ))
        ;;(check (if bonus-exist (bonus-check-by-id bonus-id) false))
        (info (get-staker-bonus staker bonus-id))
        (prev-time (get stake-time info))
        (active-bonus (and (> height block-start) (>  height prev-time)))
        ) 
        (if (and active-bonus bonus-exist)
          (if (and (> (len bonus-checks) u0 ) (< prev-time block-end)) 
            (if (> height block-end) 
                (if (> prev-time block-start) (/ (* u100000000 (- block-end prev-time)) bonus-blocks-per-token) (/ (* u100000000 (- block-end block-start)) bonus-blocks-per-token))
                (if (> prev-time block-start) (/ (* u100000000 (- height prev-time)) bonus-blocks-per-token) (/ (* u100000000 (- height block-start)) bonus-blocks-per-token))
            ) 
            u0
          )
          u0
        )        
    )
)

;; add a new bonus, max bonus emission is 50 tokens per day
(define-public (bonus-add (bonus-id uint) (addresses (list 10 principal)) ( blocks-x-token-bonus uint) (start-block uint) (bonus-period uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (asserts! (>= blocks-x-token-bonus u288) (err ERR-EMISSION-TOO-HIGH))
    (asserts! (and (> bonus-id u0) (>= BONUS-LIMIT bonus-id)) (err ERR-NOT-VALID-BONUS))
    (map-set bonus {id: bonus-id} {blocks-per-token: blocks-x-token-bonus, bonus-check: addresses,  bonus-start-block: start-block, bonus-end-block: (+ start-block bonus-period)})
    (if (not (is-some (index-of (var-get bonuses) bonus-id)))
        (var-set bonuses (unwrap-panic (as-max-len? (append (var-get bonuses) bonus-id) u3)))
        true
    )    
    (ok (print {action: "bonus-add", bonus: (map-get? bonus {id: bonus-id}), bonuses: (var-get bonuses)}))
  )
)

(define-public (bonus-remove (bonus-id uint))
  (let (
    (all-bonuses (var-get bonuses))
  )
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (asserts! (> (len all-bonuses) u1) (err ERR-NOT-VALID-BONUS))
    (var-set removing-bonus-id bonus-id)
    (map-delete bonus {id: bonus-id})
    (var-set bonuses (filter remove-bonus-id all-bonuses))
    (ok (print {action: "bonus-remove", bonuses: (var-get bonuses)}))
  )
)

(define-public (check-bonus-one (bonus-id uint) (staker principal))
    (let (
        (bonus-points (check-collect-bonus bonus-id staker))
        (stakedBonuses (get-staked-bonuses staker))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq contract-caller (var-get staking-helper)) (err ERR-CONTRACT-NOT-AUTHORIZED))
    (map-set staked-bonuses {staker: staker} (merge stakedBonuses {points-balance: (+ (get points-balance stakedBonuses) bonus-points)}))
    (map-set staker-bonus { staker: staker, bonus-id: bonus-id } {stake-time: block-height})
    (ok true)
    )
)

(define-public (bonus-collect (staker principal))
    (let (
        (stakedBonuses (get-staked-bonuses staker))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq contract-caller (var-get staking-helper)) (err ERR-CONTRACT-NOT-AUTHORIZED))
    (map-set staked-bonuses {staker: staker} (merge stakedBonuses {points-balance: u0}))
    (ok true)
    )
)

(define-private (remove-bonus-id (item-id uint))
  (if (is-eq item-id (var-get removing-bonus-id))
    false
    true
  )
)

;;change contract admin
(define-public (change-admin (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set admin address))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (helper-change (helper principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set staking-helper helper))
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

(print (bonus-add u1 (list 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bulls 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-bears 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-whales) u288 block-height u3600))