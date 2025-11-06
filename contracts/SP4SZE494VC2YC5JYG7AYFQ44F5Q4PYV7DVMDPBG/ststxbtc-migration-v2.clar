;; @contract stSTXbtc Migration
;; @version 1
;;
;; Migrates stSTXbtc tokens from v1 to v2

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_UNSUPPORTED_POSITION u10401)

;;-------------------------------------
;; Migration
;;-------------------------------------

(define-public (migrate-ststxbtc (addresses (list 200 principal)))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (ok (map migrate-address addresses))
  )
)

(define-private (migrate-address (address principal))
  (let (
    (balance (unwrap-panic (contract-call? .ststxbtc-token get-balance address)))
    (supported-position (contract-call? .ststxbtc-tracking-data get-supported-positions address))
  )
    ;; (asserts! (not (get active supported-position)) (err ERR_UNSUPPORTED_POSITION))
    (if (> balance u0)
      (begin
        (try! (contract-call? .ststxbtc-token burn-for-protocol balance address))
        (try! (contract-call? .ststxbtc-token-v2 mint-for-protocol balance address))
        (ok true)
      )
      (ok true)
    )
  )
)

(define-public (migrate-self)
  (let (
    (balance (unwrap-panic (contract-call? .ststxbtc-token get-balance contract-caller)))
  )
    (if (> balance u0)
      (begin
        (try! (contract-call? .ststxbtc-token burn-for-protocol balance contract-caller))
        (try! (contract-call? .ststxbtc-token-v2 mint-for-protocol balance contract-caller))
        (ok true)
      )
      (ok true)
    )
  )
)
