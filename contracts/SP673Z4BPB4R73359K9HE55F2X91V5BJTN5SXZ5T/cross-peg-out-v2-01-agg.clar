;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.extension-trait.extension-trait)

(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-PAUSED (err u1015))
(define-constant ERR-USER-NOT-WHITELISTED (err u1016))
(define-constant ERR-AMOUNT-LESS-THAN-MIN-FEE (err u1017))
(define-constant ERR-INVALID-AMOUNT (err u1019))

(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-data-var is-paused bool true)

;; public calls

(define-public (transfer-to-swap (amount-in-fixed uint) (token-in-trait <ft-trait>) (token-out principal) (min-amount-out (optional uint)) (dest-chain-id uint) (settle-details { address: (buff 256), chain-id: (optional uint) }))
  (let (
      (sender tx-sender)
      (token-in (contract-of token-in-trait))
      (validation-data (try! (validate-transfer-to-swap sender amount-in-fixed token-in token-out dest-chain-id)))
      (chain-details (get chain-details validation-data))
      (token-in-details (get token-in-details validation-data))
      (token-out-details (get token-out-details validation-data))
      (fee (max (mul-down amount-in-fixed (get fee token-in-details)) (get-min-fee-or-default { token: token-in, chain-id: dest-chain-id })))
      (net-amount (- amount-in-fixed fee)))
    (if (get burnable token-in-details)
      (begin
        (as-contract (try! (contract-call? token-in-trait burn-fixed net-amount sender)))
        (and (> fee u0) (try! (contract-call? token-in-trait transfer-fixed fee sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 none))))
      (try! (contract-call? token-in-trait transfer-fixed amount-in-fixed sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 none)))
    (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-accrued-fee token-in fee)))
    (as-contract (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 remove-token-reserve { token: token-in, chain-id: dest-chain-id } amount-in-fixed)))
    (print { object: "cross-bridge-endpoint", action: "transfer-to-swap", user: sender, chain: (get name chain-details), dest-chain-id: dest-chain-id, net-amount: net-amount, fee-amount: fee, settle-details: settle-details, token-in: token-in, token-out: token-out, min-amount-out: min-amount-out })
    (ok true)))

;; read-only calls

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED)))

(define-read-only (validate-transfer-to-swap (sender principal) (amount-in-fixed uint) (token-in principal) (token-out principal) (dest-chain-id uint))
  (let (
      (chain-details (try! (get-approved-chain-or-fail dest-chain-id)))
      (token-in-details (try! (get-approved-pair-or-fail { token: token-in, chain-id: dest-chain-id })))
      (token-out-details (try! (get-approved-pair-or-fail { token: token-out, chain-id: dest-chain-id }))))
    (asserts! (not (get-paused)) ERR-PAUSED)
    (asserts! (and (>= amount-in-fixed (get min-amount token-in-details)) (<= amount-in-fixed (get max-amount token-in-details)) (<= amount-in-fixed (get-token-reserve-or-default { token: token-in, chain-id: dest-chain-id }))) ERR-INVALID-AMOUNT)
    (asserts! (> amount-in-fixed (get-min-fee-or-default { token: token-in, chain-id: dest-chain-id })) ERR-AMOUNT-LESS-THAN-MIN-FEE)
    (ok { amount: amount-in-fixed, chain-details: chain-details, token-in: token-in, token-out: token-out, token-in-details: token-in-details, token-out-details: token-out-details })))

(define-read-only (get-paused)
  (var-get is-paused))

(define-read-only (get-approved-chain-or-fail (dest-chain-id uint))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-chain-or-fail dest-chain-id))

(define-read-only (get-token-reserve-or-default (pair { token: principal, chain-id: uint }))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default pair))

(define-read-only (get-min-fee-or-default (pair { token: principal, chain-id: uint }))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-min-fee-or-default pair))

(define-read-only (get-approved-pair-or-fail (pair { token: principal, chain-id: uint }))
  (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail pair))

;; governance calls

(define-public (set-paused (paused bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set is-paused paused))))

;; internal functions

(define-private (mul-down (a uint) (b uint))
  (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (max (a uint) (b uint))
  (if (<= a b) b a))

(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true))