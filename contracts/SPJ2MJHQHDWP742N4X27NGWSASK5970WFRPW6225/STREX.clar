;; 07/12/2022 First MemeCoin on BTC by Axbubble.BTC 


(define-fungible-token strex)

(define-map allowances
  { spender: principal, owner: principal }
  { allowance: uint }
)
(define-data-var total-supply uint u0)


(define-private (get-total-supply)
  (var-get total-supply))

(define-private (allowance-of (spender principal) (owner principal))
  (begin
    (print
      (map-get? allowances { spender: spender, owner: owner }))
    (print
      (get allowance
        (map-get? allowances { spender: spender, owner: owner })
      )
    )
    (default-to u0
      (get allowance
        (map-get? allowances { spender: spender, owner: owner })
      )
    )
  )
)

(define-public (get-allowance-of (spender principal) (owner principal))
  (ok (allowance-of spender owner))
)

(define-public (transfer (recipient principal) (amount uint))
  (ft-transfer? strex amount tx-sender recipient)
)

(define-private (decrease-allowance (spender principal) (owner principal) (amount uint))
  (let ((allowance (allowance-of spender owner)))
    (if (or (> amount allowance) (<= amount u0))
      true
      (begin
        (map-set allowances
          { spender: spender, owner: owner }
          { allowance: (- allowance amount) }
        )
        true
      )
    )
  )
)

(define-private (increase-allowance (spender principal) (owner principal) (amount uint))
  (let ((allowance (allowance-of spender owner)))
    (if (<= amount u0)
      false
      (begin
        (print (tuple (spender spender) (owner owner)))
        (print (map-set allowances
          { spender: spender, owner: owner }
          { allowance: (+ allowance amount) }
          )
        )
        true
      )
    )
  )
)


(define-public (transfer-token (recipient principal) (amount uint))
  (transfer recipient amount)
)

(define-public (transfer-from (owner principal) (recipient principal) (amount uint))
  (let ((allowance (allowance-of tx-sender owner)))
      (if (or (> amount allowance) (<= amount u0))
        (err false)
        (if (and
              (is-ok (ft-transfer? strex amount owner recipient))
              (decrease-allowance tx-sender owner amount))
          (ok true)
          (err false)))))

(define-public (approve (spender principal) (amount uint))
  (if (and (> amount u0)
           (increase-allowance spender tx-sender amount))
      (ok amount)
      (err false)))


(define-public (revoke (spender principal))
  (let ((allowance (allowance-of spender tx-sender)))
    (if (and (> allowance u0)
             (decrease-allowance spender tx-sender allowance))
        (ok 0)
        (err false))))

(define-public (balance-of (owner principal))
  (begin
      (print owner)
      (ok (ft-get-balance strex owner))
  )
)

(define-private (mint! (account principal) (amount uint))
  (if (<= amount u0)
      (err false)
      (begin
        (var-set total-supply (+ (var-get total-supply) amount))
        (unwrap-panic (ft-mint? strex amount account))
        (ok amount))))


(begin
  (try! (mint! 'STJ2MJHQHDWP742N4X27NGWSASK5970WFS567PYY u100000000000))
)