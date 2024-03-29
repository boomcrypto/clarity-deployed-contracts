;; PoX-lite contract, MVP.
;; This is alpha-quality code.  Tests are included in the tests/ directory, but this code is unaudited.
;; DO NOT USE IN PRODUCTION.
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.initializable-trait-v1a.initializable-poxl-token-trait)


;; error codes
(define-constant ERR-NO-WINNER u4231)
(define-constant ERR-NO-SUCH-MINER u4232)
(define-constant ERR-IMMATURE-TOKEN-REWARD u4233)
(define-constant ERR-UNAUTHORIZED u4234)
(define-constant ERR-ALREADY-CLAIMED u4235)
(define-constant ERR-STACKING-NOT-AVAILABLE u4236)
(define-constant ERR-CANNOT-STACK u4237)
(define-constant ERR-INSUFFICIENT-BALANCE u4238)
(define-constant ERR-ALREADY-MINED u4239)
(define-constant ERR-ROUND-FULL u4240)
(define-constant ERR-NOTHING-TO-REDEEM u4241)
(define-constant ERR-CANNOT-MINE u4242)
(define-constant PERMISSION_DENIED_ERROR u4243)

(define-constant STACKSWAP_ACCOUNT 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275)

;; Tailor to your needs.
(define-constant TOKEN-REWARD-MATURITY u100)        ;; how long a miner must wait before claiming their minted tokens
(define-constant FIRST-STACKING-BLOCK u99999999999999999)           ;; Stacks block height when Stacking is available
(define-constant REWARD-CYCLE-LENGTH u500)          ;; how long a reward cycle is
(define-constant MAX-REWARD-CYCLES u32)             ;; how many reward cycles a Stacker can Stack their tokens for

;; NOTE: must be as long as MAX-REWARD-CYCLES


(define-constant REWARD-CYCLE-INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31))

;; lookup table for converting 1-byte buffers to uints via index-of
(define-constant BUFF-TO-BYTE (list 
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
    (unwrap-panic (index-of BUFF-TO-BYTE byte)))

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

;; Convert a little-endian 16-byte buff into a uint.
(define-private (buff-to-uint-le (word (buff 16)))
    (get acc
        (fold add-and-shift-uint-le (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15) { acc: u0, data: word })
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

;; Convert the lower 16 bytes of a buff into a little-endian uint.
(define-private (lower-16-le (input (buff 32)))
    (get acc
        (fold lower-16-le-closure (list u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31) { acc: 0x, data: input })
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Stacking configuration, as data vars (so it's easy to test).
(define-data-var first-stacking-block uint FIRST-STACKING-BLOCK)
(define-data-var reward-cycle-length uint REWARD-CYCLE-LENGTH)
(define-data-var token-reward-maturity uint TOKEN-REWARD-MATURITY)
(define-data-var max-reward-cycles uint MAX-REWARD-CYCLES)
(define-data-var coinbase-reward uint u50000000)
(define-data-var rem-item uint u0)


;; NOTE: keep this private -- it's used by the test harness to set smaller (easily-tested) values.
;; (define-private (configure (first-block uint) (rc-len uint) (reward-maturity uint) (max-lockup uint))
;;     (begin
;;         (var-set first-stacking-block first-block)
;;         (var-set reward-cycle-length rc-len)
;;         (var-set token-reward-maturity reward-maturity)
;;         (var-set max-reward-cycles max-lockup)
;;         (var-set coinbase-reward coinbase-reward-to-set)
;;         ;; (ok true)
;;    )
;; )

;; (begin
;;     (asserts! (is-eq (len REWARD-CYCLE-INDEXES) MAX-REWARD-CYCLES) (err "Invalid max reward cycles"))
;;     (configure FIRST-STACKING-BLOCK REWARD-CYCLE-LENGTH TOKEN-REWARD-MATURITY MAX-REWARD-CYCLES)
;; )

;; Bind Stacks block height to a list of up to 32 miners (and how much they mined) per block,
;; and track whether or not the miner has come back to claim their tokens.
(define-map miners
    { stacks-block-height: uint }
    {
        miners: (list 32 { miner: principal, amount-ustx: uint }),
        claimed: bool
    }
)

;; How many uSTX are mined per reward cycle, and how many tokens are locked up in the same reward cycle.
(define-map tokens-per-cycle
    { reward-cycle: uint }
    { total-ustx: uint, total-tokens: uint }
)

;; Who has locked up how many tokens for a given reward cycle.
(define-map stacked-per-cycle
    { owner: principal, reward-cycle: uint }
    { amount-token: uint }
)

;; The fungible token that can be Stacked.
(define-fungible-token stackables)

;; Function for deciding how many tokens to mint, depending on when they were mined.
;; Tailor to your own needs.
(define-read-only (get-coinbase-amount (stacks-block-ht uint))
    (var-get coinbase-reward)
)

;; Getter for getting the list of miners and uSTX committments for a given block.
(define-read-only (get-miners-at-block (stacks-block-ht uint))
    (match (map-get? miners { stacks-block-height: stacks-block-ht })
        miner-rec (get miners miner-rec)
        (list )
    )
)

;; Getter for getting how many tokens are Stacked by the given principal in the given reward cycle.
(define-read-only (get-stacked-in-cycle (miner-id principal) (reward-cycle uint))
    (match (map-get? stacked-per-cycle { owner: miner-id, reward-cycle: reward-cycle })
        stacked-rec (get amount-token stacked-rec)
        u0
    )
)

;; Getter for getting how many uSTX are committed and tokens are Stacked per reward cycle.
(define-read-only (get-tokens-per-cycle (rc uint))
    (match (map-get? tokens-per-cycle { reward-cycle: rc })
        token-info token-info
        { total-ustx: u0, total-tokens: u0 }
    )
)

;; API endpoint for getting statistics about this PoX-lite contract.
;; Compare to /v2/pox on the Stacks node.
(define-read-only (get-pox-lite-info)
    (match (get-reward-cycle block-height)
        cur-reward-cycle
            (ok
                (let (
                    (token-info (get-tokens-per-cycle cur-reward-cycle))
                    (total-ft-supply (ft-get-supply stackables))
                    (total-ustx-supply (stx-get-balance (as-contract tx-sender)))
                )
                {
                    reward-cycle-id: cur-reward-cycle,
                    first-block-height: (var-get first-stacking-block),
                    reward-cycle-length: (var-get reward-cycle-length),
                    total-supply: total-ft-supply,
                    total-ustx-locked: total-ustx-supply,
                    cur-liquid-supply: (- total-ft-supply (get total-tokens token-info)),
                    cur-locked-supply: (get total-tokens token-info),
                    cur-ustx-committed: (get total-ustx token-info)
                })
            )
        (err ERR-STACKING-NOT-AVAILABLE)
    )
)

;; Produce the new tokens for the given claimant, who won the tokens at the given Stacks block height.
(define-private (mint-coinbase (recipient principal) (stacks-block-ht uint))
    (begin

        (unwrap-panic (ft-mint? stackables (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-fee-v1a get-owner-amount (get-coinbase-amount stacks-block-ht)) tx-sender))
        (unwrap-panic (ft-mint? stackables (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-fee-v1a get-stackswap-amount (get-coinbase-amount stacks-block-ht)) STACKSWAP_ACCOUNT))
        ;; (try! (ft-mint? stackables (get-coinbase-amount stacks-block-ht) recipient))
        (ok true)
        ;; (ft-mint? stackables (get-coinbase-amount stacks-block-ht) recipient)
    )
)

;; Getter to obtain the list of miners and uSTX commitments at a given Stacks block height,
;; OR, an empty such structure.
(define-private (get-block-miner-rec-or-default (stacks-block-ht uint))
    (match (map-get? miners { stacks-block-height: stacks-block-ht })
        rec rec
        { miners: (list ), claimed: false })
)

;; Inner fold function for getting how many uSTX were committed by a list of miners.
(define-private (get-block-commit-total-closure (idx uint) (input { sum: uint, miners: (list 32 { miner: principal, amount-ustx: uint }) }))
    (let (
        (sum (get sum input))
        (miners-list (get miners input))
        (commit-at-index (match (element-at miners-list idx)
                            miner-rec (get amount-ustx miner-rec)
                            u0))
    )
    {
        sum: (+ sum commit-at-index),
        miners: miners-list
    })
)

;; Given a list of miners and uSTX commitments, return how many uSTX were committed in total.
(define-read-only (get-block-commit-total (miners-list (list 32 { miner: principal, amount-ustx: uint })))
    (get sum
        (fold get-block-commit-total-closure REWARD-CYCLE-INDEXES
            { sum: u0, miners: miners-list })
    )
)

;; Inner fold function to determine which miner won the token batch at a particular Stacks block height, given a sampling value.
(define-private (get-block-winner-closure (idx uint) (input { sum: uint, sample: uint, winner-index: (optional uint), miners: (list 32 { miner: principal, amount-ustx: uint }) }))
    (let (
        (sum (get sum input))
        (sample (get sample input))
        (miners-list (get miners input))
        (commit-at-index (match (element-at miners-list idx)
                            miner-rec (get amount-ustx miner-rec)
                            u0))
        (next-sum (+ sum commit-at-index))
        (next-winner-index 
            (if (and (>= sample sum) (< sample next-sum) (> commit-at-index u0))
                (some idx)
                (get winner-index input)))
    )
    {
        sum: next-sum,
        sample: sample,
        winner-index: next-winner-index,
        miners: miners-list
    })
)

;; Determine who won a given batch of tokens, given a random sample and a list of miners and commitments.
;; The probability that a given miner wins the batch is proportional to how many uSTX it committed out of the 
;; sum of commitments for this block.
(define-read-only (get-block-winner (random-sample uint) (miners-list (list 32 { miner: principal, amount-ustx: uint })))
    (let (
        (commit-total (get-block-commit-total miners-list))
        (winner-index-opt
            (if (> commit-total u0)
                (get winner-index
                    (fold get-block-winner-closure REWARD-CYCLE-INDEXES
                        { sum: u0, sample: (mod random-sample commit-total), winner-index: none, miners: miners-list }))
                none))
    )
    (match winner-index-opt
        winner-index (match (element-at miners-list winner-index)
            winning-miner-rec (some winning-miner-rec)
            none)
        none))
)

;; Inner fold function for finding a given miner in a list of miners.
(define-private (has-mined-in-list-closure (idx uint) (input { found: bool, candidate: principal, miners: (list 32 { miner: principal, amount-ustx: uint }) }))
    (let (
        (already-found (get found input))
        (miner-candidate (get candidate input))
        (miners-list (get miners input))
    )
    {
        found: (match (element-at miners-list idx)
                       miner-rec (or already-found (is-eq miner-candidate (get miner miner-rec)))
                       already-found),
        candidate: miner-candidate,
        miners: miners-list
    })
)

;; Determine if a given miner has already mined in a list of miners.
(define-read-only (has-mined-in-list (miner principal) (miner-list (list 32 { miner: principal, amount-ustx: uint })))
    (get found
        (fold has-mined-in-list-closure REWARD-CYCLE-INDEXES
            { found: false, candidate: miner, miners: miner-list }))
)

;; Determine whether or not the given principal can claim the mined tokens at a particular block height,
;; given the miners record for that block height, a random sample, and the current block height.
(define-read-only (can-claim-tokens (claimer principal) 
                                    (claimer-stacks-block-height uint)
                                    (random-sample uint)
                                    (miners-rec { 
                                        miners: (list 32 { miner: principal, amount-ustx: uint }),
                                        claimed: bool
                                    })
                                    (current-stacks-block uint))
    (let (
        (reward-maturity (var-get token-reward-maturity))
        (maximum-stacks-block-height
            (if (>= current-stacks-block reward-maturity)
                (- current-stacks-block reward-maturity)
                u0))
    )
    (if (< claimer-stacks-block-height maximum-stacks-block-height)
        (begin
            (asserts! (not (get claimed miners-rec))
                (err ERR-ALREADY-CLAIMED))

            (match (get-block-winner random-sample (get miners miners-rec))
                winner-rec (if (is-eq claimer (get miner winner-rec))
                               (ok true)
                               (err ERR-UNAUTHORIZED))
                (err ERR-NO-WINNER))
        )
        (err ERR-IMMATURE-TOKEN-REWARD)))
)

;; Mark a batch of mined tokens as claimed, so no one else can go and claim them.
(define-private (set-tokens-claimed (claimed-stacks-block-height uint))
    (let (
      (miner-rec (unwrap!
          (map-get? miners { stacks-block-height: claimed-stacks-block-height })
          (err ERR-NO-WINNER)))
    )
    (begin
       (asserts! (not (get claimed miner-rec))
          (err ERR-ALREADY-CLAIMED))

       (map-set miners
           { stacks-block-height: claimed-stacks-block-height }
           { 
               miners: (get miners miner-rec),
               claimed: true
           }
       )
       (ok true)))
)

;; Determine whether or not the given miner can actually mine tokens right now.
;; * Stacking must be active for this smart contract
;; * No more than 31 miners must have mined already
;; * This miner hasn't mined in this block before
;; * The miner is committing a positive number of uSTX
;; * The miner has the uSTX to commit
(define-read-only (can-mine-tokens (miner-id principal)
                                   (stacks-bh uint)
                                   (amount-ustx uint)
                                   (miners-rec { 
                                       miners: (list 32 { miner: principal, amount-ustx: uint }),
                                       claimed: bool
                                   }))

    (begin
        (asserts! (is-some (get-reward-cycle stacks-bh))
            (err ERR-STACKING-NOT-AVAILABLE))

        (asserts! (< (len (get miners miners-rec)) u32)
            (err ERR-ROUND-FULL))

        (asserts! (not (has-mined-in-list miner-id (get miners miners-rec)))
            (err ERR-ALREADY-MINED))

        (asserts! (> amount-ustx u0)
            (err ERR-CANNOT-MINE))

        (asserts! (>= (stx-get-balance miner-id) amount-ustx)
            (err ERR-INSUFFICIENT-BALANCE))

        (ok true)
    )
)

;; Determine if a Stacker can Stack their tokens.  Like PoX, they must supply
;; a future Stacks block height at which Stacking begins, as well as a lock-up period
;; in reward cycles.
;; * The Stacker's start block height must be in the future
;; * The first reward cycle must be _after_ the current reward cycle
;; * The lock period must be valid (positive, but no greater than the maximum allowed period)
;; * The Stacker must have tokens to Stack.
(define-read-only (can-stack-tokens (stacker-id principal) (amount-tokens uint) (now-stacks-ht uint) (start-stacks-ht uint) (lock-period uint))
    (let (
        (cur-reward-cycle (unwrap! (get-reward-cycle now-stacks-ht) (err ERR-STACKING-NOT-AVAILABLE)))
        (start-reward-cycle (+ u1 (unwrap! (get-reward-cycle start-stacks-ht) (err ERR-STACKING-NOT-AVAILABLE))))
        (max-lockup (var-get max-reward-cycles))
    )
    (begin
        (asserts! (< now-stacks-ht start-stacks-ht)
            (err ERR-CANNOT-STACK))

        (asserts! (< cur-reward-cycle start-reward-cycle)
            (err ERR-CANNOT-STACK))

        (asserts! (and (> lock-period u0) (<= lock-period max-lockup))
            (err ERR-CANNOT-STACK))

        (asserts! (> amount-tokens u0)
            (err ERR-CANNOT-STACK))

        (asserts! (<= amount-tokens (ft-get-balance stackables stacker-id))
            (err ERR-INSUFFICIENT-BALANCE))

        (ok true)
    ))
)

;; Determine how many uSTX a Stacker is allowed to claim, given the reward cycle they Stacked in and the current block height.
;; This method only returns a positive value if:
;; * The current block height is in a subsequent reward cycle
;; * The Stacker actually did lock up some tokens in the target reward cycle
;; * The Stacker locked up _enough_ tokens to get at least one uSTX.
;; It's possible to Stack tokens but not receive uSTX.  For example, no miners may have mined in this reward cycle.
;; As another example, you may have Stacked so few that you'd be entitled to less than 1 uSTX.
(define-read-only (get-entitled-stacking-reward (stacker-id principal) (target-reward-cycle uint) (cur-block-height uint))
    (let (
        (stacked-this-cycle
            (get amount-token
                (default-to { amount-token: u0 }
                    (map-get? stacked-per-cycle { owner: stacker-id, reward-cycle: target-reward-cycle }))))
        (total-tokens-this-cycle
            (default-to { total-ustx: u0, total-tokens: u0 }
                (map-get? tokens-per-cycle { reward-cycle: target-reward-cycle })))
    )
    (match (get-reward-cycle cur-block-height)
        cur-reward-cycle
          (if (or (<= cur-reward-cycle target-reward-cycle) (is-eq u0 (get total-tokens total-tokens-this-cycle)))
              ;; either this reward cycle hasn't finished yet, or the Stacker contributed nothing
              u0
              ;; (total-ustx * this-stackers-tokens) / total-tokens-stacked
              (/ (* (get total-ustx total-tokens-this-cycle) stacked-this-cycle) 
                 (get total-tokens total-tokens-this-cycle))
          )
        ;; before first reward cycle
        u0
    ))
)

;; Mark a miner as having mined in a given Stacks block and committed the given uSTX.
(define-private (set-tokens-mined (miner-id principal) (stacks-bh uint) (commit-ustx uint))
    (let (
        (miner-rec (get-block-miner-rec-or-default stacks-bh))
        (rc (unwrap! (get-reward-cycle stacks-bh)
            (err ERR-STACKING-NOT-AVAILABLE)))
        (tokens-mined (match (map-get? tokens-per-cycle { reward-cycle: rc })
                                rec rec
                                { total-ustx: u0, total-tokens: u0 }))
    )
    (begin
        (map-set miners
            { stacks-block-height: stacks-bh }
            {
                miners: (unwrap-panic (as-max-len? (append (get miners miner-rec) { miner: miner-id, amount-ustx: commit-ustx }) u32)),
                claimed: false
            }
        )
        (map-set tokens-per-cycle
            { reward-cycle: rc }
            { total-ustx: (+ commit-ustx (get total-ustx tokens-mined)), total-tokens: (get total-tokens tokens-mined) }
        )
        (ok true)
    ))
)

;; Get the reward cycle for a given Stacks block height
(define-read-only (get-reward-cycle (stacks-bh uint))
    (let (
        (first-stack-block (var-get first-stacking-block))
        (rc-len (var-get reward-cycle-length))
    )
    (if (>= stacks-bh first-stack-block)
        (some (/ (- stacks-bh first-stack-block) rc-len))
        none
    ))
)

;; Get the first Stacks block height for a given reward cycle.
(define-read-only (get-first-block-height-in-reward-cycle (reward-cycle uint))
    (+ (var-get first-stacking-block) (* (var-get reward-cycle-length) reward-cycle)))

;; Read the on-chain VRF and turn the lower 16 bytes into a uint, in order to sample the set of miners and determine
;; which one may claim the token batch for the given block height.
(define-read-only (get-random-uint-at-block (stacks-block uint))
    (let (
        (vrf-lower-uint-opt
            (match (get-block-info? vrf-seed stacks-block)
                vrf-seed (some (buff-to-uint-le (lower-16-le vrf-seed)))
                none))
    )
    vrf-lower-uint-opt)
)

;; Inner fold function for Stacking tokens.  Populates the stacked-per-cycle and tokens-per-cycle tables for each
;; reward cycle the Stacker is Stacking in.
(define-private (stack-tokens-closure (reward-cycle-idx uint) (stacker { id: principal, amt: uint, first: uint, last: uint }))
    (let (
        (stacker-id (get id stacker))
        (amount-token (get amt stacker))
        (first-reward-cycle (get first stacker))
        (last-reward-cycle (get last stacker))
        (target-reward-cycle (+ first-reward-cycle reward-cycle-idx))
        (stacked-already (match (map-get? stacked-per-cycle { owner: stacker-id, reward-cycle: target-reward-cycle })
                                rec (get amount-token rec)
                                u0))
        (tokens-this-cycle (match (map-get? tokens-per-cycle { reward-cycle: target-reward-cycle })
                                rec rec
                                { total-ustx: u0, total-tokens: u0 }))
    )
    (begin
        (if (and (>= target-reward-cycle first-reward-cycle) (< target-reward-cycle last-reward-cycle))
            (begin
                (map-set stacked-per-cycle
                    { owner: stacker-id, reward-cycle: target-reward-cycle }
                    { amount-token: (+ amount-token stacked-already) })

                (map-set tokens-per-cycle
                    { reward-cycle: target-reward-cycle }
                    { total-ustx: (get total-ustx tokens-this-cycle), total-tokens: (+ amount-token (get total-tokens tokens-this-cycle)) })

                true)
           false)
        { id: stacker-id, amt: amount-token, first: first-reward-cycle, last: last-reward-cycle }
    ))
)

;; Stack the contract's tokens.  Stacking will begin at the next reward cycle following
;; the reward cycle in which start-stacks-ht resides.
;; This method takes possession of the Stacker's tokens until the given number of reward cycles
;; has passed.
(define-public (stack-tokens (amount-tokens uint) (start-stacks-ht uint) (lock-period uint))
    (let (
        (start-reward-cycle (+ u1 (unwrap! (get-reward-cycle start-stacks-ht) (err ERR-STACKING-NOT-AVAILABLE))))
    )
    (begin
        ;; (print u11)
        (try! (can-stack-tokens tx-sender amount-tokens block-height start-stacks-ht lock-period))

        (unwrap! (ft-transfer? stackables amount-tokens tx-sender (as-contract tx-sender))
            (err ERR-INSUFFICIENT-BALANCE))

        (fold stack-tokens-closure REWARD-CYCLE-INDEXES
            { id: tx-sender, amt: amount-tokens, first: start-reward-cycle, last: (+ start-reward-cycle lock-period) })

        (ok true)
    ))
)

;; Mine tokens.  The miner commits uSTX into this contract (which Stackers can claim later with claim-stacking-reward),
;; and in doing so, enters their candidacy to be able to claim the block reward (via claim-token-reward).  The miner must 
;; wait for a token maturity window in order to obtain the tokens.  Once that window passes, they can get the tokens.
;; This ensures that no one knows the VRF seed that will be used to pick the winner.
(define-public (mine-tokens (amount-ustx uint))
    (let (
        (miner-rec (get-block-miner-rec-or-default block-height))
    )
    (begin
        (try! (can-mine-tokens tx-sender block-height amount-ustx miner-rec))

        (try! (set-tokens-mined tx-sender block-height amount-ustx))
        (unwrap-panic (stx-transfer? amount-ustx tx-sender (as-contract tx-sender)))

        (ok true)
    ))
)

(define-read-only (can-claim-mining-reward (user principal) (mined-stacks-block-ht uint))
    (let (
        (random-sample (unwrap! (get-random-uint-at-block (+ mined-stacks-block-ht (var-get token-reward-maturity)))
                        (err ERR-IMMATURE-TOKEN-REWARD)))
        (miners-rec (unwrap! (map-get? miners { stacks-block-height: mined-stacks-block-ht })
                        (err ERR-NO-WINNER)))
    )
    (begin
        (try! (can-claim-tokens user mined-stacks-block-ht random-sample miners-rec block-height))

        ;; (try! (set-tokens-claimed mined-stacks-block-ht))
        ;; (unwrap-panic (mint-coinbase tx-sender mined-stacks-block-ht))
        ;; (fold remove-block-per-user (get miners miners-rec) mined-stacks-block-ht)
        (ok true)
    ))
)

;; Claim the block reward.  This mints and transfers out a miner's tokens if it is indeed the block winner for
;; the given Stacks block.  The VRF seed will be sampled at the target mined stacks block height _plus_ the 
;; maturity window, and if the miner (i.e. the caller of this function) both mined in the target Stacks block
;; and was later selected by the VRF as the winner, they will receive that block's token batch.
;; Note that this method actually mints the contract's tokens -- they do not exist until the miner calls
;; this method.
(define-public (claim-token-reward (mined-stacks-block-ht uint))
    (let (
        (random-sample (unwrap! (get-random-uint-at-block (+ mined-stacks-block-ht (var-get token-reward-maturity)))
                        (err ERR-IMMATURE-TOKEN-REWARD)))
        (miners-rec (unwrap! (map-get? miners { stacks-block-height: mined-stacks-block-ht })
                        (err ERR-NO-WINNER)))
    )
    (begin
        (try! (can-claim-tokens tx-sender mined-stacks-block-ht random-sample miners-rec block-height))

        (try! (set-tokens-claimed mined-stacks-block-ht))
        (unwrap-panic (mint-coinbase tx-sender mined-stacks-block-ht))
        ;; (fold remove-block-per-user (get miners miners-rec) mined-stacks-block-ht)
        (ok true)
    ))
)


;; Claim a Stacking reward.  Once a reward cycle passes, a Stacker can call this method to obtain any
;; uSTX that were committed to the contract during that reward cycle (proportional to how many tokens
;; they locked up).
(define-public (claim-stacking-reward (target-reward-cycle uint))
    (let (
        (entitled-ustx (get-entitled-stacking-reward tx-sender target-reward-cycle block-height))
        (stacker-id tx-sender)
    )
    (begin
        (asserts! (> entitled-ustx u0)
            (err ERR-NOTHING-TO-REDEEM))

        ;; can't claim again
        (map-set stacked-per-cycle
            { owner: tx-sender, reward-cycle: target-reward-cycle }
            { amount-token: u0 })

        (unwrap-panic 
            (as-contract
                (stx-transfer? entitled-ustx tx-sender stacker-id)))

        (ok true)
    ))
)

;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;

;; Data variables specific to the deployed token contract
(define-data-var token-name (string-ascii 32) "")
(define-data-var token-symbol (string-ascii 32) "")
(define-data-var token-decimals uint u0)

;; Track who deployed the token and whether it has been initialized
(define-data-var contract-owner principal tx-sender)
(define-data-var is-initialized bool false)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
    (if (is-some memo)
      (print memo)
      none
    )
    (ft-transfer? stackables amount from to)
  )
)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance stackables owner)))

;; Returns the token name
(define-read-only (get-name)
  (ok (var-get token-name)))

;; Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

;; Returns the number of decimals used
(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

;; Returns the total number of tokens that currently exist
(define-read-only (get-total-supply)
  (ok (ft-get-supply stackables)))

;; Variable for URI storage
(define-data-var uri (string-utf8 256) u"")

;; Public getter for the URI
(define-read-only (get-token-uri)
  (ok (some (var-get uri))))

;; Setter for the URI - only the owner can set it
(define-public (set-token-uri (updated-uri (string-utf8 256)))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) (err PERMISSION_DENIED_ERROR))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-uri", updated-uri: updated-uri })
    (ok (var-set uri updated-uri))))

;; Variable for UwebsiteRI storage
(define-data-var website (string-utf8 256) u"")

;; Public getter for the website
(define-read-only (get-token-website)
  (ok (some (var-get website))))

;; Setter for the website - only the owner can set it
(define-public (set-token-website (updated-website (string-utf8 256)))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) (err PERMISSION_DENIED_ERROR))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-website", updated-website: updated-website })
    (ok (var-set website updated-website))))

(define-public (initialize (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256))
    (website-to-set (string-utf8 256)) (initial-mint-amount uint) (first-stacking-block-to-set uint) (reward-cycle-lengh-to-set uint) (token-reward-maturity-to-set uint) (coinbase-reward-to-set uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v4a get-qualified-name-by-name "one-step-mint"))) (err PERMISSION_DENIED_ERROR))
    (asserts! (not (var-get is-initialized)) (err PERMISSION_DENIED_ERROR))
    (var-set is-initialized true) ;; Set to true so that this can't be called again
    (var-set token-name name-to-set)
    (var-set token-symbol symbol-to-set)
    (var-set token-decimals decimals-to-set)
    (var-set uri uri-to-set)
    (var-set website website-to-set)
    (var-set contract-owner tx-sender)
    ;; (try! (ft-mint? stackables initial-mint-amount tx-sender))
    (unwrap-panic (ft-mint? stackables (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-fee-v1a get-owner-amount initial-mint-amount) tx-sender))
    (unwrap-panic (ft-mint? stackables (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-fee-v1a get-stackswap-amount initial-mint-amount) STACKSWAP_ACCOUNT))
    ;; (asserts! (is-eq (len REWARD-CYCLE-INDEXES) MAX-REWARD-CYCLES) (err "Invalid max reward cycles"))
    (var-set first-stacking-block first-stacking-block-to-set)
    (var-set reward-cycle-length reward-cycle-lengh-to-set)
    (var-set token-reward-maturity token-reward-maturity-to-set)
    (var-set coinbase-reward coinbase-reward-to-set)
    (ok u0)
))

;; Variable for approve
(define-data-var approved bool false)

;; Public getter for the approve
(define-read-only (get-is-approved)
  (ok (some (var-get approved))))


(define-public (approve (is-approved bool))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v4a get-qualified-name-by-name "one-step-mint"))) (err PERMISSION_DENIED_ERROR))
    (ok (var-set approved is-approved))
  )
)

