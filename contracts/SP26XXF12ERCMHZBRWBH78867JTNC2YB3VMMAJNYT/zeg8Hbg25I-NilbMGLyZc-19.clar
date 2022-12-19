(use-trait AxSDVMnsiYamlC 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait NcEfqXWqwCGSVR 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)
(use-trait fMWDwheyiYXmYN 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait monYErPtHrAeeD 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v4c.liquidity-token-trait)


;; constants
;;
(define-constant contract-owner tx-sender)

;; constants errors
;;
(define-constant ERR-NOT-OWNER (err u403))
(define-constant ERR-SWAP-ALEX-FAILED u7770)
(define-constant ERR-SWAP-ARKADIKO-FAILED u7771)
(define-constant ERR-SWAP-STACKSWAP-FAILED u7772)
(define-constant ERR-BALANCE-LOWER u7773)

;; data maps and vars
;;

;; private functions
;;

(define-private (lIrZANWJdVyFpL
    (gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (pXfHvdKmHDUGJjF uint)
    (cMUfNFrmT8z3bzk uint)
    (dx uint)
 )
    (let
        (
            (PWuyHpzaB2MRbKf (unwrap-panic (contract-call? gSdwYJmyTzoWDD get-decimals)))
            (lgOKJUDXNTYsaE (unwrap! (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper gSdwYJmyTzoWDD WwVyVrEOHQxVXy (gqyGnZJgEuDTGv dx pXfHvdKmHDUGJjF PWuyHpzaB2MRbKf) none)) (err ERR-SWAP-ALEX-FAILED)))
            (lgOKJUDXNTYsaE-converted (gqyGnZJgEuDTGv lgOKJUDXNTYsaE PWuyHpzaB2MRbKf cMUfNFrmT8z3bzk))
        )
        (ok lgOKJUDXNTYsaE-converted)
    )
)

(define-private (jijxzMDvfRcCZC
    (HWOztqcyfgyqxB <AxSDVMnsiYamlC>)
    (PwzYDAsBvcrhaj <AxSDVMnsiYamlC>)
    (PcvSXbBlExqEQR bool)
    (dx uint)
 )
    (let
        (
            (kg4QmHMALRSVjuU (if PcvSXbBlExqEQR
                (unwrap! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x HWOztqcyfgyqxB PwzYDAsBvcrhaj dx u0)) (err ERR-SWAP-ARKADIKO-FAILED))
                (unwrap! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y HWOztqcyfgyqxB PwzYDAsBvcrhaj dx u0)) (err ERR-SWAP-ARKADIKO-FAILED))
            ))
            (lgOKJUDXNTYsaE (if PcvSXbBlExqEQR
                (unwrap-panic (element-at kg4QmHMALRSVjuU u0))
                (unwrap-panic (element-at kg4QmHMALRSVjuU u1))
            ))
        )
        (ok lgOKJUDXNTYsaE)
    )
)

(define-private (CVsvpVOgvZZqZL
    (DxALcRZBPLzUJn <fMWDwheyiYXmYN>)
    (BkSeCLoVnCtPlX <fMWDwheyiYXmYN>)
    (qPlYaMcJXmysRu <monYErPtHrAeeD>)
    (UAWqZvuqvdHDzq bool)
    (dx uint)
 )
    (let
        (
            (kg4QmHMALRSVjuU (if UAWqZvuqvdHDzq
                (unwrap! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x DxALcRZBPLzUJn BkSeCLoVnCtPlX qPlYaMcJXmysRu dx u0)) (err ERR-SWAP-STACKSWAP-FAILED))
                (unwrap! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y DxALcRZBPLzUJn BkSeCLoVnCtPlX qPlYaMcJXmysRu dx u0)) (err ERR-SWAP-STACKSWAP-FAILED))
            ))
            (lgOKJUDXNTYsaE (if UAWqZvuqvdHDzq
                (unwrap-panic (element-at kg4QmHMALRSVjuU u0))
                (unwrap-panic (element-at kg4QmHMALRSVjuU u1))
            ))
        )
        (ok lgOKJUDXNTYsaE)
    )
)

(define-read-only (gqyGnZJgEuDTGv
    (n uint)
    (b uint) 
    (a uint)
 )
    (/ (* n (pow u10 a)) (pow u10 b))
)

(define-private (VCQGoSAdvbxUQE
    (GpyEQn9wUaQGL6Q (string-ascii 10))
    (KnKttLSP2Bg7cb6 principal)
    (TPksrk9EaNzhmtf principal)
    (dx uint)
)
    (ok
        (if (is-eq GpyEQn9wUaQGL6Q "arkadiko")
            (try! (wZWrGLyILlrjrJ KnKttLSP2Bg7cb6 TPksrk9EaNzhmtf dx))
            (if (is-eq GpyEQn9wUaQGL6Q "alex")
                (try! (jCNlDTWjRAKdEN KnKttLSP2Bg7cb6 TPksrk9EaNzhmtf dx))
                (if (is-eq GpyEQn9wUaQGL6Q "stackswap")
                    (try! (ZyPMebpnWHRDUT KnKttLSP2Bg7cb6 TPksrk9EaNzhmtf dx))
                    (unwrap-panic (ok u0))
                )
            )
        )
    )
)

;; public functions
;;

(define-public (swap-helper
    (gmf9MFsEr5uXqn6 <AxSDVMnsiYamlC>)
    (esHhZSmChD5PCRU <AxSDVMnsiYamlC>)
    (REZaDNbWLaV7mk3 (string-ascii 10))
    (B2ScWCyaYXQhb8x (string-ascii 10))
    (dx uint)
    (jnJe1z8sXPa46T bool)
)
    (let
        (
            (z89U2vcrbMgcMz3 tx-sender)
            (KnKttLSP2Bg7cb6 (contract-of gmf9MFsEr5uXqn6))
            (TPksrk9EaNzhmtf (contract-of esHhZSmChD5PCRU))
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (if (is-eq jnJe1z8sXPa46T true)
            (begin (try! (stx-transfer? dx tx-sender (as-contract tx-sender))))
            (begin (try! (contract-call? gmf9MFsEr5uXqn6 transfer dx tx-sender (as-contract tx-sender) none)))
        )
        (let
            (
                (lgOKJUDXNTYsaE (unwrap-panic (VCQGoSAdvbxUQE REZaDNbWLaV7mk3 KnKttLSP2Bg7cb6 TPksrk9EaNzhmtf dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (VCQGoSAdvbxUQE B2ScWCyaYXQhb8x KnKttLSP2Bg7cb6 TPksrk9EaNzhmtf lgOKJUDXNTYsaE)))
            )
            (if (is-eq jnJe1z8sXPa46T true)
                (begin (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3))))
                (begin (try! (as-contract (contract-call? gmf9MFsEr5uXqn6 transfer nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3 none))))
            )
            (asserts! (< dx nmoFJdZDqlSrMz) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-private (jCNlDTWjRAKdEN
    (KnKttLSP2Bg7cb6 principal)
    (TPksrk9EaNzhmtf principal)
    (dx uint)
)
    (ok
        (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token))
            (try! (lIrZANWJdVyFpL 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda u6 u6 dx))
            (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token))
                (try! (lIrZANWJdVyFpL 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u6 u6 dx))
        (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token) (is-eq TPksrk9EaNzhmtf 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin))
            (try! (lIrZANWJdVyFpL 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc u6 u8 dx))
            (if (and (is-eq KnKttLSP2Bg7cb6 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token))
                (try! (lIrZANWJdVyFpL 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u8 u6 dx))
        (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token) (is-eq TPksrk9EaNzhmtf 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2))
            (try! (lIrZANWJdVyFpL 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia u6 u6 dx))
            (if (and (is-eq KnKttLSP2Bg7cb6 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token))
                (try! (lIrZANWJdVyFpL 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx u6 u6 dx))
            (unwrap-panic (ok u0))
        ))))))
    )
)

(define-private (wZWrGLyILlrjrJ
    (KnKttLSP2Bg7cb6 principal)
    (TPksrk9EaNzhmtf principal)
    (dx uint)
)
    (ok
        (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token))
            (try! (jijxzMDvfRcCZC 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token false dx))
            (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token))
                (try! (jijxzMDvfRcCZC 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token true dx))
        (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token))
            (try! (jijxzMDvfRcCZC 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token false dx))
            (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token))
                (try! (jijxzMDvfRcCZC 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token true dx))
        (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token) (is-eq TPksrk9EaNzhmtf 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token))
            (try! (jijxzMDvfRcCZC 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token false dx))
            (if (and (is-eq KnKttLSP2Bg7cb6 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token))
                (try! (jijxzMDvfRcCZC 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token true dx))
            (unwrap-panic (ok u0))
        ))))))
    )
)

(define-private (ZyPMebpnWHRDUT
    (KnKttLSP2Bg7cb6 principal)
    (TPksrk9EaNzhmtf principal)
    (dx uint)
)
    (ok
        (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token))
            (try! (CVsvpVOgvZZqZL 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c false dx))
            (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token))
                (try! (CVsvpVOgvZZqZL 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c true dx))
        (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token))
            (try! (CVsvpVOgvZZqZL 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l false dx))
            (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token))
                (try! (CVsvpVOgvZZqZL 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l true dx))
        (if (and (is-eq KnKttLSP2Bg7cb6 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token) (is-eq TPksrk9EaNzhmtf 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2))
            (try! (CVsvpVOgvZZqZL 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773 false dx))
            (if (and (is-eq KnKttLSP2Bg7cb6 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2) (is-eq TPksrk9EaNzhmtf 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token))
                (try! (CVsvpVOgvZZqZL 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773 true dx))
            (unwrap-panic (ok u0))
        ))))))
    )
)
    