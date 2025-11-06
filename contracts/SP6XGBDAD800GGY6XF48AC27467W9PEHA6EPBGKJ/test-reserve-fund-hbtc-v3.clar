;; @contract Reserve Fund
;; @version 0.1
;; @description Reserve fund contract to cover negative rewards

(use-trait ft .sip-010-trait.sip-010-trait)

(define-constant ERR_INSUFFICIENT_BALANCE (err u106001))
(define-constant this-contract (as-contract tx-sender))

;;-------------------------------------
;; Transfer
;;-------------------------------------

;; @desc - transfers asset from reserve fund to recipient
;; @param - asset: asset to transfer (sip-010-trait)
;; @param - amount: amount of asset to transfer (10**8)
;; @param - recipient: recipient of the asset
;; @param - memo: optional memo for the transfer
(define-public (transfer (asset <ft>) (amount uint) (recipient principal) (memo (optional (buff 34))))
  (let (
    (balance (try! (contract-call? asset get-balance this-contract)))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-protocol contract-caller))
    (asserts! (>= balance amount) ERR_INSUFFICIENT_BALANCE)
    (print { action: "transfer", user: contract-caller, data: { asset: asset, amount: amount, recipient: recipient, sender: this-contract, balance: balance }})
    (ok (try! (as-contract (contract-call? asset transfer amount tx-sender recipient memo))))
  )
)