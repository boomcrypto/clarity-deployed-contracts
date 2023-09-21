;; Title: DME017 Quest Helper
;; Author: rozar.btc
;; Synopsis:
;; A utility contract to manage and control various aspects of quests including STX quest funding.
;; Description:
;; The Quest Helper is a comprehensive tool that allows users to update quest expiration, activation, maximum completion, and STX rewards. 
;; Notably, it provides a mechanism for managing STX quest funding.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-not-found (err u2001))
(define-constant err-unauthorized (err u3100))
(define-constant err-reward-too-low (err u3101))

;; --- Authorization checks

(define-read-only (is-owner (quest-id uint))
    (contract-call? .dme016-quest-ownership is-owner quest-id)
)

;; --- Quest Owner functions

(define-public (set-quest-metadata (quest-id uint) (metadata-uri (optional (string-utf8 256))))
    (begin
        (unwrap! (is-owner quest-id) err-unauthorized)
        (contract-call? .dme008-quest-metadata set-metadata quest-id metadata-uri)
    )
)

(define-public (set-quest-expiration (quest-id uint) (block uint))
    (begin
        (unwrap! (is-owner quest-id) err-unauthorized)
        (contract-call? .dme011-quest-expiration set-expiration quest-id block)
    )
)

(define-public (set-quest-activation (quest-id uint) (block uint))
    (begin
        (unwrap! (is-owner quest-id) err-unauthorized)
        (contract-call? .dme012-quest-activation set-activation quest-id block)
    )
)

(define-public (set-quest-max-completion (quest-id uint) (max-completions uint))
    (begin
        (unwrap! (is-owner quest-id) err-unauthorized)
        (contract-call? .dme013-quest-max-completions set-max-completions quest-id max-completions)
    )
)

(define-public (set-quest-stx-rewards (quest-id uint) (amount uint))
    (begin
        (unwrap! (is-owner quest-id) err-unauthorized)
        (asserts! (>= amount u500) err-reward-too-low)
        (contract-call? .dme014-stx-rewards set-rewards quest-id amount)
    )
)

(define-public (deposit-quest-rewards (quest-id uint))
    (let (
        (stx-rewards (unwrap! (contract-call? .dme014-stx-rewards get-rewards quest-id) err-not-found))
        (max-completions (unwrap! (contract-call? .dme013-quest-max-completions get-max-completions quest-id) err-not-found))
        (fee-percentage (unwrap! (contract-call? .dme014-stx-rewards get-fee-percentage) err-not-found))
        (rewards-amount (* stx-rewards max-completions))
        (fee-amount (/ (* rewards-amount fee-percentage) u100))
        (total-amount (+ rewards-amount fee-amount))
    )
        (unwrap! (stx-transfer? total-amount tx-sender .dme014-stx-rewards) err-unauthorized)
        (as-contract (contract-call? .dme016-quest-ownership increment-quest-rewards-deposited quest-id total-amount))
    )
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)