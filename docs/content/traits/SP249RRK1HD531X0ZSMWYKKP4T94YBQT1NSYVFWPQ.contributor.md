---
title: "Trait contributor"
draft: true
---
```
;; Constants
(define-constant contributor-contract (as-contract tx-sender))

;; Error codes
(define-constant err-not-admin (err u101))
(define-constant err-allow-pool-in-pox-first (err u102))
(define-constant err-fund-to-commit (err u103))

;; Data vars
(define-data-var contributor-admin principal tx-sender)
(define-data-var funds-to-commit bool false)

(define-data-var rewards-address {version: (buff 1), hashbytes: (buff 32) } 
    {
        version: 0x04,
        hashbytes: 0x6408bf89b8038c618c4ad6e03d0d33cf6581c978})

;; Public functions
(define-public (update-contributor-admin (new-admin principal))
    (begin 
        (asserts! (is-eq contract-caller (var-get contributor-admin)) err-not-admin)
        (ok (var-set contributor-admin new-admin))))

(define-public (update-rewards-address (new-rewards-address {version: (buff 1), hashbytes: (buff 32)}))
    (begin 
        (asserts! (is-eq contract-caller (var-get contributor-admin)) err-not-admin)
        (asserts! (not (var-get funds-to-commit)) err-fund-to-commit)
        (ok (var-set rewards-address new-rewards-address))))

(define-public (contributor-delegate (amount-ustx uint))
    (let ((current-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-4 current-pox-reward-cycle)))
    (asserts! (check-contributor-SC-pox-allowance) err-allow-pool-in-pox-first)
    (try! (contributor-delegate-inner amount-ustx contributor-contract none))
    (ok true)))

(define-public (contributor-revoke-delegation)
    (contract-call? 'SP000000000000000000002Q6VF78.pox-4 revoke-delegate-stx))

(define-public (admin-stack (stacker principal) (amount-ustx uint) (lock-period uint))
    (begin
        (asserts! (is-eq (var-get contributor-admin) contract-caller) err-not-admin)
        (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-4 delegate-stack-stx stacker amount-ustx (var-get rewards-address) burn-block-height lock-period))
            stacker-details 
                (begin 
                    (var-set funds-to-commit true)
                    (ok stacker-details))
            error (err (to-uint error)))))

(define-public (admin-stack-extend (stacker principal) (extend-count uint))
    (begin
        (asserts! (is-eq (var-get contributor-admin) contract-caller) err-not-admin)
        (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-4 delegate-stack-extend stacker (var-get rewards-address) extend-count))
            extend-details 
                (begin 
                    (var-set funds-to-commit true)
                    (ok extend-details))
            error (err (to-uint error)))))

(define-public (admin-stack-increase (stacker principal) (increase-by uint))
    (begin
        (asserts! (is-eq (var-get contributor-admin) contract-caller) err-not-admin)
        (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-4 delegate-stack-increase stacker (var-get rewards-address) increase-by))
            stacker-details 
                (begin 
                    (var-set funds-to-commit true)
                    (ok stacker-details))
            error (err (to-uint error)))))

(define-public (admin-aggregation-commit (reward-cycle uint) 
                                         (signer-sig (optional (buff 65)))
                                         (signer-pubkey (buff 33))
                                         (max-allowed-amount uint)
                                         (auth-id uint))
    (begin 
        (asserts! (is-eq (var-get contributor-admin) contract-caller) err-not-admin)
        (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-4 stack-aggregation-commit-indexed (var-get rewards-address) reward-cycle signer-sig signer-pubkey max-allowed-amount auth-id))
            index 
                (begin 
                    (var-set funds-to-commit false)
                    (ok index))
            error 
                (begin 
                    (print {err-commit-ignored: error})
                    (err (to-uint error))))))

(define-public (admin-aggregation-increase (reward-cycle uint) 
                                           (index uint)
                                           (signer-sig (optional (buff 65)))
                                           (signer-pubkey (buff 33))
                                           (max-allowed-amount uint)
                                           (auth-id uint))
    (begin 
        (asserts! (is-eq (var-get contributor-admin) contract-caller) err-not-admin)
        (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-4 stack-aggregation-increase (var-get rewards-address) reward-cycle index signer-sig signer-pubkey max-allowed-amount auth-id))
            success 
                (begin 
                    (var-set funds-to-commit false)
                    (ok true))
            error 
                (begin 
                    (print {err-increase-ignored: error})
                    (ok false)))))

;; Private functions
(define-private (contributor-delegate-inner (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint)))
(let ((result-revoke
        ;; Calls revoke and ignores result
        (contract-call? 'SP000000000000000000002Q6VF78.pox-4 revoke-delegate-stx)))
  ;; Calls delegate-stx, converts any error to uint
  (match (contract-call? 'SP000000000000000000002Q6VF78.pox-4 delegate-stx amount-ustx delegate-to until-burn-ht none)
    success (ok success)
    error (err (* u1000 (to-uint error))))))

;; Read-only functions
(define-read-only (check-contributor-SC-pox-allowance)
    (is-some 
        (contract-call? 'SP000000000000000000002Q6VF78.pox-4 get-allowance-contract-callers contract-caller contributor-contract)))

(define-read-only (get-contributor-admin)
    (var-get contributor-admin))

(define-read-only (get-rewards-address)
    (var-get rewards-address))

```
