;; @contract Block Info
;; @version 20
;;
;; Contract to get info at given block

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_BLOCK_INFO u42001)

;;-------------------------------------
;; stSTX info
;;-------------------------------------

(define-read-only (get-ststx-supply-at-block (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))
  )
    (at-block block-hash (contract-call? .ststx-token get-total-supply))
  )
)
