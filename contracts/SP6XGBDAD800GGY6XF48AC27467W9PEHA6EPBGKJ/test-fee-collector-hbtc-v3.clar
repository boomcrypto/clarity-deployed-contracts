;; @contract Fee Collector
;; @description Collects protocol fees and transfers to fee address
;; @version 0.1

(use-trait ft .sip-010-trait.sip-010-trait)

(define-constant ERR_INSUFFICIENT_BALANCE (err u107001))

(define-constant this-contract (as-contract tx-sender))

;;-------------------------------------
;; Withdrawal
;;-------------------------------------

;; @desc - transfers asset to fee address
;; @param - asset: asset to transfer (sip-010-trait)
(define-public (withdraw (asset <ft>))
  (let (
    (asset-contract (contract-of asset))
    (balance (try! (contract-call? asset get-balance this-contract)))
    (fee-address (contract-call? .test-state-hbtc-v3 get-fee-address))
  )
    (try! (contract-call? .test-state-hbtc-v3 check-transfer-auth asset-contract))
    (asserts! (> balance u0) ERR_INSUFFICIENT_BALANCE)
    (print { action: "withdraw", user: contract-caller, data: { asset: asset, amount: balance, recipient: fee-address, sender: this-contract, balance: balance }})
    (ok (try! (as-contract (contract-call? asset transfer balance tx-sender fee-address none))))
  )
)