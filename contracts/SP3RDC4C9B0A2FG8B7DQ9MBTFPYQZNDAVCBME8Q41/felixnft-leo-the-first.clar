;; felixnft-leo-the-first
;; v1
;; Learn more at https://felixapp.xyz/
;; ---
;;
(define-constant felix 'SP3RDC4C9B0A2FG8B7DQ9MBTFPYQZNDAVCBME8Q41)
(define-constant fee u10000)
(define-constant difficulty u2)
(define-constant ticket-price u100000)
(define-constant available-tickets u100)
(define-constant end-block-height (+ tenure-height u300))
(define-constant contract-principal (as-contract tx-sender))
(define-constant funder tx-sender)

(define-non-fungible-token felix-nft-leo-the-first uint)

(define-constant err-sale-period-ended (err u100))
(define-constant err-standard-principal-only (err u101))
(define-constant err-sold-out (err u102))
(define-constant err-number-unavailable (err u103))
(define-constant err-number-out-of-bounds (err u104))
(define-constant err-too-soon (err u105))
(define-constant err-already-finished (err u106))
(define-constant err-drawing-number (err u107))
(define-constant err-not-finished (err u108))
(define-constant err-invalid-ticket (err u109))
(define-constant err-prize-claimed (err u110))
(define-constant err-revenue-claimed (err u111))

(define-constant err-not-authorized (err u403))

(define-data-var last-ticket-id uint u0)
(define-data-var result (optional uint) none)
(define-data-var prize-claimed bool false)
(define-data-var revenue-claimed bool false)

(define-map numbersToTicketIds uint uint)

(define-private (is-standard-principal-call)
    (is-none (get name (unwrap! (principal-destruct? contract-caller) false))))

(define-private (pick-lottery-numbers (random-number uint))
    (ok (mod random-number (unwrap! (element-at (list u10 u100 u1000 u10000 u100000 u1000000 u10000000 u100000000 u1000000000 u10000000000) (- difficulty u1)) err-drawing-number))))

(define-read-only (get-winner)
    (match (var-get result)
        winning-numbers (map-get? numbersToTicketIds winning-numbers)
        none))

(define-read-only (get-result) (var-get result))

(define-public (buy-ticket (recipient principal) (numbers uint))
    (begin
        (asserts! (is-standard-principal-call) err-standard-principal-only)
        (asserts! (< tenure-height end-block-height) err-sale-period-ended)
        (asserts! (< (var-get last-ticket-id) available-tickets) err-sold-out)
        (asserts! (is-none (map-get? numbersToTicketIds numbers)) err-number-unavailable)
        (asserts! (<= numbers (- (pow u10 difficulty) u1)) err-number-out-of-bounds)
        (let
            ((ticket-id (+ (var-get last-ticket-id) u1)))
        (try! (stx-transfer? ticket-price contract-caller contract-principal))
        (try! (stx-transfer? fee contract-caller felix))
        (try! (nft-mint? felix-nft-leo-the-first ticket-id recipient))
        (asserts! (is-eq (map-insert numbersToTicketIds numbers ticket-id) true) err-number-unavailable)
        (var-set last-ticket-id ticket-id)
        (ok ticket-id))))

(define-public (draw)
    (begin
        (asserts! (is-standard-principal-call) err-standard-principal-only)
        (asserts! (> tenure-height end-block-height) err-too-soon)
        (asserts! (is-none (var-get result)) err-already-finished)
        (let
            ((random-number (unwrap! (contract-call? 'SP3RDC4C9B0A2FG8B7DQ9MBTFPYQZNDAVCBME8Q41.felix-meta-v3 get-rnd end-block-height) err-drawing-number))
            (lottery-numbers (unwrap! (pick-lottery-numbers random-number) err-drawing-number)))
        (var-set result (some lottery-numbers))
        (ok lottery-numbers))))

(define-public (claim-prize (ticket-id uint))
    (let
        ((winning-numbers (unwrap! (var-get result) err-not-finished))
        (winning-ticket-id (unwrap! (map-get? numbersToTicketIds winning-numbers) err-invalid-ticket))
        (claimer contract-caller))
    (asserts! (is-standard-principal-call) err-standard-principal-only)
    (asserts! (is-eq (nft-get-owner? felix-nft-leo-the-first ticket-id) (some claimer)) err-not-authorized)
    (asserts! (not (var-get prize-claimed)) err-prize-claimed)
    (var-set prize-claimed true)
    (try! (as-contract (contract-call? 'SP2N959SER36FZ5QT1CX9BR63W3E8X35WQCMBYYWC.leo-cats transfer u1340 contract-principal claimer)))
    (ok true)))

(define-public (claim-revenue)
    (begin
        (asserts! (is-standard-principal-call) err-standard-principal-only)
        (asserts! (is-some (var-get result)) err-not-finished)
        (asserts! (is-eq funder contract-caller) err-not-authorized)
        (asserts! (not (var-get revenue-claimed)) err-revenue-claimed)
        (let
            ((revenue (stx-get-balance contract-principal))) 
        (match (get-winner) opt
            ;; Lottery has winner, only return revenue if it exists
            (try! (if (> revenue u0) (as-contract (stx-transfer? revenue contract-principal funder)) (ok true)))
            ;; Lottery has no winner, return revenue if it exists and transfer NFT back
            (begin 
                (try! (as-contract (contract-call? 'SP2N959SER36FZ5QT1CX9BR63W3E8X35WQCMBYYWC.leo-cats transfer u1340 contract-principal funder)))
                (try! (if (> revenue u0) (as-contract (stx-transfer? revenue contract-principal funder)) (ok true)))
            ))
        (var-set revenue-claimed true)
        (ok true))))

;; Transfers the NFT on deployment
(begin
    (contract-call? 'SP2N959SER36FZ5QT1CX9BR63W3E8X35WQCMBYYWC.leo-cats transfer u1340 funder contract-principal))