(use-trait crIpAPiuSDrgnkMMaRO 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait ghoTHmCjfAwtoxHbuco 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)
(use-trait bpyKLNDOHricyZlNpjv 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait BzRRJiMqNRBrrFSdK 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v4c.liquidity-token-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant ERR_INVALID_CALLER u111)
(define-constant ERR_NOT_AUTHORIZED u1111)
(define-constant ERR_START_AMT u4444)
(define-constant ERR_END_AMT u5555)


(define-constant ONE_6 u1000000)
(define-constant ONE_8 u100000000)
(define-constant ADMIN_PRINCIPAL tx-sender)

(define-data-var SQOQESUEmkmWIoTBZ uint u0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (Six2Eight (n uint))
    (/ (* n ONE_8) ONE_6)
)

(define-read-only (Eight2Six (n uint))
    (/ (* n ONE_6) ONE_8)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (mzGLlZSVDKYSrFhwS
    (isSTX bool)
    (token <crIpAPiuSDrgnkMMaRO>) 
 )
    (if (is-eq isSTX true) 
        (stx-get-balance (as-contract tx-sender))
        (unwrap-panic (contract-call? token get-balance (as-contract tx-sender)))
    )
)

(define-private (YZqqARQDvfWyifiKx
    (isSTX bool)
    (token <bpyKLNDOHricyZlNpjv>) 
 )
    (if (is-eq isSTX true) 
        (stx-get-balance (as-contract tx-sender))
        (unwrap-panic (contract-call? token get-balance (as-contract tx-sender)))
    )
)

(define-private (gMUXJsOCSRPrUKpTQ
    (n uint)
    (b uint) 
    (a uint)
 )
    (/ (* n (pow u10 a)) (pow u10 b))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-map fqGdJqOPSNqGvqdFGcNKD principal bool)
(map-set fqGdJqOPSNqGvqdFGcNKD tx-sender true)

(define-read-only (xQhcYBiZAyamiSayMQ (user principal))
  (match (map-get? fqGdJqOPSNqGvqdFGcNKD user)
    value (ok true)
    (err ERR_INVALID_CALLER)
  )
)
(define-public (JFxsqyClPTjxbWaSd (user principal))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (map-set fqGdJqOPSNqGvqdFGcNKD
      user true
    ))
  )
)
(define-public (jTlYyeRyYpkskJWRpq (user principal))
  (begin
    (asserts! (is-eq contract-caller ADMIN_PRINCIPAL) (err ERR_INVALID_CALLER))
    (ok (map-delete fqGdJqOPSNqGvqdFGcNKD
      user
    ))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (veglBlOCbjzQBRrbV
    (biqdMkSckelmBXREy uint)
    (HFeFyXHEHTmrmmOcl bool)
    (ouLOLHHpBLBAKmsYT bool)
    (VPAxBGMKpQWTjRMnu <ghoTHmCjfAwtoxHbuco>) 
    (kwrDL3XesfmiRhRVA <ghoTHmCjfAwtoxHbuco>) 
    (neOCKrExDlzWtNOHT <crIpAPiuSDrgnkMMaRO>) 
    (KoQBDapJJAmQyRaTbT <crIpAPiuSDrgnkMMaRO>) 
    (yUCHeGXpSYLsVQrQOv <BzRRJiMqNRBrrFSdK>) 
    (AgIJzBsylJwSnXjfW uint)
    (qRXbRiatsWCtdRTfy bool)
    (jwragaWAMRRZvKUrN bool)
 )   
    
    (let 
        (
            (fWWAQpaODedaTLiAf (mzGLlZSVDKYSrFhwS qRXbRiatsWCtdRTfy neOCKrExDlzWtNOHT))
            (HyiLEyhXJyyTLTdez (mzGLlZSVDKYSrFhwS jwragaWAMRRZvKUrN KoQBDapJJAmQyRaTbT))
            (user tx-sender)
        )
        (try! (xQhcYBiZAyamiSayMQ contract-caller))

        ;; transfer
        (if (is-eq qRXbRiatsWCtdRTfy true)
            (begin
                (try! (stx-transfer? AgIJzBsylJwSnXjfW tx-sender (as-contract tx-sender)))
            )
            (begin 
                (try! (contract-call? neOCKrExDlzWtNOHT transfer AgIJzBsylJwSnXjfW tx-sender (as-contract tx-sender) none))
            )
        )
        (var-set SQOQESUEmkmWIoTBZ (- (mzGLlZSVDKYSrFhwS qRXbRiatsWCtdRTfy neOCKrExDlzWtNOHT) fWWAQpaODedaTLiAf))
        (asserts! (>= (var-get SQOQESUEmkmWIoTBZ) AgIJzBsylJwSnXjfW) (err ERR_START_AMT))

        (try! (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper VPAxBGMKpQWTjRMnu kwrDL3XesfmiRhRVA (gMUXJsOCSRPrUKpTQ AgIJzBsylJwSnXjfW (unwrap-panic (contract-call? neOCKrExDlzWtNOHT get-decimals)) (unwrap-panic (contract-call? VPAxBGMKpQWTjRMnu get-decimals))) none)))

        (let 
            (  
                (mJyWYdafcxnFpCxPC (mzGLlZSVDKYSrFhwS jwragaWAMRRZvKUrN KoQBDapJJAmQyRaTbT))
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
                    (GWEalEXaamLCxBTfp (mzGLlZSVDKYSrFhwS qRXbRiatsWCtdRTfy neOCKrExDlzWtNOHT))
                    (VtwEBxmuunDWeQSKk (- GWEalEXaamLCxBTfp fWWAQpaODedaTLiAf))
                ) 
                (asserts! (>= VtwEBxmuunDWeQSKk (+ AgIJzBsylJwSnXjfW biqdMkSckelmBXREy)) (err ERR_END_AMT))
                
                ;; transfer
                (if (is-eq qRXbRiatsWCtdRTfy true)
                    (begin
                        (try! (as-contract (stx-transfer? VtwEBxmuunDWeQSKk  tx-sender user)))
                    )
                    (begin 
                        (try! (as-contract (contract-call? neOCKrExDlzWtNOHT transfer VtwEBxmuunDWeQSKk tx-sender user none)))
                    )
                )
                
                (ok (list fWWAQpaODedaTLiAf AgIJzBsylJwSnXjfW biqdMkSckelmBXREy GWEalEXaamLCxBTfp VtwEBxmuunDWeQSKk))
            )
        )
    
    )
)

(define-public (rcvneHFXhAhddGYiy
    (biqdMkSckelmBXREy uint)
    (HFeFyXHEHTmrmmOcl bool)
    (ouLOLHHpBLBAKmsYT bool)
    (VPAxBGMKpQWTjRMnu <ghoTHmCjfAwtoxHbuco>) 
    (kwrDL3XesfmiRhRVA <ghoTHmCjfAwtoxHbuco>) 
    (neOCKrExDlzWtNOHT <crIpAPiuSDrgnkMMaRO>) 
    (KoQBDapJJAmQyRaTbT <crIpAPiuSDrgnkMMaRO>) 
    (yUCHeGXpSYLsVQrQOv <BzRRJiMqNRBrrFSdK>) 
    (AgIJzBsylJwSnXjfW uint)
    (qRXbRiatsWCtdRTfy bool)
    (jwragaWAMRRZvKUrN bool)
 )   
    (let 
        (
            (fWWAQpaODedaTLiAf (mzGLlZSVDKYSrFhwS qRXbRiatsWCtdRTfy neOCKrExDlzWtNOHT))
            (HyiLEyhXJyyTLTdez (mzGLlZSVDKYSrFhwS jwragaWAMRRZvKUrN KoQBDapJJAmQyRaTbT))
            (user tx-sender)
        )
        (try! (xQhcYBiZAyamiSayMQ contract-caller))
        
        ;; transfer
        (if (is-eq qRXbRiatsWCtdRTfy true)
            (begin
                (try! (stx-transfer? AgIJzBsylJwSnXjfW tx-sender (as-contract tx-sender)))
            )
            (begin 
                (try! (contract-call? neOCKrExDlzWtNOHT transfer AgIJzBsylJwSnXjfW tx-sender (as-contract tx-sender) none))
            )
        )
        (var-set SQOQESUEmkmWIoTBZ (- (mzGLlZSVDKYSrFhwS qRXbRiatsWCtdRTfy neOCKrExDlzWtNOHT) fWWAQpaODedaTLiAf))
        (asserts! (>= (var-get SQOQESUEmkmWIoTBZ) AgIJzBsylJwSnXjfW) (err ERR_START_AMT))

        (if (and HFeFyXHEHTmrmmOcl true)
            (begin
                (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y neOCKrExDlzWtNOHT KoQBDapJJAmQyRaTbT yUCHeGXpSYLsVQrQOv AgIJzBsylJwSnXjfW u0)))
            )
            (begin
                (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x KoQBDapJJAmQyRaTbT neOCKrExDlzWtNOHT yUCHeGXpSYLsVQrQOv AgIJzBsylJwSnXjfW u0)))
            )
        )
        (let 
            (  
                (mJyWYdafcxnFpCxPC (mzGLlZSVDKYSrFhwS jwragaWAMRRZvKUrN KoQBDapJJAmQyRaTbT))
                (jsfXBfqjVEyyoppKa (- mJyWYdafcxnFpCxPC HyiLEyhXJyyTLTdez))
            ) 

            (try! (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper kwrDL3XesfmiRhRVA VPAxBGMKpQWTjRMnu (gMUXJsOCSRPrUKpTQ jsfXBfqjVEyyoppKa (unwrap-panic (contract-call? KoQBDapJJAmQyRaTbT get-decimals)) (unwrap-panic (contract-call? kwrDL3XesfmiRhRVA get-decimals))) none)))

            (let 
                (
                    (GWEalEXaamLCxBTfp (mzGLlZSVDKYSrFhwS qRXbRiatsWCtdRTfy neOCKrExDlzWtNOHT))
                    (VtwEBxmuunDWeQSKk (- GWEalEXaamLCxBTfp fWWAQpaODedaTLiAf))
                ) 
                (asserts! (>= VtwEBxmuunDWeQSKk (+ AgIJzBsylJwSnXjfW biqdMkSckelmBXREy)) (err ERR_END_AMT))

                ;; transfer
                (if (is-eq qRXbRiatsWCtdRTfy true)
                    (begin
                        (try! (as-contract (stx-transfer? VtwEBxmuunDWeQSKk  tx-sender user)))
                    )
                    (begin 
                        (try! (as-contract (contract-call? neOCKrExDlzWtNOHT transfer VtwEBxmuunDWeQSKk tx-sender user none)))
                    )
                )
                (ok (list fWWAQpaODedaTLiAf AgIJzBsylJwSnXjfW biqdMkSckelmBXREy GWEalEXaamLCxBTfp VtwEBxmuunDWeQSKk))
            )
        )
    )
)

(define-public (UYmovvIBsPvVynCjA
    (biqdMkSckelmBXREy uint)
    (HFeFyXHEHTmrmmOcl bool)
    (ouLOLHHpBLBAKmsYT bool)
    (VPAxBGMKpQWTjRMnu <ghoTHmCjfAwtoxHbuco>) 
    (kwrDL3XesfmiRhRVA <ghoTHmCjfAwtoxHbuco>) 
    (CXWwAaHSjGJpyOHHl <bpyKLNDOHricyZlNpjv>) 
    (lFWXIWCZHyyQxjwTS <bpyKLNDOHricyZlNpjv>) 
    (AgIJzBsylJwSnXjfW uint)
    (qRXbRiatsWCtdRTfy bool)
    (jwragaWAMRRZvKUrN bool)
 )   
    
    (let 
        (
            (fWWAQpaODedaTLiAf (YZqqARQDvfWyifiKx qRXbRiatsWCtdRTfy CXWwAaHSjGJpyOHHl))
            (HyiLEyhXJyyTLTdez (YZqqARQDvfWyifiKx jwragaWAMRRZvKUrN lFWXIWCZHyyQxjwTS))
            (user tx-sender)
        )
        (try! (xQhcYBiZAyamiSayMQ contract-caller))

        ;; transfer
        (if (is-eq qRXbRiatsWCtdRTfy true)
            (begin
                (try! (stx-transfer? AgIJzBsylJwSnXjfW tx-sender (as-contract tx-sender)))
            )
            (begin 
                (try! (contract-call? CXWwAaHSjGJpyOHHl transfer AgIJzBsylJwSnXjfW tx-sender (as-contract tx-sender) none))
            )
        )
        (var-set SQOQESUEmkmWIoTBZ (- (YZqqARQDvfWyifiKx qRXbRiatsWCtdRTfy CXWwAaHSjGJpyOHHl) fWWAQpaODedaTLiAf))
        (asserts! (>= (var-get SQOQESUEmkmWIoTBZ) AgIJzBsylJwSnXjfW) (err ERR_START_AMT))

        (try! (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper VPAxBGMKpQWTjRMnu kwrDL3XesfmiRhRVA (gMUXJsOCSRPrUKpTQ AgIJzBsylJwSnXjfW (unwrap-panic (contract-call? CXWwAaHSjGJpyOHHl get-decimals)) (unwrap-panic (contract-call? VPAxBGMKpQWTjRMnu get-decimals))) none)))

        (let 
            (  
                (mJyWYdafcxnFpCxPC (YZqqARQDvfWyifiKx jwragaWAMRRZvKUrN lFWXIWCZHyyQxjwTS))
                (jsfXBfqjVEyyoppKa (- mJyWYdafcxnFpCxPC HyiLEyhXJyyTLTdez))
            ) 
            (if (and ouLOLHHpBLBAKmsYT true)
                (begin
                    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y lFWXIWCZHyyQxjwTS CXWwAaHSjGJpyOHHl jsfXBfqjVEyyoppKa u0)))
                )
                (begin
                    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x CXWwAaHSjGJpyOHHl lFWXIWCZHyyQxjwTS jsfXBfqjVEyyoppKa u0)))

                )
            )
            (let 
                (
                    (GWEalEXaamLCxBTfp (YZqqARQDvfWyifiKx qRXbRiatsWCtdRTfy CXWwAaHSjGJpyOHHl))
                    (VtwEBxmuunDWeQSKk (- GWEalEXaamLCxBTfp fWWAQpaODedaTLiAf))
                ) 
                (asserts! (>= VtwEBxmuunDWeQSKk (+ AgIJzBsylJwSnXjfW biqdMkSckelmBXREy)) (err ERR_END_AMT))

                ;; transfer
                (if (is-eq qRXbRiatsWCtdRTfy true)
                    (begin
                        (try! (as-contract (stx-transfer? VtwEBxmuunDWeQSKk  tx-sender user)))
                    )
                    (begin 
                        (try! (as-contract (contract-call? CXWwAaHSjGJpyOHHl transfer VtwEBxmuunDWeQSKk tx-sender user none)))
                    )
                )
                (ok (list fWWAQpaODedaTLiAf AgIJzBsylJwSnXjfW biqdMkSckelmBXREy GWEalEXaamLCxBTfp VtwEBxmuunDWeQSKk))
            )
        )
    
    )
)

(define-public (iaPHuHfycQo0DPZBz
    (biqdMkSckelmBXREy uint)
    (HFeFyXHEHTmrmmOcl bool)
    (ouLOLHHpBLBAKmsYT bool)
    (VPAxBGMKpQWTjRMnu <ghoTHmCjfAwtoxHbuco>) 
    (kwrDL3XesfmiRhRVA <ghoTHmCjfAwtoxHbuco>) 
    (CXWwAaHSjGJpyOHHl <bpyKLNDOHricyZlNpjv>) 
    (lFWXIWCZHyyQxjwTS <bpyKLNDOHricyZlNpjv>) 
    (AgIJzBsylJwSnXjfW uint)
    (qRXbRiatsWCtdRTfy bool)
    (jwragaWAMRRZvKUrN bool)
 )   
    (let 
        (
            (fWWAQpaODedaTLiAf (YZqqARQDvfWyifiKx qRXbRiatsWCtdRTfy CXWwAaHSjGJpyOHHl))
            (HyiLEyhXJyyTLTdez (YZqqARQDvfWyifiKx jwragaWAMRRZvKUrN lFWXIWCZHyyQxjwTS))
            (user tx-sender)
        )
        (try! (xQhcYBiZAyamiSayMQ contract-caller))

        ;; transfer
        (if (is-eq qRXbRiatsWCtdRTfy true)
            (begin
                (try! (stx-transfer? AgIJzBsylJwSnXjfW tx-sender (as-contract tx-sender)))
            )
            (begin 
                (try! (contract-call? CXWwAaHSjGJpyOHHl transfer AgIJzBsylJwSnXjfW tx-sender (as-contract tx-sender) none))
            )
        )
        (var-set SQOQESUEmkmWIoTBZ (- (YZqqARQDvfWyifiKx qRXbRiatsWCtdRTfy CXWwAaHSjGJpyOHHl) fWWAQpaODedaTLiAf))
        (asserts! (>= (var-get SQOQESUEmkmWIoTBZ) AgIJzBsylJwSnXjfW) (err ERR_START_AMT))

        (if (and HFeFyXHEHTmrmmOcl true)
            (begin
                (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y CXWwAaHSjGJpyOHHl lFWXIWCZHyyQxjwTS AgIJzBsylJwSnXjfW u0)))
            )
            (begin
                (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x lFWXIWCZHyyQxjwTS CXWwAaHSjGJpyOHHl AgIJzBsylJwSnXjfW u0)))
            )
        )
        (let 
            (  
                (mJyWYdafcxnFpCxPC (YZqqARQDvfWyifiKx jwragaWAMRRZvKUrN lFWXIWCZHyyQxjwTS))
                (jsfXBfqjVEyyoppKa (- mJyWYdafcxnFpCxPC HyiLEyhXJyyTLTdez))
            ) 

            (try! (as-contract (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper kwrDL3XesfmiRhRVA VPAxBGMKpQWTjRMnu (gMUXJsOCSRPrUKpTQ jsfXBfqjVEyyoppKa (unwrap-panic (contract-call? lFWXIWCZHyyQxjwTS get-decimals)) (unwrap-panic (contract-call? kwrDL3XesfmiRhRVA get-decimals))) none)))

            (let 
                (
                    (GWEalEXaamLCxBTfp (YZqqARQDvfWyifiKx qRXbRiatsWCtdRTfy CXWwAaHSjGJpyOHHl))
                    (VtwEBxmuunDWeQSKk (- GWEalEXaamLCxBTfp fWWAQpaODedaTLiAf))
                ) 
                (asserts! (>= VtwEBxmuunDWeQSKk (+ AgIJzBsylJwSnXjfW biqdMkSckelmBXREy)) (err ERR_END_AMT))

                ;; transfer
                (if (is-eq qRXbRiatsWCtdRTfy true)
                    (begin
                        (try! (as-contract (stx-transfer? VtwEBxmuunDWeQSKk  tx-sender user)))
                    )
                    (begin 
                        (try! (as-contract (contract-call? CXWwAaHSjGJpyOHHl transfer VtwEBxmuunDWeQSKk tx-sender user none)))
                    )
                )
                (ok (list fWWAQpaODedaTLiAf AgIJzBsylJwSnXjfW biqdMkSckelmBXREy GWEalEXaamLCxBTfp VtwEBxmuunDWeQSKk))
            )
        )
    )
)