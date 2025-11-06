;; SPDX-License-Identifier: BUSL-1.1

;; Contract to hold the constants

(define-constant SCALING-FACTOR u100000000)

(define-read-only (get-scaling-factor) SCALING-FACTOR)

(define-constant MARKET-TOKEN-DECIMALS (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-decimals)))

(define-read-only (get-market-token-decimals) MARKET-TOKEN-DECIMALS)

(define-constant STACKS_BLOCK_TIME u5)

(define-read-only (get-stacks-block-time) STACKS_BLOCK_TIME)
