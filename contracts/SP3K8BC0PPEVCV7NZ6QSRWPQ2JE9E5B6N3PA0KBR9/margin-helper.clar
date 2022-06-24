(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait sft-trait .trait-semi-fungible.semi-fungible-trait)
(use-trait flash-loan-user-trait .trait-flash-loan-user.flash-loan-user-trait)
(define-constant ONE_8 u100000000)
(define-public (create-margin-position (token-trait <ft-trait>) (collateral-trait <ft-trait>) (expiry uint) (yield-token-trait <sft-trait>) (key-token-trait <sft-trait>) (dx uint) (min-dy (optional uint)))
    (let
        (
            (sender tx-sender)
            (gross-dx (div-down dx (- ONE_8 (try! (contract-call? .collateral-rebalancing-pool-v1 get-ltv (contract-of token-trait) (contract-of collateral-trait) expiry)))))
            (loan-amount (- gross-dx dx))
            (loan-amount-with-fee (mul-down loan-amount (+ ONE_8 (unwrap-panic (contract-call? .alex-vault get-flash-loan-fee-rate)))))
            (loaned (as-contract (try! (contract-call? .alex-vault transfer-ft collateral-trait loan-amount sender))))
            (minted-yield-token (get yield-token (try! (contract-call? .collateral-rebalancing-pool-v1 add-to-position token-trait collateral-trait expiry yield-token-trait key-token-trait gross-dx))))
            (swapped-token (get dx (try! (contract-call? .yield-token-pool swap-y-for-x expiry yield-token-trait token-trait minted-yield-token min-dy))))
        )
        (try! (contract-call? .swap-helper-v1-03 swap-helper token-trait collateral-trait swapped-token none))      
        (try! (contract-call? collateral-trait transfer-fixed loan-amount-with-fee sender .alex-vault none))
        (ok loan-amount-with-fee)
    )
)
(define-public (roll-position (token <ft-trait>) (collateral <ft-trait>) (the-key-token <sft-trait>) (flash-loan-user <flash-loan-user-trait>) (expiry uint) (expiry-to-roll uint))
    (let
        (
            (reduce-data (try! (contract-call? .collateral-rebalancing-pool-v1 reduce-position-key token collateral expiry the-key-token ONE_8)))
        )
        (contract-call? .alex-vault flash-loan flash-loan-user collateral 
            (+ 
                (get dx reduce-data) 
                (if (is-eq (get dy reduce-data) u0) u0 (try! (contract-call? .swap-helper-v1-03 swap-helper token collateral (get dy reduce-data) none)))
            ) 
            (some (uint-to-buff expiry-to-roll))
        )
    )
)
(define-data-var so-far uint u0)
(define-data-var out-buf (buff 16) 0x)
(define-private (uint-to-buff (n uint))
    (if (is-eq n u0) 0x00
    (begin 
        (var-set out-buf 0x)
        (var-set so-far n)
        (map mod-256 mods)
        (var-get out-buf)
    ))
)
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
(define-constant mods
    (list 
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
        true true true true true true true true
    )
)
(define-private (val-append (vmod uint))
    (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at BUFF-TO-BYTE vmod)) (var-get out-buf)) u16))
)
(define-private (mod-256 (vmod bool))
    (let 
        (
            (sf (var-get so-far)) 
            (mod-val (mod sf u256))
        )
        (if (> sf u0) 
            (begin 
                (var-set so-far (/ sf u256))
                (var-set out-buf (val-append mod-val))
                mod-val
            )
            mod-val
        )
    )
)
(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)
(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0)
    u0
    (/ (* a ONE_8) b)
  )
)