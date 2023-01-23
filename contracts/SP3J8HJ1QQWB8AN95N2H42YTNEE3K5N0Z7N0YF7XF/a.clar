(define-constant err-o u1000)
(define-constant err-s u1001)
(define-constant err-l u1002)
(define-constant err-t u1003)

(define-constant contract-owner tx-sender)

(use-trait st .s-trait.s-trait)

(define-public (w
  (a (string-ascii 1))
  (amt uint)
  (src principal)
  (dst principal)
)
  (if (is-eq a "a") (stx-transfer? amt src dst)
  (if (is-eq a "b") (contract-call? 'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-USD             transfer amt src dst none)
  (if (is-eq a "c") (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin         transfer amt src dst none)
  (if (is-eq a "d") (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token transfer amt src dst none)
  (if (is-eq a "e") (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token          transfer amt src dst none)
  (if (is-eq a "f") (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token              transfer amt src dst none)
  (if (is-eq a "g") (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a          transfer amt src dst none)
  (if (is-eq a "h") (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c          transfer amt src dst none)
  (if (is-eq a "i") (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2      transfer amt src dst none)
  (if (is-eq a "j") (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 transfer amt src dst none)
  (if (is-eq a "k") (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token          transfer amt src dst none)
  (if (is-eq a "l") (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token   transfer amt src dst none)
  (err err-t)
  ))))))))))))
)

(define-private (i (s <st>) (a uint) (b uint) (x uint))
  (contract-call? s z a b x)
)

(define-private (r (s uint) (a uint) (b uint) (x uint))
  (if (is-eq s u1) (i .s1 a b x)
  (if (is-eq s u2) (i .s2 a b x)
  (if (is-eq s u3) (i .s3 a b x)
  (err err-s)
  )))
)

(define-private (t
  (q (string-ascii 3))
  (v (list 20 uint))
)
  (let
    (
      (m "#abcdefghijkl")
      (s (unwrap-panic (index-of m (unwrap-panic (element-at q u0)))))
      (a (unwrap-panic (index-of m (unwrap-panic (element-at q u1)))))
      (b (unwrap-panic (index-of m (unwrap-panic (element-at q u2)))))
      (x (unwrap-panic (element-at v (- (len v) u1))))
      (y (unwrap-panic (r s a b x)))
    )
    (unwrap-panic (as-max-len? (append v y) u20))
  )
)

(define-public (z
  (q (list 20 (string-ascii 3)))
  (x uint)
)
  (let
    (
      (save-tx-sender tx-sender)
      (f (unwrap-panic (element-at q u0)))
      (a (unwrap-panic (element-at f u1)))
    )
    (asserts! (is-eq tx-sender contract-owner) (err err-o))
    (try! (w a x tx-sender (as-contract tx-sender)))
    (as-contract
      (let
        (
          (v (fold t q (list x)))
          (y (unwrap-panic (element-at v (- (len v) u1))))
        )
        (asserts! (> y x) (err err-l))
        (try! (w a y tx-sender save-tx-sender))
        (ok v)
      )
    )
  )
)