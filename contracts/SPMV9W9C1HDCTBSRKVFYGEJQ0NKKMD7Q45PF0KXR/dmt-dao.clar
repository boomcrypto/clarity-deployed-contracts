;; error codes
(define-constant ERR-NO-WINNER u0)
(define-constant ERR-NO-SUCH-MINER u1)
(define-constant ERR-IMMATURE-TOKEN-REWARD u2)
(define-constant ERR-UNAUTHORIZED u3)
(define-constant ERR-ALREADY-CLAIMED u4)
(define-constant ERR-STACKING-NOT-AVAILABLE u5)
(define-constant ERR-CANNOT-STACK u6)
(define-constant ERR-INSUFFICIENT-BALANCE u7)
(define-constant ERR-ALREADY-MINED u8)
(define-constant ERR-ROUND-FULL u9)  ;; deprecated - this error is not used anymore
(define-constant ERR-NOTHING-TO-REDEEM u10)
(define-constant ERR-CANNOT-MINE u11)
(define-constant ERR-MINER-ALREADY-REGISTERED u12)
(define-constant ERR-MINING-ACTIVATION-THRESHOLD-REACHED u13)
(define-constant ERR-MINER-ID-NOT-FOUND u14)
(define-constant ERR-TOO-SMALL-COMMITMENT u15)
(define-constant ERR-TOO-MANY-MINERS u16)

(define-constant LONG-UINT-LIST (list
u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 
u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 
u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48
u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64
u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80
u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96
u97 u98 u99 u100 u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112
u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 u126 u127 u128 
))

(define-constant TOKEN-REWARD-MATURITY u5)      ;; how long a miner must wait before claiming their minted tokens
(define-constant ACTIVATION-HEIGHT u3000)       ;; The beginning height of the mining process
(define-constant MAX-MINERS-COUNT u128)               ;; maximum players in one cycle

(define-constant RTX_CUSTODIED_WALLET 'STKBS86JFA8BBJ1FF66QQEV855SQS6PWQ4TZ0ASQ)  ;; the custodied wallet address for the city
(define-data-var dmt-wallet principal RTX_CUSTODIED_WALLET)  ;; variable used in place of constant for easier testing

(define-data-var token-reward-maturity uint TOKEN-REWARD-MATURITY)
(define-data-var block-reward uint u10)
(define-data-var miners-nonce uint u0)          ;; variable used to generate unique miner-id's
(define-data-var latest-cycle-height uint u0)   ;; variable used to record latest cycle height. For example the latest block is 2008, then the latest-cycle-height is 2010
                                                ;; it will always be multiple of five

;; Bind Stacks block height to a list of up to 128 miners (and how much they mined) per block,
;; and track whether or not the miner has come back to claim their tokens and who mined the least.
(define-map mined-blocks
    { stacks-block-height: uint }
    {
        miners-count: uint,
        commitment-ustx: uint,
        winner-id: uint,
        claimed: bool,
    }
)

(define-map blocks-miners
  { stacks-block-height: uint, idx: uint }
  { miner-id: uint, ustx: uint }
)

;; Maps miner address to uint miner-id
(define-map miners
    { miner: principal }
    { miner-id: uint }
)

(define-map miners-block-commitment
    { miner-id: uint, stacks-block-height: uint }
    { committed: bool }
)

(define-read-only (get-mined-blocks (stacks-block-height uint))
    ;;(is-some (map-get? mined-blocks
    ;;    { stacks-block-height: stacks-block-height }
    ;;))
    (get-mined-block-or-default stacks-block-height)
)

(define-read-only (get-blocks-miners (stacks-block-height uint) (idx uint))
    (match (map-get? blocks-miners
        { stacks-block-height: stacks-block-height, idx: idx }
    )
    miner miner
    {
        miner-id: u0, 
        ustx: u0,
    }
    )
)

;; Determine if a given miner has already mined at given block height
(define-read-only (has-mined (miner-id uint) (stacks-block-height uint))
    (is-some (map-get? miners-block-commitment 
        { miner-id: miner-id, stacks-block-height: stacks-block-height }
    ))
)

;; Returns miners ID if it has been created, or creates and returns new
(define-private (get-or-create-miner-id (miner principal))
    (match (get miner-id (map-get? miners { miner: miner }))
        value value
        (let
            ((new-id (+ u1 (var-get miners-nonce))))
            (map-set miners
                { miner: miner }
                { miner-id: new-id}
            )
            (var-set miners-nonce new-id)
            new-id
        )
    )
)

(define-read-only (get-next-block-height)
    (+ (- block-height (mod block-height u5)) u6)
)

;; Mine tokens.  The miner commits uSTX into this contract (which Stackers can claim later with claim-stacking-reward),
;; and in doing so, enters their candidacy to be able to claim the block reward (via claim-token-reward).  The miner must 
;; wait for a token maturity window in order to obtain the tokens.  Once that window passes, they can get the tokens.
;; This ensures that no one knows the VRF seed that will be used to pick the winner.
(define-public (mine-tokens (amount-ustx uint) (memo (optional (string-ascii 34))))
    (begin
        (let
            (
                (next-block-height (get-next-block-height))
            )
            (if (is-some memo)
                (print memo)
                none
            )
            (try! (mine-tokens-at-block next-block-height (get-or-create-miner-id tx-sender) (/ amount-ustx u5)))
            (try! (mine-tokens-at-block (+ next-block-height u1) (get-or-create-miner-id tx-sender) (/ amount-ustx u5)))
            (try! (mine-tokens-at-block (+ next-block-height u2) (get-or-create-miner-id tx-sender) (/ amount-ustx u5)))
            (try! (mine-tokens-at-block (+ next-block-height u3) (get-or-create-miner-id tx-sender) (/ amount-ustx u5)))
            (try! (mine-tokens-at-block (+ next-block-height u4) (get-or-create-miner-id tx-sender) (/ amount-ustx u5)))
        )
        (ok true)
    )
)

(define-private (mine-tokens-at-block (stacks-block-height uint) (miner-id uint) (amount-ustx uint))
    (begin
        (try! (can-mine-tokens tx-sender miner-id stacks-block-height amount-ustx))
        (try! (set-tokens-mined tx-sender miner-id stacks-block-height amount-ustx))
        (unwrap-panic (stx-transfer? amount-ustx tx-sender (var-get dmt-wallet)))
        (ok true)
    )
)

;; Determine whether or not the given miner can actually mine tokens right now.
;; * This miner hasn't mined this cycle before
;; * The miner is committing a positive number of uSTX
;; * The miner has the uSTX to commit
(define-read-only (can-mine-tokens (miner principal) (miner-id uint) (stacks-block-height uint) (amount-ustx uint))
    (let
        (
            (block (get-mined-block-or-default stacks-block-height))
        )        
        (if (is-eq MAX-MINERS-COUNT (get miners-count block))
            (err ERR-TOO-SMALL-COMMITMENT)
            (begin
                (asserts! (not (has-mined miner-id stacks-block-height))
                    (err ERR-ALREADY-MINED))

                (asserts! (> amount-ustx u0)
                    (err ERR-CANNOT-MINE))

                (asserts! (>= (stx-get-balance miner) amount-ustx)
                    (err ERR-INSUFFICIENT-BALANCE))

                (ok true)
            )
        )
    )
)

;; Getter to obtain the list of miners and uSTX commitments at a given Stacks block height,
;; OR, an empty such structure.

(define-private (get-mined-block-or-default (stacks-block-height uint))
    (match (map-get? mined-blocks { stacks-block-height: stacks-block-height })
        block block
        { 
            miners-count: u0, 
            commitment-ustx: u0,
            winner-id: u0,
            claimed: false,
        })
)


;; Mark a miner as having mined in a given Stacks block and committed the given uSTX.
(define-private (set-tokens-mined (miner principal) (miner-id uint) (stacks-block-height uint) (commit-ustx uint))
    (let (
        (block (get-mined-block-or-default stacks-block-height))
        (increased-miners-count (+ (get miners-count block) u1))
        (new-idx increased-miners-count)
        (commitment-ustx (get commitment-ustx block))
    )
    (begin
        (begin
            ;; list is not full - add new miner and calculate if he committed the least
            (map-set blocks-miners
                { stacks-block-height: stacks-block-height, idx: new-idx }
                { miner-id: miner-id, ustx: commit-ustx }
            )

            (map-set miners-ids
                { miner-id: miner-id }
                { miner-addr: tx-sender }
            )

            (map-set mined-blocks
                { stacks-block-height: stacks-block-height }
                {
                    miners-count: increased-miners-count,
                    commitment-ustx: (+ commitment-ustx commit-ustx),
                    winner-id: u0,
                    claimed: false
                }
            )
        )
            
        
        ;;TODO
        (map-set miners-block-commitment
            { miner-id: miner-id, stacks-block-height: stacks-block-height}
            { committed: true }
        )
        (if (> MAX-MINERS-COUNT (get miners-count block))
            (ok true)
            (err ERR-TOO-MANY-MINERS)
        )
    ))
)


(define-fungible-token resonancetoken u10000000)

(define-public (claim-token-reward (mined-stacks-block-ht uint))
    (let (
        (random-sample (unwrap! (get-random-uint-at-block (+ mined-stacks-block-ht (var-get token-reward-maturity)))
                        (err ERR-IMMATURE-TOKEN-REWARD)))
        (block (unwrap! (map-get? mined-blocks { stacks-block-height: mined-stacks-block-ht })
                        (err ERR-NO-WINNER)))
    )
    (begin
        (try! (can-claim-tokens tx-sender mined-stacks-block-ht random-sample block-height))
        (try! (set-tokens-claimed mined-stacks-block-ht))
        (unwrap-panic (mint-coinbase tx-sender mined-stacks-block-ht))

        (ok true)
    ))
)


;; Returns miner ID if it has been created
(define-read-only (get-miner-id (miner principal))
    (get miner-id (map-get? miners { miner: miner }))
)

;; Mark a batch of mined tokens as claimed, so no one else can go and claim them.
(define-private (set-tokens-claimed (claimed-stacks-block-height uint))
    (let (
      (miner-rec (unwrap!
          (map-get? mined-blocks { stacks-block-height: claimed-stacks-block-height })
          (err ERR-NO-WINNER)))
    )
    (begin
       (asserts! (not (get claimed miner-rec))
          (err ERR-ALREADY-CLAIMED))

       (map-set mined-blocks
           { stacks-block-height: claimed-stacks-block-height }
           (merge miner-rec { claimed: true })
       )
       (ok true)))
)

(define-read-only (can-claim-tokens (claimer principal) 
                                    (claimer-stacks-block-height uint)
                                    (random-sample uint)
                                    (current-stacks-block uint))
    (let (
        (block (unwrap! (map-get? mined-blocks { stacks-block-height: claimer-stacks-block-height })
                        (err ERR-NO-WINNER)))
        (claimer-id (unwrap! (get-miner-id claimer) 
                        (err ERR-MINER-ID-NOT-FOUND)))
        (reward-maturity (var-get token-reward-maturity))

    )
    (if (< claimer-stacks-block-height (- current-stacks-block (var-get token-reward-maturity)))
        (begin
            (asserts! (not (get claimed block))
                (err ERR-ALREADY-CLAIMED))

            (match (get-block-winner claimer-stacks-block-height random-sample)
                winner-rec (if (is-eq claimer-id (get miner-id winner-rec))
                               (ok true)
                               (err ERR-UNAUTHORIZED))
                (err ERR-NO-WINNER))
        )
        (err ERR-IMMATURE-TOKEN-REWARD)))
)


;; Determine who won a given batch of tokens, given a random sample and a list of miners and commitments.
;; The probability that a given miner wins the batch is proportional to how many uSTX it committed out of the 
;; sum of commitments for this block.
(define-read-only (get-block-winner (stacks-block-height uint) (random-sample uint))
    (let
        (
            (commit-total (default-to u0 (get commitment-ustx (map-get? mined-blocks {stacks-block-height: stacks-block-height}))))
        )
        (if (> commit-total u0)
            (get winner (fold 
                get-block-winner-closure 
                (get-uint-list (get miners-count (get-mined-block-or-default stacks-block-height)))
                { 
                    stacks-block-height: stacks-block-height,
                    sample: (mod random-sample commit-total), 
                    sum: u0, 
                    winner: none
                }
            ))
            none
        )
    )
)

;; Inner fold function to determine which miner won the token batch at a particular Stacks block height, given a sampling value.
(define-private (get-block-winner-closure (idx uint) (data { stacks-block-height: uint, sample: uint, sum: uint, winner: (optional { miner-id: uint, ustx: uint})}))
    (begin
        (match (map-get? blocks-miners { stacks-block-height: (get stacks-block-height data), idx: idx})
            miner 
            (let
                (
                    (sum (get sum data))
                    (sample (get sample data))
                    (ustx (get ustx miner))
                    (next-sum (+ sum ustx))
                    (new-winner
                        (if (and (>= sample sum) (< sample next-sum))
                            (some miner)
                            (get winner data)
                        )
                    )
                )
                {
                    stacks-block-height: (get stacks-block-height data),
                    sample: sample,
                    sum: next-sum,
                    winner: new-winner
                }
            )
            data
        )
    )
)

(define-map UintLists
    uint                ;; size
    (list 128 uint)     ;; actual list
)

(define-map miners-ids
    {miner-id: uint}
    {miner-addr: principal}
)

(define-read-only (get-miner-addr (miner-id uint))
    (match (map-get? miners-ids { miner-id: miner-id })
        miner miner
        { 
            miner-addr: 'STWNR9453W215A1HGRN4GPXE2SDHW2S51WFTCTEE
        })
)

(define-private (get-uint-list (size uint))
    (default-to (list ) (map-get? UintLists size))
)

(fold fill-uint-list-closure LONG-UINT-LIST true)

(define-private (fill-uint-list-closure (idx uint) (x bool))
    (if (is-eq idx u1)
        (map-insert UintLists
            idx
            (unwrap-panic (as-max-len? (list u1) u128))
        )
        (map-insert UintLists
            idx
            (unwrap-panic (as-max-len? (append (unwrap-panic (map-get? UintLists (- idx u1))) idx) u128))
        )
    )
)

;; Read the on-chain VRF and turn the lower 16 bytes into a uint, in order to sample the set of miners and determine
;; which one may claim the token batch for the given block height.
(define-read-only (get-random-uint-at-block (stacks-block uint))
    (let 
        (
            (vrf-lower-uint-opt
                (match (get-block-info? vrf-seed stacks-block)
                    vrf-seed (some (buff-to-uint-le (lower-16-le vrf-seed)))
                    none)
            )
        )
        vrf-lower-uint-opt
    )
)

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

(define-private (mint-coinbase (recipient principal) (stacks-block-ht uint))
    (ft-mint? resonancetoken (var-get block-reward) recipient)
) 

;; define initial token URI
(define-data-var token-uri (optional (string-utf8 256)) (some u"<link to token-uri>"))

;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;
;; testnet 
;; (impl-trait 'ST2EKQHV1XVFET0FP9VC4EBTFSCA1GVACD6QR3RXR.sip-010-trait-ft-standard.sip-010-trait)
;; mainnet
;;(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-read-only (get-name)
    (ok "Resonance Token"))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender)
            (err ERR-UNAUTHORIZED))

        (if (is-some memo)
            (print memo)
            none
        )

        (ft-transfer? resonancetoken amount from to)
    )
)

(define-read-only (get-symbol)
    (ok "RTX"))

;; minimal unit is 0

(define-read-only (get-decimals)
    (ok u0))

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance resonancetoken user)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply resonancetoken)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))