;; leos-stacks101-mint
;; LEOS (stage1) : On-chain Mint Verification Contract for Stacks 101 Course

(use-trait safe-trait .leos-stage1-traits.safe-trait)
(use-trait boom-nft-trait .leos-stage1-traits.boom-nft-trait)
(use-trait ft-trait .leos-stage1-traits.ft-trait)
(use-trait sandbox-contract-trait .leos-stage1-traits.sandbox-contract-trait)

;; constants
(define-constant course-name "Stacks 101")
(define-constant contract-owner tx-sender)
(define-constant null-block 0x0000000000000000000000000000000000000000000000000000000000000000)

;; errors
(define-constant err-mint-paused (err u100))
(define-constant err-module-setup (err u101))
(define-constant err-module-receive (err u102))
(define-constant err-module-send (err u103))
(define-constant err-module-explorer (err u104))
(define-constant err-module-multi-safe (err u105))
(define-constant err-module-nft (err u106))
(define-constant err-module-sandbox (err u107))
(define-constant err-module-ft (err u108))
(define-constant err-not-authorized (err u401))

;; data maps and vars
(define-data-var module-ctrl (list 9 bool) (list true true true true true true true true true))

;; private functions
;; #[allow(unchecked_data)]
(define-public (set-module-ctrl (cfg (list 9 bool)))
    (begin 
        (asserts! (is-eq contract-caller contract-owner) err-not-authorized)
        (ok (var-set module-ctrl cfg))
    )
)

(define-read-only (get-module-ctrl)
    (var-get module-ctrl)
)

(define-read-only (is-mint-enabled)
    (default-to false (element-at (var-get module-ctrl) u0))
)

(define-read-only (is-module-enabled (x uint))
    (default-to false (element-at (var-get module-ctrl) x))
)

;; module-1
(define-read-only (verify-module-setup (subject principal))
    (is-eq subject tx-sender)
)

;; module-2
(define-read-only (verify-module-receive (amount uint) (rx-block uint))
    (let (
        (prev-block (- rx-block u1))
        (prev-block-hash (default-to null-block (get-block-info? id-header-hash prev-block)))
        (rx-block-hash (default-to null-block (get-block-info? id-header-hash rx-block)))
        (prev-stx-balance (at-block prev-block-hash (stx-get-balance tx-sender)))
        (rx-stx-balance (at-block rx-block-hash (stx-get-balance tx-sender)))
        )
        (is-eq (+ prev-stx-balance amount) rx-stx-balance)
    )
)

;; module-3
(define-read-only (verify-module-send (amount uint) (tx-block uint))
    (let (
        (prev-block (- tx-block u1))
        (prev-block-hash (default-to null-block (get-block-info? id-header-hash prev-block)))
        (tx-block-hash (default-to null-block (get-block-info? id-header-hash tx-block)))
        (prev-stx-balance (at-block prev-block-hash (stx-get-balance tx-sender)))
        (tx-stx-balance (at-block tx-block-hash (stx-get-balance tx-sender)))
        )
        (is-eq (- prev-stx-balance amount) tx-stx-balance)
    )
)

;; module-4
(define-read-only (verify-module-explorer (tx-block uint) (burn-block uint))
    (let (
        (tx-block-hash (default-to null-block (get-block-info? id-header-hash (+ tx-block u1))))
        (burn-block-id (at-block tx-block-hash burn-block-height))
        )
        (is-eq burn-block burn-block-id)
    )
)

;; module-5
(define-public (verify-module-multi-safe (safe <safe-trait>))
    (let (
        (safe-owners (get owners (unwrap! (contract-call? safe get-info) (err false))))
        )
        (ok (is-some (index-of safe-owners tx-sender)))
    )
)

;; module-6
(define-public (verify-module-nft (nft <boom-nft-trait>) (token-id uint))
    (ok (is-eq tx-sender (unwrap! (unwrap! (contract-call? nft get-owner token-id) (err false)) (err false))))
)

;; module-7
(define-public (verify-module-sandbox (contract <sandbox-contract-trait>))
    (contract-call? contract test-emit-event)
)

;; module-8
(define-public (verify-module-ft (ft <ft-trait>))
    (let (
        (amount (unwrap! (contract-call? ft get-balance tx-sender) (err false)))
        (symbol (unwrap! (contract-call? ft get-symbol) (err false)))
        )
        (ok (and (> amount u0) (is-eq symbol "USDA")))
    )
)

;; public functions
(define-public (mint
        (subject principal) ;; module-setup
        (rx-amount uint) (rx-block uint) ;; module-receive
        (tx-amount uint) (tx-block uint) ;; module-send
        (burn-block uint) ;; module-explorer
        (safe <safe-trait>) ;; module-multi-safe
        (nft <boom-nft-trait>) (nft-id uint) ;; module-nft
        (contract <sandbox-contract-trait>) ;; module-sandbox
        (ft <ft-trait>) ;; module-ft
    )
    (let (
        (price (contract-call? .learning-leos-club-nft get-mint-price))
        )
        (asserts! (is-mint-enabled) err-mint-paused)
        (asserts! (or (not (is-module-enabled u1)) (verify-module-setup subject)) err-module-setup)
        (asserts! (or (not (is-module-enabled u2)) (verify-module-receive rx-amount rx-block)) err-module-receive)
        (asserts! (or (not (is-module-enabled u3)) (verify-module-send tx-amount tx-block)) err-module-send)
        (asserts! (or (not (is-module-enabled u4)) (verify-module-explorer tx-block burn-block)) err-module-explorer)
        (asserts! (or (not (is-module-enabled u5)) (is-ok (verify-module-multi-safe safe))) err-module-multi-safe)
        (asserts! (or (not (is-module-enabled u6)) (is-ok (verify-module-nft nft nft-id))) err-module-nft)
        (asserts! (or (not (is-module-enabled u7)) (is-ok (verify-module-sandbox contract))) err-module-sandbox)
        (asserts! (or (not (is-module-enabled u8)) (is-ok (verify-module-ft ft))) err-module-ft)
        (if (> price u0)
            (begin
                (try! (stx-transfer? price tx-sender contract-owner))
                (as-contract (contract-call? .learning-leos-club-nft mint subject course-name))
            )
            (as-contract (contract-call? .learning-leos-club-nft mint subject course-name))
        )
    )
)

(begin
    (contract-call? .learning-leos-club-nft set-mint-authority (as-contract tx-sender) true)
)
(print {log: "stage1 initialized - leos-stack101-mint"})
