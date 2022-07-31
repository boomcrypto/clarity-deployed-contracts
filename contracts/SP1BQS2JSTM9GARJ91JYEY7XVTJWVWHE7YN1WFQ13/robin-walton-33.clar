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
(define-constant ERR-SWAP-CRYPTOMATE-FAILED u7772)
(define-constant ERR-SWAP-STACKSWAP-FAILED u7773)
(define-constant ERR-BALANCE-LOWER u7774)

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
            (alex-token-decimal (unwrap-panic (contract-call? gSdwYJmyTzoWDD get-decimals)))
            (lgOKJUDXNTYsaE (unwrap! (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper gSdwYJmyTzoWDD WwVyVrEOHQxVXy (gqyGnZJgEuDTGv dx ejKQclDkhPafKm alex-token-decimal) none)) (err ERR-SWAP-ALEX-FAILED)))
            (lgOKJUDXNTYsaE-converted (gqyGnZJgEuDTGv lgOKJUDXNTYsaE alex-token-decimal ejKQclDkhPafKm))
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
            (swapped-amounts (if PcvSXbBlExqEQR
                (unwrap! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x HWOztqcyfgyqxB PwzYDAsBvcrhaj dx u0)) (err ERR-SWAP-ARKADIKO-FAILED))
                (unwrap! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y HWOztqcyfgyqxB PwzYDAsBvcrhaj dx u0)) (err ERR-SWAP-ARKADIKO-FAILED))
            ))
            (lgOKJUDXNTYsaE (if PcvSXbBlExqEQR
                (unwrap-panic (element-at swapped-amounts u0))
                (unwrap-panic (element-at swapped-amounts u1))
            ))
        )
        (ok lgOKJUDXNTYsaE)
    )
)

(define-private (cROekNbvCdEEBh
    (YPGwfXTpnGgNsx <sip-010-token>)
    (askpQperGOEINH <sip-010-token>)
    (RzKOjmAPkyevSw <liquidity-token>)
    (EHnckTQOiALgaw bool)
    (dx uint)
 )
    (let
        (
            (swapped-amounts (if EHnckTQOiALgaw
                (unwrap! (as-contract (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-y-for-x YPGwfXTpnGgNsx askpQperGOEINH RzKOjmAPkyevSw dx u0)) (err ERR-SWAP-CRYPTOMATE-FAILED))
                (unwrap! (as-contract (contract-call? 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap swap-x-for-y YPGwfXTpnGgNsx askpQperGOEINH RzKOjmAPkyevSw dx u0)) (err ERR-SWAP-CRYPTOMATE-FAILED))
            ))
            (lgOKJUDXNTYsaE (if EHnckTQOiALgaw
                (unwrap-panic (element-at swapped-amounts u0))
                (unwrap-panic (element-at swapped-amounts u1))
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
            (swapped-amounts (if UAWqZvuqvdHDzq
                (unwrap! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x DxALcRZBPLzUJn BkSeCLoVnCtPlX qPlYaMcJXmysRu dx u0)) (err ERR-SWAP-STACKSWAP-FAILED))
                (unwrap! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y DxALcRZBPLzUJn BkSeCLoVnCtPlX qPlYaMcJXmysRu dx u0)) (err ERR-SWAP-STACKSWAP-FAILED))
            ))
            (lgOKJUDXNTYsaE (if UAWqZvuqvdHDzq
                (unwrap-panic (element-at swapped-amounts u0))
                (unwrap-panic (element-at swapped-amounts u1))
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
    (gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (HWOztqcyfgyqxB <sip-010-token>)
    (PwzYDAsBvcrhaj <sip-010-token>)
    (PcvSXbBlExqEQR bool)
    (dx uint)
    (jnJe1z8sXPa46T bool)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (if (is-eq jnJe1z8sXPa46T true)
            (begin (try! (stx-transfer? dx tx-sender (as-contract tx-sender))))
            (begin (try! (contract-call? gSdwYJmyTzoWDD transfer dx tx-sender (as-contract tx-sender) none)))
        )
        (let
            (
                (lgOKJUDXNTYsaE (unwrap-panic (lIrZANWJdVyFpL (unwrap-panic (contract-call? HWOztqcyfgyqxB get-decimals)) gSdwYJmyTzoWDD WwVyVrEOHQxVXy dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (jijxzMDvfRcCZC HWOztqcyfgyqxB PwzYDAsBvcrhaj PcvSXbBlExqEQR lgOKJUDXNTYsaE)))
            )
            (if (is-eq jnJe1z8sXPa46T true)
                (begin (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender save-tx-sender))))
                (begin (try! (as-contract (contract-call? gSdwYJmyTzoWDD transfer nmoFJdZDqlSrMz tx-sender save-tx-sender none))))
            )
            (asserts! (< dx nmoFJdZDqlSrMz) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (HvAkvycJfuJMKN
    (gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (YPGwfXTpnGgNsx <sip-010-token>)
    (askpQperGOEINH <sip-010-token>)
    (RzKOjmAPkyevSw <liquidity-token>)
    (EHnckTQOiALgaw bool)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (lgOKJUDXNTYsaE (unwrap-panic (lIrZANWJdVyFpL (unwrap-panic (contract-call? YPGwfXTpnGgNsx get-decimals)) gSdwYJmyTzoWDD WwVyVrEOHQxVXy dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (cROekNbvCdEEBh YPGwfXTpnGgNsx askpQperGOEINH RzKOjmAPkyevSw EHnckTQOiALgaw lgOKJUDXNTYsaE)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, lgOKJUDXNTYsaE: lgOKJUDXNTYsaE, nmoFJdZDqlSrMz: nmoFJdZDqlSrMz })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (wZWrGLyILlrjrJ
    (gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (DxALcRZBPLzUJn <fMWDwheyiYXmYN>)
    (BkSeCLoVnCtPlX <fMWDwheyiYXmYN>)
    (qPlYaMcJXmysRu <monYErPtHrAeeD>)
    (UAWqZvuqvdHDzq bool)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (lgOKJUDXNTYsaE (unwrap-panic (lIrZANWJdVyFpL (unwrap-panic (contract-call? DxALcRZBPLzUJn get-decimals)) gSdwYJmyTzoWDD WwVyVrEOHQxVXy dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (CVsvpVOgvZZqZL DxALcRZBPLzUJn BkSeCLoVnCtPlX qPlYaMcJXmysRu UAWqZvuqvdHDzq lgOKJUDXNTYsaE)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, lgOKJUDXNTYsaE: lgOKJUDXNTYsaE, nmoFJdZDqlSrMz: nmoFJdZDqlSrMz })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (ZyPMebpnWHRDUT
    (HWOztqcyfgyqxB <sip-010-token>)
    (PwzYDAsBvcrhaj <sip-010-token>)
    (PcvSXbBlExqEQR bool)
    (gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (lgOKJUDXNTYsaE (unwrap-panic (jijxzMDvfRcCZC HWOztqcyfgyqxB PwzYDAsBvcrhaj PcvSXbBlExqEQR dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (lIrZANWJdVyFpL (unwrap-panic (contract-call? PwzYDAsBvcrhaj get-decimals)) gSdwYJmyTzoWDD WwVyVrEOHQxVXy lgOKJUDXNTYsaE)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, lgOKJUDXNTYsaE: lgOKJUDXNTYsaE, nmoFJdZDqlSrMz: nmoFJdZDqlSrMz })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (haDXMyuPLSeEzH
    (HWOztqcyfgyqxB <sip-010-token>)
    (PwzYDAsBvcrhaj <sip-010-token>)
    (PcvSXbBlExqEQR bool)
    (DxALcRZBPLzUJn <fMWDwheyiYXmYN>)
    (BkSeCLoVnCtPlX <fMWDwheyiYXmYN>)
    (qPlYaMcJXmysRu <monYErPtHrAeeD>)
    (UAWqZvuqvdHDzq bool)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (lgOKJUDXNTYsaE (unwrap-panic (jijxzMDvfRcCZC HWOztqcyfgyqxB PwzYDAsBvcrhaj PcvSXbBlExqEQR dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (CVsvpVOgvZZqZL DxALcRZBPLzUJn BkSeCLoVnCtPlX qPlYaMcJXmysRu UAWqZvuqvdHDzq lgOKJUDXNTYsaE)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, lgOKJUDXNTYsaE: lgOKJUDXNTYsaE, nmoFJdZDqlSrMz: nmoFJdZDqlSrMz })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (FhuapZwmwXBMRC
    (YPGwfXTpnGgNsx <sip-010-token>)
    (askpQperGOEINH <sip-010-token>)
    (RzKOjmAPkyevSw <liquidity-token>)
    (EHnckTQOiALgaw bool)
    (gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (lgOKJUDXNTYsaE (unwrap-panic (cROekNbvCdEEBh YPGwfXTpnGgNsx askpQperGOEINH RzKOjmAPkyevSw EHnckTQOiALgaw dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (lIrZANWJdVyFpL (unwrap-panic (contract-call? askpQperGOEINH get-decimals)) gSdwYJmyTzoWDD WwVyVrEOHQxVXy lgOKJUDXNTYsaE)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, lgOKJUDXNTYsaE: lgOKJUDXNTYsaE, nmoFJdZDqlSrMz: nmoFJdZDqlSrMz })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (oJlhZJPzehhyvS
    (YPGwfXTpnGgNsx <sip-010-token>)
    (askpQperGOEINH <sip-010-token>)
    (RzKOjmAPkyevSw <liquidity-token>)
    (EHnckTQOiALgaw bool)
    (DxALcRZBPLzUJn <fMWDwheyiYXmYN>)
    (BkSeCLoVnCtPlX <fMWDwheyiYXmYN>)
    (qPlYaMcJXmysRu <monYErPtHrAeeD>)
    (UAWqZvuqvdHDzq bool)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (lgOKJUDXNTYsaE (unwrap-panic (cROekNbvCdEEBh YPGwfXTpnGgNsx askpQperGOEINH RzKOjmAPkyevSw EHnckTQOiALgaw dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (CVsvpVOgvZZqZL DxALcRZBPLzUJn BkSeCLoVnCtPlX qPlYaMcJXmysRu UAWqZvuqvdHDzq lgOKJUDXNTYsaE)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, lgOKJUDXNTYsaE: lgOKJUDXNTYsaE, nmoFJdZDqlSrMz: nmoFJdZDqlSrMz })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (AxSDVMnsiYamlC
    (DxALcRZBPLzUJn <fMWDwheyiYXmYN>)
    (BkSeCLoVnCtPlX <fMWDwheyiYXmYN>)
    (qPlYaMcJXmysRu <monYErPtHrAeeD>)
    (UAWqZvuqvdHDzq bool)
    (gSdwYJmyTzoWDD <NcEfqXWqwCGSVR>)
    (WwVyVrEOHQxVXy <NcEfqXWqwCGSVR>)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (lgOKJUDXNTYsaE (unwrap-panic (CVsvpVOgvZZqZL DxALcRZBPLzUJn BkSeCLoVnCtPlX qPlYaMcJXmysRu UAWqZvuqvdHDzq dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (lIrZANWJdVyFpL (unwrap-panic (contract-call? BkSeCLoVnCtPlX get-decimals)) gSdwYJmyTzoWDD WwVyVrEOHQxVXy lgOKJUDXNTYsaE)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, lgOKJUDXNTYsaE: lgOKJUDXNTYsaE, nmoFJdZDqlSrMz: nmoFJdZDqlSrMz })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (VCQGoSAdvbxUQE
    (DxALcRZBPLzUJn <fMWDwheyiYXmYN>)
    (BkSeCLoVnCtPlX <fMWDwheyiYXmYN>)
    (qPlYaMcJXmysRu <monYErPtHrAeeD>)
    (UAWqZvuqvdHDzq bool)
    (HWOztqcyfgyqxB <sip-010-token>)
    (PwzYDAsBvcrhaj <sip-010-token>)
    (PcvSXbBlExqEQR bool)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (lgOKJUDXNTYsaE (unwrap-panic (CVsvpVOgvZZqZL DxALcRZBPLzUJn BkSeCLoVnCtPlX qPlYaMcJXmysRu UAWqZvuqvdHDzq dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (jijxzMDvfRcCZC HWOztqcyfgyqxB PwzYDAsBvcrhaj PcvSXbBlExqEQR lgOKJUDXNTYsaE)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, lgOKJUDXNTYsaE: lgOKJUDXNTYsaE, nmoFJdZDqlSrMz: nmoFJdZDqlSrMz })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)

(define-public (MANSixHBZedErm
    (DxALcRZBPLzUJn <fMWDwheyiYXmYN>)
    (BkSeCLoVnCtPlX <fMWDwheyiYXmYN>)
    (qPlYaMcJXmysRu <monYErPtHrAeeD>)
    (UAWqZvuqvdHDzq bool)
    (YPGwfXTpnGgNsx <sip-010-token>)
    (askpQperGOEINH <sip-010-token>)
    (RzKOjmAPkyevSw <liquidity-token>)
    (EHnckTQOiALgaw bool)
    (dx uint)
)
    (let
        (
            (save-tx-sender tx-sender)
        )
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
        (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
        (let
            (
                (balance-before (stx-get-balance (as-contract tx-sender)))
                (lgOKJUDXNTYsaE (unwrap-panic (CVsvpVOgvZZqZL DxALcRZBPLzUJn BkSeCLoVnCtPlX qPlYaMcJXmysRu UAWqZvuqvdHDzq dx)))
                (nmoFJdZDqlSrMz (unwrap-panic (cROekNbvCdEEBh YPGwfXTpnGgNsx askpQperGOEINH RzKOjmAPkyevSw EHnckTQOiALgaw lgOKJUDXNTYsaE)))
                (balance-after (stx-get-balance (as-contract tx-sender)))
            )
            (try! (as-contract (stx-transfer? nmoFJdZDqlSrMz tx-sender save-tx-sender)))
            (print { message: "swap", balance-before: balance-before, balance-after: balance-after, dx: dx, lgOKJUDXNTYsaE: lgOKJUDXNTYsaE, nmoFJdZDqlSrMz: nmoFJdZDqlSrMz })
            (asserts! (< balance-before balance-after) (err ERR-BALANCE-LOWER))
            (ok nmoFJdZDqlSrMz)
        )
    )
)