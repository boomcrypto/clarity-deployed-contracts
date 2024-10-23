(define-read-only (calc-stx-scha-stx (liquidity uint))
  (/ (* liquidity u90711607748) (unwrap-panic (scs-lp-total))))

(define-read-only (calc-stx-scha-scha (liquidity uint))
  (/ (* liquidity u982604817795) (unwrap-panic (scs-lp-total))))

(define-read-only (calc-stx-wcha-stx (liquidity uint))
  (/ (* liquidity u24022473965) (unwrap-panic (wcs-lp-total))))

(define-read-only (calc-stx-wcha-wcha (liquidity uint))
  (/ (* liquidity u282617340771) (unwrap-panic (wcs-lp-total))))
  
(define-read-only (scs-lp-total)
  (let
    (
      (block-hash (unwrap! (get-block-info? id-header-hash u166688) (err u500)))
      (lp-total (at-block block-hash (unwrap! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-scha get-total-supply) (err u500))))
    )
    (ok lp-total)
  )
)

(define-read-only (wcs-lp-total)
  (let
    (
      (block-hash (unwrap! (get-block-info? id-header-hash u166688) (err u500)))
      (lp-total (at-block block-hash (unwrap! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-wcha get-total-supply) (err u500))))
    )
    (ok lp-total)
  )
)

(define-read-only (scs-user-lp-checker (address principal) (block uint))
  (let
    (
      (block-hash (unwrap! (get-block-info? id-header-hash block) (err u500)))
      (amount (at-block block-hash (unwrap! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-scha get-balance address) (err u500))))
    )
    (ok amount)
  )
)

(define-read-only (wcs-user-lp-checker (address principal) (block uint))
  (let
    (
      (block-hash (unwrap! (get-block-info? id-header-hash block) (err u500)))
      (amount (at-block block-hash (unwrap! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-wcha get-balance address) (err u500))))
    )
    (ok amount)
  )
)

(define-read-only (scs-lands-lp-checker (address principal) (block uint))
  (let
    (
      (block-hash (unwrap! (get-block-info? id-header-hash block) (err u500)))
      (amount-in-lands (at-block block-hash (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-balance u13 address) (err u500))))
    )
    (ok amount-in-lands)
  )
)

(define-read-only (wcs-lands-lp-checker (address principal) (block uint))
  (let
    (
      (block-hash (unwrap! (get-block-info? id-header-hash block) (err u500)))
      (amount-in-lands (at-block block-hash (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-balance u12 address) (err u500))))
    )
    (ok amount-in-lands)
  )
)