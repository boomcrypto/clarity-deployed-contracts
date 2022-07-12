(define-fungible-token vibes-token)
(define-constant E-UNAUTH u101) ;; UN-AUTHORIZED
(define-constant E-IS u103) ;; INVALID SPENDER
(define-constant E-ZV u104) ;; ZERO VALUE
(define-constant E-NEAB u105) ;; NOT ENOUGH APPROVED BALANCE

;; Storage
(define-data-var contract-owner principal tx-sender)
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var total-supply uint u0)
(define-map allowances {spender: principal, owner: principal} uint)
(impl-trait .sip-010-trait.sip-010-trait)


(define-read-only (get-name)
    (ok "HireVibes"))

(define-read-only (get-symbol)
    (ok "VIBES"))

(define-read-only (get-decimals)
    (ok u8))

(define-read-only (get-total-supply)
    (ok (ft-get-supply vibes-token)))

(define-read-only (get-balance (owner principal))
    (ok (get-balance-of owner)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

(define-read-only (get-contract-owner)
    (ok (var-get contract-owner))
)

;; PRIVATE FUNCTIONS

;; check if the tx sender is the owner
(define-private (is-owner)
    (let 
        ((owner (var-get contract-owner)))
        (is-eq owner tx-sender)
    )
)

(define-private (get-allowance-of (owner principal) (spender principal))
    (default-to u0
        (map-get? allowances {spender: spender, owner: owner})))



;; Update-Allowance
(define-private (update-allowance (amount uint) (owner principal) (spender principal))
    (map-set allowances {spender: spender, owner: owner} amount)
)
;; Get Balance

(define-private (get-balance-of (owner principal))
    (ft-get-balance vibes-token owner)
)

;; PUBLIC FUNCTIONS
(define-public (set-owner (new-owner principal))
    (begin
        (asserts! (is-owner) (err E-UNAUTH))
        (ok (var-set contract-owner new-owner))
    )
)

(define-public (donate (amount uint)) 
    (let
        ((owner (var-get contract-owner)))
        (stx-transfer? amount tx-sender owner)
    )
)

(define-public (allowance-of (owner principal) (spender principal) )
    (ok (get-allowance-of owner spender))
)
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq sender tx-sender) (err E-UNAUTH))
        (ft-transfer? vibes-token amount sender recipient)
    )
)

(define-public (transfer-from (amount uint) (owner principal) (spender principal) (recipient principal) )
    (begin
        (asserts! (is-eq tx-sender spender) (err E-UNAUTH))
        (let 
            ((allowance (get-allowance-of owner spender)))
            (asserts! (>= allowance amount) (err E-NEAB))
            (update-allowance (- allowance amount) owner spender)
        )
        (ft-transfer? vibes-token amount owner recipient)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-owner) (err E-UNAUTH))
        (ok (var-set token-uri (some value)))
    )
)

(define-public (burn (amount uint) (sender principal))
    (begin 
         (asserts! (is-eq tx-sender sender) (err E-UNAUTH))
         (ft-burn? vibes-token amount sender)
    )
)

;; approve
(define-public (approve (amount uint) (owner principal) (spender principal))
    (begin 
        (asserts! (is-eq tx-sender owner) (err E-IS))
        (update-allowance amount owner spender)
        (ok true)
    )
)

;; mint
(define-private (mint (amount uint) (recipient principal))
    (begin 
        (asserts! ( > amount u0) (err E-ZV))
        (var-set total-supply (+ (var-get total-supply) amount))
        (ft-mint? vibes-token amount recipient)
    )
)

(mint u35000000000000000 tx-sender)