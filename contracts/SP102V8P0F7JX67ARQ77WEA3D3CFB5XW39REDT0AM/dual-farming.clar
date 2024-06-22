(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait sft-trait .trait-semi-fungible.semi-fungible-trait)
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-NOT-FOUND (err u1003))
(define-constant ERR-USER-ID-NOT-FOUND (err u1004))
(define-constant ONE_8 u100000000)
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-map approved-pair { token: principal, id: uint } { dual-token: principal, multiplier-in-fixed: uint, start-cycle: uint, end-cycle: uint })
(define-read-only (is-dao-or-extension)
    (ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED)))
		
(define-read-only (check-is-approved-pair (token principal) (token-id uint) (dual-token principal))
  (ok (asserts! (is-eq dual-token (get dual-token (try! (get-pair-details-or-fail token token-id)))) ERR-NOT-AUTHORIZED)))
(define-read-only (get-pair-details (token principal) (token-id uint))
  (map-get? approved-pair { token: token, id: token-id }))
(define-read-only (get-pair-details-or-fail (token principal) (token-id uint))
  (ok (unwrap! (get-pair-details token token-id) ERR-NOT-FOUND)))
(define-read-only (get-dual-token-or-fail (token principal) (token-id uint))
  (ok (get dual-token (try! (get-pair-details-or-fail token token-id)))))
(define-read-only (get-multiplier-by-cycle-or-default (token principal) (token-id uint) (target-cycle uint))
  (match (get-pair-details token token-id)
    pair-details 
		(if (and (>= target-cycle (get start-cycle pair-details)) (<= target-cycle (get end-cycle pair-details))) 
			(get multiplier-in-fixed pair-details) 
			u0)
    u0))
(define-read-only (get-multiplier-in-fixed-or-default (token principal) (token-id uint))
  (match (get-pair-details token token-id)
    pair-details (get multiplier-in-fixed pair-details)
    u0))
(define-read-only (get-start-cycle-or-default (token principal) (token-id uint))
  (match (get-pair-details token token-id)
    pair-details (get start-cycle pair-details)
    MAX_UINT))
(define-read-only (get-end-cycle-or-default (token principal) (token-id uint))
  (match (get-pair-details token token-id)
    pair-details (get end-cycle pair-details)
    MAX_UINT))
(define-public (set-dual-token-or-fail (token principal) (token-id uint) (new-dual-token principal))
  (let (
      (pair-details (try! (get-pair-details-or-fail token token-id))))
    (try! (is-dao-or-extension))
    (ok (map-set approved-pair { token: token, id: token-id } (merge pair-details { dual-token: new-dual-token })))))
(define-public (set-multiplier-in-fixed (token principal) (token-id uint) (new-multiplier-in-fixed uint))
  (let (
      (pair-details (try! (get-pair-details-or-fail token token-id))))
    (try! (is-dao-or-extension))
    (ok (map-set approved-pair { token: token, id: token-id } (merge pair-details { multiplier-in-fixed: new-multiplier-in-fixed })))))
(define-public (set-start-cycle (token principal) (token-id uint) (new-start-cycle uint))
  (let (
      (pair-details (try! (get-pair-details-or-fail token token-id))))
    (try! (is-dao-or-extension))
    (ok (map-set approved-pair { token: token, id: token-id } (merge pair-details { start-cycle: new-start-cycle })))))
(define-public (set-end-cycle (token principal) (token-id uint) (new-end-cycle uint))
  (let (
      (pair-details (try! (get-pair-details-or-fail token token-id))))
    (try! (is-dao-or-extension))
    (ok (map-set approved-pair { token: token, id: token-id } (merge pair-details { end-cycle: new-end-cycle })))))
(define-public (add-token (token principal) (token-id uint) (dual-token principal) (multiplier-in-fixed uint) (start-cycle uint) (end-cycle uint))
  (begin
    (try! (is-dao-or-extension))
    (ok (map-set approved-pair { token: token, id: token-id } { dual-token: dual-token, multiplier-in-fixed: multiplier-in-fixed, start-cycle: start-cycle, end-cycle: end-cycle }))))
(define-public (claim-staking-reward (token-trait <sft-trait>) (token-id uint) (dual-token-trait <ft-trait>) (target-cycle uint))
  (let (
      (token (contract-of token-trait))
      (dual-token (contract-of dual-token-trait))
      (sender tx-sender)
      (claimed (try! (contract-call? .alex-farming claim-staking-reward token-trait token-id target-cycle)))
      (entitled-dual (mul-down (get entitled-token claimed) (get-multiplier-by-cycle-or-default token token-id target-cycle))))
    (try! (check-is-approved-pair token token-id dual-token))
    (and (> entitled-dual u0) (as-contract (try! (contract-call? dual-token-trait transfer-fixed entitled-dual tx-sender sender none))))
    (ok { to-return: (get to-return claimed), entitled-token: (get entitled-token claimed), entitled-dual: entitled-dual })))
(define-public (claim-staking-reward-many (token <sft-trait>) (token-id uint) (dual-token <ft-trait>) (reward-cycles (list 200 uint)))
  (ok (map 
      claim-staking-reward
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
        token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
        token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
        token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
        token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
        token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
        token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
        token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
        token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
        token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
        token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id	token-id
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
      reward-cycles)))
(define-private (sum-claimed (claimed-response (response (tuple (entitled-dual uint) (entitled-token uint) (to-return uint)) uint)) (sum-so-far uint))
  (match claimed-response
    claimed (+ sum-so-far (get to-return claimed) (get entitled-token claimed))
    err sum-so-far))
(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))