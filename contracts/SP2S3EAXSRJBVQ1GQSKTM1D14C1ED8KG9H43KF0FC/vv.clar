(define-constant LIST_10 (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10))

(define-private (f (index uint) (cur_btc_height uint))
  (match (get-burn-block-info? header-hash cur_btc_height) hash
    cur_btc_height
    (- cur_btc_height u1)
  )
)

(define-read-only (get_info (height uint))
  {
    btc_end_at: (fold f LIST_10 (+ height u7)),
    height: height, 
    vrf: (get-block-info? vrf-seed height), 
    burn: (get-burn-block-info? header-hash height), 
    bh: block-height 
  }
)

(define-read-only (get-info_2 (height uint))
  { height: height, vrf: (get-block-info? vrf-seed height), burn: (get-burn-block-info? header-hash height) })