;; Implement the `ft-trait` trait defined in the `ft-trait` contract - SIP 10
;; This can use sugared syntax in real deployment (unit tests do not allow)
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)

;; STSW_TOKEN ERRORS 4220~4224
(define-constant ERR_PERMISSION_DENIED u4221)

;; Data variables specific to the deployed token contract
(define-data-var token-name (string-ascii 32) "STACKSWAP")
(define-data-var token-symbol (string-ascii 32) "STSW")
(define-data-var token-decimals uint u6)

;; Track who deployed the token and whether it has been initialized
(define-data-var deployer-principal principal 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275)
(define-data-var is-initialized bool false)

;; Meta Read Only Functions for reading details about the contract - conforms to SIP 10
;; --------------------------------------------------------------------------

;; Defines built in support functions for tokens used in this contract
;; A second optional parameter can be added here to set an upper limit on max total-supply
(define-fungible-token stsw)

;; Get the token balance of the specified owner in base units
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance stsw owner)))

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
  (ok (ft-get-supply stsw)))


;; Write function to transfer tokens between accounts - conforms to SIP 10
;; --------------------------------------------------------------------------

;; Transfers tokens to a recipient
;; The originator of the transaction (tx-sender) must be the 'sender' principal
;; Smart contracts can move tokens from their own address by calling transfer with the 'as-contract' modifier to override the tx-sender.

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR_PERMISSION_DENIED))
    (try! (ft-transfer? stsw amount from to))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

;; Token URI
;; --------------------------------------------------------------------------

;; Variable for URI storage
(define-data-var uri (string-utf8 256) u"https://app.stackswap.org/token/stsw.json")

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


;; Initialization
;; --------------------------------------------------------------------------
   
(ft-mint? stsw u1000000000000000 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275)

