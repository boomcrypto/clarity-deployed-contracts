;; RANGE
;; src: https://github.com/njordhov/clarity-sequence/blob/main/contracts/range/range7.clar

(define-constant max-len (- (pow 2 7) 1))

(define-private (check-type-integer
                 (value1 int))
 (begin
  (assert- (let ((tmp5 value1))
            (and (<= 0 tmp5) (<= tmp5 127))) "No value matching the type")
  value1))

(define-private (assert-
                 (invariant bool)
                 (message (string-ascii 64)))
 (unwrap-panic (if invariant (ok 0) (err message))))

(define-private (min-num-integer-integer
                 (left int)
                 (right int))
 (begin
  (assert- (and (<= 0 left) (<= left 127)) "Out of bounds: left")
  (assert- (and (<= 127 right) (<= right 127)) "Out of bounds: right")
  (if (< left right) left right)))

(define-private (asc-list
                 (d int)
                 (l (list 128 int)))
 (let ((n1 (to-int (len l))))
  (if (> n1 d)
   l
   (unwrap-panic
    (as-max-len?
     (append l
      (+ n1
       (unwrap-panic (element-at l u0))))
     u128)))))

(define-private (rep-list
                 (d int)
                 (l (list 128 int)))
 (let ((n1 (to-int (len l))))
  (if (> n1 d)
   l
   (unwrap-panic
    (as-max-len?
     (concat l l)
     u128)))))

(define-private (range-1-integer-integer
                 (lo int)
                 (hi int))
 (begin
  (assert- (and (<= 0 lo) (<= lo 0)) "Out of bounds: lo")
  (assert- (and (<= 0 hi) (<= hi 127)) "Out of bounds: hi")
  (let ((d (- hi lo)))
   (fold asc-list
    (fold rep-list (list d d d d d d d) (list d))
    (list lo)))))

(define-private (repeat-step-integer
                 (n int)
                 (acc {a: (list 128 int), r: (list 127 int)}))
 (let ((a (get a acc))
       (r (get r acc))
       (lenr (to-int (len r))))
  (if (< lenr n)
   (let ((c (mod (to-uint (- n lenr))
             (* (len a) u2))))
    {a: (unwrap-panic
         (as-max-len?
          (concat a a)
          u128)),
     r: (if (> c u0)
         (unwrap-panic
          (as-max-len?
           (concat r a)
           u127))
         r)})
   (let ((record14 acc))
    (merge record14
     {a: (get a record14),
      r: (get r record14)})))))

(define-private (repeater-integer-list
                 (v int)
                 (nrep (list 7 int)))
 (fold repeat-step-integer
  nrep
  {a: (list v),
   r: (list)}))

(define-private (repeat7b-integer
                 (nd int)
                 (vd int))
 (begin
  (assert- (and (<= 0 nd) (<= nd 127)) "Out of bounds: nd")
  (get r (repeater-integer-list vd (list nd nd nd nd nd nd nd)))))

(define-read-only (range (low int) (high int))
 (let ((n (check-type-integer (- high low -1))))
  (map + (range-1-integer-integer 0 (min-num-integer-integer n max-len))
   (repeat7b-integer n low))))

(define-constant buffer-range (list
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
                               0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff))

(define-private (check-type-3-integer
                 (value7 int))
 (begin
  (assert- (and (<= 0 value7) (<= value7 256)) "Out of bounds: value7")
  (begin
   (assert- (let ((tmp69 value7))
             (and (<= 0 tmp69) (<= tmp69 255))) "No value matching the type")
   value7)))

(define-private (check-type-integer1
                 (value1 int))
 (begin
  (assert- (and (<= -254 value1) (<= value1 256)) "Out of bounds: value1")
  (begin
   (assert- (let ((tmp73 value1))
             (and (<= 0 tmp73) (<= tmp73 127))) "No value matching the type")
   value1)))

(define-private (asc-1-list
                 (d int)
                 (l (list 256 int)))
 (let ((n1 (to-int (len l))))
  (if (> n1 d)
   l
   (unwrap-panic
    (as-max-len?
     (append l
      (+ n1
       (unwrap-panic (element-at l u0))))
     u256)))))

(define-private (rep-1-list
                 (d int)
                 (l (list 256 int)))
 (let ((n1 (to-int (len l))))
  (if (> n1 d)
   l
   (unwrap-panic
    (as-max-len?
     (concat l l)
     u256)))))

(define-private (range-2-integer-integer
                 (lo int)
                 (hi int))
 (begin
  (assert- (and (<= 0 lo) (<= lo 255)) "Out of bounds: lo")
  (assert- (and (<= 0 hi) (<= hi 255)) "Out of bounds: hi")
  (let ((d (- hi lo)))
   (fold asc-1-list
    (fold rep-1-list (list d d d d d d d d) (list d))
    (list lo)))))

(define-private (reducer-buffer-buffer
                 (item (buff 1))
                 (acc (buff 256)))
 (unwrap-panic
  (as-max-len?
   (concat acc item)
   u256)))

(define-private (check-type-integer2
                 (value1 int))
 (begin
  (assert- (and (<= -126 value1) (<= value1 128)) "Out of bounds: value1")
  (begin
   (assert- (let ((tmp79 value1))
             (and (<= 0 tmp79) (<= tmp79 127))) "No value matching the type")
   value1)))

(define-private (asc-list1
                 (d int)
                 (l (list 128 int)))
 (let ((n1 (to-int (len l))))
  (if (> n1 d)
   l
   (unwrap-panic
    (as-max-len?
     (append l
      (+ n1
       (unwrap-panic (element-at l u0))))
     u128)))))

(define-private (rep-list1
                 (d int)
                 (l (list 128 int)))
 (let ((n1 (to-int (len l))))
  (if (> n1 d)
   l
   (unwrap-panic
    (as-max-len?
     (concat l l)
     u128)))))

(define-private (range-1-integer-integer1
                 (lo int)
                 (hi int))
 (begin
  (assert- (and (<= 0 lo) (<= lo 127)) "Out of bounds: lo")
  (assert- (and (<= 0 hi) (<= hi 127)) "Out of bounds: hi")
  (let ((d (- hi lo)))
   (fold asc-list1
    (fold rep-list1 (list d d d d d d d) (list d))
    (list lo)))))

(define-private (unwrap-panic-
                 (item1 (optional (buff 1))))
 (unwrap-panic item1))

(define-private (is-some-
                 (item1 (optional (buff 1))))
 (is-some item1))

(define-private (element-at-
                 (item1 (list 256 (buff 1)))
                 (item2 int))
 (begin
  (assert- (and (<= 0 item2) (<= item2 127)) "Out of bounds: item2")
  (element-at item1 (to-uint item2))))

(define-private (repeat7b-list
                 (nd int)
                 (vd (list 256 (buff 1))))
 (begin
  (assert- (and (<= 0 nd) (<= nd 127)) "Out of bounds: nd")
  (get r (repeater-list-list vd (list nd nd nd nd nd nd nd)))))

(define-private (repeat-step-integer1
                 (n int)
                 (acc {a: (list 128 (list 256 (buff 1))), r: (list 127 (list 256 (buff 1)))}))
 (let ((a (get a acc))
       (r (get r acc))
       (lenr (to-int (len r))))
  (if (< lenr n)
   (let ((c (mod (to-uint (- n lenr))
             (* (len a) u2))))
    {a: (unwrap-panic
         (as-max-len?
          (concat a a)
          u128)),
     r: (if (> c u0)
         (unwrap-panic
          (as-max-len?
           (concat r a)
           u127))
         r)})
   (let ((record50 acc))
    (merge record50
     {a: (get a record50),
      r: (get r record50)})))))

(define-private (repeater-list-list
                 (v (list 256 (buff 1)))
                 (nrep (list 7 int)))
 (fold repeat-step-integer1
  nrep
  {a: (list v),
   r: (list)}))

(define-private (subseq-list
                 (seq (list 256 (buff 1)))
                 (n int)
                 (m int))
 (begin
  (assert- (and (<= 0 n) (<= n 127)) "Out of bounds: n")
  (assert- (and (<= 0 m) (<= m 127)) "Out of bounds: m")
  (let ((sub-len (check-type-integer2 (- m n -1))))
   (map unwrap-panic-
    (filter is-some-
     (map element-at-
      (repeat7b-list sub-len seq)
      (range-1-integer-integer1 n m)))))))

(define-read-only (range-buff
                   (first-item (buff 1))
                   (last-item (buff 1)))
 (let ((init 0x))
  (fold reducer-buffer-buffer
   (subseq-list buffer-range
    (check-type-3-integer (to-int
                           (unwrap-panic (index-of buffer-range first-item))))
    (check-type-3-integer (to-int
                           (unwrap-panic (index-of buffer-range last-item))))) init)))

(define-constant ascii-range (list "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"))

(define-private (check-type-integer3
                 (value1 int))
 (begin
  (assert- (and (<= -25 value1) (<= value1 27)) "Out of bounds: value1")
  (begin
   (assert- (let ((tmp99 value1))
             (and (<= 0 tmp99) (<= tmp99 127))) "No value matching the type")
   value1)))

(define-private (asc-2-list
                 (d int)
                 (l (list 32 int)))
 (let ((n1 (to-int (len l))))
  (if (> n1 d)
   l
   (unwrap-panic
    (as-max-len?
     (append l
      (+ n1
       (unwrap-panic (element-at l u0))))
     u32)))))

(define-private (rep-2-list
                 (d int)
                 (l (list 32 int)))
 (let ((n1 (to-int (len l))))
  (if (> n1 d)
   l
   (unwrap-panic
    (as-max-len?
     (concat l l)
     u32)))))

(define-private (range-3-integer-integer
                 (lo int)
                 (hi int))
 (begin
  (assert- (and (<= 0 lo) (<= lo 26)) "Out of bounds: lo")
  (assert- (and (<= 0 hi) (<= hi 26)) "Out of bounds: hi")
  (let ((d (- hi lo)))
   (fold asc-2-list
    (fold rep-2-list (list d d d d d) (list d))
    (list lo)))))

(define-private (reducer-1-string-string
                 (item (string-ascii 1))
                 (acc (string-ascii 27)))
 (unwrap-panic
  (as-max-len?
   (concat acc item)
   u27)))

(define-private (unwrap-panic-1-
                 (item1 (optional (string-ascii 1))))
 (unwrap-panic item1))

(define-private (is-some-1-
                 (item1 (optional (string-ascii 1))))
 (is-some item1))

(define-private (element-at-1-
                 (item1 (list 26 (string-ascii 1)))
                 (item2 int))
 (begin
  (assert- (and (<= 0 item2) (<= item2 127)) "Out of bounds: item2")
  (element-at item1 (to-uint item2))))

(define-private (repeat7b-list1
                 (nd int)
                 (vd (list 26 (string-ascii 1))))
 (begin
  (assert- (and (<= 0 nd) (<= nd 127)) "Out of bounds: nd")
  (get r (repeater-list-list1 vd (list nd nd nd nd nd nd nd)))))

(define-private (repeat-step-integer2
                 (n int)
                 (acc {a: (list 128 (list 26 (string-ascii 1))), r: (list 127 (list 26 (string-ascii 1)))}))
 (let ((a (get a acc))
       (r (get r acc))
       (lenr (to-int (len r))))
  (if (< lenr n)
   (let ((c (mod (to-uint (- n lenr))
             (* (len a) u2))))
    {a: (unwrap-panic
         (as-max-len?
          (concat a a)
          u128)),
     r: (if (> c u0)
         (unwrap-panic
          (as-max-len?
           (concat r a)
           u127))
         r)})
   (let ((record86 acc))
    (merge record86
     {a: (get a record86),
      r: (get r record86)})))))

(define-private (repeater-list-list1
                 (v (list 26 (string-ascii 1)))
                 (nrep (list 7 int)))
 (fold repeat-step-integer2
  nrep
  {a: (list v),
   r: (list)}))

(define-private (subseq-list1
                 (seq (list 26 (string-ascii 1)))
                 (n int)
                 (m int))
 (begin
  (assert- (and (<= 0 n) (<= n 127)) "Out of bounds: n")
  (assert- (and (<= 0 m) (<= m 127)) "Out of bounds: m")
  (let ((sub-len (check-type-integer2 (- m n -1))))
   (map unwrap-panic-1-
    (filter is-some-1-
     (map element-at-1-
      (repeat7b-list1 sub-len seq)
      (range-1-integer-integer1 n m)))))))

(define-read-only (range-ascii
                   (first-item (string-ascii 1))
                   (last-item (string-ascii 1)))
 (let ((init1 ""))
  (fold reducer-1-string-string
   (subseq-list1 ascii-range
    (to-int
     (unwrap-panic (index-of ascii-range first-item)))
    (to-int
     (unwrap-panic (index-of ascii-range last-item)))) init1)))
