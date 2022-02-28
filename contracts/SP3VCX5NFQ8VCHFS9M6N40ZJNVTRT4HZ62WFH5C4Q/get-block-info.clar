;; get-block-info
;; Expose the get-block-info clarity values so they can be used outside of smart contracts.

(define-read-only (get-block-info-time (block-height-expr uint))
  (get-block-info? time block-height-expr))

(define-read-only (get-block-info-header-hash (block-height-expr uint))
  (get-block-info? header-hash block-height-expr))

(define-read-only (get-block-info-burnchain-header-hash (block-height-expr uint))
  (get-block-info? burnchain-header-hash block-height-expr))

(define-read-only (get-block-info-id-header-hash (block-height-expr uint))
  (get-block-info? id-header-hash block-height-expr))

(define-read-only (get-block-info-miner-address (block-height-expr uint))
  (get-block-info? miner-address block-height-expr))

(define-read-only (get-block-info-vrf-seed (block-height-expr uint))
  (get-block-info? vrf-seed block-height-expr))