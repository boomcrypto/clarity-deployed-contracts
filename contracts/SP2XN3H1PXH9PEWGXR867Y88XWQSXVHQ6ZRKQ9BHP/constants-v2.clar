;; Contract to hold the constants

(define-constant SCALING-FACTOR (contract-call? .constants-v1 get-scaling-factor))

(define-read-only (get-scaling-factor) SCALING-FACTOR)

(define-constant MARKET-TOKEN-DECIMALS (contract-call? .constants-v1 get-market-token-decimals))

(define-read-only (get-market-token-decimals) MARKET-TOKEN-DECIMALS)

(define-constant STACKS_BLOCK_TIME (contract-call? .constants-v1 get-stacks-block-time))

(define-read-only (get-stacks-block-time) STACKS_BLOCK_TIME)

(define-constant PRICE-DECIMALS u8)

(define-read-only (get-price-decimals) PRICE-DECIMALS)

(define-constant PRICE-SCALING-FACTOR (pow u10 PRICE-DECIMALS))

(define-read-only (get-price-scaling-factor) PRICE-SCALING-FACTOR)
