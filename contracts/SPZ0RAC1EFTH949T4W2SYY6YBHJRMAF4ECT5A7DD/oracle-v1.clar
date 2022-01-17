(define-constant err-recover (err u61))
(define-constant err-incorrect-signature (err u62))
(define-constant err-not-owner (err u63))
(define-constant err-older-timestamp (err u64))

;; TODO(psq): change address for mainnet, change to deployment address (ORACLE_STX)
(define-constant contract-owner 'SPZ0RAC1EFTH949T4W2SYY6YBHJRMAF4ECT5A7DD)

;; "\x19Ethereum Signed Message:\n32"
(define-constant eth-preamble 0x19457468657265756d205369676e6564204d6573736167653a0a3332)

(define-map oracle-data
  { source: (string-ascii 16), symbol: (string-ascii 32) }
  { timestamp: uint, height: uint, amount: uint }
)

(define-map sources
  { source: (string-ascii 16) }
  { public-key: (buff 33) }
)

(define-data-var offsets-timestamp (list 8 uint) (list u60 u61 u62 u63))
(define-data-var offsets-amount (list 8 uint) (list u120 u121 u122 u123 u124 u125 u126 u127))
(define-data-var offsets-symbol-offset (list 8 uint) (list u94 u95))  ;; 1 byte might be enough
(define-data-var offsets-symbol-length (list 8 uint) (list u223))  ;; assume 1 byte is enough

(define-constant BUFF_TO_UINT8 (list
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

(define-constant UINT8_TO_ASCII (list
    "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "."
    "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "."
    " " "!" "\"" "#" "$" "%" "&" "'" "(" ")" "*" "+" "," "-" "." "/"
    "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" ":" ";" "<" "=" ">" "?"
    "@" "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O"
    "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" "[" "." "]" "^" "_"
    "@" "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o"
    "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z" "{" "|" "}" "~" "."
    "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "."
    "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "."
    "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "."
    "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "."
    "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "."
    "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "."
    "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "."
))

(define-private (buff-to-u8 (byte (buff 1)))
  (unwrap-panic (index-of BUFF_TO_UINT8 byte))
)

(define-private (buff-to-ascii (byte (buff 1)))
  (unwrap-panic (element-at UINT8_TO_ASCII (unwrap-panic (index-of BUFF_TO_UINT8 byte))))
)

(define-private (add-and-shift-uint-offsets (idx uint) (input { acc: uint, data: (buff 256) }))
  (let (
    (acc (get acc input))
    (data (get data input))
    (byte (buff-to-u8 (unwrap-panic (element-at data idx))))
  )
  {
    acc: (+ (* acc u256) byte),
    data: data
  })
)

(define-private (buff-to-uint (word (buff 256)) (offsets (list 8 uint)))
  (get acc
    (fold add-and-shift-uint-offsets offsets { acc: u0, data: word })
  )
)

(define-private (construct-string (idx uint) (input { acc: (string-ascii 32), offset: uint, length: uint, data: (buff 256) }))
  (let (
      (acc (get acc input))
      (offset (get offset input))
      (length (get length input))
      (data (get data input))
      (char (buff-to-ascii (unwrap-panic (element-at data (+ idx offset)))))
    )
    (if (> length u0)
      {
        acc: (unwrap-panic (as-max-len? (concat acc char) u32)),
        offset: offset,
        length: (- length u1),
        data: data
      }
      input
    )
  )
)

(define-private (buff-to-string (msg (buff 256)) (symbol-offset uint) (symbol-length uint))
  (get acc
    (fold construct-string (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31) { acc: "", offset: symbol-offset, length: symbol-length, data: msg })
  )
)

;; this one liner took 3-4 whole days to get right... you are welcome!
(define-read-only (verify-signature (msg (buff 256)) (signature (buff 65)) (public-key (buff 33)))
  (is-eq (unwrap-panic (secp256k1-recover? (keccak256 (concat eth-preamble (keccak256 msg))) signature)) public-key)
)

;; 32-63 of message
(define-read-only (extract-timestamp (msg (buff 256)))
  (buff-to-uint msg (var-get offsets-timestamp))
)

;; 96-127 of message
(define-read-only (extract-amount (msg (buff 256)))
  (buff-to-uint msg (var-get offsets-amount))
)

;; 64-95 offset
;; length usually at 192, value at 224
(define-read-only (extract-symbol (msg (buff 256)))
  (let ((length-offset (buff-to-uint msg (var-get offsets-symbol-offset))))
    (let ((symbol-offset (+ length-offset u32)) (symbol-length (buff-to-uint msg (list (+ length-offset u31)))))
      (unwrap-panic (as-max-len? (buff-to-string msg symbol-offset symbol-length) u32))
    )
  )
)

;; source needs to be known and have a key
;; verify message was signed with source
;; verify timestamp is strictly higher than current one, we don't want to go back in time
(define-public (add-price (source (string-ascii 16)) (msg (buff 256)) (sig (buff 65)))
  (if (verify-signature msg sig (get public-key (unwrap-panic (map-get? sources {source: source}))))
    (let ((timestamp (extract-timestamp msg)) (amount (extract-amount msg)) (symbol (extract-symbol msg)) (data-opt (map-get? oracle-data {source: source, symbol: symbol})))
      (if (is-some data-opt)
        (let ((data (unwrap-panic data-opt)) (prior-timestamp (get timestamp data)))
          (if (> timestamp prior-timestamp)
            (begin
              (map-set oracle-data {source: source, symbol: symbol} {timestamp: timestamp, height: block-height, amount: amount })
              (ok true)
            )
            err-older-timestamp
          )
        )
        (begin
          (map-set oracle-data {source: source, symbol: symbol} {timestamp: timestamp, height: block-height, amount: amount })
          (ok true)
        )
      )
    )
    err-incorrect-signature
  )
)

(define-private (call-add-price (price {src: (string-ascii 16), msg: (buff 256), sig: (buff 65)}))
  (unwrap-panic (add-price (get src price) (get msg price) (get sig price)))
)

;; main entry point for adding a batch or quotes in one transaction
(define-public (add-prices (prices (list 100 {src: (string-ascii 16), msg: (buff 256), sig: (buff 65)})))
  (begin
    (map call-add-price prices)
    (ok true)
  )
)

;; the price has been vetted by add-price, so it can be retrieved as fast as can be
(define-read-only (get-price (source (string-ascii 16)) (symbol (string-ascii 32)))
  (map-get? oracle-data {source: source, symbol: symbol})
)

(define-public (add-source (source (string-ascii 16)) (public-key (buff 33)))
  ;; check sender
  ;; insert source into known sources
  (if (is-eq tx-sender contract-owner)
    (begin
      (map-set sources { source: source} { public-key: public-key })
      (ok true)
    )
    err-not-owner
  )
)

(define-public (revoke-source (source (string-ascii 16)))
  ;; check sender
  ;; remove source from known sources
  (if (is-eq tx-sender contract-owner)
    (begin
      (map-delete sources { source: source})
      (ok true)
    )
    err-not-owner
  )
)

(define-read-only (check-source (source (string-ascii 16)))
  (map-get? sources { source: source})
)

;; preseed with trusted sources
;; need compressed version of public keys
(map-set sources {source: "coinbase"} {public-key: 0x034170a2083dccbc2be253885a8d0e9f7ce859eb370d0c5cae3b6994af4cb9d666})  ;; Eth: 0xfCEAdAFab14d46e20144F48824d0C09B1a03F2BC
(map-set sources {source: "okcoin"} {public-key: 0x0325df290b8c4930adcf8cd5c883616a1204ccc3d6ba3c4a636d6bcecd08e466d3})  ;; Eth: 0x419c555b739212684432050b7ce459ea8e7b8bda
(map-set sources {source: "artifix-okcoin"} {public-key: 0x02752f4db204f7cdf6e022dc486af2572579bc9a0fe7c769b58d95f42234269367})  ;; stx: SPZ0RAC1EFTH949T4W2SYY6YBHJRMAF4ECT5A7DD
(map-set sources {source: "artifix-binance"} {public-key: 0x02752f4db204f7cdf6e022dc486af2572579bc9a0fe7c769b58d95f42234269367})  ;; stx: SPZ0RAC1EFTH949T4W2SYY6YBHJRMAF4ECT5A7DD

