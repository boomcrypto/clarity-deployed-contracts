;; sbc-token
;; Sustainable Bitcoin Certificate Token Definitions and Utilities

;; constants
;; The address for contract owner who deployed this contract.
(define-constant contract-owner tx-sender)
;; Errors
(define-constant ERR_CONTRACT_OWNER_ONLY u0)
(define-constant ERR_USER_ALREADY_REGISTERED u1)
(define-constant ERR_USER_NOT_REGISTERED u2)
(define-constant ERR_TOKEN_OWNER_ONLY u3)

;; data maps and vars
;; A map from a minted Bitcoin block to its owner address and Bitcoin amount.
(define-map minted-block-info
    {block: uint}
    {
        btc-address: (buff 40),
        btc-amount: uint,
        sbc-amount: uint
    }
)

;; A map from a Bitcoin address to the total sbc it has minted.
;; Only registered users are recorded.
(define-map minted-sbc-by-user
    {btc-address: (buff 40)}
    {total-minted-sbc: uint} 
)

;; URI for SBC token
(define-data-var token-uri (string-utf8 256) u"https://sbp-public.s3.amazonaws.com/json/sbc.json")

;; SIP-010 DEFINITION
;; (impl-trait .sip010-ft-trait.sip010-ft-trait)
;; Update to this definition when deploy on the mainnet
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token sbc)
;; SIP-010 FUNCTIONS
;; Transfer from the caller to a new principal
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR_TOKEN_OWNER_ONLY))
    (try! (ft-transfer? sbc amount from to))
    (match memo to-print (print to-print) 0x)
    (ok true)    
  )
)

;; the human readable name of the token
(define-read-only (get-name)
  (ok "Sustainable Bitcoin Certificate")
)

;; the ticker symbol, or empty if none
(define-read-only (get-symbol)
  (ok "SBC")
)

;; the number of decimals used, e.g. 8 would mean 100_000_000 represents 1 token
;; SBC uses 8, which is the same as Bitcoin
(define-read-only (get-decimals)
  (ok u8)
)

;; the balance of the passed principal
(define-read-only (get-balance (user principal))
  (ok (ft-get-balance sbc user))
)

;; the current total supply (which does not need to be a constant)
(define-read-only (get-total-supply)
  (ok (ft-get-supply sbc))
)

;; an optional URI that represents metadata of this token
(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

;; UTILITIES
;; Checks if caller is contract owner
(define-private (is-caller-contract-owner)
   (is-eq contract-caller contract-owner)
)

;; Checks if sender is contract owner
(define-private (is-sender-contract-owner)
   (is-eq tx-sender contract-owner)
)

;; Sets token URI to new value, only accessible by Auth
(define-public (set-token-uri (new-uri (string-utf8 256)))
  (begin
    (asserts! (is-sender-contract-owner) (err ERR_CONTRACT_OWNER_ONLY))
    (ok (var-set token-uri new-uri))
  )
)

;; Mints new tokens, only accessible by contract owner.
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-caller-contract-owner) (err ERR_CONTRACT_OWNER_ONLY))
    (ft-mint? sbc amount recipient)
  )
)

;; Registers a new BTC address and initialize its total minted sbc.
(define-public (regist-sbc-user (btc-address (buff 40)))
  (begin
    (asserts! (is-caller-contract-owner) (err ERR_CONTRACT_OWNER_ONLY))
    (asserts! (is-eq (map-get? minted-sbc-by-user {btc-address: btc-address}) none) (err ERR_USER_ALREADY_REGISTERED))
    (map-insert minted-sbc-by-user {btc-address: btc-address} {total-minted-sbc: u0})
    (ok true)
  )
)

;; Mints new tokens and record data, only accessible by contract owner.
;; The recipient should already be registered.
(define-public (mint-and-record (amount uint) (recipient principal) (btc-block uint) (btc-address (buff 40)))
  (begin
    (asserts! (is-caller-contract-owner) (err ERR_CONTRACT_OWNER_ONLY))
    (asserts! (not (is-eq (map-get? minted-sbc-by-user {btc-address: btc-address}) none)) (err ERR_USER_NOT_REGISTERED))
    (try! (ft-mint? sbc amount recipient))
    (map-set minted-block-info {block: btc-block} {btc-address: btc-address, btc-amount: amount, sbc-amount: amount})
    (let ((current-btc 
      (get total-minted-sbc (unwrap! (map-get? minted-sbc-by-user {btc-address: btc-address}) (err ERR_USER_NOT_REGISTERED)))))
      (map-set minted-sbc-by-user {btc-address: btc-address} {total-minted-sbc: (+ current-btc amount)})                    
    )
    (ok true)
  )
)

;; SEND-MANY

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err
    (map send-token recipients)
    (ok true)
  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)
  )
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let
    (
      (transferOk (try! (transfer amount tx-sender to memo)))
    )
    (ok transferOk)
  )
)