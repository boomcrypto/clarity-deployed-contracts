;; @contract Vault Reserve
;; @version 1

(use-trait ft .sip-010-trait.sip-010-trait)

(define-constant ERR_INSUFFICIENT_BALANCE (err u107001))

;;-------------------------------------
;; Transfer
;;-------------------------------------

;; @desc - transfers asset to recipient
;; @param - asset: asset to transfer (sip-010-trait)
;; @param - amount: amount of asset to transfer (10**8)
;; @param - recipient: recipient of the asset
(define-public (transfer (asset <ft>) (amount uint) (recipient principal))
  (let (
    (balance (try! (contract-call? asset get-balance (as-contract tx-sender))))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-protocol contract-caller))
    (try! (contract-call? .test-hq-vaults-v1 check-is-protocol recipient))
    (try! (contract-call? .test-state-hbtc-v1 check-is-transfer-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-asset (contract-of asset)))
    (asserts! (>= balance amount) ERR_INSUFFICIENT_BALANCE)
    (print { action: "transfer", user: contract-caller, contract: .test-reserve-hbtc-v1, data: { asset: asset, amount: amount, recipient: recipient, balance: balance }})
    (ok (try! (as-contract (contract-call? asset transfer amount tx-sender recipient none))))
  )
)