;; @contract Supported Protocol - Zest
;; @version 2

(impl-trait .protocol-trait-v1.protocol-trait)

;;-------------------------------------
;; Zest 
;;-------------------------------------

(define-read-only (get-balance (user principal))
  (ok (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-token get-balance user))
)
