;; @contract Vault Fee
;; @version 1

(use-trait ft .sip-010-trait.sip-010-trait)


(define-constant ERR_INSUFFICIENT_BALANCE (err u111001))

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant this-contract (as-contract tx-sender))

;;-------------------------------------
;; Transfer
;;-------------------------------------

;; @desc - transfers asset to fee address
;; @param - asset: asset to transfer (sip-010-trait)
(define-public (withdraw (asset <ft>))
  (let (
    (balance (try! (contract-call? asset get-balance (as-contract tx-sender))))
    (fee-address (contract-call? .test-state-hbtc2-v1 get-fee-address))
  )
    (try! (contract-call? .test-state-hbtc2-v1 check-is-transfer-enabled))
    (asserts! (> balance u0) ERR_INSUFFICIENT_BALANCE)
    (print { action: "withdraw", user: contract-caller, data: { asset: asset, amount: balance, recipient: fee-address, balance: balance, sender: this-contract }})
    (ok (try! (as-contract (contract-call? asset transfer balance tx-sender fee-address none))))
  )
)