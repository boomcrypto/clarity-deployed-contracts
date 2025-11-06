;; @contract Supported Position - Zest
;; @version 2

(impl-trait .position-trait-v1.position-trait)

(define-read-only (get-holder-balance (user principal))
  (ok (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-token get-balance user))
)