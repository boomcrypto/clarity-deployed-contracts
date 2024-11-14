---
title: "Trait charisma-randomizer-rc1"
draft: true
---
```
;; Stateless VRF Random Seed Generator with User-Specific Seed

;; Read Only functions

(define-read-only (get-random-seed)
  (let
    (
      (block-seed (unwrap-panic (get-block-info? vrf-seed (- block-height u1))))
      (block-random (lower-16-le block-seed))
      (user-balance (stx-get-balance tx-sender))
      (user-random (mod user-balance u65536))  ;; Convert user balance to a 16-bit number
      (combined-seed (xor block-random user-random))  ;; Combine block and user randomness
    )
    (ok combined-seed)
  )
)

(define-read-only (roll-die (sides uint))
  (let
    ((random-value (unwrap-panic (get-random-seed))))
    (ok (+ u1 (mod random-value sides)))
  )
)

;; Private functions

(define-private (lower-16-le (vrf-seed (buff 32)))
  (fold + 
    (map lower-16-le-inner
      (list 
        (unwrap-panic (element-at vrf-seed u16))
        (unwrap-panic (element-at vrf-seed u17))
        (unwrap-panic (element-at vrf-seed u18))
        (unwrap-panic (element-at vrf-seed u19))
        (unwrap-panic (element-at vrf-seed u20))
        (unwrap-panic (element-at vrf-seed u21))
        (unwrap-panic (element-at vrf-seed u22))
        (unwrap-panic (element-at vrf-seed u23))
        (unwrap-panic (element-at vrf-seed u24))
        (unwrap-panic (element-at vrf-seed u25))
        (unwrap-panic (element-at vrf-seed u26))
        (unwrap-panic (element-at vrf-seed u27))
        (unwrap-panic (element-at vrf-seed u28))
        (unwrap-panic (element-at vrf-seed u29))
        (unwrap-panic (element-at vrf-seed u30))
        (unwrap-panic (element-at vrf-seed u31))
      )
      (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15)
    )
    u0
  )
)

(define-private (lower-16-le-inner (byte (buff 1)) (pos uint))
  (* (buff-to-u8 byte) (pow u2 (* u8 pos)))
)

(define-private (buff-to-u8 (byte (buff 1)))
  (unwrap-panic (index-of 0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff byte))
)
```
