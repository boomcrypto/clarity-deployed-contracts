(define-constant CONTRACT-OWNER tx-sender)

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

(define-public (claim-two)
    (mint (list true true))
)

(define-public (claim-three)
    (mint (list true true true))
)

(define-public (claim-four)
    (mint (list true true true true))
)

(define-public (claim-five)
    (mint (list true true true true true))
)

(define-public (claim-six)
    (mint (list true true true true true true))
)

(define-public (claim-seven)
    (mint (list true true true true true true true))
)

(define-public (claim-eight)
    (mint (list true true true true true true true true))
)

(define-public (claim-nine)
    (mint (list true true true true true true true true true))
)

(define-public (claim-ten)
    (mint (list true true true true true true true true true true))
)

(define-public (claim-mia)
    (mint-in-mia (list true))
)

(define-public (claim-mia-two)
    (mint-in-mia (list true true))
)

(define-public (claim-mia-three)
    (mint-in-mia (list true true true))
)

(define-public (claim-mia-four)
    (mint-in-mia (list true true true true))
)

(define-public (claim-mia-five)
    (mint-in-mia (list true true true true true))
)

(define-public (claim-mia-six)
    (mint-in-mia (list true true true true true true))
)

(define-public (claim-mia-seven)
    (mint-in-mia (list true true true true true true true))
)

(define-public (claim-mia-eight)
    (mint-in-mia (list true true true true true true true true))
)

(define-public (claim-mia-nine)
    (mint-in-mia (list true true true true true true true true true))
)

(define-public (claim-mia-ten)
    (mint-in-mia (list true true true true true true true true true true))
)

(define-public (claim-nyc)
    (mint-in-nyc (list true))
)

(define-public (claim-nyc-two)
    (mint-in-nyc (list true true))
)

(define-public (claim-nyc-three)
    (mint-in-nyc (list true true true))
)

(define-public (claim-nyc-four)
    (mint-in-nyc (list true true true true))
)

(define-public (claim-nyc-five)
    (mint-in-nyc (list true true true true true))
)

(define-public (claim-nyc-six)
    (mint-in-nyc (list true true true true true true))
)

(define-public (claim-nyc-seven)
    (mint-in-nyc (list true true true true true true true))
)

(define-public (claim-nyc-eight)
    (mint-in-nyc (list true true true true true true true true))
)

(define-public (claim-nyc-nine)
    (mint-in-nyc (list true true true true true true true true true))
)

(define-public (claim-nyc-ten)
    (mint-in-nyc (list true true true true true true true true true true))
)

(define-private (mint (orders (list 10 bool)))
    (let (
            (passes (get-passes tx-sender))
        )
        (if (var-get premint-enabled)
            (begin
                (asserts! (>= passes (len orders)) (err ERR_NOT_ENOUGH_PASSES))
                (map-set mint-passes tx-sender (- passes (len orders)))
                (contract-call? .uninterested-brown-catshark mint orders "stx")
            )
            (begin
                (asserts! (var-get sale-enabled) (err ERR_PUBLIC_SALE_DISABLED))
                (contract-call? .uninterested-brown-catshark mint orders "stx")
            )
        )
    )
)

(define-private (mint-in-mia (orders (list 10 bool)))
    (let (
            (passes (get-passes tx-sender))
        )
        (if (var-get premint-enabled)
            (begin
                (asserts! (>= passes (len orders)) (err ERR_NOT_ENOUGH_PASSES))
                (map-set mint-passes tx-sender (- passes (len orders)))
                (contract-call? .uninterested-brown-catshark mint orders "mia")
            )
            (begin
                (asserts! (var-get sale-enabled) (err ERR_PUBLIC_SALE_DISABLED))
                (contract-call? .uninterested-brown-catshark mint orders "mia")
            )
        )
    )
)

(define-private (mint-in-nyc (orders (list 10 bool)))
    (let (
            (passes (get-passes tx-sender))
        )
        (if (var-get premint-enabled)
            (begin
                (asserts! (>= passes (len orders)) (err ERR_NOT_ENOUGH_PASSES))
                (map-set mint-passes tx-sender (- passes (len orders)))
                (contract-call? .uninterested-brown-catshark mint orders "nyc")
            )
            (begin
                (asserts! (var-get sale-enabled) (err ERR_PUBLIC_SALE_DISABLED))
                (contract-call? .uninterested-brown-catshark mint orders "nyc")
            )
        )
    )
)

(define-public (toggle-sale-state)
    (let (
        (premint (not (var-get premint-enabled)))
        (sale (not (var-get sale-enabled)))
        )
        (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR_UNAUTHORIZED))
        (var-set premint-enabled premint)
        (var-set sale-enabled sale)
        (print  { premint: premint, sale: sale })
        (ok true)
    )
)

(define-public (init)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR_UNAUTHORIZED))
        (ok (var-set premint-enabled true))
    )
)

(define-read-only (get-passes (caller principal))
    (default-to u0 (map-get? mint-passes caller))
)

(contract-call? .uninterested-brown-catshark set-mint-addr (as-contract tx-sender))

(map-set mint-passes 'SP3ZJP253DENMN3CQFEQSPZWY7DK35EH3SEH0J8PK u10)
(map-set mint-passes 'SPJ6EME4DQ8242ZDR56VAVB7R9PAY0ZBV1640EQX u10)
(map-set mint-passes 'SP3S21WY0A8YQK9MSHVW4E4YYTSE696MSHKR6YTAN u10)
(map-set mint-passes 'SP3GDV2YWE3E4CGZK4NYM2YASZ82G8E4AC7C9CFQT u10)
(map-set mint-passes 'SP2WQQG79CYFP29WV8V1KF8SNAKZVCRXY0J7G3HE9 u10)
(map-set mint-passes 'SP1PHVM3NZYRGJWANWY7G61YMQFATS2B6ZM09NKM2 u10)
(map-set mint-passes 'SP6AEPBKR5D56ZXJBTNMJTFPYD04654XY3QRF969 u10)
(map-set mint-passes 'SP3BAFMN5YMG021BDWS8JMW8WY8ASKHYJQAD489KB u10)
(map-set mint-passes 'SP17XBHF35ZTWB0RT7G7EP1C3W01HKZ5WN73NTB4Q u10)