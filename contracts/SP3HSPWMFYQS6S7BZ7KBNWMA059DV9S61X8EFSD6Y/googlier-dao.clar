(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)
(use-trait dao-token-trait .googlier-dao-token-trait-v1.dao-token-trait)

;; googlier DAO 
;; 
;; Keep contracts used in protocol. 
;; Emergency switch to shut down protocol.


;; Errors
(define-constant ERR-NOT-AUTHORIZED u100401)

;; Contract addresses
(define-map contracts
  { name: (string-ascii 256) }
  {
    address: principal, ;; e.g. 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y
    qualified-name: principal ;; e.g. 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.freddie
  }
)
(define-map contracts-data
  { qualified-name: principal }
  {
    can-mint: bool,
    can-burn: bool
  }
)

;; Variables
(define-data-var emergency-shutdown-activated bool false)
(define-data-var dao-owner principal tx-sender)
(define-data-var payout-address principal (var-get dao-owner)) ;; to which address the foundation is paid
(define-data-var guardian principal (var-get dao-owner)) ;; guardian that can be set

(define-read-only (get-dao-owner)
  (var-get dao-owner)
)

(define-read-only (get-payout-address)
  (var-get payout-address)
)

(define-public (set-dao-owner (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get dao-owner)) (err ERR-NOT-AUTHORIZED))

    (ok (var-set dao-owner address))
  )
)

(define-public (set-payout-address (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get dao-owner)) (err ERR-NOT-AUTHORIZED))

    (ok (var-set payout-address address))
  )
)

(define-read-only (get-guardian-address)
  (var-get guardian)
)

(define-public (set-guardian-address (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get guardian)) (err ERR-NOT-AUTHORIZED))

    (ok (var-set guardian address))
  )
)

(define-public (toggle-emergency-shutdown)
  (begin
    (asserts! (is-eq tx-sender (var-get guardian)) (err ERR-NOT-AUTHORIZED))

    (ok (var-set emergency-shutdown-activated (not (var-get emergency-shutdown-activated))))
  )
)

(define-read-only (get-emergency-shutdown-activated)
  (ok (var-get emergency-shutdown-activated))
)

;; Get contract address
(define-read-only (get-contract-address-by-name (name (string-ascii 256)))
  (get address (map-get? contracts { name: name }))
)

;; Get contract qualified name
(define-read-only (get-qualified-name-by-name (name (string-ascii 256)))
  (get qualified-name (map-get? contracts { name: name }))
)

;; Check if contract can mint
(define-read-only (get-contract-can-mint-by-qualified-name (qualified-name principal))
  (default-to 
    false
    (get can-mint (map-get? contracts-data { qualified-name: qualified-name }))
  )
)

;; Check if contract can burn
(define-read-only (get-contract-can-burn-by-qualified-name (qualified-name principal))
  (default-to 
    false
    (get can-burn (map-get? contracts-data { qualified-name: qualified-name }))
  )
)

;; Governance contract can setup DAO contracts
(define-public (set-contract-address (name (string-ascii 256)) (address principal) (qualified-name principal) (can-mint bool) (can-burn bool))
  (let (
    (current-contract (map-get? contracts { name: name }))
  )
    (begin
      (asserts! (is-eq (unwrap-panic (get-qualified-name-by-name "governance")) contract-caller) (err ERR-NOT-AUTHORIZED))

      (map-set contracts { name: name } { address: address, qualified-name: qualified-name })
      (if (is-some current-contract)
        (map-set contracts-data { qualified-name: (unwrap-panic (get qualified-name current-contract)) } { can-mint: false, can-burn: false })
        false
      )
      (map-set contracts-data { qualified-name: qualified-name } { can-mint: can-mint, can-burn: can-burn })
      (ok true)
    )
  )
)

;; ---------------------------------------------------------
;; Protocol tokens
;; ---------------------------------------------------------

;; Mint protocol tokens
(define-public (mint-token (token <dao-token-trait>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq (get-contract-can-mint-by-qualified-name contract-caller) true) (err ERR-NOT-AUTHORIZED))
    (print { type: "token", action: "minted", data: { amount: amount, recipient: recipient } })
    (contract-call? token mint-for-dao amount recipient)
  )
)

;; Burn protocol tokens
(define-public (burn-token (token <dao-token-trait>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq (get-contract-can-burn-by-qualified-name contract-caller) true) (err ERR-NOT-AUTHORIZED))
    (print { type: "token", action: "burned", data: { amount: amount, recipient: recipient } })
    (contract-call? token burn-for-dao amount recipient)
  )
)

;; This method is called by the auction engine when more bad debt needs to be burned
;; but the vault collateral is not sufficient
;; As a result, additional gglr will be minted to cover bad debt
(define-public (request-gglr-tokens (collateral-amount uint))
  (begin
    (asserts! (is-eq (unwrap-panic (get-qualified-name-by-name "auction-engine")) contract-caller) (err ERR-NOT-AUTHORIZED))

    (contract-call? .googlier-token mint-for-dao collateral-amount (as-contract (unwrap-panic (get-qualified-name-by-name "sip10-reserve"))))
  )
)


;; ---------------------------------------------------------
;; Contract initialisation
;; ---------------------------------------------------------

;; Initialize the contract
(begin
  ;; Add initial contracts
  (map-set contracts
    { name: "freddie" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-freddie-v1-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-freddie-v1-1 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "auction-engine" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-auction-engine-v4-3
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-auction-engine-v4-3 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "oracle" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-oracle-v1-1
    }
  )
  (map-set contracts
    { name: "collateral-types" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-collateral-types-v3-1
    }
  )
  (map-set contracts
    { name: "governance" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-governance-v4-1
    }
  )
  (map-set contracts
    { name: "stake-registry" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stake-registry-v1-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stake-registry-v1-1 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "stake-pool-gglr" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stake-pool-gglr-v1-2
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stake-pool-gglr-v1-2 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "stake-pool-gglr-USD" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stake-pool-gglr-USD-v1-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stake-pool-gglr-USD-v1-1 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "stake-pool-wstx-USD" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stake-pool-wstx-USD-v1-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stake-pool-wstx-USD-v1-1 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "stake-pool-wstx-gglr" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stake-pool-wstx-gglr-v1-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stake-pool-wstx-gglr-v1-1 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "stacker" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stacker-v1-1
    }
  )
  (map-set contracts
    { name: "stacker-2" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stacker-2-v1-1
    }
  )
  (map-set contracts
    { name: "stacker-3" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stacker-3-v1-1
    }
  )
  (map-set contracts
    { name: "stacker-4" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stacker-4-v1-1
    }
  )

  (map-set contracts
    { name: "stacker-payer" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stacker-payer-v3-3
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stacker-payer-v3-3 }
    {
      can-mint: false,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "stx-reserve" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stx-reserve-v1-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-stx-reserve-v1-1 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "sip10-reserve-v1-1" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-sip10-reserve-v1-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-sip10-reserve-v1-1 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "sip10-reserve" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-sip10-reserve-v2-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-sip10-reserve-v2-1 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "gglr-guardian" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-gglr-guardian-v1-1
    }
  )

  (map-set contracts
    { name: "gglr-init" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-gglr-init
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-gglr-init }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "vault-rewards" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-vault-rewards-v1-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-vault-rewards-v1-1 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "swap" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-swap-v2-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-swap-v2-1 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "liquidator" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-auction-engine-v4-3
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-auction-engine-v4-3 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "liquidation-rewards-gglr" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-liquidation-rewards-gglr-v1-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-liquidation-rewards-gglr-v1-1 }
    {
      can-mint: true,
      can-burn: true
    }
  )

  (map-set contracts
    { name: "liquidation-rewards" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-liquidation-rewards-v1-2
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-liquidation-rewards-v1-2 }
    {
      can-mint: false,
      can-burn: false
    }
  )

    (map-set contracts
    { name: "liquidation-pool" }
    {
      address: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y,
      qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-liquidation-pool-v1-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y.googlier-liquidation-pool-v1-1 }
    {
      can-mint: false,
      can-burn: false
    }
  )
)
