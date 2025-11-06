;; @contract stSTXbtc token
;; @version 2
;;

(impl-trait .sip-010-trait-ft-standard.sip-010-trait)

;; Defines the Stacked STX BTC token according to the SIP010 Standard
(define-fungible-token ststxbtc)

(define-constant ERR_NOT_AUTHORIZED u1401)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var token-uri (string-utf8 256) u"https://app.stackingdao.com/ststxbtc-token.json")

;;-------------------------------------
;; SIP-010 
;;-------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply ststxbtc))
)

(define-read-only (get-name)
  (ok "Stacked STX BTC Token")
)

(define-read-only (get-symbol)
  (ok "stSTXbtc")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance ststxbtc account))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR_NOT_AUTHORIZED))
    (try! (ft-transfer? ststxbtc amount sender recipient))

    (try! (contract-call? .ststxbtc-tracking-v2 refresh-wallet sender (ft-get-balance ststxbtc sender)))
    (try! (contract-call? .ststxbtc-tracking-v2 refresh-wallet recipient (ft-get-balance ststxbtc recipient)))

    (print memo)
    (print { action: "transfer", data: { sender: tx-sender, recipient: recipient, amount: amount, block-height: block-height } })

    (ok true)
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (ok (var-set token-uri value))
  )
)

;;-------------------------------------
;; Mint / Burn
;;-------------------------------------

;; Mint method
(define-public (mint-for-protocol (amount uint) (recipient principal))
  (let (
    (result (ft-mint? ststxbtc amount recipient))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (try! (contract-call? .ststxbtc-tracking-data-v2 set-total-supply (ft-get-supply ststxbtc)))
    (try! (contract-call? .ststxbtc-tracking-v2 refresh-wallet recipient (ft-get-balance ststxbtc recipient)))
    result
  )
)

;; Burn method
(define-public (burn-for-protocol (amount uint) (sender principal))
  (let (
    (result (ft-burn? ststxbtc amount sender))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (try! (contract-call? .ststxbtc-tracking-data-v2 set-total-supply (ft-get-supply ststxbtc)))
    (try! (contract-call? .ststxbtc-tracking-v2 refresh-wallet sender (ft-get-balance ststxbtc sender)))
    result
  )
)

;; Burn external
(define-public (burn (amount uint))
  (let (
    (result (ft-burn? ststxbtc amount tx-sender))
  )
    (try! (contract-call? .ststxbtc-tracking-data-v2 set-total-supply (ft-get-supply ststxbtc)))
    (try! (contract-call? .ststxbtc-tracking-v2 refresh-wallet tx-sender (ft-get-balance ststxbtc tx-sender)))
    result
  )
)
