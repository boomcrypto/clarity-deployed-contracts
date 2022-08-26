(define-map stakes uint {
  staked: bool,
  staker: principal,
  staked-block: uint
})

(define-map stakers principal (list 3000 uint))
(define-map lifetime-harvested principal uint)

(define-data-var simulated-block-height uint u0)
(define-data-var removing-item-id uint u3001)

(define-data-var payout-one principal 'SP1GPNZB0JSC9RXJTXVBAMSPQE29WM1SE8V39R6K2)
(define-data-var payout-two principal 'SP1GPNZB0JSC9RXJTXVBAMSPQE29WM1SE8V39R6K2)
(define-data-var payout-three principal 'SP1GPNZB0JSC9RXJTXVBAMSPQE29WM1SE8V39R6K2)

(define-data-var fee-one uint u2000000)
(define-data-var fee-two uint u2000000)
(define-data-var fee-three uint u1000000)

(define-data-var admin principal 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6)

(define-constant deployer tx-sender)
(define-constant contract-address (as-contract tx-sender))
(define-constant err-not-authorized u403)
(define-constant err-not-found u404)
(define-constant err-already-staked u410)

;;
;; READ-ONLY FUNCTIONS
;; To get the state of staking and the contract
;;

(define-read-only (is-staked (id uint))
  (if (and (is-some (map-get? stakes id))
           (is-eq (get staked (unwrap-panic (map-get? stakes id))) true)
           (is-eq (get staker (unwrap-panic (map-get? stakes id))) (get-monkey-owner id)))
      true
      false
  )
)

(define-read-only (get-user-balance (user principal))
  (fold + (map get-monkey-balance (get-staked-ids tx-sender)) u0)
)

(define-read-only (get-lifetime-harvested (user principal))
  (default-to u0 (map-get? lifetime-harvested user))
)

(define-read-only (get-monkey-balance (id uint))
  (if (not (is-staked id)) u0
      (/ (* (get-bgr id)
            (- (get-block-height)
               (get staked-block (unwrap-panic (map-get? stakes id))))
            u1000000
          )
          u14400)
  )
)

(define-read-only (get-bgr (id uint))
;;(/ (unwrap-panic (contract-call? .bgr-v2 lookup (- id u1))) u100)
  (/ (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bgr-v2 lookup (- id u1))) u100)
)

(define-read-only (get-monkey-owner (id uint))
;;(unwrap-panic (unwrap-panic (contract-call? .bitcoin-monkeys get-owner id)))
  (unwrap-panic (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys get-owner id)))
)

(define-read-only (get-balance)
;; (as-contract (contract-call? .btc-monkeys-bananas get-balance contract-address))
  (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas get-balance contract-address))
)

(define-public (stake (id uint))
  (begin
    (asserts! (is-eq tx-sender (get-monkey-owner id)) (err err-not-authorized))
    (asserts! (not (is-staked id)) (err err-already-staked))
    (map-set stakes id {
      staked: true,
      staker: tx-sender,
      staked-block: (get-block-height)
    }) 
    (map-set stakers tx-sender (unwrap-panic (as-max-len? (concat (default-to (list ) (map-get? stakers tx-sender)) (list id)) u3000)))
    (ok true)
  )
)

(define-private (hrvst (user principal))
  (begin 
    (map harvest-monkey (get-staked-ids tx-sender))
    (ok true)
  )
)

(define-public (harvest)
  (begin
    (try! (pay-harvest-fees))
    (hrvst tx-sender)
  )
)

(define-private (harvest-monkey (id uint))
  (let ( 
        (owner (get-monkey-owner id)) 
        (balance (get-monkey-balance id)) 
       )
    (asserts! (or (is-admin) (is-eq tx-sender owner))
              (err err-not-authorized))
    (asserts! (is-some (map-get? stakes id)) (err err-not-found))
    (and 
      (> balance u0)
;;      (try! (as-contract (contract-call? .btc-monkeys-bananas transfer balance contract-address owner none)))
      (try! (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer balance contract-address owner none)))
    )
    (map-set stakes id {
      staked: true,
      staker: owner,
      staked-block: (get-block-height)
    }) 
    (map-set lifetime-harvested owner 
             (+ (default-to u0 (map-get? lifetime-harvested owner)) balance))
    (ok true)
  )
)

(define-public (unstake (id uint))
  (let ((owner (get-monkey-owner id)))
    (asserts! (or (is-admin) (is-eq tx-sender owner)) (err err-not-authorized))
    (asserts! (is-staked id) (err err-not-found))
    (try! (harvest-monkey id))
    (map-set stakes id {
      staked: false,
      staker: owner,
      staked-block: (get-block-height)
    })
    (var-set removing-item-id id)
    (map-set stakers owner (filter remove-item-id (default-to (list ) (map-get? stakers owner))))
    (ok true)
  )
)

(define-private (remove-item-id (item-id uint))
  (if (is-eq item-id (var-get removing-item-id))
    false
    true
  )
)

(define-private (pay-harvest-fees)
  (begin
    (try! (stx-transfer? (var-get fee-one) tx-sender (var-get payout-one)))
    (try! (stx-transfer? (var-get fee-two) tx-sender (var-get payout-two)))
    (try! (stx-transfer? (var-get fee-three) tx-sender (var-get payout-three)))
    (ok true) 
  )
)

(define-read-only (get-stake-info (id uint))
  (if (is-staked id)
      (map-get? stakes id)
      none)
)

(define-read-only (get-staked-ids (user principal))
  (filter is-staked (default-to (list ) (map-get? stakers user)))
)

(define-read-only (get-block-height)
;; (var-get simulated-block-height)
  block-height
)

(define-public (set-block-height (height uint))
  (ok (var-set simulated-block-height height))
)

;;
;; ADMIN FUNCTIONS
;; These should all be gated with is-admin
;; 

(define-public (admin-harvest (user principal))
  (begin 
    (asserts! (is-admin) (err err-not-authorized))
    (hrvst user)
  )
)

(define-private (is-admin)
  (or (is-eq tx-sender deployer)
      (is-eq tx-sender (var-get admin)))
)

(define-public (withdraw (amount uint))
  (begin 
    (asserts! (is-admin) (err err-not-authorized))
    ;;  (try! (as-contract (contract-call? .btc-monkeys-bananas transfer amount contract-address tx-sender none)))
    (try! (as-contract (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer amount contract-address tx-sender none)))
    (ok true)
  ) 
)

(define-public (set-payout-one (addr principal))
  (begin 
    (asserts! (is-admin) (err err-not-authorized))
    (var-set payout-one addr)
    (ok true)
  )
)

(define-public (set-payout-two (addr principal))
  (begin 
    (asserts! (is-admin) (err err-not-authorized))
    (var-set payout-two addr)
    (ok true)
  )
)

(define-public (set-payout-three (addr principal))
  (begin 
    (asserts! (is-admin) (err err-not-authorized))
    (var-set payout-three addr)
    (ok true)
  )
)

(define-public (set-fee-one (amount uint))
  (begin 
    (asserts! (is-admin) (err err-not-authorized))
    (var-set fee-one amount)
    (ok true)
  )
)

(define-public (set-fee-two (amount uint))
  (begin 
    (asserts! (is-admin) (err err-not-authorized))
    (var-set fee-two amount)
    (ok true)
  )
)

(define-public (set-fee-three (amount uint))
  (begin 
    (asserts! (is-admin) (err err-not-authorized))
    (var-set fee-three amount)
    (ok true)
  )
)

(define-public (set-admin (addr principal))
  (begin
    (asserts! (is-admin) (err err-not-authorized))
    (ok (var-set admin addr))
  )
)
