(define-constant DEPLOYER tx-sender)

(define-constant ERR_NOT_ENOUGH_PASSES u300)
(define-constant ERR_PUBLIC_SALE_DISABLED u301)
(define-constant ERR_CONTRACT_INITIALIZED u302)

(define-constant ERR_UNAUTHORIZED u302)

(define-map mint-passes principal uint)

(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)

(define-public (claim)
    (mint (list true))
)

(define-public (claim-three)
    (mint (list true true true))
)

(define-public (claim-five)
    (mint (list true true true true true))
)

(define-public (claim-ten)
    (mint (list true true true true true true true true true true))
)

(define-private (mint (orders (list 10 bool)))
    (let (
            (passes (get-passes tx-sender))
        )
        (if (var-get premint-enabled)
            (begin
                (asserts! (>= passes (len orders)) (err ERR_NOT_ENOUGH_PASSES))
                (map-set mint-passes tx-sender (- passes (len orders)))
                (contract-call? .commoners mint orders)
            )
            (begin
                (asserts! (var-get sale-enabled) (err ERR_PUBLIC_SALE_DISABLED))
                (contract-call? .commoners mint orders)
            )
        )
    )
)

(define-public (toggle-sale-state)
    (let (
        (premint (not (var-get premint-enabled)))
        (sale (not (var-get sale-enabled)))
        )
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR_UNAUTHORIZED))
        (var-set premint-enabled premint)
        (var-set sale-enabled sale)
        (print  { premint: premint, sale: sale })
        (ok true)
    )
)

(define-public (init)
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR_UNAUTHORIZED))
        (ok (var-set premint-enabled true))
    )
)

(define-read-only (get-passes (caller principal))
    (default-to u0 (map-get? mint-passes caller))
)

(contract-call? .commoners set-mint-addr (as-contract tx-sender))

(map-set mint-passes 'SP2M54B2S1W7A4R4CYBHY2DN5TR7EQF46R8Z43AVW u5)
(map-set mint-passes 'SP1V8CG8XJENRVEH02SC6RWSY5P1725KTWWCAZJS0 u5)
(map-set mint-passes 'SP38F13RDY25HD5MV9ZEF1FG5N7CM5RYDAZ9F3BWC u5)
(map-set mint-passes 'SPN8Z4TP0W9Z0F5GMS38XT8AT0DT5JB82QPTNZAY u5)
(map-set mint-passes 'SP3641JAKBRFJW11R5FWBBQQMWDGQT2MMB1V8FRES u5)
(map-set mint-passes 'SP286TT5H3JDYXN32F8QWAX8PHG1GH2A3BAXA6B2 u5)
(map-set mint-passes 'SPDNZNAR01JZ9VHWG2X6S4AMAQYZD7PEMH9AH7VN u5)
(map-set mint-passes 'SP1QG2JZA1DF5BWG1K5GRM0GRD1H8FWTEXJ4SBS21 u5)
(map-set mint-passes 'SP2HXR3BJSGSAD98XA6KT725EMMNPNW8MZ3ZEAFCS u5)
(map-set mint-passes 'SP3N0MVPYBV1VB2HTPCKQ4TMG160DSVE449715PE0 u5)
(map-set mint-passes 'SP3SYSY9P77MBJN24H0REVGR0CCF35YBXDBFWTSDH u5)
(map-set mint-passes 'SP2XGS393ZWE6X0EGQMWRPGCR7FYWQZ818B39DFWE u5)
(map-set mint-passes 'SP17G237T33PECW9DAT6YF9RCQG7FC2SYY0GCC8K8 u5)
(map-set mint-passes 'SP1NEK4NHT79WH7VA3ZZXQYPSPG9JBERY716NB3Z1 u5)
