
(define-private (matched-prev-block-hash (current-list-index uint) (found-match bool))
  (or 
    found-match
    (is-eq (var-get temp-before-btc-hash) (get-burn-block-info? header-hash (- (var-get temp-wanted-btc-block) current-list-index)))
  )
)

(define-private (matched-after-block-hash (current-list-index uint) (found-match bool))
  (or 
    found-match
    (is-eq (var-get temp-after-btc-hash) (get-burn-block-info? header-hash (+ (var-get temp-wanted-btc-block) current-list-index)))
  )
)

(define-data-var list-before-nums (list 100 uint)  (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10))
(define-data-var list-after-nums (list 100 uint)  (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10))

(define-data-var temp-before-btc-hash (optional (buff 32)) (some 0x0000000000000000000000000000000000000000000000000000000000000000))
(define-data-var temp-after-btc-hash (optional (buff 32)) (some 0x0000000000000000000000000000000000000000000000000000000000000000))
(define-data-var temp-wanted-btc-block uint u0)

(define-public (validate-stx-block-brackets-btc-block (first-stx-block-height uint) (btc-block-wanted uint))
  (let
    ( 
      (stx-tenure-btc-hash (get-tenure-info? burnchain-header-hash first-stx-block-height))
      (prev-stx-tenure-btc-hash (get-tenure-info? burnchain-header-hash (- first-stx-block-height u1)))
    )
    ;; Early exit: if tenure is same as previous block, this is NOT the first stacks block in tenure
    (if (is-eq stx-tenure-btc-hash prev-stx-tenure-btc-hash)
      (ok false)
      (begin
        (var-set temp-before-btc-hash prev-stx-tenure-btc-hash)
        (var-set temp-after-btc-hash stx-tenure-btc-hash)
        (var-set temp-wanted-btc-block btc-block-wanted)
        (if (not (fold matched-prev-block-hash (var-get list-before-nums) false))
          (ok false)
          (if (not (fold matched-after-block-hash (var-get list-after-nums) false))
            (ok false)
            (ok true)
          )
        )
      )
    )
  )
)
