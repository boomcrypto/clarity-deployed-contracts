;; SPDX-License-Identifier: BUSL-1.1

;; TRAITS
(use-trait callback-trait .trait-flash-loan-v1.flash-loan)

;; CONSTANTS
(define-constant SUCCESS (ok true))
;; Maximum fee percentage
(define-constant max-fee u100000000)


;; Errors
(define-constant ERR_CONTRACT_NOT_ALLOWED (err u110000))
(define-constant ERR-NOT-AUTHORIZED (err u110001))
(define-constant ERR-INVALID-FEE (err u110002))


;; Data vars
;; List of allowed contracts that are called back during the flash loan
(define-map allowed-contracts principal bool)
;; Flag to allow any contract to use flash loan
(define-data-var allow-any bool false)
;; Fee of 0.01% for processing flash loan scaled to 10^8
(define-data-var fee uint u10000)

;; Read only functions

(define-read-only (get-fee) (var-get fee))

(define-read-only (is-contract-allowed (contract principal))
  (if (var-get allow-any) true (default-to false (map-get? allowed-contracts contract)))
)

;; Public functions

(define-public (set-allowed-contract (contract principal))
  (begin
    (asserts! (is-governance) ERR-NOT-AUTHORIZED)
    (map-set allowed-contracts contract true)
    (print {
      action: "set-allowed-contract",
      contract: contract
    })
    SUCCESS
))

(define-public (remove-allowed-contract (contract principal))
  (begin
    (asserts! (is-governance) ERR-NOT-AUTHORIZED)
    (map-delete allowed-contracts contract)
    (print {
      action: "remove-allowed-contract",
      contract: contract
    })
    SUCCESS
))

(define-public (update-fee (new-fee uint))
  (begin
    (asserts! (is-governance) ERR-NOT-AUTHORIZED)
    (asserts! (<= new-fee max-fee) ERR-INVALID-FEE)
    (print {
      action: "update-fee",
      old-value: (var-get fee),
      new-value: new-fee,
    })
    (var-set fee new-fee)
    SUCCESS
))

(define-public (update-allow-any-contract (value bool))
  (begin
    (asserts! (is-governance) ERR-NOT-AUTHORIZED)
    (print {
      action: "update-allow-any-contract",
      old-value: (var-get allow-any),
      new-value: value,
    })
    (var-set allow-any value)
    SUCCESS
))

(define-public (flash-loan (amount uint) (callback <callback-trait>) (data (optional (buff 20480))))
  (let (
      (flash-loan-fee (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.math-v1 divide-round-up (* amount (var-get fee)) max-fee))
      (caller contract-caller)
      (callback-contract (contract-of callback))
    )
    (asserts! (is-contract-allowed callback-contract) ERR_CONTRACT_NOT_ALLOWED)
    ;; transfer funds to user
    (try! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 transfer-to 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc caller amount))
    (try! (contract-call? callback on-granite-flash-loan amount flash-loan-fee data))
    (try! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 transfer-from 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc caller amount))
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

;; private functions


(define-private (is-governance)
  (is-eq (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-governance) contract-caller)
)

(map-set allowed-contracts 'SPEP08Q2GWNA8MTCT6QHYMRSV30BD9YMXP99WZNC.liquidator true)
(map-set allowed-contracts 'SP15GZK5ZXX3B9FBKDM5JE2M7KVKMC8ZW8E6NQYG2.liquidator true)