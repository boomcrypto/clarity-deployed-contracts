---
title: "Trait ROCKBreaker"
draft: true
---
```
(define-data-var current-buffer (buff 32) 0x0000000000000000000000000000000000000000000000000000000000000000)
(define-data-var last-call-block uint u0)

;; Retrieve a specific byte from the buffer using element-at?
(define-private (get-byte (buffer (buff 32)) (index uint))
  (unwrap-panic (element-at? buffer index))
)

;; Retrieve a specific uint from the user's password list using element-at?
(define-private (get-user-byte (user-password (list 32 uint)) (index uint))
  (unwrap-panic (element-at? user-password index))
)

;; Compare each byte of the buffer manually against user password
(define-private (check-password (user-password (list 32 uint)) (buffer (buff 32)))
  (let (
        ;; Retrieve each byte from the buffer and convert to uint using buff-to-uint-be
        (byte-0 (buff-to-uint-be (get-byte buffer u0)))
        (byte-1 (buff-to-uint-be (get-byte buffer u1)))
        (byte-2 (buff-to-uint-be (get-byte buffer u2)))
        (byte-3 (buff-to-uint-be (get-byte buffer u3)))
        (byte-4 (buff-to-uint-be (get-byte buffer u4)))
        (byte-5 (buff-to-uint-be (get-byte buffer u5)))
        (byte-6 (buff-to-uint-be (get-byte buffer u6)))
        (byte-7 (buff-to-uint-be (get-byte buffer u7)))
        (byte-8 (buff-to-uint-be (get-byte buffer u8)))
        (byte-9 (buff-to-uint-be (get-byte buffer u9)))
        (byte-10 (buff-to-uint-be (get-byte buffer u10)))
        (byte-11 (buff-to-uint-be (get-byte buffer u11)))
        (byte-12 (buff-to-uint-be (get-byte buffer u12)))
        (byte-13 (buff-to-uint-be (get-byte buffer u13)))
        (byte-14 (buff-to-uint-be (get-byte buffer u14)))
        (byte-15 (buff-to-uint-be (get-byte buffer u15)))
        (byte-16 (buff-to-uint-be (get-byte buffer u16)))
        (byte-17 (buff-to-uint-be (get-byte buffer u17)))
        (byte-18 (buff-to-uint-be (get-byte buffer u18)))
        (byte-19 (buff-to-uint-be (get-byte buffer u19)))
        (byte-20 (buff-to-uint-be (get-byte buffer u20)))
        (byte-21 (buff-to-uint-be (get-byte buffer u21)))
        (byte-22 (buff-to-uint-be (get-byte buffer u22)))
        (byte-23 (buff-to-uint-be (get-byte buffer u23)))
        (byte-24 (buff-to-uint-be (get-byte buffer u24)))
        (byte-25 (buff-to-uint-be (get-byte buffer u25)))
        (byte-26 (buff-to-uint-be (get-byte buffer u26)))
        (byte-27 (buff-to-uint-be (get-byte buffer u27)))
        (byte-28 (buff-to-uint-be (get-byte buffer u28)))
        (byte-29 (buff-to-uint-be (get-byte buffer u29)))
        (byte-30 (buff-to-uint-be (get-byte buffer u30)))
        (byte-31 (buff-to-uint-be (get-byte buffer u31)))

        ;; Retrieve each uint from the user's password using element-at?
        (user-byte-0 (get-user-byte user-password u0))
        (user-byte-1 (get-user-byte user-password u1))
        (user-byte-2 (get-user-byte user-password u2))
        (user-byte-3 (get-user-byte user-password u3))
        (user-byte-4 (get-user-byte user-password u4))
        (user-byte-5 (get-user-byte user-password u5))
        (user-byte-6 (get-user-byte user-password u6))
        (user-byte-7 (get-user-byte user-password u7))
        (user-byte-8 (get-user-byte user-password u8))
        (user-byte-9 (get-user-byte user-password u9))
        (user-byte-10 (get-user-byte user-password u10))
        (user-byte-11 (get-user-byte user-password u11))
        (user-byte-12 (get-user-byte user-password u12))
        (user-byte-13 (get-user-byte user-password u13))
        (user-byte-14 (get-user-byte user-password u14))
        (user-byte-15 (get-user-byte user-password u15))
        (user-byte-16 (get-user-byte user-password u16))
        (user-byte-17 (get-user-byte user-password u17))
        (user-byte-18 (get-user-byte user-password u18))
        (user-byte-19 (get-user-byte user-password u19))
        (user-byte-20 (get-user-byte user-password u20))
        (user-byte-21 (get-user-byte user-password u21))
        (user-byte-22 (get-user-byte user-password u22))
        (user-byte-23 (get-user-byte user-password u23))
        (user-byte-24 (get-user-byte user-password u24))
        (user-byte-25 (get-user-byte user-password u25))
        (user-byte-26 (get-user-byte user-password u26))
        (user-byte-27 (get-user-byte user-password u27))
        (user-byte-28 (get-user-byte user-password u28))
        (user-byte-29 (get-user-byte user-password u29))
        (user-byte-30 (get-user-byte user-password u30))
        (user-byte-31 (get-user-byte user-password u31))

        ;; Check if all bytes are equal
        (right-answer (and
          (is-eq byte-0 user-byte-0)
          (is-eq byte-1 user-byte-1)
          (is-eq byte-2 user-byte-2)
          (is-eq byte-3 user-byte-3)
          (is-eq byte-4 user-byte-4)
          (is-eq byte-5 user-byte-5)
          (is-eq byte-6 user-byte-6)
          (is-eq byte-7 user-byte-7)
          (is-eq byte-8 user-byte-8)
          (is-eq byte-9 user-byte-9)
          (is-eq byte-10 user-byte-10)
          (is-eq byte-11 user-byte-11)
          (is-eq byte-12 user-byte-12)
          (is-eq byte-13 user-byte-13)
          (is-eq byte-14 user-byte-14)
          (is-eq byte-15 user-byte-15)
          (is-eq byte-16 user-byte-16)
          (is-eq byte-17 user-byte-17)
          (is-eq byte-18 user-byte-18)
          (is-eq byte-19 user-byte-19)
          (is-eq byte-20 user-byte-20)
          (is-eq byte-21 user-byte-21)
          (is-eq byte-22 user-byte-22)
          (is-eq byte-23 user-byte-23)
          (is-eq byte-24 user-byte-24)
          (is-eq byte-25 user-byte-25)
          (is-eq byte-26 user-byte-26)
          (is-eq byte-27 user-byte-27)
          (is-eq byte-28 user-byte-28)
          (is-eq byte-29 user-byte-29)
          (is-eq byte-30 user-byte-30)
          (is-eq byte-31 user-byte-31)
        ))
      )
  
    (ok right-answer)
  )
)


;; Public function that updates the buffer for the block-height and compares with the user's password
(define-public (enter-password (user-password (list 32 uint)))
  (let (
        ;; Get the current block's header-hash (a buff 32)
        (block-hash (unwrap-panic (get-block-info? header-hash block-height)))
        (current-balance (unwrap-panic (as-contract (contract-call? 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock get-balance tx-sender))))
        (last-block (var-get last-call-block)) ;; Get the last block the function was called
    )
    (begin

    (try! (contract-call? 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock transfer u1000000 tx-sender (as-contract tx-sender) none))
      ;; Check if this is the first call of this block
      (if (> block-height last-block)
        (begin
          ;; Update the last-call-block variable with the current block height
          (var-set last-call-block block-height)
          
          ;; Update the current-buffer data variable with the block-hash
          (var-set current-buffer block-hash)
          
          ;; Compare the user's password with the block-hash bytes
          (if (unwrap-panic (check-password user-password block-hash))
            (ok (try! (contract-call? 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock transfer current-balance (as-contract tx-sender) tx-sender none))) ;; Return true if the password matches
            (ok false) ;; Return false if the password does not match
          )
        )
        (err u1000) ;; Error if another person has already called this function in this block
      )
    )
  )
)
```
