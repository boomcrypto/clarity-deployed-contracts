(define-read-only (get-pools-1)
    (let (
        (stx-leo (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u28))
        (leo-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u9))
        (stx-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u6))
        (stx-abtc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u3))
)
    {
        stx-leo: (ok stx-leo),
        leo-aeusdc: (ok leo-aeusdc),
        stx-aeusdc: (ok stx-aeusdc),
        stx-abtc: (ok stx-abtc)
    })
)

(define-read-only (get-pools-2)
    (let (
        (stx-welsh (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u27))
        (welsh-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u10))
        (velar-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u22))
        (velar-wstx (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u21))
 )
    {
        stx-welsh: (ok stx-welsh),
        welsh-aeusdc: (ok welsh-aeusdc),
        velar-aeusdc: (ok velar-aeusdc),
        velar-wstx: (ok velar-wstx)
    })
)

(define-read-only (get-pools-3)
    (let (
        (ststx-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u8))
        (abtc-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u7))
        (stx-odin (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u23))
        (stx-rock (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u18))
        )
    {
        ststx-aeusdc: (ok ststx-aeusdc),
        abtc-aeusdc: (ok abtc-aeusdc),
        stx-odin: (ok stx-odin),
        stx-rock: (ok stx-rock)
    })
)

(define-read-only (get-pools-4)
    (let (
        (stx-long (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u14))
        (stx-kangaroo (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u15))
    )
    {
        stx-long: (ok stx-long),
        stx-kangaroo: (ok stx-kangaroo)
    })
)

(define-read-only (get-all-pools)
    (let (
        (pools-1 (get-pools-1))
        (pools-2 (get-pools-2))
        (pools-3 (get-pools-3))
        (pools-4 (get-pools-4))
    )
    {
        pools-1: pools-1,
        pools-2: pools-2,
        pools-3: pools-3,
        pools-4: pools-4
    })
)