(use-trait TIOaKkHYJRWXepw 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait ghQoTHmC3jfAQ7 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait) 
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait BzRRJiMqNRBTOFSdK 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v4c.liquidity-token-trait)


(define-constant ERR_INVALID_CALLER u111)
(define-constant ERR_NOT_AUTHORIZED u1111)
(define-constant ERR_START_AMT u4444)
(define-constant ERR_END_AMT u5555)


(define-constant ONE_6 u1000000)
(define-constant ONE_8 u100000000)
(define-constant ADMIN_PRINCIPAL tx-sender)

(define-data-var SQOQESUEmkmWIoTBZ uint u0)


(define-read-only (Six2Eight (n uint))
    (/ (* n ONE_8) ONE_6)
)

(define-read-only (Eight2Six (n uint))
    (/ (* n ONE_6) ONE_8)
)

(define-private (qaNyBCOIKDqQHcnTT
    (isSTX bool)
    (token <TIOaKkHYJRWXepw>) 
 )
    (if (is-eq isSTX true) 
        (stx-get-balance (as-contract tx-sender))
        (unwrap-panic (contract-call? token get-balance (as-contract tx-sender)))
    )
)

(define-private (gMUXJsOCSRPrUKpTQ
    (token_amt uint)
    (token_basic <TIOaKkHYJRWXepw>) 
    (token_alex <ghQoTHmC3jfAQ7>)
 )
    (/ (* token_amt (pow u10 (unwrap-panic (contract-call? token_alex get-decimals)))) (pow u10 (unwrap-panic (contract-call? token_basic get-decimals))))
)

(define-map NRYLSTRNhafCKTqJg principal bool)
(map-set NRYLSTRNhafCKTqJg tx-sender true)

(define-read-only (xQhcYBiZAyamiSayMQ (UmgoIhfJWomNRjLWT principal))
  (match (map-get? NRYLSTRNhafCKTqJg UmgoIhfJWomNRjLWT)
    value (ok true)
    (err ERR_INVALID_CALLER)
  )
)
(define-public (JFxsqyClPTjxbWaS3 (UmgoIhfJWomNRjLWT principal))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (map-set NRYLSTRNhafCKTqJg
      UmgoIhfJWomNRjLWT true
    ))
  )
)
(define-public (jTlYyeRyYpkskJWRpq (UmgoIhfJWomNRjLWT principal))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (map-delete NRYLSTRNhafCKTqJg
      UmgoIhfJWomNRjLWT
    ))
  )
)

(define-public (npNiEKpZqMiWpysLu
    (biqdMkSckelmBXREy uint)
    (HFiFyXHEHTmrmmOcl bool)
    (ouLOLHHpBLBAKmsYT bool)
    (CXWwAaHSjGJpyOHHl <ft-trait>) 
    (lFWXIWCZHyyQxjwTS <ft-trait>) 
    (neOCKrExDlzWtNOHT <TIOaKkHYJRWXepw>) 
    (KoQBDapJJAmQyRaTbT <TIOaKkHYJRWXepw>) 
    (yUCHeGXpSYLsVQrQOv <BzRRJiMqNRBTOFSdK>) 
    (AgIJzBsylJwSnXjfW uint)
    (qRXbRiatsWCtdRTfy bool)
    (jwragaWAMRRZvKUrN bool)
 )   
    
    (let 
        (
            (fWWAQpaODedaTLiAf (qaNyBCOIKDqQHcnTT qRXbRiatsWCtdRTfy neOCKrExDlzWtNOHT))
            (HyiLEyhXJyyTLTdez (qaNyBCOIKDqQHcnTT jwragaWAMRRZvKUrN KoQBDapJJAmQyRaTbT))
            (UmgoIhfJWomNRjLWT tx-sender)
        )
        (try! (xQhcYBiZAyamiSayMQ contract-caller))

        ;; transfer
        (if (is-eq qRXbRiatsWCtdRTfy true)
            (begin
                (try! (stx-transfer? AgIJzBsylJwSnXjfW tx-sender (as-contract tx-sender)))
                (var-set SQOQESUEmkmWIoTBZ (- (qaNyBCOIKDqQHcnTT qRXbRiatsWCtdRTfy neOCKrExDlzWtNOHT) fWWAQpaODedaTLiAf))
            )
            (begin 
                (try! (contract-call? neOCKrExDlzWtNOHT transfer AgIJzBsylJwSnXjfW tx-sender (as-contract tx-sender) none))
                (var-set SQOQESUEmkmWIoTBZ (- (unwrap-panic (contract-call? neOCKrExDlzWtNOHT get-balance (as-contract tx-sender))) fWWAQpaODedaTLiAf))
            )
        )
        (asserts! (>= (var-get SQOQESUEmkmWIoTBZ) AgIJzBsylJwSnXjfW) (err ERR_START_AMT))
        (if (and HFiFyXHEHTmrmmOcl true)
            (begin 
                (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y CXWwAaHSjGJpyOHHl lFWXIWCZHyyQxjwTS AgIJzBsylJwSnXjfW u0)))
            )
            (begin 
                (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x lFWXIWCZHyyQxjwTS CXWwAaHSjGJpyOHHl AgIJzBsylJwSnXjfW u0)))
            )
        )
        (let 
            (  
                (mJyWYdafcxnFpCxPC (qaNyBCOIKDqQHcnTT jwragaWAMRRZvKUrN KoQBDapJJAmQyRaTbT))
                (jsfXBfqjVEyyoppKa (- mJyWYdafcxnFpCxPC HyiLEyhXJyyTLTdez))
            ) 
            (if (and ouLOLHHpBLBAKmsYT true)
                (begin
                    (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y KoQBDapJJAmQyRaTbT neOCKrExDlzWtNOHT yUCHeGXpSYLsVQrQOv jsfXBfqjVEyyoppKa u0)))
                )
                (begin
                    (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x neOCKrExDlzWtNOHT KoQBDapJJAmQyRaTbT yUCHeGXpSYLsVQrQOv jsfXBfqjVEyyoppKa u0)))
                )
            )
            (let 
                (
                    (GWEalEXaamLCxBTfp (qaNyBCOIKDqQHcnTT qRXbRiatsWCtdRTfy neOCKrExDlzWtNOHT))
                    (VtwEBxmuunDWeQSKk (- GWEalEXaamLCxBTfp fWWAQpaODedaTLiAf))
                ) 
                (asserts! (>= VtwEBxmuunDWeQSKk (+ AgIJzBsylJwSnXjfW biqdMkSckelmBXREy)) (err ERR_END_AMT))
                
                ;; transfer
                (if (is-eq qRXbRiatsWCtdRTfy true)
                    (begin
                        (try! (as-contract (stx-transfer? VtwEBxmuunDWeQSKk  tx-sender UmgoIhfJWomNRjLWT)))
                    )
                    (begin 
                        (try! (as-contract (contract-call? neOCKrExDlzWtNOHT transfer VtwEBxmuunDWeQSKk tx-sender UmgoIhfJWomNRjLWT none)))
                    )
                )
                (ok (list fWWAQpaODedaTLiAf AgIJzBsylJwSnXjfW biqdMkSckelmBXREy GWEalEXaamLCxBTfp VtwEBxmuunDWeQSKk))
            )
        )
    )
)