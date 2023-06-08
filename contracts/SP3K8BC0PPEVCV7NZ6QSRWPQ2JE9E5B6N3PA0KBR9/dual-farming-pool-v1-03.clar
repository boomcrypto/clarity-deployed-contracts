(impl-trait .trait-ownable.ownable-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-NOT-FOUND (err u1003))
(define-constant ERR-USER-ID-NOT-FOUND (err u1004))
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-data-var contract-owner principal tx-sender)
(define-map approved-pair 
  principal
  {
    dual-token: principal,
    multiplier-in-fixed: uint,
    start-cycle: uint
  }
)
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    (ok (var-set contract-owner owner))
  )
)
(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)
(define-private (check-is-approved-pair (token principal) (dual-token principal))
  (ok (asserts! (is-eq dual-token (get dual-token (try! (get-pair-details-or-fail token)))) ERR-NOT-AUTHORIZED))
)
(define-read-only (get-pair-details (token principal))
  (map-get? approved-pair token)
)
(define-read-only (get-pair-details-or-fail (token principal))
  (ok (unwrap! (get-pair-details token) ERR-NOT-FOUND))
)
(define-read-only (get-dual-token-or-fail (token principal))
  (ok (get dual-token (try! (get-pair-details-or-fail token))))
)
(define-public (set-dual-token-or-fail (token principal) (new-dual-token principal))
  (let 
    (
      (pair-details (try! (get-pair-details-or-fail token)))
    )
    (try! (check-is-owner))
    (ok (map-set approved-pair token (merge pair-details { dual-token: new-dual-token })))
  )
)
(define-read-only (get-multiplier-by-cycle-or-default (token principal) (target-cycle uint))
  (match (get-pair-details token)
    pair-details
    (if (< target-cycle (get start-cycle pair-details)) u0 (get multiplier-in-fixed pair-details))
    u0
  )
)
(define-read-only (get-multiplier-in-fixed-or-default (token principal))
  (match (get-pair-details token)
    pair-details
    (get multiplier-in-fixed pair-details)
    u0
  )
)
(define-public (set-multiplier-in-fixed (token principal) (new-multiplier-in-fixed uint))
  (let 
    (
      (pair-details (try! (get-pair-details-or-fail token)))
    )
    (try! (check-is-owner))
    (ok (map-set approved-pair token (merge pair-details { multiplier-in-fixed: new-multiplier-in-fixed })))
  )
)
(define-read-only (get-start-cycle-or-default (token principal))
  (match (get-pair-details token)
    pair-details
    (get start-cycle pair-details)
    MAX_UINT
  )
)
(define-public (set-start-cycle (token principal) (new-start-cycle uint))
  (let 
    (
      (pair-details (try! (get-pair-details-or-fail token)))
    )
    (try! (check-is-owner))
    (ok (map-set approved-pair token (merge pair-details { start-cycle: new-start-cycle })))
  )
)
(define-public (add-token (token principal) (dual-token principal) (multiplier-in-fixed uint) (start-cycle uint))
  (begin
    (try! (check-is-owner))
    (ok (map-set approved-pair token { dual-token: dual-token, multiplier-in-fixed: multiplier-in-fixed, start-cycle: start-cycle }))
  )
)
(define-public (claim-staking-reward-by-tx-sender (token-trait <ft-trait>) (dual-token-trait <ft-trait>) (target-cycle uint))
  (let
    (
      (token (contract-of token-trait))
      (dual-token (contract-of dual-token-trait))
      (sender tx-sender)
      (claimed (try! (contract-call? .alex-reserve-pool claim-staking-reward token-trait target-cycle)))
      (entitled-dual (mul-down (get entitled-token claimed) (get-multiplier-by-cycle-or-default token target-cycle)))
    )
    (try! (check-is-approved-pair token dual-token))
    (and 
      (> entitled-dual u0)
      (as-contract (try! (contract-call? dual-token-trait transfer-fixed entitled-dual tx-sender sender none)))
    )
    (ok { to-return: (get to-return claimed), entitled-token: (get entitled-token claimed), entitled-dual: entitled-dual })
  )
)
(define-public (claim-staking-reward-by-auto-alex (dual-token-trait <ft-trait>) (target-cycle uint))
  (let 
    (
      (dual-token (contract-of dual-token-trait))
      (user-id (unwrap! (contract-call? .alex-reserve-pool get-user-id .age000-governance-token .auto-alex-v2) ERR-USER-ID-NOT-FOUND))
      (entitled-token (contract-call? .alex-reserve-pool get-staking-reward .age000-governance-token user-id target-cycle))
      (entitled-dual (mul-down entitled-token (get-multiplier-by-cycle-or-default .age000-governance-token target-cycle)))
    )
    (try! (check-is-approved-pair .age000-governance-token dual-token))
    (try! (contract-call? .auto-alex-v2 claim-and-stake target-cycle))
    (and 
      (> entitled-dual u0)
      (as-contract (try! (contract-call? dual-token-trait transfer-fixed entitled-dual tx-sender .auto-alex-v2 none)))
    )
    (ok { to-return: u0, entitled-token: entitled-token, entitled-dual: entitled-dual })
  )
)
(define-public (claim-and-mint-auto-alex (dual-token-trait <ft-trait>) (reward-cycles (list 200 uint)))
  (let 
    (
      (claimed (unwrap-panic (claim-staking-reward .age000-governance-token dual-token-trait reward-cycles)))
    )
    (try! (contract-call? .auto-alex-v2 add-to-position (fold sum-claimed claimed u0)))
    (ok claimed)
  )
)
(define-public (claim-staking-reward (token <ft-trait>) (dual-token <ft-trait>) (reward-cycles (list 200 uint)))
  (ok 
    (map 
      claim-staking-reward-by-tx-sender 
      (list 
        token token token token token token token token token token token token token token token token token token token token
        token token token token token token token token token token token token token token token token token token token token
        token token token token token token token token token token token token token token token token token token token token
        token token token token token token token token token token token token token token token token token token token token
        token token token token token token token token token token token token token token token token token token token token
        token token token token token token token token token token token token token token token token token token token token
        token token token token token token token token token token token token token token token token token token token token
        token token token token token token token token token token token token token token token token token token token token
        token token token token token token token token token token token token token token token token token token token token
        token token token token token token token token token token token token token token token token token token token token
      ) 
      (list 
        dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token
        dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token
        dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token
        dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token
        dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token
        dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token
        dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token
        dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token
        dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token
        dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token dual-token        
      )       
      reward-cycles      
    )
  )
)
(define-constant ONE_8 u100000000)
(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)
(define-private (sum-claimed (claimed-response (response (tuple (entitled-dual uint) (entitled-token uint) (to-return uint)) uint)) (sum-so-far uint))
  (match claimed-response
    claimed (+ sum-so-far (get to-return claimed) (get entitled-token claimed))
    err sum-so-far
  )
)