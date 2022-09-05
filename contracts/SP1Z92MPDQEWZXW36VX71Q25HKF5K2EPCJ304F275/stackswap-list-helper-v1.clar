;;;;;;;;;;;;;;;;;;;;;;;MANAGE;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant MAX_REWARD_CYCLES u36)             
(define-constant REWARD_CYCLE_INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35))

(define-data-var rem-item uint u0)
(define-private (remove-filter (a uint)) (not (is-eq a (var-get rem-item))))

(define-data-var size-item uint u0)
(define-data-var add-num uint u0)
(define-private (size-filter (a uint)) (< a (var-get size-item)))

(define-data-var check-list (list 100 uint) (list ))
(define-private (check-filter (a uint))
 (is-none (index-of (var-get check-list) a))
)

(define-public (delete-item-from-list (idx-list (list 100 uint)) (ritem uint))
  (begin 
    (var-set rem-item ritem)
    (ok (unwrap-panic (as-max-len? (filter remove-filter idx-list) u100)))
  )
)

(define-public (add-items-to-list (idx-list (list 100 uint)) (sizeitem uint) (addnum uint))
    (ok (as-max-len? (concat idx-list (unwrap-panic (check-item-from-list idx-list (unwrap-panic (cut-sized-list sizeitem addnum))))) u100))
)

(define-private (add-num-func (num uint))
    (+ num (var-get add-num))
)
(define-public (cut-sized-list (sizeitem uint) (addnum uint))
  (begin 
    (var-set size-item sizeitem)
    (var-set add-num addnum)
    (ok (map add-num-func (unwrap-panic (as-max-len? (filter size-filter REWARD_CYCLE_INDEXES) u36))))
  )
)
(define-public (check-item-from-list (idx-list (list 100 uint)) (new-list (list 36 uint)))
  (begin 
    (var-set check-list idx-list)
    (ok (unwrap-panic (as-max-len? (filter check-filter new-list) u36)))
  )
)