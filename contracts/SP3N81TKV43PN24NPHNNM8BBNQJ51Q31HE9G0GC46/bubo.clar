(impl-trait .nft-trait.nft-trait)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ITEMS-COUNT u10000)
(define-constant COST-PER-MINT u10000000) ;; 10 STX
(define-constant METADATA-URL "ipfs://QmRWzC2FEB4u1jEkVpc18XwxnVCxks7ZwLuhFHjfn2FeAU")

(define-constant WALLET_1 'SP3QGVAJF6MR97EMER9CG5D49554H32RMGXACY2T2) ;; Bubo 1
(define-constant WALLET_2 'SP31BKGJ5B9J5ZPB01XZE5CVAMWWDTVDKEQCJZJGP) ;; Bubo 2
(define-constant WALLET_3 'SPRP3YK0A1SXM9KRJEVEG0TNGB4EETQM3NQE79P)   ;; Bubo 3
(define-constant WALLET_4 'SP332YPTKCRZQPGS1B09TK8MDV4AR9HVJR98H47T4) ;; Bubo 4
(define-constant WALLET_5 'SP1R53477K751WX62R5FMQ22M2FW4EXHKDZV6CG76) ;; Piggy Bank

(define-constant ERR-ALL-MINTED (err u300))
(define-constant ERR-NOT-AUTHORIZED (err u401))

(define-non-fungible-token bubo uint)

(define-read-only (get-last-token-id)
    (ok (unwrap-panic (map-get? chosen-ids (var-get remaining))))
)

(define-read-only (get-token-uri (id uint))
    (ok (some METADATA-URL))
)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? bubo id))
)

(define-public (transfer (id uint) (sender principal) (recipient principal))
    (if (and (is-eq sender tx-sender) (is-owner id sender))
        (match (nft-transfer? bubo id sender recipient)
            success (ok true)
            error (err error)
        )
        ERR-NOT-AUTHORIZED
    )
)

(define-public (mint)
    (let ((remaining-ids (var-get remaining)))
        (asserts! (> remaining-ids u0) ERR-ALL-MINTED)
        (match (cycle-random-id remaining-ids)
            random-id (begin
                (try! (stx-transfer? u1250000 tx-sender WALLET_1)) ;; 1.25 STX
                (try! (stx-transfer? u1250000 tx-sender WALLET_2)) ;; 1.25 STX
                (try! (stx-transfer? u1250000 tx-sender WALLET_3)) ;; 1.25 STX
                (try! (stx-transfer? u1250000 tx-sender WALLET_4)) ;; 1.25 STX
                (try! (stx-transfer? u5000000 tx-sender WALLET_5)) ;; 5 STX
                (nft-mint? bubo random-id tx-sender)
                )
            err_code (err err_code)
        )
    )
)

(define-public (mint-five)
  (begin
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (ok true)
  )
)

(define-public (mint-ten)
  (begin
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (try! (mint))
    (ok true)
  )
)

(define-public (burn (id uint))
  (if (is-owner id tx-sender)
    (match (nft-burn? bubo id tx-sender)
      success (ok true)
      error (err error)
    )
    ERR-NOT-AUTHORIZED
  )
)

(define-private (is-owner (id uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? bubo id) false))
)

;; Random Number Generation Code Start
;; Article Explaining The Code Logic: https://app.sigle.io/friendsferdinand.id.stx/0qcwQKKc5ifXdnonQLXjF
;; Source: https://github.com/FriendsFerdinand/random-test/blob/main/contracts
(define-map chosen-ids uint uint)
(define-data-var remaining uint ITEMS-COUNT)
(define-data-var last-block uint u0)
(define-data-var last-vrf (buff 128) 0x00)
(define-data-var b-idx uint u0)
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

(define-private (set-vrf)
    (let (
        (seed (unwrap-panic (get-block-info? vrf-seed (- block-height u1))))
        )
        (var-set last-vrf
            (concat
                (sha512 (unwrap-panic (element-at seed u0)))
                (sha512 (unwrap-panic (element-at seed u1)))
            )
        )
    )
)

(define-private (rand (byte-idx uint))
    (let ((vrf (var-get last-vrf)) )
        (+ 
            (* (unwrap-panic (index-of BUFF_TO_BYTE (unwrap-panic (element-at vrf byte-idx)))) u256)
            (unwrap-panic (index-of BUFF_TO_BYTE (unwrap-panic (element-at vrf (+ byte-idx u1)))))
        )
    )
)

(define-private (swap-container (id uint) (idx uint) (ids-remaining uint))
    (let (
            (top (- ids-remaining u1))
            (top-id (default-to top (map-get? chosen-ids top)))
        )
        (map-set chosen-ids top id)
        (map-set chosen-ids idx top-id)
        (var-set remaining top)
    )
)

(define-private (cycle-random-id (remaining-ids uint))
    (let (
         (byte-idx (var-get b-idx))
         )
        (if (is-eq (var-get last-block) block-height)
            (begin
                (asserts! (< byte-idx u126) (err u502)) ;; We ran out of random numbers, try again next block
                (let (
                    (picked-idx (mod (rand byte-idx) remaining-ids))
                    (picked-id (default-to picked-idx (map-get? chosen-ids picked-idx)))
                    )
                    (swap-container picked-id picked-idx remaining-ids)
                    (var-set b-idx (+ byte-idx u2))
                    (ok picked-id)
                )
            )
            (begin
                (set-vrf)
                (let (
                    (picked-idx (mod (rand byte-idx) remaining-ids))
                    (picked-id (default-to picked-idx (map-get? chosen-ids picked-idx)))
                    )
                    (var-set last-block block-height)
                    (swap-container picked-id picked-idx remaining-ids)
                    (var-set b-idx u2)
                    (ok picked-id)
                )
            )
        )
    )
)
;; Random Number Generation Code End

(print "Shout out to hz for all the support!")