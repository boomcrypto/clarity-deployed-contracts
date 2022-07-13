(define-constant deployer tx-sender)

(define-constant err-not-authorized u403)

(define-data-var last-collected-block uint block-height)
(define-data-var is-enabled bool true)
(define-data-var admin principal tx-sender)

(define-public (distribute)
  (begin 
    (asserts! (or (is-eq tx-sender deployer) (is-eq tx-sender (var-get admin))) (err err-not-authorized))
    (asserts! (var-get is-enabled) (err err-not-authorized))
    (map distribute-single-reward (map to-uint (contract-call? .range range 1 2500)))
    (ok (var-set last-collected-block (get-block-height)))
  )
) 

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

(define-read-only (get-last-collected-block)
  (var-get last-collected-block)
)

(define-private (distribute-single-reward (id uint))
  (begin 
    (if (is-component-eligible id)
;;    (contract-call? .slime collect (get-component-owner id) (get-outstanding-reward-for-id id))
      (begin (print (tuple (owner (get-component-owner id)) (reward (get-outstanding-reward-for-id id)))) (ok true))
      (begin (print (tuple (owner (get-component-owner id)) (reward "none"))) (ok true))
    )
  )
)

(define-read-only (get-component-owner (id uint))
  (unwrap-panic (unwrap-panic (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.slime-components-and-minions get-owner id)))
)

(define-read-only (is-component-eligible (id uint))
  (is-none (contract-call? 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.slime-components-and-minions get-listing-in-ustx id))
)

(define-read-only (get-outstanding-reward-for-id (id uint))
  (* (get-sgr id) (- (get-block-height) (var-get last-collected-block)))
)

(define-read-only (get-sgr (id uint))
  (unwrap-panic (contract-call? .sgr-test lookup id))
)

(define-read-only (get-block-height)
  block-height
)