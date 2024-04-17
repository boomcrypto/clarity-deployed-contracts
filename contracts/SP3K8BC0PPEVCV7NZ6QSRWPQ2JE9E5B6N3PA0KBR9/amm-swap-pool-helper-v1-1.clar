(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-constant err-not-authorised (err u1000))
(define-constant err-token-mismatch (err u1001))
(define-constant err-token-not-approved (err u1002))
(define-constant err-insufficient-balance (err u1003))
(define-constant err-request-not-found (err u1004))
(define-constant err-request-not-approved (err u1005))
(define-constant err-request-already-processed (err u1006))
(define-constant err-pool-exists (err u1007))
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant PENDING 0x00)
(define-constant APPROVED 0x01)
(define-constant REJECTED 0x02)
(define-constant FINALIZED 0x03)
(define-data-var contract-owner principal tx-sender)
(define-map approved-operators principal bool)
(define-map approved-tokens principal { approved: bool, min-x: uint })
(define-data-var request-nonce uint u0)
(define-map requests uint {
    requested-by: principal, requested-at: uint,
    token-x: principal, token-y: principal, factor: uint,
    bal-x: uint, bal-y: uint,
    fee-rate-x: uint, fee-rate-y: uint,
    max-in-ratio: uint, max-out-ratio: uint,
    threshold-x: uint, threshold-y: uint,
    oracle-enabled: bool, oracle-average: uint,
    start-block: uint,
    memo: (optional (buff 256)),
    status: (buff 1), status-memo: (optional (buff 256))
})
(define-read-only (get-approved-tokens-or-default (token principal))
    (default-to { approved: false, min-x: MAX_UINT } (map-get? approved-tokens token)))
(define-read-only (get-approved-operator-default (operator principal))
    (default-to false (map-get? approved-operators operator)))
(define-read-only (get-request-or-fail (request-id uint))
    (ok (unwrap! (map-get? requests request-id) err-request-not-found)))
(define-public (request-create
    (request-details {
        token-x: principal, token-y: principal, factor: uint,
        bal-x: uint, bal-y: uint,
        fee-rate-x: uint, fee-rate-y: uint,
        max-in-ratio: uint, max-out-ratio: uint,
        threshold-x: uint, threshold-y: uint,
        oracle-enabled: bool, oracle-average: uint,
        start-block: uint,
        memo: (optional (buff 256)) }) (token-x-trait <ft-trait>))
    (let (
            (next-nonce (+ (var-get request-nonce) u1))
            (token-details (get-approved-tokens-or-default (get token-x request-details)))
            (updated-request-details (merge request-details { requested-by: tx-sender, requested-at: block-height, status: PENDING, status-memo: none })))
        (asserts! (is-eq (get token-x request-details) (contract-of token-x-trait)) err-token-mismatch)
        (asserts! (get approved token-details) err-token-not-approved)
        (asserts! (>= (get bal-x request-details) (get min-x token-details)) err-insufficient-balance)
        (asserts! (and 
            (is-none (contract-call? .amm-swap-pool-v1-1 get-pool-exists (get token-x request-details) (get token-y request-details) (get factor request-details)))
            (is-none (contract-call? .amm-swap-pool-v1-1 get-pool-exists (get token-y request-details) (get token-x request-details) (get factor request-details))))
            err-pool-exists)
        (try! (contract-call? token-x-trait transfer-fixed (get bal-x request-details) tx-sender (as-contract tx-sender) none))
        (map-set requests next-nonce updated-request-details)
        (var-set request-nonce next-nonce)
        (print { notification: "request-create", payload: updated-request-details })
        (ok next-nonce)))
(define-public (finalize-request (request-id uint) (token-x-trait <ft-trait>) (token-y-trait <ft-trait>))
    (let (
            (request-details (try! (get-request-or-fail request-id)))
            (updated-request-details (merge request-details { requested-by: tx-sender, status: FINALIZED })))
        (asserts! (is-eq (get requested-by request-details) tx-sender) err-not-authorised)
        (asserts! (is-eq (get status request-details) APPROVED) err-request-not-approved)
        (asserts! (is-eq (get token-x request-details) (contract-of token-x-trait)) err-token-mismatch)
        (asserts! (is-eq (get token-y request-details) (contract-of token-y-trait)) err-token-mismatch)
        (as-contract (try! (contract-call? token-x-trait transfer-fixed (get bal-x request-details) tx-sender (get requested-by request-details) none)))
        (try! (contract-call? .amm-swap-pool-v1-1 create-pool token-x-trait token-y-trait (get factor request-details) (get requested-by request-details) (get bal-x request-details) (get bal-y request-details)))
        (try! (contract-call? .amm-swap-pool-v1-1 set-fee-rate-x (get token-x request-details) (get token-y request-details) (get factor request-details) (get fee-rate-x request-details)))
        (try! (contract-call? .amm-swap-pool-v1-1 set-fee-rate-y (get token-x request-details) (get token-y request-details) (get factor request-details) (get fee-rate-y request-details)))
        (try! (contract-call? .amm-swap-pool-v1-1 set-max-in-ratio (get token-x request-details) (get token-y request-details) (get factor request-details) (get max-in-ratio request-details)))
        (try! (contract-call? .amm-swap-pool-v1-1 set-max-out-ratio (get token-x request-details) (get token-y request-details) (get factor request-details) (get max-out-ratio request-details)))
        (try! (contract-call? .amm-swap-pool-v1-1 set-threshold-x (get token-x request-details) (get token-y request-details) (get factor request-details) (get threshold-x request-details)))
        (try! (contract-call? .amm-swap-pool-v1-1 set-threshold-y (get token-x request-details) (get token-y request-details) (get factor request-details) (get threshold-y request-details)))
        (try! (contract-call? .amm-swap-pool-v1-1 set-oracle-enabled (get token-x request-details) (get token-y request-details) (get factor request-details) (get oracle-enabled request-details)))
        (try! (contract-call? .amm-swap-pool-v1-1 set-oracle-average (get token-x request-details) (get token-y request-details) (get factor request-details) (get oracle-average request-details)))
        (try! (contract-call? .amm-swap-pool-v1-1 set-start-block (get token-x request-details) (get token-y request-details) (get factor request-details) (get start-block request-details)))
        (map-set requests request-id updated-request-details)
        (print { notification: "finalize-request", payload: updated-request-details })
        (ok true)))
(define-public (approve-request (request-id uint) (wrapped-token-y principal) (memo (optional (buff 256))))
    (let (
            (request-details (try! (get-request-or-fail request-id)))
            (updated-request-details (merge request-details { token-y: wrapped-token-y, status: APPROVED, status-memo: memo })))
        (try! (check-is-approved))
        (asserts! (is-eq (get status request-details) PENDING) err-request-already-processed)
        (map-set requests request-id updated-request-details)
        (print { notification: "approve-request", payload: updated-request-details })
        (ok true)))
(define-public (reject-request (request-id uint) (token-x-trait <ft-trait>) (memo (optional (buff 256))))
    (let (
            (request-details (try! (get-request-or-fail request-id)))
            (updated-request-details (merge request-details { status: REJECTED, status-memo: memo })))
        (asserts! (or (is-ok (check-is-approved)) (is-eq tx-sender (get requested-by request-details))) err-not-authorised) ;; either requestor or approved operator can reject
        (asserts! (or (is-eq (get status request-details) PENDING) (is-eq (get status request-details) APPROVED)) err-request-already-processed)
        (asserts! (is-eq (get token-x request-details) (contract-of token-x-trait)) err-token-mismatch)
        (as-contract (try! (contract-call? token-x-trait transfer-fixed (get bal-x request-details) tx-sender (get requested-by request-details) none)))
        (map-set requests request-id updated-request-details)
        (print { notification: "reject-request", payload: updated-request-details })
        (ok true)))
(define-public (set-owner (owner principal))
    (begin
        (try! (check-is-owner))
        (ok (var-set contract-owner owner))))
(define-public (approve-operator (operator principal) (approved bool))
    (begin
        (try! (check-is-owner))
        (ok (map-set approved-operators operator approved))))
(define-public (approve-token (operator principal) (approved bool) (min-x uint))
    (begin
        (try! (check-is-owner))
        (ok (map-set approved-tokens operator { approved: approved, min-x: min-x }))))
(define-private (check-is-approved)
    (ok (asserts! (or (get-approved-operator-default tx-sender) (is-ok (check-is-owner))) err-not-authorised)))
(define-private (check-is-owner)
    (ok (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorised)))