;; felix-Stoned_Welsh-STX-Community-Lotto
;; v3
;; Learn more at https://felixapp.xyz/
;; ---
;;
(define-constant felix 'SP3RDC4C9B0A2FG8B7DQ9MBTFPYQZNDAVCBME8Q41)
;; User-defined constants
;; All price-related constants are defined in Microstacks in this contract
;; 1 STX = 1_000_000 microstacks
(define-constant fee u325000) ;; How much goes to Felix on each ticket sell
(define-constant difficulty u7) ;; Translates to how many numbers will be drawn. Must be between 1 and 10
(define-constant ticket-price u3250000) ;; How much the lottery funders want to get from each ticket
(define-constant number-of-tickets u200) ;; How many tickets can be sold
(define-constant slot-size u6900000) ;; How much each funder should contribute to become part of the lottery funders group
(define-constant number-of-slots u1000) ;; How many slots there will be. Each principal can only fill one slot.
(define-constant start-block-height u166480) ;; When the lottery can start. Starting depends on the lottery being funded, the current block height being greater than this value and someone (anyone) has to call the start function
(define-constant end-block-height u167111) ;; When the lottery will end. This block height defines when tickets will stop selling and when playes will stop being able to play.
(define-non-fungible-token felix-Stoned_Welsh-STX-Community-Lotto uint) ;; The user-defined lottery name
;; Contract variables
(define-data-var drawn-number (optional uint) none) ;; The numbers that will be drawn
(define-data-var winner (optional uint) none) ;; The winner ticket id
(define-data-var prize-pool uint u0) ;; How much is the prize pool. This is basically slots * slot-size
(define-data-var sold-tickets-pool uint u0) ;; How much is the pool of sold tickets. This is basically number-of-tickets * ticket-price
(define-data-var admin principal felix) ;; Who's the current lottery admin. This is to be used by the platform in case it needs to cancel a lottery for some reason
(define-data-var next-funder-id uint u0) ;; The id of the funder is an incremental index. We keep track of what will be the next one using this variable
;; Token ID
(define-data-var last-ticket-id uint u0) ;; We start with token uid 0, so the first ticket will have id 1
(define-map funders { address: principal } { id: uint })
(define-map fund-claimers {address: principal } { reclaimed: bool})
(define-map refund-claimers {address: principal } { reclaimed: bool })
;; Using two maps to keep track of played numbers
(define-map numbers { nums: uint } { ticket-id: uint })
(define-map tickets { ticket-id: uint } { nums: uint })
;; Errors
;; Hopefully the error names are self-explanatory
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
(define-constant err-couldnt-update-ticket-ids (err u600))
(define-constant err-unable-to-end-lottery (err u700))
(define-constant err-number-already-sold (err u800))
(define-constant err-invalid-drawn-number (err u900))
(define-constant err-not-ticket-winner (err u901))
(define-constant err-funder-already-claimed (err u1000))
(define-constant err-not-funder (err u1001))
(define-constant err-refund-already-claimed (err u1002))
(define-constant err-admin-only (err u2000))
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
;; Contract Status
;; Those are all the possible states a contract can be in, and the related helper functions
(define-constant available-contract-status
    (list "funding" "active" "won" "cancelled" "finished"))
(define-private (funding-status) (unwrap-panic (element-at? available-contract-status u0)))
(define-private (active-status) (unwrap-panic (element-at? available-contract-status u1)))
(define-private (won-status) (unwrap-panic (element-at? available-contract-status u2)))
(define-private (cancelled-status) (unwrap-panic (element-at? available-contract-status u3)))
(define-private (finished-status) (unwrap-panic (element-at? available-contract-status u4)))
(define-data-var current-status (string-ascii 9) (funding-status))
;; is-active
;; ---
;; Checks if the contract is currently in Won status
;; The only path to becoming an active contract is if it was funded and started (someone called "start")
;; This function will use the current value of the current-status variable
;; @private
;; @returns bool
(define-private (is-active) (is-eq (var-get current-status) (active-status)))
;; is-won
;; ---
;; Checks if the contract is currently in Won status
;; The only path to become a Won contract is if after being funded and activated, after the drawing of the
;; numbers we find a winner
;; This function will use the current value of the current-status variable
;; @private
;; @returns bool
(define-private (is-won) (is-eq (var-get current-status) (won-status)))
;; is-finished
;; ---
;; Checks if the contract is currently in Finished status
;; The only path to become a Won contract is if after being funded and activated, after the drawing of the
;; numbers we DO NOT find a winner
;; This function will use the current value of the current-status variable
;; @private
;; @returns bool
(define-private (is-finished) (is-eq (var-get current-status) (finished-status)))
;; is-cancelled
;; ---
;; Checks if the contract is currently in Cancelled status
;; The only path to become a Cancelled contract is if the admin of the contract calls the cancel function
;; After a contract is cancelled it allows funders and ticket-buyers to refund what they spent participating
;; in the contract
;; This function will use the current value of the current-status variable
;; @private
;; @returns bool
(define-private (is-cancelled) (is-eq (var-get current-status) (cancelled-status)))
;; is-funding
;; ---
;; Checks if the contract is currently in Funding status
;; That's the initial contract state. After it was deployed, the contract goes through this period where funding should happen
;; This function will use the current value of the current-status variable
;; @private
;; @returns bool
(define-private (is-in-funding) (is-eq (var-get current-status) (funding-status)))
;; is-admin
;; ---
;; Checks whether a given principal is the admin of the contract
;; @private
;; @param {Principal} test-principal - The Principal to be tested
;; @returns bool
(define-private (is-admin (test-principal principal)) (is-eq (var-get admin) test-principal))
;; is-private
;; ---
;; Checks whether a given principal is a funder of the contract
;; @private
;; @param {Principal} test-principal - The Principal to be tested
;; @returns bool
(define-private (is-funder (test-principal principal))
    (is-some (map-get? funders (tuple (address test-principal)))))
;; is-funded
;; ---
;; Checks if at least one principal has funded the contract. This is important to allow the contract to become active,
;; since only funded contracts can become active.
;; @private
;; @returns bool
(define-private (is-funded)
    (> (var-get next-funder-id) u0))

;; NUMBER DRAWING LOGIC
;; get-random-seed
;; ---
;; This function transforms the vrf-seed of the current block height into a sha512 string we're going to later use to
;; pick a random number. The get-block-info function can only look back at blocks, hence the -1 in the block height;
;; @private
;; @returns Response<Buffer 64>
(define-private (get-random-seed)
    (begin
        (asserts! (> block-height end-block-height) err-not-ended-yet)
        (ok (sha512 (unwrap-panic (get-block-info? vrf-seed (- end-block-height u1)))))))

;; pick-random-number
;; ---
;; This function will receive a buffer and will return an unsigned integer based on it. The unsigned integer is picked
;; by transforming the Buffer addresses into bytes and then transforming those bytes into a base/10 number.
;; @private
;; @param {Buffer 64} buffer - The buffer that will work as a source for the numbers to be picked
;; @returns uInt
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

;; pick-lottery-numbers
;; ---
;; This function will help pick the number with the right amount of decimal digits given the difficulty
;; set on the contract. If the difficulty is not a uint number between 1 and 10, it will return an error
;; @private
;; @param {uint} seed - The seed to be used to pick the number
;; @throws err-invalid-difficulty
;; @returns uint
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

;; end-lottery
;; ---
;; Auxiliary function that goes through the process of ending the lottery. It can only be called if the current contract status is active.
;; It will draw a number, check for a winner, if any, and update the contract status accordingly
;; @private
;; @returns void
(define-private (end-lottery)
    (begin
        (asserts! (is-active) err-invalid-status)
        (asserts! (is-some (var-get drawn-number)) err-unable-to-end-lottery)
        (let
            ((maybe-winner (get ticket-id (map-get? numbers (tuple (nums (unwrap-panic (var-get drawn-number))))))))
        (var-set winner maybe-winner)
        (var-set current-status (if (is-some maybe-winner) (won-status) (finished-status)))
        (ok true))))

;; get-number-by-ticket-id
;; ---
;; Returns the numbers that were played for a given ticket
;; @public
;; @readonly
;; @param {uint} id - The ticket id
;; @returns optional<list<uint>>
(define-read-only (get-number-by-ticket-id (id uint))
    (ok (map-get? tickets (tuple (ticket-id id)))))

;; get-drawn-number
;; ---
;; Returns the drawn lottery number
;; @public
;; @readonly
;; @returns optional<list<uint>>
(define-read-only (get-drawn-number)
    (var-get drawn-number))

;; get-winner-ticket-id
;; ---
;; Returns the winner ticket id
;; @public
;; @readonly
;; @returns optional<uint>
(define-read-only (get-winner-ticket-id) (ok (var-get winner)))

;; get-prize-pool
;; ---
;; Returns the prize pool in the set contract monetary unit. For now this is microstacks
;; This is the prize a lottery player will get if they win the lottery
;; It is basically the slot-size * the number of funded slots
;; @public
;; @readonly
;; @returns uint
(define-read-only (get-prize-pool) (ok (var-get prize-pool)))

;; get-sold-tickets-pool
;; ---
;; Returns the prize pool in the set contract monetary unit. For now this is microstacks
;; This is the prize a lottery player will get if they win the lottery
;; It is basically the slot-size * the number of funded slots
;; @public
;; @readonly
;; @returns uint
(define-read-only (get-sold-tickets-pool) (ok (var-get sold-tickets-pool)))

;; get-prize-pool
;; ---
;; Get all the ticket ids for a given number selection
;; @public
;; @readonly
;; @returns list<uint>
(define-read-only (get-ticket-ids (num-to-check uint))
    (ok (map-get? numbers (tuple (nums num-to-check)))))

;; get-prize-pool
;; ---
;; Get the principal that owns the ticket with a given id
;; @public
;; @readonly
;; @returns list<uint>
(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? felix-Stoned_Welsh-STX-Community-Lotto token-id)))
;; get-status
;; ---
;; Get the current status of the contract
;; @public
;; @readonly
;; @returns string-ascii
(define-read-only (get-status) (ok (var-get current-status)))

;; fund
;; ---
;; Allows a principal to fund a given lottery. A principal can only fund a lottery if:
;; 1. The lottery is in funding state
;; 2. There's at least one slot available
;; 3. The principal is not already a funder
;; On fund we transfer the slot-size to the contract and update all corresponding records
;; @public
;; @returns string-ascii
(define-public (fund)
    (begin
        (let
            ((funder-index (var-get next-funder-id))
            (current-prize (var-get prize-pool)))
        (asserts! (is-in-funding) err-invalid-status)
        (asserts! (< funder-index number-of-slots) err-no-funding-slot-available)
        (asserts! (not (is-funder contract-caller)) err-principal-already-funder)
        (try! (stx-transfer? slot-size contract-caller (as-contract tx-sender)))
        (map-insert funders { address: contract-caller } { id: funder-index })
        (var-set next-funder-id (+ funder-index u1))
        (var-set prize-pool (+ current-prize slot-size))
        (ok true))))

;; start
;; ---
;; Starts the lottery. This means the lottery will now be in active state, so tickets can be sold.
;; It must be on a valid block-height: > start-block-height
;; @public
;; @returns response<bool>
(define-public (start)
    (begin
        (asserts! (> block-height start-block-height) err-start-too-early)
        (asserts! (> (var-get next-funder-id) u0) err-not-funded)
        (asserts! (is-in-funding) err-invalid-status)
        (var-set current-status (active-status))
        (ok true)))

;; cancel
;; ---
;; Cancels a lottery.
;; Only the contract admin can call it. This function is a "panic button", in case we find something wrong with the contract
;; Only checks if the lottery was not cancelled yet and if the caller is indeed the contract admin
;; @public
;; @readonly
;; @returns response<bool>
(define-public (cancel)
    (begin
        (asserts! (is-admin contract-caller) err-admin-only)
        (var-set current-status (cancelled-status))
        (ok true)))

;; draw-numbers
;; ---
;; After the network reached the end-block height, the lottery can be drawn. This function handles this. It will generate a random
;; number based on the set difficulty and derived from the vrf-seed of the previous block. It will also check and set the lottery
;; winner if any, and move the contract to what should be its final state which can be finalized or won.
;; asserts
;; @public
;; @returns response<uint>
(define-public (draw-numbers)
    (begin
        (asserts! (is-active) err-invalid-status)
        (asserts! (> block-height end-block-height) err-not-ended-yet)
        (let
            ((random-seed (try! (get-random-seed)))
            (seed-number (pick-random-number random-seed))
            (lottery-numbers (unwrap-panic (pick-lottery-numbers seed-number))))
        (var-set drawn-number (some lottery-numbers))
        (try! (end-lottery))
        (ok lottery-numbers))))

;; buy-ticket
;; ---
;; Generates a ticket (which is effectively minting an NFT) to a recipient with the selected numbers.
;; The number must comply with the difficulty set on the contract. If the number is already taken, it will return an error.
;; Asserts that the number was not selected;
;; Asserts that the block-height is at least 5 blocks away from the lottery end-block;
;; Asserts that the lottery is not sold out
;; Asserts that the lottery is active
;; @public
;; @param {principal} recipient - who will be the ticket owner
;; @param {list<uint>} selected-nums - the number the ticket will be playing on the lottery
;; @returns response<uint> -- ticket-id
(define-public (buy-ticket (recipient principal) (selected-nums uint))
    (begin
        (asserts! (is-active) err-invalid-status)
        (asserts! (< block-height (- end-block-height u6)) err-end-too-close)
        (asserts! (< (var-get last-ticket-id) number-of-tickets) err-sold-out)
        (asserts! (<= selected-nums (- (pow u10 difficulty) u1)) err-invalid-number)
        (asserts! (is-none (map-get? numbers (tuple (nums selected-nums)))) err-number-already-sold)
        (let
            ((ticket-id (+ (var-get last-ticket-id) u1))
            (current-sells (var-get sold-tickets-pool)))
        ;; We can always insert a ticket when buying, since they all should be unique
        ;; When we insert a ticket, we also update the numbers map to keep them in sync
        ;; #[allow(unchecked_data)]
        (asserts! (map-insert tickets { ticket-id: ticket-id } { nums: selected-nums }) err-couldnt-update-ticket-ids)
        ;; #[allow(unchecked_data)]
        (asserts! (map-insert numbers { nums: selected-nums } { ticket-id: ticket-id }) err-couldnt-update-ticket-ids)
        ;; #[allow(unchecked_data)]
        (try! (stx-transfer? ticket-price contract-caller (as-contract tx-sender)))
        (try! (stx-transfer? fee contract-caller (var-get admin)))
        ;; #[allow(unchecked_data)]
        (try! (nft-mint? felix-Stoned_Welsh-STX-Community-Lotto ticket-id recipient))
        (var-set last-ticket-id ticket-id)
        (var-set sold-tickets-pool (+ current-sells ticket-price))
        (ok ticket-id))))

;; claim-prize
;; ---
;; Allows the winner to claim their prize. To call it the contract must be in won status, and the caller must be the
;; token owner. This function will verify if they are indeed the winners and if so, will transfer the prize
;; @public
;; @param {uint} ticket-id - the id of the (supposed) winning ticket
;; @returns response<uint> -- ticket-id
(define-public (claim-prize (ticket-id uint))
    (begin
        (asserts! (is-won) err-invalid-status)
        (asserts! (is-eq ticket-id (unwrap-panic (var-get winner))) err-not-ticket-winner)
        (asserts! (is-eq (unwrap! (nft-get-owner? felix-Stoned_Welsh-STX-Community-Lotto ticket-id) err-inexistent-ticket-id) contract-caller) err-not-ticket-owner)
        (let
            ((contract-principal (as-contract tx-sender))
            (winner-principal contract-caller)
            (prize (var-get prize-pool)))
        (try! (as-contract (stx-transfer? prize contract-principal winner-principal)))
        (try! (nft-burn? felix-Stoned_Welsh-STX-Community-Lotto ticket-id winner-principal))
        (ok true))))

;; claim-funds
;; ---
;; Allows the funders to claim the collected funds and get their funded slot back in case the lottery was finished but had no winners.
;; @public
;; @returns response<true>
(define-public (claim-funds)
    (let
        ((claimer contract-caller)
        (has-claimed (is-some (map-get? fund-claimers (tuple (address claimer))))))
    (begin
        (asserts! (not has-claimed) err-funder-already-claimed)
        (asserts! (is-funder claimer) err-not-funder)
        (asserts! (or (is-won) (is-finished)) err-invalid-status)
        (let
            ((number-of-funders (var-get next-funder-id))
            (contract-principal (as-contract tx-sender))
            (sold-ticket-part (/ (var-get sold-tickets-pool) number-of-funders))
            (fund-return (if (is-won) u0 slot-size))
            (total-claim (+ sold-ticket-part fund-return)))
        (try! (as-contract (stx-transfer? total-claim contract-principal claimer)))
        (map-insert fund-claimers { address: claimer } { reclaimed: true })
        (ok true)))))

;; get-ticket-refund
;; ---
;; Allows a ticket owner to get back the ticket price in case the lottery is cancelled.
;; It will assert that the sender is the ticket owner and that the contract is cancelled
;; On refund the nft is burnt, so we guarantee every ticket is only refunded once
;; @public
;; @param {uint} ticket-id - the id of the ticket
;; @returns response<uint>
(define-public (get-ticket-refund (ticket-id uint))
    (begin
        (asserts! (is-eq (unwrap! (nft-get-owner? felix-Stoned_Welsh-STX-Community-Lotto ticket-id) err-inexistent-ticket-id) contract-caller) err-not-ticket-owner)
        (asserts! (is-cancelled) err-invalid-status)
        (let
            ((ticket-owner contract-caller)
            (contract-principal (as-contract tx-sender)))
        (try! (as-contract (stx-transfer? ticket-price contract-principal ticket-owner)))
        (try! (nft-burn? felix-Stoned_Welsh-STX-Community-Lotto ticket-id ticket-owner)))
        (ok ticket-id)))

;; get-fund-refund 
;; ---
;; Allows a lottery funder to get back their funds in case the lottery is cancelled
;; It will assert that the sender is a funder, that the contract was still cancelled and that the funder didn't get a refund yet
;; @public
;; @returns response<true>
(define-public (get-fund-refund)
    (let
        ((claimer contract-caller)
        (contract-principal (as-contract tx-sender))
        (has-refunded (is-some (map-get? refund-claimers (tuple (address claimer))))))
    (begin
        (asserts! (is-cancelled) err-invalid-status)
        (asserts! (is-funder claimer) err-not-funder)
        (asserts! (not has-refunded) err-refund-already-claimed)
        (try! (as-contract (stx-transfer? slot-size contract-principal claimer)))
        (map-insert refund-claimers { address: claimer } { reclaimed: true })
        (ok true))))

;; update-admin
;; ---
;; Allows a lottery admin to update the admin principal address
;; @public
;; @returns response<principal>
(define-public (update-admin (new-admin principal))
    (begin
        ;; #[allow(unchecked_data)]
        (asserts! (is-admin contract-caller) err-admin-only)
        (var-set admin new-admin)
        (ok new-admin)))
