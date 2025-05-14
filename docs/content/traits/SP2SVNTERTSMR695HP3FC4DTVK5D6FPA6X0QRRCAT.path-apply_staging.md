---
title: "Trait path-apply_staging"
draft: true
---
```
;;; UniswapV2Pair.sol
;;; UniswapV2Factory.sol

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-auth                   (err u100)) 
(define-constant err-check-owner            (err u101)) 
(define-constant err-no-such-pool           (err u102)) 
(define-constant err-create-preconditions   (err u103)) 
(define-constant err-create-postconditions  (err u104)) 
(define-constant err-mint-preconditions     (err u105)) 
(define-constant err-mint-postconditions    (err u106)) 
(define-constant err-burn-preconditions     (err u107)) 
(define-constant err-burn-postconditions    (err u108)) 
(define-constant err-swap-preconditions     (err u109)) 
(define-constant err-swap-postconditions    (err u110)) 
(define-constant err-collect-preconditions  (err u111)) 
(define-constant err-collect-postconditions (err u112)) 
(define-constant err-anti-rug               (err u113)) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-constant this (as-contract tx-sender)) 
(define-constant owner tx-sender) 

(define-public (add-liquidity (buffer (buff 27))) (exec buffer))
(define-public (remove-liquidity (buffer (buff 27))) (exec buffer)) 
(define-public (swap-exact-tokens-for-tokens (buffer (buff 27))) (exec buffer)) 
(define-public (swap-tokens-for-exact-tokens (buffer (buff 27))) (exec buffer)) 
(define-private (exec (buffer (buff 120))) (let ((i (unwrap-panic (as-max-len? (unwrap-panic (slice? buffer u0 u2)) u2))) (nnnm (buff-to-uint-be (unwrap-panic (as-max-len? (unwrap-panic (slice? buffer u2 u7)) u5))))) (try! (stx-transfer? nnnm tx-sender this)) (try! (as-contract (dispatch i nnnm (buff-to-uint-be (unwrap-panic (as-max-len? (default-to 0x (slice? buffer u7 u12)) u5))) (buff-to-uint-be (unwrap-panic (as-max-len? (default-to 0x (slice? buffer u12 u17)) u5))) (buff-to-uint-be (unwrap-panic (as-max-len? (default-to 0x (slice? buffer u17 u22)) u5))) (buff-to-uint-be (unwrap-panic (as-max-len? (default-to 0x (slice? buffer u22 u27)) u5))) ))) (let ((new-balance (stx-get-balance this))) (asserts! (>= new-balance  nnnm) (err u53)) (ok (as-contract (try! (stx-transfer? new-balance this owner )))) ))) (define-private (dispatch (i (buff 2)) (nnnm uint) (nnnn uint) (mmmm uint) (nmmm uint) (nnmm uint)) (if (< i 0x0064) (contract-call? .exec-0 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x00c8) (contract-call? .exec-1 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x012c) (contract-call? .exec-2 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x0190) (contract-call? .exec-3 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x01f4) (contract-call? .exec-4 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x0258) (contract-call? .exec-5 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x02bc) (contract-call? .exec-6 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x0320) (contract-call? .exec-7 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x0384) (contract-call? .exec-8 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x03e8) (contract-call? .exec-9 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x044c) (contract-call? .exec-10 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x04b0) (contract-call? .exec-11 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x0514) (contract-call? .exec-12 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x0578) (contract-call? .exec-13 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x05dc) (contract-call? .exec-14 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x0640) (contract-call? .exec-15 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x06a4) (contract-call? .exec-16 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x0708) (contract-call? .exec-17 dispatch i nnnm nnnn mmmm nmmm nnmm) (if (< i 0x076c) (contract-call? .exec-18 dispatch i nnnm nnnn mmmm nmmm nnmm) (contract-call? .exec-19 dispatch i nnnm nnnn mmmm nmmm nnmm)))))))))))))))))))) )
```
