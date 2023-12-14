;; Title: pyth-oracle
;; Version: v1
;; Check for latest version: https://github.com/hirosystems/stacks-pyth-bridge#latest-version
;; Report an issue: https://github.com/hirosystems/stacks-pyth-bridge/issues

(use-trait pyth-storage-trait .pyth-traits-v1.storage-trait)
(use-trait pyth-decoder-trait .pyth-traits-v1.decoder-trait)
(use-trait wormhole-core-trait .wormhole-traits-v1.core-trait)

;; Generic error
(define-constant ERR_PANIC (err u0))
;; Balance insufficient for handling fee
(define-constant ERR_BALANCE_INSUFFICIENT (err u402))

(define-public (read-price-feed 
    (price-feed-id (buff 32))
    (pyth-storage-address <pyth-storage-trait>))
  (begin
    ;; Check execution flow
    (try! (contract-call? .pyth-governance-v1 check-storage-contract pyth-storage-address))
    ;; Perform contract-call
    (contract-call? pyth-storage-address read price-feed-id)))

(define-public (verify-and-update-price-feeds 
    (price-feed-bytes (buff 8192))
    (execution-plan {
      pyth-storage-contract: <pyth-storage-trait>,
      pyth-decoder-contract: <pyth-decoder-trait>,
      wormhole-core-contract: <wormhole-core-trait>
    }))
  (begin
    ;; Check execution flow
    (try! (contract-call? .pyth-governance-v1 check-execution-flow contract-caller (some execution-plan)))
    ;; Perform contract-call
    (let ((pyth-decoder-contract (get pyth-decoder-contract execution-plan))
          (wormhole-core-contract (get wormhole-core-contract execution-plan))
          (pyth-storage-contract (get pyth-storage-contract execution-plan))
          (decoded-prices (try! (contract-call? pyth-decoder-contract decode-and-verify-price-feeds price-feed-bytes wormhole-core-contract)))
          (updated-prices (try! (contract-call? pyth-storage-contract write decoded-prices)))
          (fee-info (contract-call? .pyth-governance-v1 get-fee-info))
          (fee-amount (* (len updated-prices) (* (get mantissa fee-info) (pow u10 (get exponent fee-info))))))
      ;; Charge fee
      (unwrap! (stx-transfer? fee-amount tx-sender (get address fee-info)) ERR_BALANCE_INSUFFICIENT)
      (ok updated-prices))))
