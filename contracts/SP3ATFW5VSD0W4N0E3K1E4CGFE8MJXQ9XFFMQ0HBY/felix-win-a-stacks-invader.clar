;; felix-win-a-stacks-invader
;; v5
;; Learn more at https://felixapp.xyz/
;; ---
;;
(define-constant felix 'SP3RDC4C9B0A2FG8B7DQ9MBTFPYQZNDAVCBME8Q41)
(define-constant fee u100000)
(define-constant difficulty u2)
(define-constant ticket-price u1000000)
(define-constant number-of-tickets u269)
(define-constant slot-size u1000000)
(define-constant number-of-slots u1)
(define-constant start-block-height u169295)
(define-constant start-block-buffer u10)
(define-constant end-block-height u170295)
(define-constant end-cooldown u6)
(define-non-fungible-token felix-win-a-stacks-invader uint)

(define-constant contract-principal (as-contract tx-sender))

(define-data-var drawn-number (optional uint) none)
(define-data-var winner (optional uint) none)
(define-data-var prize-pool uint u0)
(define-data-var sold-tickets-pool uint u0)
(define-data-var admin principal felix)
(define-data-var funder-count uint u0)
(define-data-var last-ticket-id uint u0)

;; Maps funders to a bool indicating if they have claimed their funds
(define-map funders principal bool)
;; Maps chosen numbers to ticket ids
(define-map numbersToTicketIds uint uint)

(define-constant err-not-ticket-owner (err u101))
(define-constant err-inexistent-ticket-id (err u102))
(define-constant err-sold-out (err u200))
(define-constant err-invalid-difficulty (err u201))
(define-constant err-invalid-number (err u202))
(define-constant err-end-too-close (err u300) )
(define-constant err-not-ended-yet (err u301) )
(define-constant err-start-too-early (err u500))
(define-constant err-not-funded (err u501))
(define-constant err-invalid-status (err u502))
(define-constant err-no-funding-slot-available (err u503))
(define-constant err-principal-already-funder (err u504))
(define-constant err-start-too-close (err u505))
(define-constant err-couldnt-update-ticket-ids (err u600))
(define-constant err-unable-to-end-lottery (err u700))
(define-constant err-unable-to-get-random-seed (err u701))
(define-constant err-number-already-sold (err u800))
(define-constant err-invalid-drawn-number (err u900))
(define-constant err-not-ticket-winner (err u901))
(define-constant err-funder-already-claimed (err u1000))
(define-constant err-not-funder (err u1001))
(define-constant err-refund-already-claimed (err u1002))
(define-constant err-admin-only (err u2000))
(define-constant err-standard-principal-only (err u2001))
(define-constant err-cant-burn-winning-ticket (err u3000))

(define-constant available-contract-status
    (list "funding" "active" "won" "cancelled" "finished"))
(define-private (funding-status) (unwrap-panic (element-at? available-contract-status u0)))
(define-private (active-status) (unwrap-panic (element-at? available-contract-status u1)))
(define-private (won-status) (unwrap-panic (element-at? available-contract-status u2)))
(define-private (cancelled-status) (unwrap-panic (element-at? available-contract-status u3)))
(define-private (finished-status) (unwrap-panic (element-at? available-contract-status u4)))
(define-data-var current-status (string-ascii 9) (funding-status))
(define-private (is-active) (is-eq (var-get current-status) (active-status)))
(define-private (is-won) (is-eq (var-get current-status) (won-status)))
(define-private (is-finished) (is-eq (var-get current-status) (finished-status)))
(define-private (is-cancelled) (is-eq (var-get current-status) (cancelled-status)))
(define-private (is-in-funding) (is-eq (var-get current-status) (funding-status)))
(define-private (is-funder (test-principal principal))
    (is-some (map-get? funders test-principal)))
(define-private (is-funded)
    (> (var-get funder-count) u0))

(define-private (is-standard-principal-call)
    (is-none (get name (unwrap! (principal-destruct? contract-caller) false))))

(define-private (is-admin (test-principal principal)) (is-eq (var-get admin) test-principal))

(define-private (pick-lottery-numbers (seed uint))
    (if (is-eq difficulty u1) (ok (mod seed u10))
    (if (is-eq difficulty u2) (ok (mod seed u100))
    (if (is-eq difficulty u3) (ok (mod seed u1000))
    (if (is-eq difficulty u4) (ok (mod seed u10000))
    (if (is-eq difficulty u5) (ok (mod seed u100000))
    (if (is-eq difficulty u6) (ok (mod seed u1000000))
    (if (is-eq difficulty u7) (ok (mod seed u10000000))
    (if (is-eq difficulty u8) (ok (mod seed u100000000))
    (if (is-eq difficulty u9) (ok (mod seed u1000000000))
    (if (is-eq difficulty u10) (ok (mod seed u10000000000))
    err-invalid-difficulty)))))))))))

(define-private (end-lottery)
    (begin
        (asserts! (is-active) err-invalid-status)
        (asserts! (is-some (var-get drawn-number)) err-unable-to-end-lottery)
        (let
            ((maybe-winner-ticket-id (map-get? numbersToTicketIds (unwrap-panic (var-get drawn-number)))))
        (var-set winner maybe-winner-ticket-id)
        (var-set current-status (if (is-some maybe-winner-ticket-id) (won-status) (finished-status)))
        (ok true))))

(define-read-only (get-drawn-number)
    (var-get drawn-number))

(define-read-only (get-winner-ticket-id) (ok (var-get winner)))

(define-read-only (get-prize-pool) (ok (var-get prize-pool)))

(define-read-only (get-sold-tickets-pool) (ok (var-get sold-tickets-pool)))

(define-read-only (get-ticket-ids (num-to-check uint))
    (ok (map-get? numbersToTicketIds num-to-check)))

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? felix-win-a-stacks-invader token-id)))

(define-read-only (get-status) (ok (var-get current-status)))

(define-public (fund) 
    (let
        ((last-funder-count (var-get funder-count))
        (current-prize (var-get prize-pool))) 
    (asserts! (is-standard-principal-call) err-standard-principal-only)
    (asserts! (is-in-funding) err-invalid-status)
    (asserts! (> start-block-height block-height) err-start-too-close)
    (asserts! (< block-height (- end-block-height end-cooldown)) err-end-too-close)
    (asserts! (> end-block-height (+ start-block-height start-block-buffer)) err-end-too-close)
    (asserts! (< last-funder-count number-of-slots) err-no-funding-slot-available)
    (asserts! (not (is-funder contract-caller)) err-principal-already-funder)
    (try! (stx-transfer? slot-size contract-caller contract-principal))
    (map-insert funders contract-caller false)
    (var-set funder-count (+ last-funder-count u1))
    (var-set prize-pool (+ current-prize slot-size))
    (ok true)))

(define-public (start)
    (begin
        (asserts! (is-standard-principal-call) err-standard-principal-only)
        (asserts! (is-in-funding) err-invalid-status)
        (asserts! (> block-height start-block-height) err-start-too-early)
        (asserts! (> end-block-height (+ start-block-height start-block-buffer)) err-end-too-close)
        (asserts! (> end-block-height block-height) err-end-too-close)
        (asserts! (> (var-get funder-count) u0) err-not-funded)
        (var-set current-status (active-status))
        (ok true)))

(define-public (cancel)
    (begin
        (asserts! (is-standard-principal-call) err-standard-principal-only)
        (asserts! (is-admin contract-caller) err-admin-only)
        (var-set current-status (cancelled-status))
        (ok true)))

(define-public (draw-numbers)
    (begin 
        (asserts! (is-standard-principal-call) err-standard-principal-only)
        (asserts! (is-active) err-invalid-status)
        (asserts! (> block-height end-block-height) err-not-ended-yet)
        (let
            ;; We're using the citycoin-vrf-v2 contract to get a random number
            ((random-number (unwrap! (contract-call? 'SP3RDC4C9B0A2FG8B7DQ9MBTFPYQZNDAVCBME8Q41.felix-meta-v3 get-rnd (- end-block-height u1)) err-unable-to-get-random-seed))
            (lottery-numbers (unwrap-panic (pick-lottery-numbers random-number))))
        (var-set drawn-number (some lottery-numbers))
        (try! (end-lottery))
        (ok lottery-numbers))))

(define-public (buy-ticket (recipient principal) (selected-nums uint))
    (let
        ((ticket-id (+ (var-get last-ticket-id) u1))
        (current-sells (var-get sold-tickets-pool)))
    (asserts! (is-standard-principal-call) err-standard-principal-only)
    (asserts! (is-active) err-invalid-status)
    (asserts! (< block-height (- end-block-height end-cooldown)) err-end-too-close)
    (asserts! (< (var-get last-ticket-id) number-of-tickets) err-sold-out)
    (asserts! (<= selected-nums (- (pow u10 difficulty) u1)) err-invalid-number)
    (asserts! (is-none (map-get? numbersToTicketIds selected-nums)) err-number-already-sold)
    ;; #[allow(unchecked_data)]
    (asserts! (map-insert numbersToTicketIds selected-nums ticket-id) err-couldnt-update-ticket-ids)
    ;; #[allow(unchecked_data)]
    (try! (stx-transfer? ticket-price contract-caller contract-principal))
    (try! (stx-transfer? fee contract-caller (var-get admin)))
    ;; #[allow(unchecked_data)]
    (try! (nft-mint? felix-win-a-stacks-invader ticket-id recipient))
    (var-set last-ticket-id ticket-id)
    (var-set sold-tickets-pool (+ current-sells ticket-price))
    (ok ticket-id)))

(define-public (claim-prize (ticket-id uint))
    (let
        ((alleged-winner-principal contract-caller)
        (prize (var-get prize-pool)))
    (asserts! (is-standard-principal-call) err-standard-principal-only)
    (asserts! (is-won) err-invalid-status)
    (asserts! (is-eq (unwrap! (nft-get-owner? felix-win-a-stacks-invader ticket-id) err-inexistent-ticket-id) contract-caller) err-not-ticket-owner)
    (asserts! (is-eq ticket-id (unwrap-panic (var-get winner))) err-not-ticket-winner)
    (try! (as-contract (stx-transfer? prize contract-principal alleged-winner-principal)))
    (try! (nft-burn? felix-win-a-stacks-invader ticket-id alleged-winner-principal))
    (ok true)))

(define-public (claim-funds)
    (let
        ((claimer contract-caller)
        (has-claimed (map-get? funders claimer)))
    (asserts! (is-standard-principal-call) err-standard-principal-only)
    (asserts! (is-funder claimer) err-not-funder)
    (asserts! (or (is-won) (is-finished)) err-invalid-status)
    (asserts! (not (unwrap! has-claimed err-not-funder)) err-funder-already-claimed)
    (let
        ((number-of-funders (var-get funder-count))
        (sold-ticket-part (/ (var-get sold-tickets-pool) number-of-funders))
        (fund-return (if (is-won) u0 slot-size))
        (total-claim (+ sold-ticket-part fund-return)))
    (try! (as-contract (stx-transfer? total-claim contract-principal claimer)))
    (map-set funders claimer true)
    (ok true))))

(define-public (get-ticket-refund (ticket-id uint))
    (let
        ((ticket-owner contract-caller))
    (asserts! (is-standard-principal-call) err-standard-principal-only)
    (asserts! (is-eq (unwrap! (nft-get-owner? felix-win-a-stacks-invader ticket-id) err-inexistent-ticket-id) contract-caller) err-not-ticket-owner)
    (asserts! (is-cancelled) err-invalid-status)
    (try! (as-contract (stx-transfer? ticket-price contract-principal ticket-owner)))
    (try! (nft-burn? felix-win-a-stacks-invader ticket-id ticket-owner))
    (ok ticket-id)))

(define-public (get-fund-refund)
    (begin
        (asserts! (is-standard-principal-call) err-standard-principal-only)
        (asserts! (is-cancelled) err-invalid-status)
        (let
            ((claimer contract-caller)
            (has-refunded (unwrap! (map-get? funders claimer) err-not-funder)))
        (asserts! (is-funder claimer) err-not-funder)
        (asserts! (not has-refunded) err-refund-already-claimed)
        (try! (as-contract (stx-transfer? slot-size contract-principal claimer)))
        (map-set funders claimer true)
        (ok true))))

(define-public (burn-ticket (ticket-id uint))
    (begin
        (asserts! (is-standard-principal-call) err-standard-principal-only)
        (asserts! (or (is-finished) (is-won)) err-invalid-status)
        (asserts! (not (is-eq (default-to u0 (var-get winner)) ticket-id)) err-cant-burn-winning-ticket)
        ;; #[allow(unchecked_data)]
        (nft-burn? felix-win-a-stacks-invader ticket-id contract-caller)))

(define-public (update-admin (new-admin principal))
    (begin
        (asserts! (is-standard-principal-call) err-standard-principal-only)
        (asserts! (is-admin contract-caller) err-admin-only)
        ;; #[allow(unchecked_data)]
        (var-set admin new-admin)
        (ok new-admin)))
