(define-constant ERR_O u1000)
(define-constant ERR_L u1001)
(define-constant ERR_Q u1002)
(define-constant ERR_F u1003)
(define-constant ERR_R u1004)
(define-constant ERR_W u1005)
  
(define-constant A2N "#abcdefghijkl")

(define-constant OWNER tx-sender)
    
(use-trait st .s-trait.s-trait)
      
(define-private (w
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
  (err ERR_W)
  ))))))))))))
)

(define-private (i (s <st>) (a uint) (b uint) (x uint))
  (contract-call? s z a b x)
)

(define-private (r (s uint) (a uint) (b uint) (x uint))
  (if (is-eq s u1) (i .s1 a b x)
  (if (is-eq s u2) (i .s2 a b x)
  (if (is-eq s u3) (i .s3 a b x)
  (err ERR_R)
  )))
)

(define-private (t
  (q (string-ascii 3))
  (v (list 20 (response uint uint)))
)
  (match (unwrap-panic (element-at v (- (len v) u1)))
    x (let
        (
          (s (unwrap-panic (index-of A2N (unwrap-panic (element-at q u0)))))
          (a (unwrap-panic (index-of A2N (unwrap-panic (element-at q u1)))))
          (b (unwrap-panic (index-of A2N (unwrap-panic (element-at q u2)))))
          (y (r s a b x))
        )
        (unwrap-panic (as-max-len? (append v y) u20))
      )
    x (unwrap-panic (as-max-len? (append v (err x)) u20))
  )
)

(define-public (Z
  (q (list 20 (string-ascii 3)))
  (x uint)
  (Y uint)
)
  (let
    (
      (sender tx-sender)
      (f (unwrap! (element-at q u0) (err ERR_Q)))
      (l (unwrap! (element-at q (- (len q) u1)) (err ERR_Q)))
      (a (unwrap! (element-at f u1) (err ERR_Q)))
      (b (unwrap! (element-at l u2) (err ERR_Q)))
    )
    (asserts! (is-eq tx-sender OWNER) (err ERR_O))
    (try! (w a x tx-sender (as-contract tx-sender)))
    (as-contract
      (let
        (
          (v (fold t q (list (ok x))))
          (resp (unwrap! (element-at v (- (len v) u1)) (err ERR_F)))
        )
        (match resp
          y (begin
              (asserts! (>= y Y) (err ERR_L))
              (try! (w b y tx-sender sender))
              (ok v)
            )
          y (err y)
        )
      )
    )
  )
)

(define-public (z
  (q (list 20 (string-ascii 3)))
  (x uint)
)
  (Z q x (+ x u1))
)