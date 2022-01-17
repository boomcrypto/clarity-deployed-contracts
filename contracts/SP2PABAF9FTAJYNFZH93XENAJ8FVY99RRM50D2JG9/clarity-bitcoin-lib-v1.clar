;; Error codes
(define-constant ERR-OUT-OF-BOUNDS u1)
(define-constant ERR-TOO-MANY-TXINS u2)
(define-constant ERR-TOO-MANY-TXOUTS u3)
(define-constant ERR-VARSLICE-TOO-LONG u4)
(define-constant ERR-BAD-HEADER u5)
(define-constant ERR-PROOF-TOO-SHORT u6)

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

;; List with 512 items, used for folding something 512 times
(define-constant LIST_512 (list
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
))

;; List with 256 items, used for folding something 256 times
(define-constant LIST_256 (list
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
))

;; List with 128 items, used for folding something 128 times
(define-constant LIST_128 (list
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
))

;; List with 64 items, used for folding something 64 times
(define-constant LIST_64 (list
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
))

;; List with 32 items, used for folding something 32 times
(define-constant LIST_32 (list
   true true true true true true true true true true true true true true true true
   true true true true true true true true true true true true true true true true
))

;; List with 16 items, used for folding something 16 times
(define-constant LIST_16 (list
   true true true true true true true true true true true true true true true true
))

;; Convert a 1-byte buff into a uint.
(define-read-only (buff-to-u8 (byte (buff 1)))
    (unwrap-panic (index-of BUFF_TO_BYTE byte)))

;; Append a byte at the given index in the given data to acc.
(define-read-only (inner-read-slice-1024 (ignored bool) (input { acc: (buff 1024), data: (buff 1024), index: uint }))
    (let (
        (acc (get acc input))
        (data (get data input))
        (ctr (get index input))
        (byte (unwrap-panic (element-at data ctr)))
    )
    {
        acc: (unwrap-panic (as-max-len? (concat acc byte) u1024)),
        data: data,
        index: (+ u1 ctr)
    })
)

;; Read 512 bytes from data, starting at index.  Return the 512-byte slice.
(define-read-only (read-slice-512 (input { data: (buff 1024), index: uint }))
    (get acc
        (fold inner-read-slice-1024 LIST_512 { acc: 0x, data: (get data input), index: (get index input) })))

;; Read 256 bytes from data, starting at index.  Return the 256-byte slice.
(define-read-only (read-slice-256 (input { data: (buff 1024), index: uint }))
    (get acc
        (fold inner-read-slice-1024 LIST_256 { acc: 0x, data: (get data input), index: (get index input) })))

;; Read 128 bytes from data, starting at index.  Return the 128-byte slice.
(define-read-only (read-slice-128 (input { data: (buff 1024), index: uint }))
    (get acc
        (fold inner-read-slice-1024 LIST_128 { acc: 0x, data: (get data input), index: (get index input) })))

;; Read 64 bytes from data, starting at index.  Return the 64-byte slice.
(define-read-only (read-slice-64 (input { data: (buff 1024), index: uint }))
    (get acc
        (fold inner-read-slice-1024 LIST_64 { acc: 0x, data: (get data input), index: (get index input) })))

;; Read 32 bytes from data, starting at index.  Return the 32-byte slice.
(define-read-only (read-slice-32 (input { data: (buff 1024), index: uint }))
    (get acc
        (fold inner-read-slice-1024 LIST_32 { acc: 0x, data: (get data input), index: (get index input) })))

;; Read 16 bytes from data, starting at index.  Return the 16-byte slice.
(define-read-only (read-slice-16 (input { data: (buff 1024), index: uint }))
    (get acc
        (fold inner-read-slice-1024 LIST_16 { acc: 0x, data: (get data input), index: (get index input) })))

;; Read 8 bytes from data, starting at index.  Return the 8-byte slice.
(define-read-only (read-slice-8 (input { data: (buff 1024), index: uint }))
    (get acc
        (fold inner-read-slice-1024 (list true true true true true true true true) { acc: 0x, data: (get data input), index: (get index input) })))

;; Read 4 bytes from data, starting at index.  Return the 4-byte slice.
(define-read-only (read-slice-4 (input { data: (buff 1024), index: uint }))
    (get acc
        (fold inner-read-slice-1024 (list true true true true) { acc: 0x, data: (get data input), index: (get index input) })))

;; Read 2 bytes from data, starting at index.  Return the 2-byte slice.
(define-read-only (read-slice-2 (input { data: (buff 1024), index: uint }))
    (get acc
        (fold inner-read-slice-1024 (list true true) { acc: 0x, data: (get data input), index: (get index input) })))

;; Read 1 byte from data, starting at index.  Return the 1-byte slice.
(define-read-only (read-slice-1 (input { data: (buff 1024), index: uint }))
    (get acc
        (fold inner-read-slice-1024 (list true) { acc: 0x, data: (get data input), index: (get index input) })))

;; Read a fixed-sized chunk of data from a given buffer (up to remaining bytes), starting at index, and append it to acc.
;; chunk_size must be a power of 2, up to 1024
(define-read-only (inner-read-slice (chunk_size uint) (input { acc: (buff 1024), buffer: (buff 1024), index: uint, remaining: uint }))
    (let (
        (ctr (get index input))
        (remaining (get remaining input))
    )
    (if (is-eq u0 remaining)
        ;; done reading
        input
        (let (
            (acc (get acc input))
            (databuff (get buffer input))
        )
        (if (> chunk_size remaining)
            ;; chunk size too big for remainder, so just skip it.
            input
            ;; we have at least chunk_size bytes to read!
            ;; dispatch to the right fixed-size slice reader.
            (if (is-eq chunk_size u512)
                { acc: (unwrap-panic (as-max-len? (concat acc (read-slice-512 { data: databuff, index: ctr })) u1024)), buffer: databuff, index: (+ chunk_size ctr), remaining: (- remaining chunk_size) }
            (if (is-eq chunk_size u256)
                { acc: (unwrap-panic (as-max-len? (concat acc (read-slice-256 { data: databuff, index: ctr })) u1024)), buffer: databuff, index: (+ chunk_size ctr), remaining: (- remaining chunk_size) }
            (if (is-eq chunk_size u128)
                { acc: (unwrap-panic (as-max-len? (concat acc (read-slice-128 { data: databuff, index: ctr })) u1024)), buffer: databuff, index: (+ chunk_size ctr), remaining: (- remaining chunk_size) }
            (if (is-eq chunk_size u64)
                { acc: (unwrap-panic (as-max-len? (concat acc (read-slice-64 { data: databuff, index: ctr })) u1024)), buffer: databuff, index: (+ chunk_size ctr), remaining: (- remaining chunk_size) }
            (if (is-eq chunk_size u32)
                { acc: (unwrap-panic (as-max-len? (concat acc (read-slice-32 { data: databuff, index: ctr })) u1024)), buffer: databuff, index: (+ chunk_size ctr), remaining: (- remaining chunk_size) }
            (if (is-eq chunk_size u16)
                { acc: (unwrap-panic (as-max-len? (concat acc (read-slice-16 { data: databuff, index: ctr })) u1024)), buffer: databuff, index: (+ chunk_size ctr), remaining: (- remaining chunk_size) }
            (if (is-eq chunk_size u8)
                { acc: (unwrap-panic (as-max-len? (concat acc (read-slice-8 { data: databuff, index: ctr })) u1024)), buffer: databuff, index: (+ chunk_size ctr), remaining: (- remaining chunk_size) }
            (if (is-eq chunk_size u4)
                { acc: (unwrap-panic (as-max-len? (concat acc (read-slice-4 { data: databuff, index: ctr })) u1024)), buffer: databuff, index: (+ chunk_size ctr), remaining: (- remaining chunk_size) }
            (if (is-eq chunk_size u2)
                { acc: (unwrap-panic (as-max-len? (concat acc (read-slice-2 { data: databuff, index: ctr })) u1024)), buffer: databuff, index: (+ chunk_size ctr), remaining: (- remaining chunk_size) }
            (if (is-eq chunk_size u1)
                { acc: (unwrap-panic (as-max-len? (concat acc (read-slice-1 { data: databuff, index: ctr })) u1024)), buffer: databuff, index: (+ chunk_size ctr), remaining: (- remaining chunk_size) }
                { acc: acc, buffer: databuff, index: ctr, remaining: remaining }
            ))))))))))
        ))
    ))
)

;; Top-level function to read a slice of a given size from a given (buff 1024), starting at a given offset.
;; Returns (ok (buff 1024)) on success, and it contains "buff[offset..(offset+size)]"
;; Returns (err ERR-OUT-OF-BOUNDS) if the slice offset and/or size would copy a range of bytes outside the given buffer.
(define-read-only (read-slice (data (buff 1024)) (offset uint) (size uint))
    (if (or (>= offset (len data)) (> (+ offset size) (len data)))
        (err ERR-OUT-OF-BOUNDS)
        (begin
           (print "read slice")
           (print size)
           (ok
             (get acc
                 (fold inner-read-slice (list u512 u256 u128 u64 u32 u16 u8 u4 u2 u1) { acc: 0x, buffer: data, index: offset, remaining: size }))
           )
        )
    )
)

;; Reads the next two bytes from txbuff as a big-endian 16-bit integer, and updates the index.
;; Returns (ok { uint16: uint, ctx: { txbuff: (buff 1024), index: uint } }) on success.
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff
(define-read-only (read-uint16 (ctx { txbuff: (buff 1024), index: uint }))
    (let (
        (data (get txbuff ctx))
        (base (get index ctx))
        (byte-1 (buff-to-u8 (unwrap! (element-at data base) (err ERR-OUT-OF-BOUNDS))))
        (byte-2 (buff-to-u8 (unwrap! (element-at data (+ u1 base)) (err ERR-OUT-OF-BOUNDS))))
        (ret (+ (* byte-2 u256) byte-1))
    )
    (begin
       (print "read uint16")
       (print ret)
       (ok {
           uint16: ret,
           ctx: { txbuff: data, index: (+ u2 base) }
       })
    ))
)

;; Reads the next four bytes from txbuff as a big-endian 32-bit integer, and updates the index.
;; Returns (ok { uint32: uint, ctx: { txbuff: (buff 1024), index: uint } }) on success.
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff
(define-read-only (read-uint32 (ctx { txbuff: (buff 1024), index: uint }))
    (let (
        (data (get txbuff ctx))
        (base (get index ctx))
        (byte-1 (buff-to-u8 (unwrap! (element-at data base) (err ERR-OUT-OF-BOUNDS))))
        (byte-2 (buff-to-u8 (unwrap! (element-at data (+ u1 base)) (err ERR-OUT-OF-BOUNDS))))
        (byte-3 (buff-to-u8 (unwrap! (element-at data (+ u2 base)) (err ERR-OUT-OF-BOUNDS))))
        (byte-4 (buff-to-u8 (unwrap! (element-at data (+ u3 base)) (err ERR-OUT-OF-BOUNDS))))
        (ret (+ (* byte-4 u16777216) (* byte-3 u65536) (* byte-2 u256) byte-1))
    )
    (begin
       (print "read uint32")
       (print ret)
       (ok {
           uint32: ret,
           ctx: { txbuff: data, index: (+ u4 base) }
       })
    ))
)

;; Reads the next eight bytes from txbuff as a big-endian 64-bit integer, and updates the index.
;; Returns (ok { uint64: uint, ctx: { txbuff: (buff 1024), index: uint } }) on success.
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff
(define-read-only (read-uint64 (ctx { txbuff: (buff 1024), index: uint }))
    (let (
        (data (get txbuff ctx))
        (base (get index ctx))
        (byte-1 (buff-to-u8 (unwrap! (element-at data base) (err ERR-OUT-OF-BOUNDS))))
        (byte-2 (buff-to-u8 (unwrap! (element-at data (+ u1 base)) (err ERR-OUT-OF-BOUNDS))))
        (byte-3 (buff-to-u8 (unwrap! (element-at data (+ u2 base)) (err ERR-OUT-OF-BOUNDS))))
        (byte-4 (buff-to-u8 (unwrap! (element-at data (+ u3 base)) (err ERR-OUT-OF-BOUNDS))))
        (byte-5 (buff-to-u8 (unwrap! (element-at data (+ u4 base)) (err ERR-OUT-OF-BOUNDS))))
        (byte-6 (buff-to-u8 (unwrap! (element-at data (+ u5 base)) (err ERR-OUT-OF-BOUNDS))))
        (byte-7 (buff-to-u8 (unwrap! (element-at data (+ u6 base)) (err ERR-OUT-OF-BOUNDS))))
        (byte-8 (buff-to-u8 (unwrap! (element-at data (+ u7 base)) (err ERR-OUT-OF-BOUNDS))))
        (ret (+
           (* byte-8 u72057594037927936)
           (* byte-7 u281474976710656)
           (* byte-6 u1099511627776)
           (* byte-5 u4294967296)
           (* byte-4 u16777216)
           (* byte-3 u65536)
           (* byte-2 u256)
           byte-1))
    )
    (begin
       (print "read uint64")
       (print ret)
       (ok {
           uint64: ret,
           ctx: { txbuff: data, index: (+ u8 base) }
       })
    ))
)

;; Reads the next varint from txbuff, and updates the index.
;; Returns (ok { varint: uint, ctx: { txbuff: (buff 1024), index: uint } }) on success
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff.
(define-read-only (read-varint (ctx { txbuff: (buff 1024), index: uint }))
    (let (
        (ptr (get index ctx))
        (tx (get txbuff ctx))
        (byte (buff-to-u8 (unwrap! (element-at tx ptr)
                            (err ERR-OUT-OF-BOUNDS))))
    )
    (if (<= byte u252)
        (begin
           (print "varint 1")
           (print byte)
           ;; given byte is the varint
           (ok { varint: byte, ctx: { txbuff: tx, index: (+ u1 ptr) }})
        )
        (if (is-eq byte u253)
            (let (
                ;; next two bytes is the varint
                (parsed-u16 (try! (read-uint16 { txbuff: tx, index: (+ u1 ptr) })))
            )
            (begin
                (print "varint 2")
                (print (get uint16 parsed-u16))
                (ok { varint: (get uint16 parsed-u16), ctx: (get ctx parsed-u16) })
            ))
            (if (is-eq byte u254)
                (let (
                    ;; next four bytes is the varint
                    (parsed-u32 (try! (read-uint32 { txbuff: tx, index: (+ u1 ptr) })))
                )
                (begin
                    (print "varint 4")
                    (print (get uint32 parsed-u32))
                    (ok { varint: (get uint32 parsed-u32), ctx: (get ctx parsed-u32) })
                ))
                (let (
                    ;; next eight bytes is the varint
                    (parsed-u64 (try! (read-uint64 { txbuff: tx, index: (+ u1 ptr) })))
                )
                (begin
                    (print "varint 8")
                    (print (get uint64 parsed-u64))
                    (ok { varint: (get uint64 parsed-u64), ctx: (get ctx parsed-u64) })
                ))
            )
        )
    ))
)

;; Reads a varint-prefixed byte slice from txbuff, and updates the index to point to the byte after the varint and slice.
;; Returns (ok { varslice: (buff 1024), ctx: { txbuff: (buff 1024), index: uint } }) on success, where varslice has the length of the varint prefix.
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff.
(define-read-only (read-varslice (old-ctx { txbuff: (buff 1024), index: uint }))
    (let (
        (parsed (try! (read-varint old-ctx)))
        (slice-len (get varint parsed))
        (ctx (get ctx parsed))
        (slice (try! (read-slice (get txbuff ctx) (get index ctx) slice-len)))
    )
    (ok {
        varslice: slice,
        ctx: { txbuff: (get txbuff ctx), index: (+ (len slice) (get index ctx)) }
    }))
)

;; Generate a permutation of a given 32-byte buffer, appending the element at target-index to hash-output.
;; The target-index decides which index in hash-input gets appended to hash-output.
(define-read-only (inner-buff32-permutation (target-index uint) (state { hash-input: (buff 32), hash-output: (buff 32) }))
    {
        hash-input: (get hash-input state),
        hash-output: (unwrap-panic
            (as-max-len? (concat
                (get hash-output state)
                (unwrap-panic
                    (as-max-len?
                        (unwrap-panic
                            (element-at (get hash-input state) target-index))
                    u32)))
            u32))
    }
)

;; Reverse the byte order of a 32-byte buffer.  Returns the (buff 32).
(define-read-only (reverse-buff32 (input (buff 32)))
    (get hash-output
         (fold inner-buff32-permutation
             (list u31 u30 u29 u28 u27 u26 u25 u24 u23 u22 u21 u20 u19 u18 u17 u16 u15 u14 u13 u12 u11 u10 u9 u8 u7 u6 u5 u4 u3 u2 u1 u0)
             { hash-input: input, hash-output: 0x }))
)

;; Reads a big-endian hash -- consume the next 32 bytes, and reverse them.
;; Returns (ok { hashslice: (buff 32), ctx: { txbuff: (buff 1024), index: uint } }) on success, and updates the index.
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff.
(define-read-only (read-hashslice (old-ctx { txbuff: (buff 1024), index: uint }))
    (let (
        (hash-le (unwrap-panic
                    (as-max-len? (try!
                                    (read-slice (get txbuff old-ctx) (get index old-ctx) u32))
                    u32)))
    )
    (ok {
        hashslice: (reverse-buff32 hash-le),
        ctx: { txbuff: (get txbuff old-ctx), index: (+ u32 (get index old-ctx)) }
    }))
)

;; Inner fold method to read the next tx input from txbuff.
;; The index in ctx will be updated to point to the next tx input if all goes well (or to the start of the outputs)
;; Returns (ok { ... }) on success.
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff.
;; Returns (err ERR-VARSLICE-TOO-LONG) if we find a scriptSig that's too long to parse.
;; Returns (err ERR-TOO-MANY-TXINS) if there are more than eight inputs to read.
(define-read-only (read-next-txin (ignored bool)
                                  (state-res (response {
                                    ctx: { txbuff: (buff 1024), index: uint },
                                    remaining: uint,
                                    txins: (list 8 {
                                        outpoint: {
                                            hash: (buff 32),
                                            index: uint
                                        },
                                        scriptSig: (buff 256),      ;; just big enough to hold a 2-of-3 multisig script
                                        sequence: uint
                                    })
                                  } uint)))
    (match state-res
        state
            (if (< u0 (get remaining state))
                (let (
                   (remaining (get remaining state))
                   (ctx (get ctx state))
                   (parsed-hash (try! (read-hashslice ctx)))
                   (parsed-index (try! (read-uint32 (get ctx parsed-hash))))
                   (parsed-scriptSig (try! (read-varslice (get ctx parsed-index))))
                   (parsed-sequence (try! (read-uint32 (get ctx parsed-scriptSig))))
                   (new-ctx (get ctx parsed-sequence))
                )
                (ok {
                   ctx: new-ctx,
                   remaining: (- remaining u1),
                   txins: (unwrap!
                     (as-max-len?
                         (append (get txins state)
                             {
                                 outpoint: {
                                    hash: (get hashslice parsed-hash),
                                    index: (get uint32 parsed-index)
                                 },
                                 scriptSig: (unwrap! (as-max-len? (get varslice parsed-scriptSig) u256) (err ERR-VARSLICE-TOO-LONG)),
                                 sequence: (get uint32 parsed-sequence)
                             })
                     u8)
                     (err ERR-TOO-MANY-TXINS))
                }))
                (ok state)
            )
        error
            (err error)
    )
)

;; Read a transaction's inputs.
;; Returns (ok { txins: (list { ... }), remaining: uint, ctx: { txbuff: (buff 1024), index: uint } }) on success, and updates the index in ctx to point to the start of the tx outputs.
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff.
;; Returns (err ERR-VARSLICE-TOO-LONG) if we find a scriptSig that's too long to parse.
;; Returns (err ERR-TOO-MANY-TXINS) if there are more than eight inputs to read.
(define-read-only (read-txins (ctx { txbuff: (buff 1024), index: uint }))
    (let (
        (parsed-num-txins (try! (read-varint ctx)))
        (num-txins (get varint parsed-num-txins))
        (new-ctx (get ctx parsed-num-txins))
    )
    (if (> num-txins u8)
        (err ERR-TOO-MANY-TXINS)
        (fold read-next-txin (list true true true true true true true true) (ok { ctx: new-ctx, remaining: num-txins, txins: (list ) }))
    ))
)

;; Read the next transaction output, and update the index in ctx to point to the next output.
;; Returns (ok { ... }) on success
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff.
;; Returns (err ERR-VARSLICE-TOO-LONG) if we find a scriptPubKey that's too long to parse.
;; Returns (err ERR-TOO-MANY-TXOUTS) if there are more than eight outputs to read.
(define-read-only (read-next-txout (ignored bool)
                                   (state-res (response {
                                    ctx: { txbuff: (buff 1024), index: uint },
                                    remaining: uint,
                                    txouts: (list 8 {
                                        value: uint,
                                        scriptPubKey: (buff 128)
                                    })
                                   } uint)))
    (match state-res
        state
            (if (< u0 (get remaining state))
                (let (
                    (remaining (get remaining state))
                    (parsed-value (try! (read-uint64 (get ctx state))))
                    (parsed-script (try! (read-varslice (get ctx parsed-value))))
                    (new-ctx (get ctx parsed-script))
                )
                (ok {
                    ctx: new-ctx,
                    remaining: (- remaining u1),
                    txouts: (unwrap!
                        (as-max-len?
                            (append (get txouts state)
                                {
                                    value: (get uint64 parsed-value),
                                    scriptPubKey: (unwrap! (as-max-len? (get varslice parsed-script) u128) (err ERR-VARSLICE-TOO-LONG))
                                })
                        u8)
                        (err ERR-TOO-MANY-TXOUTS))
                }))
                (ok state)
            )
        error
            (err error)
    )
)

;; Read all transaction outputs in a transaction.  Update the index to point to the first byte after the outputs, if all goes well.
;; Returns (ok { txouts: (list { ... }), remaining: uint, ctx: { txbuff: (buff 1024), index: uint } }) on success, and updates the index in ctx to point to the start of the tx outputs.
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff.
;; Returns (err ERR-VARSLICE-TOO-LONG) if we find a scriptPubKey that's too long to parse.
;; Returns (err ERR-TOO-MANY-TXOUTS) if there are more than eight outputs to read.
(define-read-only (read-txouts (ctx { txbuff: (buff 1024), index: uint }))
    (let (
        (parsed-num-txouts (try! (read-varint ctx)))
        (num-txouts (get varint parsed-num-txouts))
        (new-ctx (get ctx parsed-num-txouts))
    )
    (if (> num-txouts u8)
        (err ERR-TOO-MANY-TXOUTS)
        (fold read-next-txout (list true true true true true true true true) (ok { ctx: new-ctx, remaining: num-txouts, txouts: (list ) }))
    ))
)

;; Parse a Bitcoin transaction, with up to 8 inputs and 8 outputs, with scriptSigs of up to 256 bytes each, and with scriptPubKeys up to 128 bytes.
;; Returns a tuple structured as follows on success:
;; (ok {
;;      version: uint,                      ;; tx version
;;      ins: (list 8
;;          {
;;              outpoint: {                 ;; pointer to the utxo this input consumes
;;                  hash: (buff 32),
;;                  index: uint
;;              },
;;              scriptSig: (buff 256),      ;; spending condition script
;;              sequence: uint
;;          }),
;;      outs: (list 8
;;          {
;;              value: uint,                ;; satoshis sent
;;              scriptPubKey: (buff 128)    ;; parse this to get an address
;;          }),
;;      locktime: uint
;; })
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff.
;; Returns (err ERR-VARSLICE-TOO-LONG) if we find a scriptPubKey or scriptSig that's too long to parse.
;; Returns (err ERR-TOO-MANY-TXOUTS) if there are more than eight inputs to read.
;; Returns (err ERR-TOO-MANY-TXINS) if there are more than eight outputs to read.
(define-read-only (parse-tx (tx (buff 1024)))
    (let (
        (ctx { txbuff: tx, index: u0 })
        (parsed-version (try! (read-uint32 ctx)))
        (parsed-txins (try! (read-txins (get ctx parsed-version))))
        (parsed-txouts (try! (read-txouts (get ctx parsed-txins))))
        (parsed-locktime (try! (read-uint32 (get ctx parsed-txouts))))
    )
    (ok {
        version: (get uint32 parsed-version),
        ins: (get txins parsed-txins),
        outs: (get txouts parsed-txouts),
        locktime: (get uint32 parsed-locktime)
    }))
)

;; Parse a Bitcoin block header.
;; Returns a tuple structured as folowed on success:
;; (ok {
;;      version: uint,                  ;; block version,
;;      parent: (buff 32),              ;; parent block hash,
;;      merkle-root: (buff 32),         ;; merkle root for all this block's transactions
;;      timestamp: uint,                ;; UNIX epoch timestamp of this block, in seconds
;;      nbits: uint,                    ;; compact block difficulty representation
;;      nonce: uint                     ;; PoW solution
;; })
;; Returns (err ERR-BAD-HEADER) if the header buffer isn't actually 80 bytes long.
(define-read-only (parse-block-header (headerbuff (buff 80)))
    (let (
        (ctx { txbuff: (unwrap! (as-max-len? headerbuff u1024) (err ERR-BAD-HEADER)), index: u0 })

        ;; none of these should fail, since they're all fixed-length fields whose lengths sum to 80
        (parsed-version (unwrap-panic (read-uint32 ctx)))
        (parsed-parent-hash (unwrap-panic (read-hashslice (get ctx parsed-version))))
        (parsed-merkle-root (unwrap-panic (read-hashslice (get ctx parsed-parent-hash))))
        (parsed-timestamp (unwrap-panic (read-uint32 (get ctx parsed-merkle-root))))
        (parsed-nbits (unwrap-panic (read-uint32 (get ctx parsed-timestamp))))
        (parsed-nonce (unwrap-panic (read-uint32 (get ctx parsed-nbits))))
    )
    (ok {
        version: (get uint32 parsed-version),
        parent: (get hashslice parsed-parent-hash),
        merkle-root: (get hashslice parsed-merkle-root),
        timestamp: (get uint32 parsed-timestamp),
        nbits: (get uint32 parsed-nbits),
        nonce: (get uint32 parsed-nonce)
    }))
)

(define-read-only (get-bc-h-hash (bh uint))
  (get-block-info? burnchain-header-hash bh))

;; Verify that a block header hashes to a burnchain header hash at a given height.
;; Returns true if so; false if not.
(define-read-only (verify-block-header (headerbuff (buff 80)) (expected-block-height uint))
    (match (get-bc-h-hash expected-block-height)
        bhh (is-eq bhh (reverse-buff32 (sha256 (sha256 headerbuff))))
        false
    ))

;; Get the txid of a transaction, but big-endian.
;; This is the reverse of what you see on block explorers.
(define-read-only (get-reversed-txid (tx (buff 1024)))
    (sha256 (sha256 tx)))

;; Get the txid of a transaction.
;; This is what you see on block explorers.
(define-read-only (get-txid (tx (buff 1024)))
    (reverse-buff32 (get-reversed-txid tx))
)

;; Determine if the ith bit in a uint is set to 1
(define-read-only (is-bit-set (val uint) (bit uint))
    (is-eq (mod (/ val (pow u2 bit)) u2) u1)
)

;; Verify the next step of a Merkle proof.
;; This hashes cur-hash against the ctr-th hash in proof-hashes, and uses that as the next cur-hash.
;; The path is a bitfield describing the walk from the txid up to the merkle root:
;; * if the ith bit is 0, then cur-hash is hashed before the next proof-hash (cur-hash is "left").
;; * if the ith bit is 1, then the next proof-hash is hashed before cur-hash (cur-hash is "right").
;; The proof verifies if cur-hash is equal to root-hash, and we're out of proof-hashes to check.
(define-read-only (inner-merkle-proof-verify (ctr uint) (state { path: uint, root-hash: (buff 32), proof-hashes: (list 12 (buff 32)), tree-depth: uint, cur-hash: (buff 32), verified: bool }))
    (if (get verified state)
        state
        (if (>= ctr (get tree-depth state))
            (begin
                (print "ctr exceeds proof length or tree depth")
                (print ctr)
                (print (get tree-depth state))
                (print (len (get proof-hashes state)))
                (merge state { verified: false })
            )
            (let (
                (path (get path state))
                (is-left (is-bit-set path ctr))
                (proof-hashes (get proof-hashes state))
                (cur-hash (get cur-hash state))
                (root-hash (get root-hash state))

                (h1 (if is-left (unwrap-panic (element-at proof-hashes ctr)) cur-hash))
                (h2 (if is-left cur-hash (unwrap-panic (element-at proof-hashes ctr))))
                (next-hash (sha256 (sha256 (concat h1 h2))))
                (is-verified (and (is-eq (+ u1 ctr) (len proof-hashes)) (is-eq next-hash root-hash)))
            )
            (begin
                (print "cur-hash")
                (print cur-hash)
                (print "next-hash")
                (print h1)
                (print h2)
                (print next-hash)
                (merge state { cur-hash: next-hash, verified: is-verified })
            ))
        )
    )
)

;; Verify a Merkle proof, given the _reversed_ txid of a transaction, the merkle root of its block, and a proof consisting of:
;; * The index in the block where the transaction can be found (starting from 0),
;; * The list of hashes that link the txid to the merkle root,
;; * The depth of the block's merkle tree (required because Bitcoin does not identify merkle tree nodes as being leaves or intermediates).
;; The _reversed_ txid is required because that's the order (big-endian) processes them in.
;; The tx-index is required because it tells us the left/right traversals we'd make if we were walking down the tree from root to transaction,
;; and is thus used to deduce the order in which to hash the intermediate hashes with one another to link the txid to the merkle root.
;; Returns (ok true) if the proof is valid.
;; Returns (ok false) if the proof is invalid.
;; Returns (err ERR-PROOF-TOO-SHORT) if the proof's hashes aren't long enough to link the txid to the merkle root.
(define-read-only (verify-merkle-proof (reversed-txid (buff 32)) (merkle-root (buff 32)) (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint }))
    (if (> (get tree-depth proof) (len (get hashes proof)))
        (err ERR-PROOF-TOO-SHORT)
        (ok
          (get verified
              (fold inner-merkle-proof-verify
                  (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11)
                  { path: (+ (pow u2 (get tree-depth proof)) (get tx-index proof)), root-hash: merkle-root, proof-hashes: (get hashes proof), cur-hash: reversed-txid, tree-depth: (get tree-depth proof), verified: false }))
        )
    )
)

;; Top-level verification code to determine whether or not a Bitcoin transaction was mined in a prior Bitcoin block.
;; It takes the block header and block height, the transaction, and a merkle proof, and determines that:
;; * the block header corresponds to the block that was mined at the given Bitcoin height
;; * the transaction's merkle proof links it to the block header's merkle root.
;; The proof is a list of sibling merkle tree nodes that allow us to calculate the parent node from two children nodes in each merkle tree level,
;; the depth of the block's merkle tree, and the index in the block in which the given transaction can be found (starting from 0).
;; The first element in hashes must be the given transaction's sibling transaction's ID.  This and the given transaction's txid are hashed to
;; calculate the parent hash in the merkle tree, which is then hashed with the *next* hash in the proof, and so on and so forth, until the final
;; hash can be compared against the block header's merkle root field.  The tx-index tells us in which order to hash each pair of siblings.
;; Note that the proof hashes -- including the sibling txid -- must be _big-endian_ hashes, because this is how Bitcoin generates them.
;; This is the reverse of what you'd see in a block explorer!
;; Returns (ok true) if the proof checks out.
;; Returns (ok false) if not.
;; Returns (err ERR-PROOF-TOO-SHORT) if the proof doesn't contain enough intermediate hash nodes in the merkle tree.
(define-read-only (was-tx-mined-compact (block { header: (buff 80), height: uint }) (tx (buff 1024)) (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint }))
    (if (verify-block-header (get header block) (get height block))
        (verify-merkle-proof (get-reversed-txid tx) (reverse-buff32 (get merkle-root (try! (parse-block-header (get header block))))) proof)
        (ok false)
    )
)

(define-read-only (concat-header (block { version: (buff 4), parent: (buff 32), merkle-root: (buff 32), timestamp: (buff 4), nbits: (buff 4), nonce: (buff 4), height: uint }))
  (concat (concat (concat (concat (concat (get version block) (get parent block)) (get merkle-root block)) (get timestamp block)) (get nbits block)) (get nonce block))
)

(define-read-only (concat-var (buffer (buff 256)))
  (concat (unwrap-panic (element-at BUFF_TO_BYTE (len buffer))) buffer))

(define-read-only (concat-in (in {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}) (result (buff 1024)))
  (unwrap-panic (as-max-len? (concat (concat (concat (concat result (get hash (get outpoint in))) (get index (get outpoint in))) (concat-var (get scriptSig in))) (get sequence in)) u1024 )))

(define-read-only (concat-ins (ins (list 8
        {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)})))
       (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at BUFF_TO_BYTE (len ins))) (fold concat-in ins 0x)) u1024)))

(define-read-only (concat-out (out {value: (buff 8), scriptPubKey: (buff 128)}) (result (buff 1024)))
  (unwrap-panic (as-max-len? (concat (concat result (get value out)) (concat-var (get scriptPubKey out))) u1024)))

(define-read-only (concat-outs (outs (list 8
        {value: (buff 8), scriptPubKey: (buff 128)})))
       (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at BUFF_TO_BYTE (len outs))) (fold concat-out outs 0x)) u1024)))

(define-read-only (concat-tx (tx {version: (buff 4),
      ins: (list 8
        {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
      outs: (list 8
        {value: (buff 8), scriptPubKey: (buff 128)}),
      locktime: (buff 4)}))
 (unwrap-panic (as-max-len?  (concat (concat (concat (get version tx) (concat-ins (get ins tx))) (concat-outs (get outs tx))) (get locktime tx)) u1024)))

(define-read-only (was-tx-mined (block { version: (buff 4), parent: (buff 32), merkle-root: (buff 32), timestamp: (buff 4), nbits: (buff 4), nonce: (buff 4), height: uint }) (tx (buff 1024)) (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint }))
    (if (verify-block-header (concat-header block) (get height block))
        (verify-merkle-proof (get-reversed-txid tx) (get merkle-root block) proof)
        (err u1)
    )
)
