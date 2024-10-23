(define-read-only (calc-stx-scha-stx (liquidity uint))
  (/ (* liquidity u90711607748) (scs-lp-total)))

(define-read-only (calc-stx-scha-scha (liquidity uint))
  (/ (* liquidity u982604817795) (scs-lp-total)))

(define-read-only (calc-stx-wcha-stx (liquidity uint))
  (/ (* liquidity u24022473965) (wcs-lp-total)))

(define-read-only (calc-stx-wcha-wcha (liquidity uint))
  (/ (* liquidity u282617340771) (wcs-lp-total)))
  
(define-read-only (scs-lp-total)
  (let
    (
      (block-hash (unwrap-panic (get-block-info? id-header-hash u166688)))
    )
    (at-block block-hash (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-scha get-total-supply)))
  )
)

(define-read-only (wcs-lp-total)
  (let
    (
      (block-hash (unwrap-panic (get-block-info? id-header-hash u166688)))
    )
    (at-block block-hash (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-wcha get-total-supply)))
  )
)

(define-read-only (scs-user-lp-checker (address principal))
  (let
    (
      (block-hash (unwrap-panic (get-block-info? id-header-hash u166688)))
    )
    (at-block block-hash (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-scha get-balance address)))
  )
)

(define-read-only (wcs-user-lp-checker (address principal))
  (let
    (
      (block-hash (unwrap-panic (get-block-info? id-header-hash u166688)))
    )
    (at-block block-hash (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-wcha get-balance address)))
  )
)

(define-read-only (scs-lands-lp-checker (address principal))
  (let
    (
      (block-hash (unwrap-panic (get-block-info? id-header-hash u166688)))
    )
    (at-block block-hash (unwrap-panic (contract-call? .lands get-balance u13 address)))
  )
)

(define-read-only (wcs-lands-lp-checker (address principal))
  (let
    (
      (block-hash (unwrap-panic (get-block-info? id-header-hash u166688)))
    )
    (at-block block-hash (unwrap-panic (contract-call? .lands get-balance u12 address)))
  )
)

(define-read-only (scs-velar-lp-checker (address principal))
  (let
    (
      (block-hash (unwrap-panic (get-block-info? id-header-hash u166688)))
    )
    (at-block block-hash (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.farming-wstx-scha-core get-user-staked address))
  )
)

(define-read-only (wcs-velar-lp-checker (address principal))
  (let
    (
      (block-hash (unwrap-panic (get-block-info? id-header-hash u166688)))
    )
    (at-block block-hash (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.farming-wstx-wcha-core get-user-staked address))
  )
)

(define-public (check-all-lp (address principal))
  (let
    (
      (block-hash (unwrap-panic (get-block-info? id-header-hash u166688)))
    )
    (ok {
      a: (at-block block-hash (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-scha get-balance address))),
      b: (at-block block-hash (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-wcha get-balance address))),
      c: (at-block block-hash (unwrap-panic (contract-call? .lands get-balance u13 address))),
      d: (at-block block-hash (unwrap-panic (contract-call? .lands get-balance u12 address))),
      e: (at-block block-hash (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.farming-wstx-scha-core get-user-staked address)),
      f: (at-block block-hash (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.farming-wstx-wcha-core get-user-staked address))
    })
  )
)

 