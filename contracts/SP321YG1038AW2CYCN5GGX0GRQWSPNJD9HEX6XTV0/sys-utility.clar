;;
;; ======
;; TRAITS
;; ======
;;
(impl-trait .sip-010-trait-approve.sip-010-trait-approve)

;;
;; =================
;; TOKEN DEFINITIONS  
;; =================
;; 
(define-fungible-token greenso)

;;
;; =========
;; CONSTANTS
;; =========
;;
(define-constant token-name "Greenso")
(define-constant token-symbol "GRNS")

(define-constant err-invalid-number (err u9000))

;;
;; =========
;; DATA VARS
;; =========
;;
(define-data-var token-uri (optional (string-utf8 256)) none)

(define-map allowances { owner: principal, spender: principal } uint)

;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;

(define-public (mint (recipient principal) (amount uint))
    (let (
          (is-internal (contract-call? .sys-investor is-active recipient))
          )
      (try! (contract-call? .sys-admin assert-invoked-by-operator))
      (asserts! (> amount u0) err-invalid-number)
      (try! (ft-mint? greenso amount recipient))
      (ok amount)
      )
  )

(define-public (set-token-uri (uri (optional (string-utf8 256))))
    (begin
     (try! (contract-call? .sys-admin assert-invoked-by-operator))
     (ok (var-set token-uri uri))))


(define-public (burn (amount uint))
    (ft-burn? greenso amount tx-sender)
  )



;; sip10 trait
;; -----------

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (if (is-eq tx-sender sender)
      (try! (ft-transfer? greenso amount sender recipient))
      (begin
        (try! (spend-allowance sender tx-sender amount))
        (try! (ft-transfer? greenso amount sender recipient))
      )
    )
    (print memo)
    (ok true)
  )
  
)

(define-read-only (get-name)
    (ok token-name))

(define-read-only (get-symbol)
    (ok token-symbol))

(define-read-only (get-decimals)
    (ok u0))

(define-read-only (get-balance (account principal))
    (ok (ft-get-balance greenso  account)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply greenso)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))


;; approve

(define-private (spend-allowance (owner principal) (spender principal) (amount uint))
  (let ( (amount-allowed (unwrap-panic (allowance tx-sender spender))) )
    (asserts! (>= amount-allowed amount) (err u5))
    (ok (approve_ owner spender (- amount-allowed amount)))
  )
)

(define-private (approve_ (owner principal) (spender principal) (amount uint))
  (map-set allowances { owner: tx-sender, spender: spender } amount)
)

(define-public (increase-allowance (spender principal) (amount uint))
  (let ( (amount-allowed (unwrap-panic (allowance tx-sender spender))) )
    (ok (approve_ tx-sender spender (+ amount-allowed amount)) )
  )
)

(define-public (decrease-allowance (spender principal) (amount uint))
  (let ( (amount-allowed (unwrap-panic (allowance tx-sender spender))) )
    (asserts! (>= amount-allowed amount) (err u3))
    (ok (approve_ tx-sender spender (- amount-allowed amount)) )
  )
)

(define-public (allowance (owner principal) (spender principal))
  (ok (default-to u0 (map-get? allowances { owner: owner, spender: spender })))
)

(define-public (approve (spender principal) (amount uint))
  (ok (approve_ tx-sender spender amount))
)

;; end of sip-10 implementation
