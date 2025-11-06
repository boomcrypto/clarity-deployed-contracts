;; ---------------------------------------------------------
;; Lottery Contract - 4 Winners Mode - by STX.CITY
;; ---------------------------------------------------------

;; This lottery contract allows users to buy tickets for 10 STX each
;; The lottery concludes when 30 tickets are sold (300 STX)
;; Four winners are randomly selected from the purchased tickets
;; Each winner receives 70 STX

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-LOTTERY-ACTIVE u402)
(define-constant ERR-LOTTERY-INACTIVE u403)
(define-constant ERR-GOAL-NOT-REACHED u404)
(define-constant ERR-ALREADY-REVEALED u405)
(define-constant ERR-INVALID-TICKET u406)
(define-constant ERR_FAIL_RANDOM u407)
(define-constant ERR-INVALID-RECIPIENT u408)
(define-constant ERR-NOT-ENOUGH-PARTICIPANTS u409)


;; Constants
(define-constant TICKET-PRICE u10000000) ;; 10 STX in microSTX
(define-constant MAX-TICKETS u30) ;; Maximum number of tickets
(define-constant LOTTERY-GOAL (* TICKET-PRICE MAX-TICKETS)) ;; Goal calculated from ticket price * max tickets
(define-constant FEE-AMOUNT u20000000) ;; 20 STX fee in microSTX
(define-constant STXCITY-ADDRESS 'SP2BABPYDZ8B21XHW37Y5Z7SX8RFC33JCQ1K3N2H1)
(define-constant WINNER-COUNT u4) ;; Number of winners
(define-constant PRIZE-PER-WINNER u70000000) ;; 70 STX per winner in microSTX

;; Variables
(define-data-var lottery-active bool true)
(define-data-var lottery-id uint u1)
(define-data-var ticket-counter uint u0)
(define-data-var total-raised uint u0)
(define-data-var winner-revealed bool false)
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

;; Map to store winner information
(define-map winners
  { lottery-id: uint, position: uint }
  { ticket-id: uint, winner: principal, prize-amount: uint }
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

;; Helper function to try selecting a winner
(define-private (try-select-winner 
    (current-lottery-id uint) 
    (tickets-sold uint) 
    (used-indices (list 4 uint)) 
    (seed uint)
  )
  (let (
    ;; Generate a random value based on the seed
    (random-value (mod (+ seed stacks-block-height) u1000000))
    ;; Select a random ticket
    (random-index (mod random-value tickets-sold))
  )
    ;; Check if this index is already used
    (if (is-some (index-of used-indices random-index))
      ;; If already used, return none
      none
      ;; If not used, return the index
      (some random-index))
  )
)

;; Helper function to get a unique ticket index that hasn't been selected before
;; Non-recursive approach to avoid stack overflow
(define-private (get-unique-ticket-index 
    (current-lottery-id uint) 
    (tickets-sold uint) 
    (used-indices (list 4 uint)) 
    (seed uint)
  )
  (let (
    ;; Try to select a winner with the initial seed
    (attempt-1 (try-select-winner current-lottery-id tickets-sold used-indices seed))
    ;; If first attempt fails, try with seed + 1
    (attempt-2 (if (is-some attempt-1) 
                  attempt-1 
                  (try-select-winner current-lottery-id tickets-sold used-indices (+ seed u1))))
    ;; If second attempt fails, try with seed + 2
    (attempt-3 (if (is-some attempt-2) 
                  attempt-2 
                  (try-select-winner current-lottery-id tickets-sold used-indices (+ seed u2))))
    ;; If third attempt fails, try with seed + 3
    (attempt-4 (if (is-some attempt-3) 
                  attempt-3 
                  (try-select-winner current-lottery-id tickets-sold used-indices (+ seed u3))))
    ;; If fourth attempt fails, try with seed + 4
    (attempt-5 (if (is-some attempt-4) 
                  attempt-4 
                  (try-select-winner current-lottery-id tickets-sold used-indices (+ seed u4))))
    ;; If all attempts fail, use a fallback approach with a different calculation
    (fallback-index (mod (+ seed stacks-block-height (len used-indices)) tickets-sold))
  )
    ;; Return the first successful attempt or fallback to a different calculation
    (default-to fallback-index (match attempt-5 value (some value) none))
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
    
    ;; Check if we have enough participants for 4 winners
    (asserts! (>= tickets-sold WINNER-COUNT) (err ERR-NOT-ENOUGH-PARTICIPANTS))
    
    ;; Generate random seed using VRF with fallback
    (let (
      ;; Try to get VRF random number first
      (vrf-result (get-random-uint-at-block))
      ;; Fallback to block hash if VRF fails
      (block-hash (unwrap-panic (get-stacks-block-info? id-header-hash (- stacks-block-height u1))))
      (fallback-random (mod (+ stacks-block-height (len block-hash)) u1000000))
      ;; Use VRF if available, otherwise use fallback
      (initial-seed (default-to fallback-random vrf-result))
      
      ;; Transfer fee to STXCITY
      (fee-transfer-result (try! (as-contract (stx-transfer? FEE-AMOUNT tx-sender STXCITY-ADDRESS))))
      
      ;; Use four different random seeds to select four unique winners
      ;; This approach uses different base seeds for each winner selection
      ;; to improve randomness and avoid potential correlation
      
      ;; Initialize empty list of used indices
      (used-indices (list))
      
      ;; Select first winner with initial seed
      (first-index (get-unique-ticket-index current-lottery-id tickets-sold used-indices initial-seed))
      (first-ticket (unwrap-panic (map-get? tickets { lottery-id: current-lottery-id, ticket-id: first-index })))
      (first-winner (get buyer first-ticket))
      
      ;; Add first index to used indices
      (used-indices-1 (append used-indices first-index))
      
      ;; Select second winner with a different seed calculation
      (second-seed (mod (+ (mod initial-seed u1000) (mod stacks-block-height u1000)) u1000))
      (second-index (get-unique-ticket-index current-lottery-id tickets-sold used-indices-1 second-seed))
      (second-ticket (unwrap-panic (map-get? tickets { lottery-id: current-lottery-id, ticket-id: second-index })))
      (second-winner (get buyer second-ticket))
      
      ;; Add second index to used indices
      (used-indices-2 (append used-indices-1 second-index))
      
      ;; Select third winner with another different seed calculation
      (third-seed (mod (+ (mod initial-seed u1000) (mod (* stacks-block-height u2) u1000)) u1000))
      (third-index (get-unique-ticket-index current-lottery-id tickets-sold used-indices-2 third-seed))
      (third-ticket (unwrap-panic (map-get? tickets { lottery-id: current-lottery-id, ticket-id: third-index })))
      (third-winner (get buyer third-ticket))
      
      ;; Add third index to used indices
      (used-indices-3 (append used-indices-2 third-index))
      
      ;; Select fourth winner with yet another different seed calculation
      (fourth-seed (mod (+ (mod initial-seed u1000) (mod (* stacks-block-height u3) u1000)) u1000))
      (fourth-index (get-unique-ticket-index current-lottery-id tickets-sold used-indices-3 fourth-seed))
      (fourth-ticket (unwrap-panic (map-get? tickets { lottery-id: current-lottery-id, ticket-id: fourth-index })))
      (fourth-winner (get buyer fourth-ticket))
    )
      ;; Transfer prizes to all winners (70 STX each)
      (try! (as-contract (stx-transfer? PRIZE-PER-WINNER tx-sender first-winner)))
      (try! (as-contract (stx-transfer? PRIZE-PER-WINNER tx-sender second-winner)))
      (try! (as-contract (stx-transfer? PRIZE-PER-WINNER tx-sender third-winner)))
      (try! (as-contract (stx-transfer? PRIZE-PER-WINNER tx-sender fourth-winner)))
      
      ;; Store winner information in the map
      (map-set winners { lottery-id: current-lottery-id, position: u0 }
        { ticket-id: first-index, winner: first-winner, prize-amount: PRIZE-PER-WINNER })
      (map-set winners { lottery-id: current-lottery-id, position: u1 }
        { ticket-id: second-index, winner: second-winner, prize-amount: PRIZE-PER-WINNER })
      (map-set winners { lottery-id: current-lottery-id, position: u2 }
        { ticket-id: third-index, winner: third-winner, prize-amount: PRIZE-PER-WINNER })
      (map-set winners { lottery-id: current-lottery-id, position: u3 }
        { ticket-id: fourth-index, winner: fourth-winner, prize-amount: PRIZE-PER-WINNER })
      
      ;; Mark winners as revealed
      (var-set winner-revealed true)

      ;; Return winner info
      (ok { 
        lottery-id: current-lottery-id,
        winners: (list 
          { ticket-id: first-index, winner: first-winner, prize-amount: PRIZE-PER-WINNER }
          { ticket-id: second-index, winner: second-winner, prize-amount: PRIZE-PER-WINNER }
          { ticket-id: third-index, winner: third-winner, prize-amount: PRIZE-PER-WINNER }
          { ticket-id: fourth-index, winner: fourth-winner, prize-amount: PRIZE-PER-WINNER }
        ),
        total-prize-amount: (* PRIZE-PER-WINNER WINNER-COUNT)
      })
    )
  )
)

(define-public (start-new-lottery)
  (begin
    ;; Check if current lottery is inactive and winners have been revealed
    (asserts! (and (not (var-get lottery-active)) (var-get winner-revealed)) (err ERR-LOTTERY-ACTIVE))
    
    ;; Reset lottery state for a new round
    (var-set lottery-active true)
    (var-set lottery-id (+ (var-get lottery-id) u1))
    (var-set ticket-counter u0)
    (var-set total-raised u0)
    (var-set winner-revealed false)
    
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
    ticket-price: TICKET-PRICE,
    max-tickets: MAX-TICKETS,
    fee-amount: FEE-AMOUNT,
    winner-count: WINNER-COUNT,
    prize-per-winner: PRIZE-PER-WINNER,
    winner-1: (map-get? winners { lottery-id: (var-get lottery-id), position: u0 }),
    winner-2: (map-get? winners { lottery-id: (var-get lottery-id), position: u1 }),
    winner-3: (map-get? winners { lottery-id: (var-get lottery-id), position: u2 }),
    winner-4: (map-get? winners { lottery-id: (var-get lottery-id), position: u3 })
  }
)

(define-read-only (get-lottery-winners (lottery-id-param uint))
  (let (
    (winner1 (map-get? winners { lottery-id: lottery-id-param, position: u0 }))
    (winner2 (map-get? winners { lottery-id: lottery-id-param, position: u1 }))
    (winner3 (map-get? winners { lottery-id: lottery-id-param, position: u2 }))
    (winner4 (map-get? winners { lottery-id: lottery-id-param, position: u3 }))
  )
    {
      lottery-id: lottery-id-param,
      winners: (list 
        (default-to { ticket-id: u0, winner: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM, prize-amount: u0 } winner1)
        (default-to { ticket-id: u0, winner: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM, prize-amount: u0 } winner2)
        (default-to { ticket-id: u0, winner: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM, prize-amount: u0 } winner3)
        (default-to { ticket-id: u0, winner: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM, prize-amount: u0 } winner4)
      ),
      total-prize-amount: (* PRIZE-PER-WINNER WINNER-COUNT)
    }
  )
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