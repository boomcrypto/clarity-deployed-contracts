
(define-constant err-too-long (err u102))


;; from base 16 to base 10
(define-read-only (buff-to-u8 (byte (buff 1))) ;; buff = 1 byte = 2 hex characters
  (unwrap-panic (index-of 0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff byte)))

;; from base 10 to string-ascii
(define-read-only (uint-to-ascii (index uint)) 
  (unwrap-panic (element-at "                                             -  0123456789       ABCDEFGHIJKLMNOPQRSTUVWXYZ    _ abcdefghijklmnopqrstuvwxyz    " index)))

;; from base 16 to string-ascii
(define-read-only (buff-to-ascii (byte (buff 1))) 
  (uint-to-ascii (buff-to-u8 byte)))

(define-read-only (uint-to-string (value uint))
  (if (<= value u9)
    (unwrap-panic (element-at "0123456789" value))
    (get r 
      (fold uint-to-ascii-inner 
        0x0000000000000000000000000000000000
        {v: value, r: ""}))))

(define-read-only (uint-to-ascii-inner (i (buff 1)) (d {v: uint, r: (string-ascii 17)}))
  (if (> (get v d) u0)
    {v: (/ (get v d) u10),
      r: (unwrap-panic 
        (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get v d) u10))) (get r d)) u17))}
    d))

;; used to convert to hex
(define-private (concat-string (a (string-ascii 20)) (b (string-ascii 20))) 
  (unwrap-panic (as-max-len? (concat b a) u20)))

(define-read-only (convert-word-hex-to-ascii (byte (buff 20)))
  (fold concat-string (map buff-to-ascii byte) ""))

;; (contract-call? .bsn-nft concat-name 0x7369726a6f6e617468616e 0x627463)
(define-read-only (concat-name (first-hex (buff 20)) (second-hex (buff 9)))
  (concat 
    (concat (convert-word-hex-to-ascii first-hex) ".")
    (convert-word-hex-to-ascii second-hex)))

;; (contract-call? .conversions resolve-principal-to-ascii {name: 0x7369726a6f6e617468616e, namespace: 0x627463})
(define-read-only (resolve-principal-to-ascii (bns {name: (buff 20), namespace: (buff 9)}))
  (let ((name (as-max-len? (concat-name (get name bns) (get namespace bns)) u30)))
    (asserts! (not (is-none name)) err-too-long)
    (ok (unwrap-panic name))))
