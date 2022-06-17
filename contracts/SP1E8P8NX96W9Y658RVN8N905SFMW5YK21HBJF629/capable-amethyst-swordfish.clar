(use-trait TIOaKkHYJRWXepw 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait ghQoTHmC3jfAQ7 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait) 
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