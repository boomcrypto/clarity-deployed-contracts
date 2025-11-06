;; ---------------------------------------------------------
;; Lottery Contract - by STX.CITY
;; ---------------------------------------------------------

;; This lottery contract allows users to buy tickets for 10 STX each
;; The lottery concludes when 30 tickets are sold (300 STX)
;; A winner is randomly selected from the purchased tickets

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-LOTTERY-ACTIVE u402)
(define-constant ERR-LOTTERY-INACTIVE u403)
(define-constant ERR-GOAL-NOT-REACHED u404)
(define-constant ERR-ALREADY-REVEALED u405)
(define-constant ERR-INVALID-TICKET u406)
(define-constant ERR_FAIL_RANDOM u407)
(define-constant ERR-INVALID-RECIPIENT u408)


;; Constants
(define-constant TICKET-PRICE u10000000) 
(define-constant MAX-TICKETS u30) 
(define-constant LOTTERY-GOAL (* TICKET-PRICE MAX-TICKETS)) 
(define-constant FEE-AMOUNT u20000000) 
(define-constant STXCITY-ADDRESS 'SP2BABPYDZ8B21XHW37Y5Z7SX8RFC33JCQ1K3N2H1)

;; Variables
(define-data-var lottery-active bool true)
(define-data-var lottery-id uint u1)
(define-data-var ticket-counter uint u0)
(define-data-var total-raised uint u0)
(define-data-var winner-revealed bool false)
(define-data-var winner-ticket-id (optional uint) none)
(define-data-var winner-address (optional principal) none)
(define-data-var contract-owner principal tx-sender)

;; Data structures
(define-map tickets 
  { lottery-id: uint, ticket-id: uint } 
  { buyer: principal }
)

(define-map user-tickets 
  { lottery-id: uint, user: principal } 
  { ticket-ids: (list 30 uint) }
)

(define-read-only (get-ticket-info-test)
    (ok {
        block-info: (get-stacks-block-info? id-header-hash (- stacks-block-height u1)),
        current-height: stacks-block-height
    })
)

(define-read-only (get-random-number-test)
  (let (
    ;; Try to get VRF random number first
    (vrf-result (get-random-uint-at-block))
    ;; Fallback to block hash if VRF fails
    (block-hash (unwrap-panic (get-stacks-block-info? id-header-hash (- stacks-block-height u1))))
    (fallback-random (mod (+ stacks-block-height (len block-hash)) u1000000))
    ;; Use VRF if available, otherwise use fallback
    (random-value (default-to fallback-random vrf-result))
    (random-index (mod random-value (var-get ticket-counter)))
  )
    random-index
  )
)

(define-private (add-ticket-id-to-user (user principal) (ticket-id uint))
  (let (
    (current-lottery-id (var-get lottery-id))
    (user-ticket-map-key { lottery-id: current-lottery-id, user: user })
    (existing-tickets (default-to { ticket-ids: (list) } (map-get? user-tickets user-ticket-map-key)))
    (updated-ticket-ids (unwrap-panic (as-max-len? (append (get ticket-ids existing-tickets) ticket-id) u30)))
  )
    (map-set user-tickets 
      user-ticket-map-key
      { ticket-ids: updated-ticket-ids }
    )
  )
)

;; Public functions
;; Buy a ticket for yourself
(define-public (buy-ticket)
  (buy-ticket-for tx-sender)
)


;; Buy a ticket for a friend

(define-public (buy-ticket-for-friend (friend principal))
  ;; Check that friend is not the contract itself
  (let ((contract (as-contract tx-sender)))
    (asserts! (not (is-eq friend contract)) (err ERR-INVALID-RECIPIENT))
    (buy-ticket-for friend)
  )
)
;; Internal function to handle ticket purchase
(define-private (buy-ticket-for (recipient principal))
  (let (
    (buyer tx-sender)
    (current-lottery-id (var-get lottery-id))
    (current-ticket-id (var-get ticket-counter))
  )
    ;; Check if lottery is active
    (asserts! (var-get lottery-active) (err ERR-LOTTERY-INACTIVE))
    
    ;; Check if we haven't reached max tickets
    (asserts! (< current-ticket-id MAX-TICKETS) (err ERR-LOTTERY-INACTIVE))
    
    ;; Transfer STX from buyer to contract
    (try! (stx-transfer? TICKET-PRICE buyer (as-contract tx-sender)))
    
    ;; Record the ticket purchase with recipient as the owner
    (map-set tickets 
      { lottery-id: current-lottery-id, ticket-id: current-ticket-id }
      { buyer: recipient }
    )
    
    ;; Add ticket to recipient's list of tickets
    (add-ticket-id-to-user recipient current-ticket-id)
    
    ;; Update counters
    (var-set ticket-counter (+ current-ticket-id u1))
    (var-set total-raised (+ (var-get total-raised) TICKET-PRICE))
    
    ;; Check if goal reached and close lottery if needed
    (if (>= (var-get total-raised) LOTTERY-GOAL)
      (var-set lottery-active false)
      true
    )
    
    ;; Return success with ticket info
    (ok { ticket-id: current-ticket-id, recipient: recipient })
  )
)

(define-public (reveal-winner)
  (let (
    (current-lottery-id (var-get lottery-id))
    (tickets-sold (var-get ticket-counter))
  )
    ;; Check if lottery is inactive (completed)
    (asserts! (not (var-get lottery-active)) (err ERR-LOTTERY-ACTIVE))
    
    ;; Check if goal has been reached
    (asserts! (>= (var-get total-raised) LOTTERY-GOAL) (err ERR-GOAL-NOT-REACHED))
    
    ;; Check if winner has not been revealed yet
    (asserts! (not (var-get winner-revealed)) (err ERR-ALREADY-REVEALED))
    
    ;; Generate random winner ticket ID using VRF with fallback
    (let (
      ;; Try to get VRF random number first
      (vrf-result (get-random-uint-at-block))
      ;; Fallback to block hash if VRF fails
      (block-hash (unwrap-panic (get-stacks-block-info? id-header-hash (- stacks-block-height u1))))
      (fallback-random (mod (+ stacks-block-height (len block-hash)) u1000000))
      ;; Use VRF if available, otherwise use fallback
      (random-value (default-to fallback-random vrf-result))
      ;; Ensure the random index is within the range of sold tickets
      (random-index (mod random-value tickets-sold))
      (winning-ticket (unwrap-panic (map-get? tickets { lottery-id: current-lottery-id, ticket-id: random-index })))
      (winner (get buyer winning-ticket))
    )
      
      ;; Calculate prize amount after fee
      (let (
        (total-amount (var-get total-raised))
        (prize-amount (- total-amount FEE-AMOUNT))
      )
        ;; Transfer fee to STXCITY
        (try! (as-contract (stx-transfer? FEE-AMOUNT tx-sender STXCITY-ADDRESS)))
        
        ;; Transfer remaining prize to winner
        (try! (as-contract (stx-transfer? prize-amount tx-sender winner)))
      )
      
      ;; Set winner information
      (var-set winner-ticket-id (some random-index))
      (var-set winner-address (some winner))
      (var-set winner-revealed true)

      ;; Return winner info
      (ok { 
        lottery-id: current-lottery-id, 
        ticket-id: random-index, 
        winner: winner,
        prize-amount: (- (var-get total-raised) FEE-AMOUNT)
      })
    )
  )
)

(define-public (start-new-lottery)
  (begin
    
    
    ;; Check if current lottery is inactive and winner has been revealed
    (asserts! (and (not (var-get lottery-active)) (var-get winner-revealed)) (err ERR-LOTTERY-ACTIVE))
    
    ;; Reset lottery state for a new round
    (var-set lottery-active true)
    (var-set lottery-id (+ (var-get lottery-id) u1))
    (var-set ticket-counter u0)
    (var-set total-raised u0)
    (var-set winner-revealed false)
    (var-set winner-ticket-id none)
    (var-set winner-address none)
    
    (ok (var-get lottery-id))
  )
)

;; Read-only functions
(define-read-only (get-lottery-status)
  {
    lottery-id: (var-get lottery-id),
    active: (var-get lottery-active),
    tickets-sold: (var-get ticket-counter),
    total-raised: (var-get total-raised),
    goal: LOTTERY-GOAL,
    winner-revealed: (var-get winner-revealed),
    winner-ticket-id: (var-get winner-ticket-id),
    winner-address: (var-get winner-address),
    ticket-price: TICKET-PRICE,
    max-tickets: MAX-TICKETS,
    fee-amount: FEE-AMOUNT,
  }
)

(define-read-only (get-ticket-info (ticket-id uint))
  (let (
    (current-lottery-id (var-get lottery-id))
  )
    (map-get? tickets { lottery-id: current-lottery-id, ticket-id: ticket-id })
  )
)

(define-read-only (get-user-tickets (user principal))
  (let (
    (current-lottery-id (var-get lottery-id))
  )
    (default-to { ticket-ids: (list) } 
      (map-get? user-tickets { lottery-id: current-lottery-id, user: user })
    )
  )
)

;; Contract owner management
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (var-set contract-owner new-owner)
    (ok true)
  )
)

;; Random helper functions

;; Read the on-chain VRF and turn the lower 16 bytes into a uint, in order to sample the set of miners and determine
;; which one may claim the token batch for the given block height.
(define-read-only (get-random-uint-at-block)
  (let (
    (vrf-lower-uint-opt
      (match (get-tenure-info? vrf-seed (- stacks-block-height u1))
        vrf-seed (some (buff-to-uint-le (lower-16-le vrf-seed)))
        none))
  )
  vrf-lower-uint-opt)
)

;; UTILITIES

;; lookup table for converting 1-byte buffers to uints via index-of
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

;; Convert a 1-byte buffer into its uint representation.
(define-private (buff-to-u8 (byte (buff 1)))
  (unwrap-panic (index-of BUFF_TO_BYTE byte))
)

;; Note: This function is no longer needed as we're using the built-in buff-to-uint-le
;; Keeping the function signature for compatibility with lower-16-le function
(define-private (add-and-shift-uint-le (idx uint) (input { acc: uint, data: (buff 16) }))
  input
)

;; Convert the lower 16 bytes of a buff into a little-endian uint.
(define-private (lower-16-le (input (buff 32)))
  (get acc
    (fold lower-16-le-closure (list u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31) { acc: 0x, data: input })
  )
)

;; Inner closure for obtaining the lower 16 bytes of a 32-byte buff
(define-private (lower-16-le-closure (idx uint) (input { acc: (buff 16), data: (buff 32) }))
  (let (
    (acc (get acc input))
    (data (get data input))
    (byte (unwrap-panic (element-at data idx)))
  )
  {
    acc: (unwrap-panic (as-max-len? (concat acc byte) u16)),
    data: data
  })
)