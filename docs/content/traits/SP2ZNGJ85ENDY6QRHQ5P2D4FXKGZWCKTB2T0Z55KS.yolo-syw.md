---
title: "Trait yolo-syw"
draft: true
---
```
(define-constant ALL_HEX 0x000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF)
(define-constant BASE58_CHARS "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
(define-constant STX_VER 0x16141a15)
(define-constant BTC_VER 0x00056fc4)
(define-constant LST (list))

(define-constant ERR_INVALID_ADDR (err u1))

(define-read-only (convert (addr principal))
    (match (principal-destruct? addr) 
        ;; if version byte match the network (ie. mainnet principal on mainnet, or testnet principal on testnet)
        network-match-data (convert-inner network-match-data)
        ;; if versin byte does not match the network
        network-not-match-data (convert-inner network-not-match-data)
    )
)

(define-read-only (convert-inner (data {hash-bytes: (buff 20), name: (optional (string-ascii 40)), version:(buff 1)}))
    (let (
        ;; exit early if contract principal
        (t1 (asserts! (is-none (get name data)) ERR_INVALID_ADDR))
        ;; convert STX version byte to BTC version
        (version (unwrap-panic (element-at? BTC_VER (unwrap-panic (index-of? STX_VER (get version data))))))
        ;; concat BTC version & hash160 
        (versioned-hash-bytes (concat version (get hash-bytes data)))
        ;; concat hash-bytes & 4 bytes checksum, and convert hext to uint
        (to-encode (map hex-to-uint (concat 
            versioned-hash-bytes 
            ;; checksum = encode versionded-hash-bytes 2x with sha256, and then extract first 4 bytes
            ;; we can use unwrap-panic twice, because sha256 of empty buff will alwasy return value
            (unwrap-panic (as-max-len? (unwrap-panic (slice? (sha256 (sha256 versioned-hash-bytes)) u0 u4)) u4))
        )))
        ;; "cut" leading zeros leveraging index-of? property
        ;; first convert list of uint's to list of booleans that tells if value was 0 or not
        ;; (list u0 u0 u2 u23 u0 u3 u53 u22) -> (list true true false false true false false false)
        ;; since index-of? always returns first index we use it to find the position of first non-zero value
        ;; and we default it to u0 - in case it won't find anything
        ;; in our example, it will return (some u2)
        ;; the reason why we default to u0 is that (slice? (list u0 u0 u2 u23 u0 u3 u53 u22) u0 u0) will return (some (list))
        ;; it guarantees that our slice? will never return (none) so we can safely use unwrap-panic here
        (leading-zeros (unwrap-panic (slice? to-encode u0 (default-to u0 (index-of? (map is-zero to-encode) false)))))
    )
        (ok 
            (fold 
                convert-to-base58-string 
                ;; run through "outer-loop" everything except leading zeros
                ;; and concatenate results with leading zeros if any
                ;; we use u25, because hash-bytes (aka. hash160) = 20 bytes, version = 1 byte, and checksum = 4 bytes
                (concat (fold outer-loop (unwrap-panic (slice? to-encode (len leading-zeros) u25)) LST) leading-zeros) 
                ""
            )
        )
    )
)


(define-read-only (outer-loop (x uint) (out (list 44 uint)))
    (let (
        (new-out (fold update-out out (list x)))
        (push (fold carry-push 0x0000 (list (unwrap-panic (element-at? new-out u0)))))
    )
        (concat 
            (default-to LST (slice? new-out u1 (len new-out)))
            (default-to LST (slice? push u1 (len push)))
        )
    )
)

(define-read-only (update-out (x uint) (out (list 35 uint)))
    (let (
        ;; first byte of out is always a carry from previous iteration
        (carry (+ (unwrap-panic (element-at? out u0)) (* x u256)))
    )
        (unwrap-panic (as-max-len? (concat  
            (list (/ carry u58)) ;; new carry
            (concat 
                (default-to LST (slice? out u1 (len out))) ;; existing list
                (list (mod carry u58)) ;; new value we want to append
            )
        ) u35))
    )
)

(define-read-only (carry-push (x (buff 1)) (out (list 9 uint)))
    (let (
        ;; first byte of out is always a carry from previous iteration
        (carry (unwrap-panic (element-at? out u0)))
    )
        (if (> carry u0)
            ;; we only change out if cary is > u0
            (unwrap-panic (as-max-len? (concat 
                (list (/ carry u58)) ;; new carry
                (concat
                    (default-to LST (slice? out u1 (len out))) ;; existing list
                    (list (mod carry u58)) ;; new value we want to append
                )
            ) u9))
            ;; do nothing
            out
        )
    )
)

;; converts uint to base58 caracter and concatenate in reverse order
(define-read-only (convert-to-base58-string (x uint) (out (string-ascii 44)))
    (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at? BASE58_CHARS x)) out) u44))
)

(define-read-only (hex-to-uint (x (buff 1))) (unwrap-panic (index-of? ALL_HEX x)))
(define-read-only (is-zero (i uint)) (<= i u0))
```
