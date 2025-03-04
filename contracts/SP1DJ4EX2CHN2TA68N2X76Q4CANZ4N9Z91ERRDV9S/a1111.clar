(define-read-only (get-pools)
    (let (
        (stx-leo (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u28))
        (leo-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u9))
        (stx-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u6))
        (stx-abtc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u3))
        (stx-welsh (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u27))
        (welsh-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u10))
        (velar-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u22))
        (velar-wstx (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u21))
        (ststx-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u8))
        (abtc-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u7))
        (stx-odin (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u23))
        (stx-rock (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u18))
)
    {
        stx-leo: (ok stx-leo),
        leo-aeusdc: (ok leo-aeusdc),
        stx-aeusdc: (ok stx-aeusdc),
        stx-abtc: (ok stx-abtc),
        stx-welsh: (ok stx-welsh),
        welsh-aeusdc: (ok welsh-aeusdc),
        velar-aeusdc: (ok velar-aeusdc),
        velar-wstx: (ok velar-wstx),
        ststx-aeusdc: (ok ststx-aeusdc),
        abtc-aeusdc: (ok abtc-aeusdc),
        stx-odin: (ok stx-odin),
        stx-rock: (ok stx-rock),
    })
)