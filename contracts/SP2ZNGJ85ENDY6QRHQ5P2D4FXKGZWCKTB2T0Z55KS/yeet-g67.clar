;; Base58 decoding function for Clarity
;; Takes a base58 string and returns its hex representation

(define-constant BASE58_ALPHABET "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")

(define-private (char-to-u8 (c (string-ascii 1)))
  (unwrap-panic
    (index-of BASE58_ALPHABET c)))

(define-read-only (b58-decode (input (string-ascii 34)))
  (let
    (
      ;; Extract characters from the input string
      (c1 (unwrap-panic (element-at input u0)))
      (c2 (unwrap-panic (element-at input u1)))
      (c3 (unwrap-panic (element-at input u2)))
      (c4 (unwrap-panic (element-at input u3)))
      (c5 (unwrap-panic (element-at input u4)))
      (c6 (unwrap-panic (element-at input u5)))
      (c7 (unwrap-panic (element-at input u6)))
      (c8 (unwrap-panic (element-at input u7)))
      (c9 (unwrap-panic (element-at input u8)))
      (c10 (unwrap-panic (element-at input u9)))
      (c11 (unwrap-panic (element-at input u10)))
      (c12 (unwrap-panic (element-at input u11)))
      (c13 (unwrap-panic (element-at input u12)))
      (c14 (unwrap-panic (element-at input u13)))
      (c15 (unwrap-panic (element-at input u14)))
      (c16 (unwrap-panic (element-at input u15)))
      (c17 (unwrap-panic (element-at input u16)))
      (c18 (unwrap-panic (element-at input u17)))
      (c19 (unwrap-panic (element-at input u18)))
      (c20 (unwrap-panic (element-at input u19)))
      (c21 (unwrap-panic (element-at input u20)))
      (c22 (unwrap-panic (element-at input u21)))
      (c23 (unwrap-panic (element-at input u22)))
      (c24 (unwrap-panic (element-at input u23)))
      (c25 (unwrap-panic (element-at input u24)))
      (c26 (unwrap-panic (element-at input u25)))
      (c27 (unwrap-panic (element-at input u26)))
      (c28 (unwrap-panic (element-at input u27)))
      (c29 (unwrap-panic (element-at input u28)))
      (c30 (unwrap-panic (element-at input u29)))
      (c31 (unwrap-panic (element-at input u30)))
      (c32 (unwrap-panic (element-at input u31)))
      (c33 (unwrap-panic (element-at input u32)))
      (c34 (unwrap-panic (element-at input u33)))
      
      ;; Convert each character to its numeric value in the Base58 alphabet
      (v1 (char-to-u8 c1))
      (v2 (char-to-u8 c2))
      (v3 (char-to-u8 c3))
      (v4 (char-to-u8 c4))
      (v5 (char-to-u8 c5))
      (v6 (char-to-u8 c6))
      (v7 (char-to-u8 c7))
      (v8 (char-to-u8 c8))
      (v9 (char-to-u8 c9))
      (v10 (char-to-u8 c10))
      (v11 (char-to-u8 c11))
      (v12 (char-to-u8 c12))
      (v13 (char-to-u8 c13))
      (v14 (char-to-u8 c14))
      (v15 (char-to-u8 c15))
      (v16 (char-to-u8 c16))
      (v17 (char-to-u8 c17))
      (v18 (char-to-u8 c18))
      (v19 (char-to-u8 c19))
      (v20 (char-to-u8 c20))
      (v21 (char-to-u8 c21))
      (v22 (char-to-u8 c22))
      (v23 (char-to-u8 c23))
      (v24 (char-to-u8 c24))
      (v25 (char-to-u8 c25))
      (v26 (char-to-u8 c26))
      (v27 (char-to-u8 c27))
      (v28 (char-to-u8 c28))
      (v29 (char-to-u8 c29))
      (v30 (char-to-u8 c30))
      (v31 (char-to-u8 c31))
      (v32 (char-to-u8 c32))
      (v33 (char-to-u8 c33))
      (v34 (char-to-u8 c34))
      
      ;; Compute the decimal value using the base58 positional system
      ;; For each digit, multiply by 58^position and sum
      (decimal-value (+ 
        (* v1 (pow u58 u33))
        (* v2 (pow u58 u32))
        (* v3 (pow u58 u31))
        (* v4 (pow u58 u30))
        (* v5 (pow u58 u29))
        (* v6 (pow u58 u28))
        (* v7 (pow u58 u27))
        (* v8 (pow u58 u26))
        (* v9 (pow u58 u25))
        (* v10 (pow u58 u24))
        (* v11 (pow u58 u23))
        (* v12 (pow u58 u22))
        (* v13 (pow u58 u21))
        (* v14 (pow u58 u20))
        (* v15 (pow u58 u19))
        (* v16 (pow u58 u18))
        (* v17 (pow u58 u17))
        (* v18 (pow u58 u16))
        (* v19 (pow u58 u15))
        (* v20 (pow u58 u14))
        (* v21 (pow u58 u13))
        (* v22 (pow u58 u12))
        (* v23 (pow u58 u11))
        (* v24 (pow u58 u10))
        (* v25 (pow u58 u9))
        (* v26 (pow u58 u8))
        (* v27 (pow u58 u7))
        (* v28 (pow u58 u6))
        (* v29 (pow u58 u5))
        (* v30 (pow u58 u4))
        (* v31 (pow u58 u3))
        (* v32 (pow u58 u2))
        (* v33 (pow u58 u1))
        (* v34 (pow u58 u0)))))
      
    ;; Convert to hex representation
    decimal-value
  )
)

;; Example usage:
;; (b58-decode "1JSjpoj1m57KQqd9SvYgFzbRVUwrmk4Emd")
;; This should return the hex representation of the bitcoin address