(define-read-only (read-u8 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (buff-to-uint-be (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor) (+ (get pos cursor) u1)) (err u1)) u1) (err u1))), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u1) }
    }))

(define-read-only (read-u16 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (buff-to-uint-be (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor) (+ (get pos cursor) u2)) (err u1)) u2) (err u1))), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u2) }
    }))

(define-read-only (read-u32 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (buff-to-uint-be (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor)  (+ (get pos cursor) u4)) (err u1)) u4) (err u1))), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u4) }
    }))

(define-read-only (read-u64 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (buff-to-uint-be (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor)  (+ (get pos cursor) u8)) (err u1)) u8) (err u1))), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u8) }
    }))

(define-read-only (read-u128 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (buff-to-uint-be (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor)  (+ (get pos cursor) u16)) (err u1)) u16) (err u1))), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u16) }
    }))

(define-read-only (read-buff-1 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor) (+ (get pos cursor) u1)) (err u1)) u1) (err u1)), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u1) }
    }))

(define-read-only (read-buff-4 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor) (+ (get pos cursor) u4)) (err u1)) u4) (err u1)), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u4) }
    }))

(define-read-only (read-buff-8 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor) (+ (get pos cursor) u8)) (err u1)) u8) (err u1)), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u8) }
    }))

(define-read-only (read-buff-20 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor) (+ (get pos cursor) u20)) (err u1)) u20) (err u1)), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u20) }
    }))

(define-read-only (read-buff-32 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor) (+ (get pos cursor) u32)) (err u1)) u32) (err u1)), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u32) }
    }))

(define-read-only (read-buff-65 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor) (+ (get pos cursor) u65)) (err u1)) u65) (err u1)), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u65) }
    }))


(define-read-only (read-remaining-bytes-max-2048 (cursor { bytes: (buff 4096), pos: uint }))
    (ok { 
        value: (unwrap! (as-max-len? (unwrap! (slice? (get bytes cursor) (get pos cursor) (+  (get pos cursor) (- (len (get bytes cursor)) (get pos cursor)))) (err u1)) u2048) (err u1)), 
        next: { bytes: (get bytes cursor), pos: (+ (get pos cursor) u32) }
    }))
