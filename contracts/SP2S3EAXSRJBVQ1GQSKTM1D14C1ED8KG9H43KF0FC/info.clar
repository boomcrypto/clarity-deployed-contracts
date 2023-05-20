(define-read-only (get-info (height uint))
  { height: height, vrf: (get-block-info? vrf-seed height), burn: (get-burn-block-info? header-hash height) })
