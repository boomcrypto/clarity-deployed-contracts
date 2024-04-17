
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


;; Mazutest_TOKEN CONSTANTS
;;

;; Mazutest_TOKEN ERRORS 4220~4224
(define-constant ERR_PERMISSION_DENIED u4221)

;; Mazutest_TOKEN ERRORS 2000~2002
;;
(define-constant ERR_UNAUTHORIZED u2000)
(define-constant ERR_TOKEN_NOT_ACTIVATED u2001)
(define-constant ERR_TOKEN_ALREADY_ACTIVATED u2002)

;; Mazutest_TOKEN ERRORS 1000~1003
;;
(define-constant ERR_FAILED_TO_TRANSFER_TO_MARKETING_WALLET (err u1000))
(define-constant ERR_FAILED_TO_TRANSFER_TO_LIQUIDITY_WALLET (err u1001))
(define-constant ERR_FAILED_TO_BURN u1002)
(define-constant ERR_FAILED_TO_TRANSFER u1003)



;; TAX WALLETS
;;
(define-constant MARKETING_WALLET 'SP3KYAXAP8S712335K1ST7ZB1X0DRDZF4W90CDGRT)
(define-constant LIQUIDITY_WALLET 'SP1CNDJV6MMXYSER1BEYRN7TMFYZZ07BPN8NQZWFD)


;; Data variables specific to the deployed token contract
(define-data-var token-name (string-ascii 32) "MAZUTEST")
(define-data-var token-symbol (string-ascii 32) "MAZT")
(define-data-var token-decimals uint u6)

;; Track who deployed the token and whether it has been initialized
(define-data-var deployer-principal principal 'SP2SPEA70H0NW5VC200CZ80DRW2BHS7T2B37F6FT8)
(define-data-var is-initialized bool false)


;; Meta Read Only Functions for reading details about the contract - conforms to SIP 10
;; --------------------------------------------------------------------------

;; Defines built in support functions for tokens used in this contract
;; A second optional parameter can be added here to set an upper limit on max total-supply
(define-fungible-token Mazutest u100000000000000000)

;; Get the token balance of the specified owner in base units
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance Mazutest owner)))

;; Returns the token name
(define-read-only (get-name)
  (ok (var-get token-name)))

;; Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

;; Returns the number of decimals used
(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

;; Returns the total number of tokens that currently exist
(define-read-only (get-total-supply)
  (ok (ft-get-supply Mazutest)))


;;--------------------------------------------------------------------------

;;
;; private tax function

(define-private (tax (amount uint))
  (let
    (
      (totalToTax (* amount u1))
      (burnAmount (/ totalToTax u100))
      (marketingAmount (/ totalToTax u100))
      (liquidityAmount (/ totalToTax u50))
    )
    (begin
    (try! (ft-burn? Mazutest burnAmount tx-sender))
    (asserts! (unwrap-panic (ft-transfer? Mazutest marketingAmount tx-sender MARKETING_WALLET)) ERR_FAILED_TO_TRANSFER_TO_MARKETING_WALLET)
    (asserts! (unwrap-panic (ft-transfer? Mazutest liquidityAmount tx-sender LIQUIDITY_WALLET)) ERR_FAILED_TO_TRANSFER_TO_LIQUIDITY_WALLET)
    (ok true)
    )
  )
)

;; --------------------------------------------------------------------------

;; Write function to transfer tokens between accounts - conforms to SIP 10
;; --------------------------------------------------------------------------

;; Transfers tokens to a recipient
;; The originator of the transaction (tx-sender) must be the 'sender' principal
;; Smart contracts can move tokens from their own address by calling transfer with the 'as-contract' modifier to override the tx-sender.

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin 
    (try! (tax amount))
    (asserts! (is-eq from tx-sender) (err ERR_PERMISSION_DENIED))
    (try! (ft-transfer? Mazutest amount from to))
    (ok true))
  )


;; Token URI
;; --------------------------------------------------------------------------

;; Variable for URI storage
(define-data-var uri (string-utf8 256) u"https://mazukamba.com/assets/metadata.json")

;; Public getter for the URI
(define-read-only (get-token-uri)
  (ok (some (var-get uri))))

;; Setter for the URI - only the owner can set it
(define-public (set-token-uri (updated-uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get deployer-principal)) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-uri", updated-uri: updated-uri })
    (ok (var-set uri updated-uri))))

;;---------------------------
;; burns tokens from the specified account

(define-public (burn-tokens (burn-amount uint) (burn-from principal) )
  (begin
    ;; Print the action for any off chain watchers
    (print { action: "burn-tokens", burn-amount: burn-amount, burn-from : burn-from  })
    (ft-burn? Mazutest burn-amount burn-from)))

;; Initialization
;; --------------------------------------------------------------------------
   
(ft-mint? Mazutest u100000000000000000 'SP2SPEA70H0NW5VC200CZ80DRW2BHS7T2B37F6FT8)