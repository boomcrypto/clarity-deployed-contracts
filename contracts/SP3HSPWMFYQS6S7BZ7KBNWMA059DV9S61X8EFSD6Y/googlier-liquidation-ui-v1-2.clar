;; Liquidation pool helpers for UI

(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)
(use-trait liquidation-pool-trait .googlier-liquidation-pool-trait-v1.liquidation-pool-trait)

;; ---------------------------------------------------------
;; Fetch
;; ---------------------------------------------------------

;; Combine pending user rewards + reward data
(define-public (get-user-reward-info (reward-id uint))
  (let (
    (sender-rewards (unwrap-panic (contract-call? .googlier-liquidation-rewards-v1-1 get-rewards-of tx-sender reward-id .googlier-liquidation-pool-v1-1)))
    (rewards-data (contract-call? .googlier-liquidation-rewards-v1-1 get-reward-data reward-id))
  )
    (ok {
      reward-id: reward-id,
      pending-rewards: sender-rewards,
      token: (get token rewards-data),
      token-is-stx: (get token-is-stx rewards-data)
    })
  )
)

;; ---------------------------------------------------------
;; Claim
;; ---------------------------------------------------------

(define-public (claim-10-stx-rewards-of (reward-ids (list 10 uint)))
  (begin
    (map claim-stx-rewards-of reward-ids)
    (ok true)
  )
)

(define-public (claim-25-stx-rewards-of (reward-ids (list 25 uint)))
  (begin
    (map claim-stx-rewards-of reward-ids)
    (ok true)
  )
)

(define-public (claim-50-stx-rewards-of (reward-ids (list 50 uint)))
  (begin
    (map claim-stx-rewards-of reward-ids)
    (ok true)
  )
)

(define-public (claim-10-gglr-rewards-of (reward-ids (list 10 uint)))
  (begin
    (map claim-gglr-rewards-of reward-ids)
    (ok true)
  )
)

(define-public (claim-25-gglr-rewards-of (reward-ids (list 25 uint)))
  (begin
    (map claim-gglr-rewards-of reward-ids)
    (ok true)
  )
)

(define-public (claim-50-gglr-rewards-of (reward-ids (list 50 uint)))
  (begin
    (map claim-gglr-rewards-of reward-ids)
    (ok true)
  )
)

(define-public (claim-10-xbtc-rewards-of (reward-ids (list 10 uint)))
  (begin
    (map claim-xbtc-rewards-of reward-ids)
    (ok true)
  )
)

(define-public (claim-25-xbtc-rewards-of (reward-ids (list 25 uint)))
  (begin
    (map claim-xbtc-rewards-of reward-ids)
    (ok true)
  )
)

(define-public (claim-50-xbtc-rewards-of (reward-ids (list 50 uint)))
  (begin
    (map claim-xbtc-rewards-of reward-ids)
    (ok true)
  )
)

;; ---------------------------------------------------------
;; Claim helpers
;; ---------------------------------------------------------

(define-public (claim-stx-rewards-of (reward-id uint))
  (contract-call? .googlier-liquidation-rewards-v1-1 claim-rewards-of reward-id .xstx-token .googlier-liquidation-pool-v1-1)
)

(define-public (claim-gglr-rewards-of (reward-id uint))
  (contract-call? .googlier-liquidation-rewards-v1-1 claim-rewards-of reward-id .googlier-token .googlier-liquidation-pool-v1-1)
)

(define-public (claim-xbtc-rewards-of (reward-id uint))
  ;; TODO - UPDATE ADDRESS FOR MAINNET
  (contract-call? .googlier-liquidation-rewards-v1-1 claim-rewards-of reward-id 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.Wrapped-Bitcoin .googlier-liquidation-pool-v1-1)
)
