(define-constant CONTRACT-OWNER tx-sender)

(define-constant ERR_NOT_ENOUGH_PASSES u300)
(define-constant ERR_PUBLIC_SALE_DISABLED u301)
(define-constant ERR_CONTRACT_INITIALIZED u302)

(define-constant ERR_UNAUTHORIZED u302)

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

(define-private (mint (orders (list 10 bool)))
    (begin
        (asserts! (var-get sale-enabled) (err ERR_PUBLIC_SALE_DISABLED))
        (contract-call? .stacks-parrots-3d mint orders)
    )
)

(define-public (toggle-sale-state)
    (let (
        (sale (not (var-get sale-enabled)))
        )
        (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR_UNAUTHORIZED))
        (var-set sale-enabled sale)
        (ok true)
    )
)

(contract-call? .stacks-parrots-3d set-mint-addr (as-contract tx-sender) tx-sender)