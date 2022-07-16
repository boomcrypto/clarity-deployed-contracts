(define-constant deployer tx-sender)

(define-constant err-not-authorized u403)

(define-constant start-block u65498)
(define-map last-collected-block uint uint)
(define-data-var is-enabled bool true)
(define-data-var admin principal tx-sender)

(define-public (distribute (batch uint))
  (begin 
    (asserts! (or (is-eq tx-sender deployer) (is-eq tx-sender (var-get admin))) (err err-not-authorized))
    (asserts! (var-get is-enabled) (err err-not-authorized))
    (map distribute-single-reward (contract-call? .component-ids-250 get-ids batch))
    (ok (map-set last-collected-block batch (get-block-height)))
  )
) 

(define-private (get-batch (id uint))
  (/ (+ id u1) u250))

(define-public (set-enabled (enabled bool))
  (begin 
    (asserts! (or (is-eq tx-sender deployer) (is-eq tx-sender (var-get admin))) (err err-not-authorized))
    (ok (var-set is-enabled enabled))
  )
)

(define-public (set-admin (new-admin principal))
  (begin 
    (asserts! (or (is-eq tx-sender deployer) (is-eq tx-sender (var-get admin))) (err err-not-authorized))
    (ok (var-set admin new-admin))
  )
)

(define-read-only (get-last-collected-block (id uint))
  (match (map-get? last-collected-block (get-batch id)) v v start-block)
)

(define-private (distribute-single-reward (id uint))
  (if (has-owner id)
    (if (is-component-eligible id)
      (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token collect (get-component-owner id) (get-outstanding-reward-for-id id))
      (begin (print (tuple (owner (get-component-owner id)) (reward "none"))) (ok true))
    )
    (begin (print (tuple (token-id id) (reward "none"))) (ok true))
  )
)

(define-read-only (has-owner (id uint))
  (is-some (unwrap! (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.slime-components-and-minions get-owner id) false))
)

(define-read-only (get-component-owner (id uint))
  (unwrap-panic (unwrap-panic (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.slime-components-and-minions get-owner id)))
)

(define-read-only (is-component-eligible (id uint))
  (and 
    (is-none (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.slime-components-and-minions get-listing-in-ustx id))
    (not (is-eq (get-component-owner id) 'SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH.byzantion-market-v7))
    (not (is-eq (get-component-owner id) 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.marketplace-v4))
  )
)

(define-read-only (get-outstanding-reward-for-id (id uint))
  (/ (* u10000 (get-sgr id) (- (get-block-height) (get-last-collected-block id))) u144)
)

(define-read-only (get-sgr (id uint))
  (unwrap-panic (contract-call? .sgr2 lookup (- id u1)))
)

(define-read-only (get-block-height)
  block-height
)