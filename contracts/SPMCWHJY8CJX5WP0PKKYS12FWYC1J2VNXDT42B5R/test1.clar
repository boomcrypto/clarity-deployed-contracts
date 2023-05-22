(define-public (b (h uint))
  (begin
    (asserts! (is-none (get-burn-block-info? header-hash (+ h u7))) (err u111))
    (asserts! (is-some (get-burn-block-info? header-hash (- h u7))) (err u222))
    (ok {
      h-2: (get-burn-block-info? header-hash (- h u2)),
      h-1: (get-burn-block-info? header-hash (- h u1)),
      h0: (get-burn-block-info? header-hash h),
      h1: (get-burn-block-info? header-hash (+ h u1)),
      h2: (get-burn-block-info? header-hash (+ h u2)),
      h3: (get-burn-block-info? header-hash (+ h u3)),
    })
  )
)
