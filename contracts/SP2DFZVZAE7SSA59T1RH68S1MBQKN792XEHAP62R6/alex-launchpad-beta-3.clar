(impl-trait .trait-ownable.ownable-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)


;; alex-launchpad

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-USER-ALREADY-REGISTERED (err u10001))
(define-constant ERR-USER-ID-NOT-FOUND (err u10003))
(define-constant ERR-INVALID-TOKEN (err u2026))
(define-constant ERR-INVALID-TICKET (err u2028))
(define-constant ERR-NO-VRF-SEED-FOUND (err u2030))
(define-constant ERR-CLAIM-NOT-AVAILABLE (err u2031))
(define-constant ERR-REGISTRATION-STARTED (err u2033))
(define-constant ERR-REGISTRATION-NOT-STARTED (err u2034))
(define-constant ERR-LISTING-ACTIVATED (err u2035))
(define-constant ERR-LISTING-NOT-ACTIVATED (err u2036))
(define-constant ERR-INVALID-REGISTRATION-PERIOD (err u2037))
(define-constant ERR-REGISTRATION-ENDED (err u2038))
(define-constant ERR-REGISTRATION-NOT-ENDED (err u2039))
(define-constant ERR-CLAIM-ENDED (err u2040))
(define-constant ERR-CLAIM-NOT-ENDED (err u2041))
(define-constant ERR-INVALID-CLAIM-PERIOD (err u2042))
(define-constant ERR-REFUND-NOT-AVAILABLE (err u2043))

(define-constant ONE_8 (pow u10 u8)) ;; 8 decimal places

(define-data-var contract-owner principal tx-sender)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-owner owner))
  )
)

(define-map listing 
  principal
  {    
    ticket: principal,
    fee-to-address: principal,
    total-tickets: uint,
    amount-per-ticket: uint,
    wstx-per-ticket-in-fixed: uint,
    total-subscribed: uint,
    registration-start: uint,
    registration-end: uint,
    claim-end: uint,
    activation-threshold: uint,
    users-nonce: uint,
    last-random: uint,
    tickets-won: uint,
    activated: bool    
  }
)

(define-map subscriber-at-token
  {
    token: principal,
    user-id: uint
  }
  {
    ticket-balance: uint,
    value-low: uint,
    value-high: uint,
    tickets-won: uint,
    tickets-lost: uint,
    wstx-locked-in-fixed: uint
  }
)

;; store user principal by user id
(define-map users 
  {
    token: principal,
    user-id: uint
  }
  principal
)
;; store user id by user principal
(define-map user-ids 
  {
    token: principal,
    user: principal
  }
  uint
)

;; wstx-per-ticket-in-fixed => 8 decimal
;; all others => zero decimal
(define-public (create-pool (token-trait <ft-trait>) (ticket-trait <ft-trait>) (fee-to-address principal) (amount-per-ticket uint) (wstx-per-ticket-in-fixed uint) (registration-start uint) (registration-end uint) (claim-end uint) (activation-threshold uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (> registration-end registration-start) ERR-INVALID-REGISTRATION-PERIOD)
    (asserts! (> claim-end registration-end) ERR-INVALID-CLAIM-PERIOD)
    (map-set listing 
      (contract-of token-trait)
      {        
        ticket: (contract-of ticket-trait), 
        fee-to-address: fee-to-address,
        amount-per-ticket: amount-per-ticket,
        wstx-per-ticket-in-fixed: wstx-per-ticket-in-fixed, 
        total-subscribed: u0,
        total-tickets: u0, 
        registration-start: registration-start,
        registration-end: registration-end,
        claim-end: claim-end,
        activation-threshold: activation-threshold,
        users-nonce: u0,
        last-random: u0,
        tickets-won: u0,
        activated: false        
      }
    )    
    (ok true)
  )
)

(define-public (add-to-position (token-trait <ft-trait>) (tickets uint))
  (let
    (
      (details (unwrap! (map-get? listing (contract-of token-trait)) ERR-INVALID-TOKEN)) 
    )
    (asserts! (is-eq (get fee-to-address details) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (< block-height (get registration-start details)) ERR-REGISTRATION-STARTED)
    (asserts! (> tickets u0) ERR-INVALID-TICKET)

    (map-set listing (contract-of token-trait) (merge details { total-tickets: (+ (get total-tickets details) tickets ) }))
    
    (ok
      (unwrap! (contract-call? token-trait transfer-fixed (* (get amount-per-ticket details) tickets ONE_8) tx-sender (as-contract tx-sender) none) ERR-TRANSFER-FAILED)
    )
  )
)

;; returns activation threshold
(define-read-only (get-activation-threshold (token principal))
  (ok (get activation-threshold (unwrap! (map-get? listing token) ERR-INVALID-TOKEN)))
)

(define-read-only (get-registration-start (token principal))
  (ok (get registration-start (unwrap! (map-get? listing token) ERR-INVALID-TOKEN)))
)

(define-read-only (get-registration-end (token principal))
  (ok (get registration-end (unwrap! (map-get? listing token) ERR-INVALID-TOKEN)))
)

(define-read-only (get-claim-end (token principal))
  (ok (get claim-end (unwrap! (map-get? listing token) ERR-INVALID-TOKEN)))
)

(define-read-only (is-listing-completed (token principal))
  (let
    (
      (details (unwrap! (map-get? listing token) ERR-INVALID-TOKEN))
    )
    (ok (is-eq (get tickets-won details) (get total-tickets details)))
  )
)

(define-read-only (is-listing-activated (token principal))
  (let
    (
      (details (unwrap! (map-get? listing token) ERR-INVALID-TOKEN))
    )
    (ok (>= (get total-subscribed details) (get activation-threshold details)))
  )
)

;; returns (some listing) or none
(define-read-only (get-listing-details (token principal))
  (map-get? listing token)
)

;; returns (some user-id) or none
(define-read-only (get-user-id (token principal) (user principal))
  (map-get? user-ids {token: token, user: user})
)

;; returns (some user-principal) or none
(define-read-only (get-user (token principal) (user-id uint))
  (map-get? users {token: token, user-id: user-id})
)

;; returns (some number of registered users), used for activation and tracking user IDs, or none
(define-read-only (get-registered-users-nonce (token principal))
  (ok (get users-nonce (unwrap! (map-get? listing token) ERR-INVALID-TOKEN)))
)

;; returns user ID if it has been created, or creates and returns new ID
(define-private (get-or-create-user-id (token principal) (user principal))
  (match
    (map-get? user-ids {token: token, user: user})
    value
    (ok value)
    (let
      (
        (new-id (+ u1 (try! (get-registered-users-nonce token))))
      )
      (map-insert users {token: token, user-id: new-id} user)
      (map-insert user-ids {token: token, user: user} new-id)
      (ok new-id)
    )
  )
)

(define-public (register (token principal) (ticket-trait <ft-trait>) (ticket-amount uint))
  (begin
    (asserts! (is-none (get-user-id token tx-sender)) ERR-USER-ALREADY-REGISTERED)    
    (let
      (
        (details (unwrap! (map-get? listing token) ERR-INVALID-TOKEN))
        (user-id (try! (get-or-create-user-id token tx-sender)))
        (value-low (+ u1 (get total-subscribed details)))
        (value-high (- (+ value-low ticket-amount) u1))
        (wstx-locked-in-fixed (* ticket-amount (get wstx-per-ticket-in-fixed details)))
        (activated (>= value-high (get activation-threshold details)))
      )
      (asserts! (>= block-height (get registration-start details)) ERR-REGISTRATION-NOT-STARTED)
      (asserts! (<= block-height (get registration-end details)) ERR-REGISTRATION-ENDED)      
      (asserts! (and (is-eq (contract-of ticket-trait) (get ticket details)) (> ticket-amount u0)) ERR-INVALID-TICKET)
    
      (unwrap! (contract-call? ticket-trait transfer-fixed (* ticket-amount ONE_8) tx-sender (as-contract tx-sender) none) ERR-TRANSFER-FAILED)
      (unwrap! (contract-call? .token-wstx transfer-fixed wstx-locked-in-fixed tx-sender (as-contract tx-sender) none) ERR-TRANSFER-FAILED)

      (map-set 
        subscriber-at-token 
        { token: token, user-id: user-id} 
        { 
          ticket-balance: ticket-amount, 
          value-low: value-low, 
          value-high: value-high, 
          tickets-won: u0, 
          tickets-lost: u0,
          wstx-locked-in-fixed: wstx-locked-in-fixed }
      )
      (map-set 
        listing token 
        (merge 
          details 
          { 
            total-subscribed: value-high, 
            users-nonce: user-id, 
            activated: activated
          }
        )
      )
      (ok user-id)
    )
  )
)

(define-read-only (get-subscriber-at-token-or-default (token principal) (user-id uint))
  (default-to 
    { ticket-balance: u0, value-low: u0, value-high: u0, tickets-won: u0, tickets-lost: u0, wstx-locked-in-fixed: u0 } 
    (map-get? subscriber-at-token { token: token, user-id: user-id }))
)

(define-public (refund (token-trait <ft-trait>) (ticket-trait <ft-trait>))
  (let
    (
      (token (contract-of token-trait))     
      (claimer tx-sender)
      (details (unwrap! (map-get? listing token) ERR-INVALID-TOKEN))
      (user-id (unwrap! (get-user-id token tx-sender) ERR-USER-ID-NOT-FOUND))
      (sub-details (get-subscriber-at-token-or-default token user-id))  
      (refund-amount (* (get ticket-balance sub-details) (get wstx-per-ticket-in-fixed details)))
    )
    (asserts! (is-eq (contract-of ticket-trait) (get ticket details)) ERR-INVALID-TICKET)
    (asserts! (> block-height (get registration-end details)) ERR-REGISTRATION-NOT-ENDED)
    (asserts! (> refund-amount u0) ERR-REFUND-NOT-AVAILABLE)    
    (asserts! 
      (or 
        (not (try! (is-listing-activated token))) ;; listing is not activated
        (try! (is-listing-completed token)) ;; listing is completed
        (> block-height (get claim-end details)) ;; passed claim-end
      )
      ERR-REFUND-NOT-AVAILABLE
    )
    (map-set
      subscriber-at-token
      { token: token, user-id: user-id} 
      (merge sub-details 
        { 
          ticket-balance: u0,
          wstx-locked-in-fixed: u0
        }
      )
    )  

    (as-contract (unwrap! (contract-call? .token-wstx transfer-fixed refund-amount tx-sender claimer none) ERR-TRANSFER-FAILED))
    (as-contract (try! (contract-call? ticket-trait burn-fixed (* (get ticket-balance sub-details) ONE_8) tx-sender)))
    (ok refund-amount)
  )
)

(define-public (claim (token-trait <ft-trait>) (ticket-trait <ft-trait>))
  (begin
    (let
      (
        (token (contract-of token-trait))
        (ticket (contract-of ticket-trait))
        (details (unwrap! (map-get? listing token) ERR-INVALID-TOKEN))
      )
      (asserts! (> block-height (get registration-end details)) ERR-REGISTRATION-NOT-ENDED)
      (asserts! (try! (is-listing-activated token)) ERR-LISTING-NOT-ACTIVATED)
      (asserts! (<= block-height (get claim-end details)) ERR-CLAIM-ENDED)
      (asserts! (is-eq ticket (get ticket details)) ERR-INVALID-TICKET)
    )
    (let
      (
        (claimer tx-sender)
        (token (contract-of token-trait))
        (details (unwrap! (map-get? listing token) ERR-INVALID-TOKEN))
        (user-id (unwrap! (get-user-id token tx-sender) ERR-USER-ID-NOT-FOUND))
        (sub-details (get-subscriber-at-token-or-default token user-id))
        (total-tickets (get total-tickets details))
        (total-subscribed (get total-subscribed details))
        (tickets-won (get tickets-won details))
        (ticket-balance (get ticket-balance sub-details))
        (last-random 
          (if 
            (is-eq (get last-random details) u0) 
            (mod (unwrap! (get-random-uint-at-block (get registration-start details)) ERR-NO-VRF-SEED-FOUND) u13495287074701800000000000000) 
            (get last-random details)
          )
        )
        (this-random (get-next-random last-random))
        (value-low (get value-low sub-details))
        (value-high (get value-high sub-details))
        (wstx-per-ticket-in-fixed (get wstx-per-ticket-in-fixed details))
        ;; adjusts value-low and value-high to account for sampling with replacement
        (value-low-adjusted
          (if (< value-low (/ total-tickets u2)) 
            u0 
            (if (> (+ value-high (/ total-tickets u2)) total-subscribed)
              (- (- total-subscribed total-tickets) (- value-high value-low))
              (- value-low (/ total-tickets u2))
            )
          )
        )
        (value-high-adjusted 
          (if (< value-low (/ total-tickets u2)) 
            (+ value-high (- total-tickets value-low)) 
            (if (> (+ value-high (/ total-tickets u2)) total-subscribed)
              total-subscribed
              (+ value-high (/ total-tickets u2))
            )
          )
        )
      )      
      (asserts! (> ticket-balance u0) ERR-CLAIM-NOT-AVAILABLE)
      
      (if 
        (and 
          (>= (mod this-random total-subscribed) value-low-adjusted) 
          (<= (mod this-random total-subscribed) value-high-adjusted)
          (not (try! (is-listing-completed token)))
        )
        (begin
          (as-contract (unwrap! (contract-call? token-trait transfer-fixed (* (get amount-per-ticket details) ONE_8) tx-sender claimer none) ERR-TRANSFER-FAILED))
          (as-contract (unwrap! (contract-call? .token-wstx transfer-fixed wstx-per-ticket-in-fixed tx-sender (get fee-to-address details) none) ERR-TRANSFER-FAILED))
          (as-contract (try! (contract-call? ticket-trait burn-fixed ONE_8 tx-sender)))
          (map-set listing 
            token 
            (merge details 
              { 
                last-random: this-random, 
                tickets-won: (+ tickets-won u1)
              }
            )
          )          
          (map-set subscriber-at-token 
            { token: token, user-id: user-id } 
            (merge sub-details 
              { 
                ticket-balance: (- ticket-balance u1), 
                tickets-won: (+ (get tickets-won sub-details) u1), 
                wstx-locked-in-fixed: (- (get wstx-locked-in-fixed sub-details) wstx-per-ticket-in-fixed)
              }
            )
          )      
          (ok true)
        )
        (begin
          (as-contract (unwrap! (contract-call? .token-wstx transfer-fixed (get wstx-per-ticket-in-fixed details) tx-sender claimer none) ERR-TRANSFER-FAILED))
          (as-contract (try! (contract-call? ticket-trait burn-fixed ONE_8 tx-sender)))
          (map-set listing 
            token 
            (merge details 
              { 
                last-random: this-random
              }
            )
          )
          (map-set subscriber-at-token 
            { token: token, user-id: user-id } 
            (merge sub-details 
              { 
                ticket-balance: (- ticket-balance u1),
                tickets-lost: (+ (get tickets-lost sub-details) u1),
                wstx-locked-in-fixed: (- (get wstx-locked-in-fixed sub-details) wstx-per-ticket-in-fixed)
              }
            )
          )      
          (ok false)
        )
      )
    )
  )
)

;; implementation of Linear congruential generator following POSIX rand48
(define-private (get-next-random (last-random uint))
    (mod (+ (* u25214903917 last-random) u11) (pow u2 u48))
)

;; VRF

;; Read the on-chain VRF and turn the lower 16 bytes into a uint
(define-private (get-random-uint-at-block (stacksBlock uint))
  (let (
    (vrf-lower-uint-opt
      (match (get-block-info? vrf-seed stacksBlock)
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

;; Convert a little-endian 16-byte buff into a uint.
(define-private (buff-to-uint-le (word (buff 16)))
  (get acc
    (fold add-and-shift-uint-le (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15) { acc: u0, data: word })
  )
)

;; Inner fold function for converting a 16-byte buff into a uint.
(define-private (add-and-shift-uint-le (idx uint) (input { acc: uint, data: (buff 16) }))
  (let (
    (acc (get acc input))
    (data (get data input))
    (byte (buff-to-u8 (unwrap-panic (element-at data idx))))
  )
  {
    ;; acc = byte * (2**(8 * (15 - idx))) + acc
    acc: (+ (* byte (pow u2 (* u8 (- u15 idx)))) acc),
    data: data
  })
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

(define-public (claim-two (token-trait <ft-trait>) (ticket-trait <ft-trait>))
  (ok 
    (map 
      claim
      (list token-trait token-trait)
      (list ticket-trait ticket-trait)
    )
  )
)

(define-public (claim-three (token-trait <ft-trait>) (ticket-trait <ft-trait>))
  (ok 
    (map 
      claim
      (list token-trait token-trait token-trait)
      (list ticket-trait ticket-trait ticket-trait)
    )
  )
)

(define-public (claim-four (token-trait <ft-trait>) (ticket-trait <ft-trait>))
  (ok 
    (map 
      claim
      (list token-trait token-trait token-trait token-trait)
      (list ticket-trait ticket-trait ticket-trait ticket-trait)
    )
  )
)

(define-public (claim-five (token-trait <ft-trait>) (ticket-trait <ft-trait>))
  (ok 
    (map 
      claim
      (list token-trait token-trait token-trait token-trait token-trait)
      (list ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait)
    )
  )
)

(define-public (claim-six (token-trait <ft-trait>) (ticket-trait <ft-trait>))
  (ok 
    (map 
      claim
      (list token-trait token-trait token-trait token-trait token-trait token-trait)
      (list ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait)
    )
  )
)

(define-public (claim-seven (token-trait <ft-trait>) (ticket-trait <ft-trait>))
  (ok 
    (map 
      claim
      (list token-trait token-trait token-trait token-trait token-trait token-trait token-trait)
      (list ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait)
    )
  )
)

(define-public (claim-eight (token-trait <ft-trait>) (ticket-trait <ft-trait>))
  (ok 
    (map 
      claim
      (list token-trait token-trait token-trait token-trait token-trait token-trait token-trait token-trait)
      (list ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait)
    )
  )
)

(define-public (claim-nine (token-trait <ft-trait>) (ticket-trait <ft-trait>))
  (ok 
    (map 
      claim
      (list token-trait token-trait token-trait token-trait token-trait token-trait token-trait token-trait token-trait)
      (list ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait)
    )
  )
)

(define-public (claim-ten (token-trait <ft-trait>) (ticket-trait <ft-trait>))
  (ok 
    (map 
      claim
      (list token-trait token-trait token-trait token-trait token-trait token-trait token-trait token-trait token-trait token-trait)
      (list ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait ticket-trait)
    )
  )
)