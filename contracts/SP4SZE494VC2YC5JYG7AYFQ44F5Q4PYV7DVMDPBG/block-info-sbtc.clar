;; @contract Block Info
;; @version 2
;;
;; Contract to get info at given block

;;-------------------------------------
;; User Info
;;-------------------------------------

(define-read-only (get-ststxbtc-balance-at-block (holder principal) (position principal) (block uint))
  (let (
    (block-hash (unwrap-panic (get-block-info? id-header-hash block)))
  )
    (at-block block-hash (get amount (contract-call? .ststxbtc-tracking-data get-holder-position holder position)))
  )
)

