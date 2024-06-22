(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(define-constant owner tx-sender)
(define-constant this (as-contract tx-sender))

(define-map donk-map principal uint)
(define-private (is-owner) (is-eq tx-sender owner))

(define-public (neo (t (optional <ft-trait>)))
  (begin 
    (asserts! (is-owner) (err u9))
    (ok (match t token 
      (as-contract (contract-call? token transfer (stx-get-balance this) this owner none))
      (as-contract (stx-transfer? (stx-get-balance this) this owner))
    ))
  )
)

(define-public (donk 
  (a { route: (list 3 <ft-trait>), factor: (list 3 uint) }) 
  (v { token-in: <ft-trait>, token-out: <ft-trait>, token-0: <ft-trait>, token-1: <ft-trait>, pool-id: uint })
  (direction uint)
  (amt-in uint)
  (amount-out-min uint)
)
  (let (
    (a-route (get route a))
    (a-factor (get factor a))
    (a-hops (- (len a-route) u1))
    (v-token-in (get token-in v))
    (v-token-out (get token-out v))
    (v-token-0 (get token-0 v))
    (v-token-1 (get token-1 v))
    (v-pool-id (get pool-id v))
  )
    (asserts! (is-owner) (err u9))
    (if (is-eq a-hops u1) 
      ;; BEGIN single hop
      (let (
        (a-token-x (unwrap! (element-at? a-route u0) (err u0)))
        (a-token-y (unwrap! (element-at? a-route u1) (err u0)))
        (a-xy-factor (unwrap! (element-at? a-factor u0) (err u0)))
      )
        (if (is-eq direction u0)
          ;; Alex first, then Velar
          (let (
            (a-amt-out (a-swap-helper a-token-x a-token-y a-xy-factor amt-in none))
            (v-amt-in (unwrap! (moon-math a-amt-out (contract-of a-token-y) (contract-of v-token-in)) (err u99)))
            (v-amt-out (swap-exact-tokens-for-tokens 
              v-pool-id 
              v-token-0 
              v-token-1
              v-token-in 
              v-token-out
              v-amt-in
              u1
            ))
          )
            (asserts! (> v-amt-out amount-out-min) (err u99))
            (ok v-amt-out)
          )
          
          ;; Velar first, then Alex
          (let (
            (v-amt-out (swap-exact-tokens-for-tokens 
              v-pool-id 
              v-token-0 
              v-token-1
              v-token-in 
              v-token-out
              amt-in
              u1
            ))
            (a-amt-in (unwrap! (moon-math v-amt-out (contract-of v-token-out) (contract-of a-token-x)) (err u99)))
            (a-amt-out (a-swap-helper a-token-x a-token-y a-xy-factor a-amt-in none))
          )
            (asserts! (> a-amt-out amount-out-min) (err u99))
            (ok a-amt-out)
          )
        )
      )
      ;; END single hop


      ;; BEGIN two-hop
      (let (
        (a-token-x (unwrap! (element-at? a-route u0) (err u0)))
        (a-token-y (unwrap! (element-at? a-route u1) (err u0)))
        (a-token-z (unwrap! (element-at? a-route u2) (err u0)))
        (a-xy-factor (unwrap! (element-at? a-factor u0) (err u0)))
        (a-yz-factor (unwrap! (element-at? a-factor u1) (err u0)))
      )
        (if (is-eq direction u0)
           ;; Alex first, then Velar
          (let (
            (a-amt-out (a-swap-helper-a a-token-x a-token-y a-token-z a-xy-factor a-yz-factor amt-in none))
            (v-amt-in (unwrap! (moon-math a-amt-out (contract-of a-token-z) (contract-of v-token-in)) (err u99)))
            (v-amt-out (swap-exact-tokens-for-tokens 
              v-pool-id 
              v-token-0 
              v-token-1
              v-token-in 
              v-token-out
              v-amt-in
              u1
            ))
          )
            (asserts! (> v-amt-out amount-out-min) (err u99))
            (ok v-amt-out)
          )
          
          ;; Velar first, then Alex
          (let (
            (v-amt-out (swap-exact-tokens-for-tokens 
              v-pool-id 
              v-token-0 
              v-token-1
              v-token-in 
              v-token-out
              amt-in
              u1
            ))
            (a-amt-in (unwrap! (moon-math v-amt-out (contract-of v-token-out) (contract-of a-token-x)) (err u99)))
            (a-amt-out (a-swap-helper-a a-token-x a-token-y a-token-z a-xy-factor a-yz-factor a-amt-in none))
          )
            (asserts! (> a-amt-out amount-out-min) (err u99))
            (ok a-amt-out)
          )
        )
      )
      ;; END two-hop
    )
  )
)

(define-private (donkulate (v uint) (a uint) (b uint))
  (if (< a b)
    (* v (pow u10 (- b a)))
    (/ v (pow u10 (- a b)))
  )
)

(define-private (moon-math (v uint) (t1 principal) (t2 principal))
  (ok (donkulate v (unwrap! (map-get? donk-map t1) (err u404)) (unwrap! (map-get? donk-map t2) (err u404))))
)

(define-private (a-swap-helper (token-x <ft-trait>) (token-y <ft-trait>) (factor uint) (dx uint) (min-dy (optional uint)))
  (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper token-x token-y factor dx min-dy))
)

(define-private (a-swap-helper-a (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (factor-x uint) (factor-y uint) (dx uint) (min-dz (optional uint)))
  (a-swap-helper token-y-trait token-z-trait factor-y (a-swap-helper token-x-trait token-y-trait factor-x dx none) min-dz)
)

(define-private (swap-exact-tokens-for-tokens
  (id             uint)
  (token-0        <ft-trait>)
  (token-1        <ft-trait>)
  (token-in       <ft-trait>)
  (token-out      <ft-trait>)
  (amt-in      uint)
  (amt-out-min uint)
)
  (get amt-out (unwrap-panic (contract-call? 
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router 
    swap-exact-tokens-for-tokens 
    id 
    token-0 
    token-1 
    token-in 
    token-out
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
    amt-in
    amt-out-min
  )))
)

(define-private (add-donk (t principal) (d uint))
  (map-insert donk-map t d)
)

(define-public (add-donks (l (list 10 principal)) (v (list 10 uint)))
  (begin
    (asserts! (is-owner) (err u99))
    (ok (map add-donk l v))
  )
)

(add-donks 
  (list 
    'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpepe
    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-whashiko
    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
    'SP28NB976TJHHGF4218KT194NPWP9N1X3WY516Z1P.Hashiko
    'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
  )
  (list 
    u8
    u8
    u8
    u8
    u8
    u8
    u6
    u3
    u0
    u6
  )
)