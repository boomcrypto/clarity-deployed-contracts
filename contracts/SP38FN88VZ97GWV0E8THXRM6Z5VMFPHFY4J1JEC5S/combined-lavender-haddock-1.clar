(define-map baby-test uint
  {
    baby-name: (string-ascii 48),
    parent-badger-1: uint,
    parent-badger-2: uint,
    parent-1-trait-1: uint,
    parent-1-trait-2: uint,
    parent-1-trait-3: uint,
    parent-1-trait-4: uint,
    parent-1-trait-5: uint,
    parent-1-trait-6: uint,
    parent-1-trait-7: uint,
    parent-1-trait-8: uint,
    parent-1-trait-9: uint,
    parent-1-trait-10: uint,
    parent-2-trait-1: uint,
    parent-2-trait-2: uint,
    parent-2-trait-3: uint,
    parent-2-trait-4: uint,
    parent-2-trait-5: uint,
    parent-2-trait-6: uint,
    parent-2-trait-7: uint,
    parent-2-trait-8: uint,
    parent-2-trait-9: uint,
    parent-2-trait-10: uint
  }
)
(map-set baby-test u0
  {
    baby-name: "helloworld1",
    parent-badger-1: u0,
    parent-badger-2: u1,
    parent-1-trait-1: u1,
    parent-1-trait-2: u0,
    parent-1-trait-3: u0,
    parent-1-trait-4: u0,
    parent-1-trait-5: u0,
    parent-1-trait-6: u1,
    parent-1-trait-7: u0,
    parent-1-trait-8: u0,
    parent-1-trait-9: u0,
    parent-1-trait-10: u0,
    parent-2-trait-1: u0,
    parent-2-trait-2: u1,
    parent-2-trait-3: u1,
    parent-2-trait-4: u0,
    parent-2-trait-5: u0,
    parent-2-trait-6: u0,
    parent-2-trait-7: u0,
    parent-2-trait-8: u0,
    parent-2-trait-9: u0,
    parent-2-trait-10: u0
  }
)
(map-set baby-test u1
  {
    baby-name: "helloworld2",
    parent-badger-1: u1,
    parent-badger-2: u2,
    parent-1-trait-1: u1,
    parent-1-trait-2: u0,
    parent-1-trait-3: u0,
    parent-1-trait-4: u0,
    parent-1-trait-5: u0,
    parent-1-trait-6: u1,
    parent-1-trait-7: u0,
    parent-1-trait-8: u0,
    parent-1-trait-9: u0,
    parent-1-trait-10: u0,
    parent-2-trait-1: u0,
    parent-2-trait-2: u1,
    parent-2-trait-3: u1,
    parent-2-trait-4: u0,
    parent-2-trait-5: u0,
    parent-2-trait-6: u0,
    parent-2-trait-7: u0,
    parent-2-trait-8: u0,
    parent-2-trait-9: u0,
    parent-2-trait-10: u0
  }
)

;; Get Minted Baby Badgers Maps
(define-read-only (get-baby-test)
  (begin
    (print (map-get? baby-test u0))
    (ok (print (map-get? baby-test u1)))
  )
)

(define-read-only (get-baby-default-test)
  (begin
    (print (map-get? baby-test u0))
    (print (map-get? baby-test u1))
    (ok (print (default-to {
      baby-name: "ignoreThisMap",
      parent-badger-1: u1,
      parent-badger-2: u2,
      parent-1-trait-1: u1,
      parent-1-trait-2: u0,
      parent-1-trait-3: u0,
      parent-1-trait-4: u0,
      parent-1-trait-5: u0,
      parent-1-trait-6: u1,
      parent-1-trait-7: u0,
      parent-1-trait-8: u0,
      parent-1-trait-9: u0,
      parent-1-trait-10: u0,
      parent-2-trait-1: u0,
      parent-2-trait-2: u1,
      parent-2-trait-3: u1,
      parent-2-trait-4: u0,
      parent-2-trait-5: u0,
      parent-2-trait-6: u0,
      parent-2-trait-7: u0,
      parent-2-trait-8: u0,
      parent-2-trait-9: u0,
      parent-2-trait-10: u0
    } (map-get? baby-test u2))))
  )
)