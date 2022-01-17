(define-read-only (get_values (tid uint))
  {
    burn_h: burn-block-height,
    liquid: stx-liquid-supply,
    ts: (get-block-info? time (- block-height u2027)),
  }
)
