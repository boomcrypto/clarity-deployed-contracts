;; TRAITS
(use-trait callback-trait .trait-flash-loan-v1.flash-loan)

;; CONSTANTS
(define-constant SUCCESS (ok true))
;; Fee of 0.01% for processing flash loan scaled to 10^8
(define-constant fee u10000)
;; Maximum fee percentage
(define-constant max-fee u100000000)


;; Errors
(define-constant ERR_CONTRACT_NOT_ALLOWED (err u110000))
(define-constant ERR_RESTRICTED_TO_TESTNET (err u110001))


;; Data vars
;; List of allowed contracts that are called back during the flash loan
(define-map allowed-contracts principal bool)

;; Read only functions

(define-read-only (get-fee)
  fee
)

(define-read-only (is-contract-allowed (contract principal))
  (default-to false (map-get? allowed-contracts contract))
)

;; Public functions

(define-public (set-allowed-contract (contract principal))
  (begin
    (asserts! (not is-in-mainnet) ERR_RESTRICTED_TO_TESTNET)
    (map-set allowed-contracts contract true)
    SUCCESS
))

(define-public (flash-loan (amount uint) (callback <callback-trait>) (data (optional (buff 20480))))
  (let (
      (flash-loan-fee (contract-call? .math-v1 divide-round-up (* amount fee) max-fee))
      (caller contract-caller)
      (callback-contract (contract-of callback))
    )
    (asserts! (default-to false (map-get? allowed-contracts callback-contract)) ERR_CONTRACT_NOT_ALLOWED)
    ;; transfer funds to user
    (try! (contract-call? .state-v1 transfer-to 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc caller amount))
    (try! (contract-call? callback on-granite-flash-loan amount flash-loan-fee data))
    (try! (contract-call? .state-v1 transfer-from 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc caller amount))
    (try! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer flash-loan-fee caller .governance-v1 none))
    (print {
      action: "flash-loan",
      amount: amount,
      fee: flash-loan-fee,
      caller: caller,
      contract: callback-contract
    })
    SUCCESS
  )
)
