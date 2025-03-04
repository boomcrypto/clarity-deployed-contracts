(define-constant lead-burn-height u100)
(define-constant pred-fee u100000)

(define-constant err-invalid-args (err u100))
(define-constant err-in-anticipation (err u101))
(define-constant err-admin-only (err u102))
(define-constant err-premature-verify (err u103))
(define-constant err-block-info (err u104))
(define-constant err-invalid-height (err u105))

(define-constant contract-deployer tx-sender)

(define-map last-seqs principal uint)
(define-map preds
    { addr: principal, seq: uint }
    { height: uint, burn-height: uint, value: (string-ascii 4) }
)

(define-public (predict (value (string-ascii 4)))
    (begin
        (asserts! (or (is-eq value "up") (is-eq value "down")) err-invalid-args)
        (let
            (
                (last-seq (default-to u0 (map-get? last-seqs contract-caller)))
                (last-pred (default-to { height: u0, burn-height: u0, value: "" } (map-get? preds { addr: contract-caller, seq: last-seq })))
                (seq (+ last-seq u1))
                (last-burn-height (get burn-height last-pred))
            )

            (asserts! (< last-burn-height (- burn-block-height lead-burn-height)) err-in-anticipation)

            (map-set last-seqs contract-caller seq)
            (map-set preds
                { addr: contract-caller, seq: seq }
                { height: stacks-block-height, burn-height: burn-block-height, value: value }
            )

            (try! (stx-transfer? pred-fee contract-caller contract-deployer))
            (ok { seq: seq })
        )
    )
)

(define-public (verify (addr principal) (seq uint) (target-height uint))
    (begin
        (asserts! (is-eq contract-deployer contract-caller) err-admin-only)
        (let
            (
                (pred (unwrap! (map-get? preds { addr: addr, seq: seq }) err-invalid-args))
                (anchor-height (get height pred))
                (anchor-burn-height (get burn-height pred))
                (value (get value pred))
            )
            (asserts! (< anchor-height target-height) err-invalid-args)
            (asserts! (< (+ anchor-burn-height lead-burn-height) burn-block-height) err-premature-verify)
            (let
                (
                    (anchor-price (try! (get-price anchor-height)))
                    (target-price (try! (get-price target-height)))
                    (up-and-more
                        (and (is-eq value "up") (>= target-price anchor-price))
                    )
                    (down-and-less
                        (and (is-eq value "down") (<= target-price anchor-price))
                    )
                    (correct (if (or up-and-more down-and-less) "TRUE" "FALSE"))
                )
                (ok {
                    anchor-height: anchor-height,
                    anchor-burn-height: anchor-burn-height,
                    value: value,
                    anchor-price: anchor-price,
                    target-price: target-price,
                    correct: correct
                })
            )
        )
    )
)

(define-public (not-available (addr principal) (seq uint))
    (begin
        (asserts! (is-eq contract-deployer contract-caller) err-admin-only)
        (unwrap! (map-get? preds { addr: addr, seq: seq }) err-invalid-args)
        (ok {
            correct: "N/A"
        })
    )
)

(define-read-only (get-price (height uint))
    (let
        (
            (id (unwrap! (get-stacks-block-info? id-header-hash height) err-block-info))
        )
        (at-block id
            (ok (try!
                (contract-call?
                    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01
                    get-helper-a
                    'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
                    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
                    'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
                    u100000000
                    u100000000
                    u1
                )
            ))
        )
    )
)
