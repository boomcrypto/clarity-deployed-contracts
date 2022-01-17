(define-read-only (get_summary)
  {
    bbh: burn-block-height,
    t: (get-block-info? time (- block-height u1)),
  }
)
