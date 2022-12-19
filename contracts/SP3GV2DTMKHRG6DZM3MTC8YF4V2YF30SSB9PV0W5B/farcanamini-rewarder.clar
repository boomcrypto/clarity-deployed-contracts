
;; farcanamini-rewarder
;; <add a description here>

;; define variables
(define-constant rewarder 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.farcanamini-rewarder)
(define-data-var winner principal 'ST3GV2DTMKHRG6DZM3MTC8YF4V2YF30SSB9AEHXNX)
(define-map winners {account: principal} {rewarded: bool})
(define-data-var apikey (string-utf8 500) u"")
(define-data-var initOk bool false)
(define-data-var balance uint u0)


;; show api key(test function - should be remove for production smart contract)
(define-read-only (get-apikey)
    (var-get apikey)
)

;; setting API key to get winner's data - deprecated
(define-public (set-apikey (message (string-utf8 500)))
    (ok (var-set apikey message))
)

;; work with winners

;; read-only functions
(define-read-only (get-info)
  {balance: (var-get balance), initOk: (var-get initOk)}
)

;; private functions

;; sends the deposited amount to winner
(define-private (payout-balance)
  (unwrap-panic (as-contract (stx-transfer? (var-get balance) rewarder (var-get winner))))
)

(define-private (isRewardApproved)
  (unwrap-panic
    (if (var-get initOk)
      (err 1)
      (ok true)
    )
  )
)
;; public functions

(define-public (confirm)
    (ok (var-set initOk true))
)

(define-public (sendreward)
  (begin
    ;; update acceptance flags
    ;;(if (is-eq tx-sender rewarder)
    ;;  (begin
    ;;    (var-set initOk true)
    ;;    (ok true)
    ;;  )
    ;;)
    
    (if (var-get initOk)
      (ok (payout-balance))
      (ok true)
    )
  )
)

;; everybody can deposit money to the rewarder account
(define-public (deposit (amount uint))
  (begin
    (isRewardApproved)
    (var-set balance (+ amount (var-get balance)))
    (stx-transfer? amount tx-sender rewarder)
  )
)

;; Filling the map of winners
(define-public (addwinner (winaccount principal))
  (begin
    (var-set winner winaccount)
    (ok (map-insert winners {account: winaccount} { rewarded: false}))
  )
)