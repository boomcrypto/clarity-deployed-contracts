;; @contract Supported Protocol - Zest
;; @version 1

(impl-trait .protocol-trait-v1.protocol-trait)

;;-------------------------------------
;; Arkadiko 
;;-------------------------------------

(define-read-only (get-balance (user principal))
  (let (
    (total-lp-supply (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc get-total-supply)))
    (user-wallet (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc get-balance user)))
    (user-staked (get end (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.farming-ststx-aeusdc-core get-user-staked user)))
    (user-total (+ user-wallet user-staked))

    (pool-info (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u8))
  )
    (ok (/ (* user-total (get reserve0 pool-info)) total-lp-supply))
  )
)
