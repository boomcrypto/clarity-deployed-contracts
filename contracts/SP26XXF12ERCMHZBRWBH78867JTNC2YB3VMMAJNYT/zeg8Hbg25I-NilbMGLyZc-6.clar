(use-trait sip-010-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait liquidity-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.liquidity-token-trait.liquidity-token-trait)
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
    (ejKQclDkhPafKm uint)
    (gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (dx uint)
 )
    (let
        (
            (PWuyHpzaB2MRbKf (unwrap-panic (contract-call? gSdwYJmyTzoWDD get-decimals)))
            (lgOKJUDXNTYsaE (unwrap! (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper gSdwYJmyTzoWDD WwVyVrEOHQxVXy (gqyGnZJgEuDTGv dx ejKQclDkhPafKm PWuyHpzaB2MRbKf) none)) (err ERR-SWAP-ALEX-FAILED)))
            (lgOKJUDXNTYsaE-converted (gqyGnZJgEuDTGv lgOKJUDXNTYsaE PWuyHpzaB2MRbKf ejKQclDkhPafKm))
        )
        (ok lgOKJUDXNTYsaE-converted)
    )
)

(define-private (jijxzMDvfRcCZC
    (HWOztqcyfgyqxB <sip-010-token>)
    (PwzYDAsBvcrhaj <sip-010-token>)
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

;; public functions
;;

(define-public (jCNlDTWjRAKdEN
    (step1-gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (step1-WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (step2-HWOztqcyfgyqxB <sip-010-token>)
    (step2-PwzYDAsBvcrhaj <sip-010-token>)
    (step2-PcvSXbBlExqEQR bool)
    (dx uint)
    (jnJe1z8sXPa46T bool)
)
    (let
        (
            (z89U2vcrbMgcMz3 tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (if (is-eq jnJe1z8sXPa46T true)
            (begin (try! (stx-transfer? dx tx-sender (as-contract tx-sender))))
            (begin (try! (contract-call? step1-gSdwYJmyTzoWDD transfer dx tx-sender (as-contract tx-sender) none)))
        )
        (let
            (
                (lgOKJUDXNTYsaE (unwrap-panic (lIrZANWJdVyFpL (unwrap-panic (contract-call? step2-PwzYDAsBvcrhaj get-decimals)) step1-gSdwYJmyTzoWDD step1-WwVyVrEOHQxVXy dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (jijxzMDvfRcCZC step2-HWOztqcyfgyqxB step2-PwzYDAsBvcrhaj step2-PcvSXbBlExqEQR lgOKJUDXNTYsaE)))
            )
            (if (is-eq jnJe1z8sXPa46T true)
                (begin (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3))))
                (begin (try! (as-contract (contract-call? step1-gSdwYJmyTzoWDD transfer nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3 none))))
            )
            (asserts! (< dx nmoFJdZDqlSrMz) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (wZWrGLyILlrjrJ
    (step1-gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (step1-WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (step2-DxALcRZBPLzUJn <fMWDwheyiYXmYN>)
    (step2-BkSeCLoVnCtPlX <fMWDwheyiYXmYN>)
    (step2-qPlYaMcJXmysRu <monYErPtHrAeeD>)
    (step2-UAWqZvuqvdHDzq bool)
    (dx uint)
    (jnJe1z8sXPa46T bool)
)
    (let
        (
            (z89U2vcrbMgcMz3 tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (if (is-eq jnJe1z8sXPa46T true)
            (begin (try! (stx-transfer? dx tx-sender (as-contract tx-sender))))
            (begin (try! (contract-call? step1-gSdwYJmyTzoWDD transfer dx tx-sender (as-contract tx-sender) none)))
        )
        (let
            (
                (lgOKJUDXNTYsaE (unwrap-panic (lIrZANWJdVyFpL (unwrap-panic (contract-call? step2-BkSeCLoVnCtPlX get-decimals)) step1-gSdwYJmyTzoWDD step1-WwVyVrEOHQxVXy dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (CVsvpVOgvZZqZL step2-DxALcRZBPLzUJn step2-BkSeCLoVnCtPlX step2-qPlYaMcJXmysRu step2-UAWqZvuqvdHDzq lgOKJUDXNTYsaE)))
            )
            (if (is-eq jnJe1z8sXPa46T true)
                (begin (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3))))
                (begin (try! (as-contract (contract-call? step1-gSdwYJmyTzoWDD transfer nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3 none))))
            )
            (asserts! (< dx nmoFJdZDqlSrMz) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (ZyPMebpnWHRDUT
    (step1-HWOztqcyfgyqxB <sip-010-token>)
    (step1-PwzYDAsBvcrhaj <sip-010-token>)
    (step1-PcvSXbBlExqEQR bool)
    (step2-gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (step2-WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (dx uint)
    (jnJe1z8sXPa46T bool)
)
    (let
        (
            (z89U2vcrbMgcMz3 tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (if (is-eq jnJe1z8sXPa46T true)
            (begin (try! (stx-transfer? dx tx-sender (as-contract tx-sender))))
            (if (is-eq step1-PcvSXbBlExqEQR true)
                (begin (try! (contract-call? step1-PwzYDAsBvcrhaj transfer dx tx-sender (as-contract tx-sender) none)))
                (begin (try! (contract-call? step1-HWOztqcyfgyqxB transfer dx tx-sender (as-contract tx-sender) none)))
            )
        )
        (let
            (
                (lgOKJUDXNTYsaE (unwrap-panic (jijxzMDvfRcCZC step1-HWOztqcyfgyqxB step1-PwzYDAsBvcrhaj step1-PcvSXbBlExqEQR dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (lIrZANWJdVyFpL (unwrap-panic (contract-call? step1-HWOztqcyfgyqxB get-decimals)) step2-gSdwYJmyTzoWDD step2-WwVyVrEOHQxVXy lgOKJUDXNTYsaE)))
            )
            (if (is-eq jnJe1z8sXPa46T true)
                (begin (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3))))
                (if (is-eq step1-PcvSXbBlExqEQR true)
                    (begin (try! (as-contract (contract-call? step1-PwzYDAsBvcrhaj transfer nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3 none))))
                    (begin (try! (as-contract (contract-call? step1-HWOztqcyfgyqxB transfer nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3 none))))
                )
            )
            (asserts! (< dx nmoFJdZDqlSrMz) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (haDXMyuPLSeEzH
    (step1-HWOztqcyfgyqxB <sip-010-token>)
    (step1-PwzYDAsBvcrhaj <sip-010-token>)
    (step1-PcvSXbBlExqEQR bool)
    (step2-DxALcRZBPLzUJn <fMWDwheyiYXmYN>)
    (step2-BkSeCLoVnCtPlX <fMWDwheyiYXmYN>)
    (step2-qPlYaMcJXmysRu <monYErPtHrAeeD>)
    (step2-UAWqZvuqvdHDzq bool)
    (dx uint)
    (jnJe1z8sXPa46T bool)
)
    (let
        (
            (z89U2vcrbMgcMz3 tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (if (is-eq jnJe1z8sXPa46T true)
            (begin (try! (stx-transfer? dx tx-sender (as-contract tx-sender))))
            (if (is-eq step1-PcvSXbBlExqEQR true)
                (begin (try! (contract-call? step1-PwzYDAsBvcrhaj transfer dx tx-sender (as-contract tx-sender) none)))
                (begin (try! (contract-call? step1-HWOztqcyfgyqxB transfer dx tx-sender (as-contract tx-sender) none)))
            )
        )
        (let
            (
                (lgOKJUDXNTYsaE (unwrap-panic (jijxzMDvfRcCZC step1-HWOztqcyfgyqxB step1-PwzYDAsBvcrhaj step1-PcvSXbBlExqEQR dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (CVsvpVOgvZZqZL step2-DxALcRZBPLzUJn step2-BkSeCLoVnCtPlX step2-qPlYaMcJXmysRu step2-UAWqZvuqvdHDzq lgOKJUDXNTYsaE)))
            )
            (if (is-eq jnJe1z8sXPa46T true)
                (begin (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3))))
                (if (is-eq step1-PcvSXbBlExqEQR true)
                    (begin (try! (as-contract (contract-call? step1-PwzYDAsBvcrhaj transfer nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3 none))))
                    (begin (try! (as-contract (contract-call? step1-HWOztqcyfgyqxB transfer nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3 none))))
                )
            )
            (asserts! (< dx nmoFJdZDqlSrMz) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (AxSDVMnsiYamlC
    (step1-DxALcRZBPLzUJn <fMWDwheyiYXmYN>)
    (step1-BkSeCLoVnCtPlX <fMWDwheyiYXmYN>)
    (step1-qPlYaMcJXmysRu <monYErPtHrAeeD>)
    (step1-UAWqZvuqvdHDzq bool)
    (step2-gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (step2-WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (dx uint)
    (jnJe1z8sXPa46T bool)
)
    (let
        (
            (z89U2vcrbMgcMz3 tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (if (is-eq jnJe1z8sXPa46T true)
            (begin (try! (stx-transfer? dx tx-sender (as-contract tx-sender))))
            (if (is-eq step1-UAWqZvuqvdHDzq true)
                (begin (try! (contract-call? step1-BkSeCLoVnCtPlX transfer dx tx-sender (as-contract tx-sender) none)))
                (begin (try! (contract-call? step1-DxALcRZBPLzUJn transfer dx tx-sender (as-contract tx-sender) none)))
            )
        )
        (let
            (
                (lgOKJUDXNTYsaE (unwrap-panic (CVsvpVOgvZZqZL step1-DxALcRZBPLzUJn step1-BkSeCLoVnCtPlX step1-qPlYaMcJXmysRu step1-UAWqZvuqvdHDzq dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (lIrZANWJdVyFpL (unwrap-panic (contract-call? step1-DxALcRZBPLzUJn get-decimals)) step2-gSdwYJmyTzoWDD step2-WwVyVrEOHQxVXy lgOKJUDXNTYsaE)))
            )
            (if (is-eq jnJe1z8sXPa46T true)
                (begin (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3))))
                (if (is-eq step1-UAWqZvuqvdHDzq true)
                    (begin (try! (as-contract (contract-call? step1-BkSeCLoVnCtPlX transfer nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3 none))))
                    (begin (try! (as-contract (contract-call? step1-DxALcRZBPLzUJn transfer nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3 none))))
                )
            )
            (asserts! (< dx nmoFJdZDqlSrMz) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (VCQGoSAdvbxUQE
    (step1-DxALcRZBPLzUJn <fMWDwheyiYXmYN>)
    (step1-BkSeCLoVnCtPlX <fMWDwheyiYXmYN>)
    (step1-qPlYaMcJXmysRu <monYErPtHrAeeD>)
    (step1-UAWqZvuqvdHDzq bool)
    (step2-HWOztqcyfgyqxB <sip-010-token>)
    (step2-PwzYDAsBvcrhaj <sip-010-token>)
    (step2-PcvSXbBlExqEQR bool)
    (dx uint)
    (jnJe1z8sXPa46T bool)
)
    (let
        (
            (z89U2vcrbMgcMz3 tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (if (is-eq jnJe1z8sXPa46T true)
            (begin (try! (stx-transfer? dx tx-sender (as-contract tx-sender))))
            (if (is-eq step1-UAWqZvuqvdHDzq true)
                (begin (try! (contract-call? step1-BkSeCLoVnCtPlX transfer dx tx-sender (as-contract tx-sender) none)))
                (begin (try! (contract-call? step1-DxALcRZBPLzUJn transfer dx tx-sender (as-contract tx-sender) none)))
            )
        )
        (let
            (
                (lgOKJUDXNTYsaE (unwrap-panic (CVsvpVOgvZZqZL step1-DxALcRZBPLzUJn step1-BkSeCLoVnCtPlX step1-qPlYaMcJXmysRu step1-UAWqZvuqvdHDzq dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (jijxzMDvfRcCZC step2-HWOztqcyfgyqxB step2-PwzYDAsBvcrhaj step2-PcvSXbBlExqEQR lgOKJUDXNTYsaE)))
            )
            (if (is-eq jnJe1z8sXPa46T true)
                (begin (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3))))
                (if (is-eq step1-UAWqZvuqvdHDzq true)
                    (begin (try! (as-contract (contract-call? step1-BkSeCLoVnCtPlX transfer nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3 none))))
                    (begin (try! (as-contract (contract-call? step1-DxALcRZBPLzUJn transfer nmoFJdZDqlSrMz tx-sender z89U2vcrbMgcMz3 none))))
                )
            )
            (asserts! (< dx nmoFJdZDqlSrMz) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)
