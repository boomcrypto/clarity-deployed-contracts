(define-read-only (get-data)
  (let ((prev-block-height (- block-height u1)))
    (print {
      prev-block-height: prev-block-height,
      time: (unwrap-panic (get-block-info? time prev-block-height)),
      header-hash: (unwrap-panic (get-block-info? header-hash prev-block-height)), 
      burnchain-header-hash: (unwrap-panic (get-block-info? burnchain-header-hash prev-block-height)), 
      id-header-hash: (unwrap-panic (get-block-info? id-header-hash prev-block-height)),
      miner-address: (unwrap-panic (get-block-info? miner-address prev-block-height)),
      vrf-seed: (unwrap-panic (get-block-info? vrf-seed prev-block-height))
    })))
