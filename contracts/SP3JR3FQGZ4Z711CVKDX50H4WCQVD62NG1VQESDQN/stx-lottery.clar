;; title: lottery
;; version: 1.0.3
;; summary: STX lottery
;; description: Smart Contract to participate in STX Lottery

;; constants
;;
;; Owner
(define-constant contract-owner tx-sender)

;; Errors
(define-constant err-owner-only (err u100))
(define-constant err-low-price (err u101))
(define-constant err-no-participants (err u102))
(define-constant err-too-many-participants (err u103))

;; data vars
;;
(define-data-var participant-count uint u0)
(define-data-var previous-winner principal tx-sender)

;; data maps
;;
(define-map participants uint principal)

;; public functions
;;
(define-public (buy)
    (begin
        (asserts! (< (var-get participant-count) u200) err-too-many-participants)
        (try! (stx-transfer? u1000000 tx-sender (as-contract tx-sender)))
        (map-set participants (var-get participant-count) tx-sender)
        (var-set participant-count (+ u1 (var-get participant-count)))
        (ok true)
    )
)

(define-public (choose-winner)
    (let
        (
            (winner (unwrap-panic (map-get? participants (mod (get-random-uint u13) (var-get participant-count)))))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (>= (var-get participant-count) u1) err-no-participants)
        (try! (as-contract (stx-transfer? (/ (stx-get-balance tx-sender) u30) tx-sender contract-owner)))
        (try! (as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender winner)))
        (var-set participant-count u0)
        (var-set previous-winner winner)
        (ok true)
    )
)

;; read only functions
;;
(define-read-only (participants-number)
    (var-get participant-count)
)

(define-read-only (get-previous-winner)
    (var-get previous-winner)
)

(define-read-only (get-balance)
    (as-contract (stx-get-balance tx-sender))
)

;; private functions
;;
(define-private (get-vrf)
    (unwrap-panic
        (get-block-info? vrf-seed (- block-height u1))
    )
)

(define-private (get-byte-at (index uint))
    (unwrap-panic
        (element-at (get-vrf) index)
    )
)

(define-private (get-random-uint (index uint))
    (buff-to-uint-le (get-byte-at index))
)