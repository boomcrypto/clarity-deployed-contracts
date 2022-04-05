(impl-trait .trait-ownable.ownable-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait transfer-trait .trait-transfer.transfer-trait)

;; dual-farm-pool

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-NOT-FOUND (err u1003))

(define-data-var contract-owner principal tx-sender)

(define-map approved-pair principal principal)
(define-map dual-underlying principal principal)
(define-map multiplier-in-fixed principal uint)

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
  (ok (asserts! (is-eq dual-token (unwrap! (map-get? approved-pair token) ERR-NOT-AUTHORIZED)) ERR-NOT-AUTHORIZED))
)

(define-read-only (get-multiplier-in-fixed-or-default (token principal))
  (default-to u0 (map-get? multiplier-in-fixed token))
)

(define-public (set-multiplier-in-fixed (token principal) (new-multiplier-in-fixed uint))
  (begin
    (try! (check-is-owner))
    (ok (map-set multiplier-in-fixed token new-multiplier-in-fixed))
  )
)

(define-read-only (get-dual-token-underlying (token principal))
  (begin 
    (match (map-get? approved-pair token)
      dual-token (ok (unwrap! (map-get? dual-underlying dual-token) ERR-NOT-FOUND))
      ERR-NOT-FOUND
    )
  )
)

;; @desc add-token 
;; @params token
;; @returns (response bool)
(define-public (add-token (token principal) (dual-token principal) (underlying-token principal))
  (begin
    (try! (check-is-owner))
    (map-set approved-pair token dual-token)
    (map-set dual-underlying dual-token underlying-token)
    (contract-call? .alex-reserve-pool add-token token)
  )
)

;; STAKING REWARD CLAIMS

;; calls function to claim staking reward in active logic contract
;; @desc claim-staking-reward
;; @params token-trait; ft-trait
;; @params target-cycle
;; @returns (response tuple)
(define-private (claim-staking-reward-by-tx-sender (token-trait <ft-trait>) (dual-token-trait <transfer-trait>) (target-cycle uint))
  (let
    (
      (token (contract-of token-trait))
      (dual-token (contract-of dual-token-trait))
      (sender tx-sender)
      (claimed (try! (contract-call? .alex-reserve-pool claim-staking-reward token-trait target-cycle)))
      (entitled-dual (mul-down (get entitled-token claimed) (get-multiplier-in-fixed-or-default token)))
    )
    (try! (check-is-approved-pair token dual-token))
    (and 
      (> entitled-dual u0)
      (as-contract (try! (contract-call? dual-token-trait transfer-fixed entitled-dual tx-sender sender)))
    )
    (ok { to-return: (get to-return claimed), entitled-token: (get entitled-token claimed), entitled-dual: entitled-dual })
  )
)

(define-public (claim-staking-reward (token <ft-trait>) (dual-token <transfer-trait>) (reward-cycles (list 20 uint)))
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

;; @desc mul-down
;; @params a
;; @params b
;; @returns uint
(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)

;; contract initialisation
(set-contract-owner .executor-dao)
