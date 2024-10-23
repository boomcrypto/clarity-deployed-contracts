;; felix-Welcome
;; v4
;; Learn more at https://felixapp.xyz/
;; ---
;;
(define-constant felix 'SP3RDC4C9B0A2FG8B7DQ9MBTFPYQZNDAVCBME8Q41)
(define-constant fee u200000)
(define-constant difficulty u3)
(define-constant ticket-price u2000000)
(define-constant number-of-tickets u1000)
(define-constant slot-size u150000000)
(define-constant number-of-slots u5)
(define-constant start-block-height u166650)
(define-constant end-block-height u167200)
(define-non-fungible-token felix-Welcome uint)

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
(define-constant err-number-already-sold (err u800))
(define-constant err-invalid-drawn-number (err u900))
(define-constant err-not-ticket-winner (err u901))
(define-constant err-funder-already-claimed (err u1000))
(define-constant err-not-funder (err u1001))
(define-constant err-refund-already-claimed (err u1002))
(define-constant err-admin-only (err u2000))
(define-constant err-cant-burn-winning-ticket (err u3000))

(define-constant BUFF_TO_BYTE (list
    0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
    0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f 
    0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
    0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
    0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
    0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f 
    0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
    0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
    0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
    0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
    0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
    0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf 
    0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf 
    0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf 
    0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
    0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
))


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
(define-private (is-admin (test-principal principal)) (is-eq (var-get admin) test-principal))

(define-private (get-random-seed)
    (begin
        (asserts! (> block-height end-block-height) err-not-ended-yet)
        (ok (sha512 (unwrap-panic (get-block-info? vrf-seed (- end-block-height u1)))))))

(define-private (pick-random-number (buffer (buff 64)))
    (let 
        ((first-byte (unwrap-panic (element-at? buffer u0)))
        (second-byte (unwrap-panic (element-at? buffer u1)))
        (third-byte (unwrap-panic (element-at? buffer u2)))
        (fourth-byte (unwrap-panic (element-at? buffer u3)))
        (fifth-byte (unwrap-panic (element-at? buffer u4))))
    (+ 
    (* (unwrap-panic (index-of? BUFF_TO_BYTE first-byte)) (pow u2 (* u8 u4)))
    (* (unwrap-panic (index-of? BUFF_TO_BYTE second-byte)) (pow u2 (* u8 u3)))
    (* (unwrap-panic (index-of? BUFF_TO_BYTE third-byte)) (pow u2 (* u8 u2)))
    (* (unwrap-panic (index-of? BUFF_TO_BYTE fourth-byte)) (pow u2 (* u8 u1)))
    (* (unwrap-panic (index-of? BUFF_TO_BYTE fifth-byte)) (pow u2 (* u8 u0))))))

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
    (ok (nft-get-owner? felix-Welcome token-id)))

(define-read-only (get-status) (ok (var-get current-status)))

(define-public (fund) 
    (let
        ((last-funder-count (var-get funder-count))
        (current-prize (var-get prize-pool))) 
    (asserts! (is-in-funding) err-invalid-status)
    (asserts! (< last-funder-count number-of-slots) err-no-funding-slot-available)
    (asserts! (not (is-funder contract-caller)) err-principal-already-funder)
    (try! (stx-transfer? slot-size contract-caller contract-principal))
    (map-insert funders contract-caller false)
    (var-set funder-count (+ last-funder-count u1))
    (var-set prize-pool (+ current-prize slot-size))
    (ok true)))

(define-public (start)
    (begin
        (asserts! (> block-height start-block-height) err-start-too-early)
        (asserts! (> (var-get funder-count) u0) err-not-funded)
        (asserts! (is-in-funding) err-invalid-status)
        (var-set current-status (active-status))
        (ok true)))

(define-public (cancel)
    (begin
        (asserts! (is-admin contract-caller) err-admin-only)
        (var-set current-status (cancelled-status))
        (ok true)))

(define-public (draw-numbers)
    (begin 
        (asserts! (is-active) err-invalid-status)
        (asserts! (> block-height end-block-height) err-not-ended-yet)
        (let
            ((lottery-numbers (unwrap-panic (pick-lottery-numbers (pick-random-number (unwrap-panic (get-random-seed)))))))
        (var-set drawn-number (some lottery-numbers))
        (try! (end-lottery))
        (ok lottery-numbers))))

(define-public (buy-ticket (recipient principal) (selected-nums uint))
    (let
        ((ticket-id (+ (var-get last-ticket-id) u1))
        (current-sells (var-get sold-tickets-pool)))
    (asserts! (is-active) err-invalid-status)
    (asserts! (< block-height (- end-block-height u6)) err-end-too-close)
    (asserts! (< (var-get last-ticket-id) number-of-tickets) err-sold-out)
    (asserts! (<= selected-nums (- (pow u10 difficulty) u1)) err-invalid-number)
    (asserts! (is-none (map-get? numbersToTicketIds selected-nums)) err-number-already-sold)
    ;; #[allow(unchecked_data)]
    (asserts! (map-insert numbersToTicketIds selected-nums ticket-id) err-couldnt-update-ticket-ids)
    ;; #[allow(unchecked_data)]
    (try! (stx-transfer? ticket-price contract-caller contract-principal))
    (try! (stx-transfer? fee contract-caller (var-get admin)))
    ;; #[allow(unchecked_data)]
    (try! (nft-mint? felix-Welcome ticket-id recipient))
    (var-set last-ticket-id ticket-id)
    (var-set sold-tickets-pool (+ current-sells ticket-price))
    (ok ticket-id)))

(define-public (claim-prize (ticket-id uint))
    (let
        ((alleged-winner-principal contract-caller)
        (prize (var-get prize-pool)))
    (asserts! (is-won) err-invalid-status)
    (asserts! (is-eq (unwrap! (nft-get-owner? felix-Welcome ticket-id) err-inexistent-ticket-id) contract-caller) err-not-ticket-owner)
    (asserts! (is-eq ticket-id (unwrap-panic (var-get winner))) err-not-ticket-winner)
    (try! (as-contract (stx-transfer? prize contract-principal alleged-winner-principal)))
    (try! (nft-burn? felix-Welcome ticket-id alleged-winner-principal))
    (ok true)))

(define-public (claim-funds)
    (let
        ((claimer contract-caller)
        (has-claimed (map-get? funders claimer)))
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
    (asserts! (is-eq (unwrap! (nft-get-owner? felix-Welcome ticket-id) err-inexistent-ticket-id) contract-caller) err-not-ticket-owner)
    (asserts! (is-cancelled) err-invalid-status)
    (try! (as-contract (stx-transfer? ticket-price contract-principal ticket-owner)))
    (try! (nft-burn? felix-Welcome ticket-id ticket-owner))
    (ok ticket-id)))

(define-public (get-fund-refund)
    (let
        ((claimer contract-caller)
        (has-refunded (unwrap! (map-get? funders claimer) err-not-funder)))
    (asserts! (is-cancelled) err-invalid-status)
    (asserts! (is-funder claimer) err-not-funder)
    (asserts! (not has-refunded) err-refund-already-claimed)
    (try! (as-contract (stx-transfer? slot-size contract-principal claimer)))
    (map-set funders claimer true)
    (ok true)))

(define-public (burn-ticket (ticket-id uint))
    (begin
        (asserts! (or (is-finished) (is-won)) err-invalid-status)
        (asserts! (not (is-eq (default-to u0 (var-get winner)) ticket-id)) err-cant-burn-winning-ticket)
        ;; #[allow(unchecked_data)]
        (nft-burn? felix-Welcome ticket-id contract-caller)))

(define-public (update-admin (new-admin principal))
    (begin
        (asserts! (is-admin contract-caller) err-admin-only)
        ;; #[allow(unchecked_data)]
        (var-set admin new-admin)
        (ok new-admin)))
