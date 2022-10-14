;; abc-token

;; constants
;; The address for contract owner who deployed this contract.
(define-constant contract-owner tx-sender)
;; Errors
(define-constant ERR_CONTRACT_OWNER_ONLY u0)
(define-constant ERR_USER_ALREADY_REGISTERED u1)
(define-constant ERR_USER_NOT_REGISTERED u2)
(define-constant ERR_TOKEN_OWNER_ONLY u3)
(define-constant ERR_BTC_BLOCK_NOT_MINTED u4)

(define-map minted-block-info
    {block: uint}
    {
        btc-address: (buff 40),
        btc-amount: uint,
        abc-amount: uint
    }
)

(define-map minted-abc-by-user
    {btc-address: (buff 40)}
    {total-minted-abc: uint} 
)

;; URI for ABC token
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://abc/abc.json"))

;; SIP-010 DEFINITION
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token abc)
;; SIP-010 FUNCTIONS
;; Transfer from the caller to a new principal
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR_TOKEN_OWNER_ONLY))
    (try! (ft-transfer? abc amount from to))
    (match memo to-print (print to-print) 0x)
    (ok true)    
  )
)

;; the human readable name of the token
(define-read-only (get-name)
  (ok "ABCV3")
)

;; the ticker symbol, or empty if none
(define-read-only (get-symbol)
  (ok "ABC")
)

;; the number of decimals used, e.g. 8 would mean 100_000_000 represents 1 token
;; TSBC uses 8, which is the same as Bitcoin
(define-read-only (get-decimals)
  (ok u8)
)

;; the balance of the passed principal
(define-read-only (get-balance (user principal))
  (ok (ft-get-balance abc user))
)

;; the current total supply (which does not need to be a constant)
(define-read-only (get-total-supply)
  (ok (ft-get-supply abc))
)

;; an optional URI that represents metadata of this token
(define-read-only (get-token-uri)
  (ok (var-get token-uri))
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
(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-sender-contract-owner) (err ERR_CONTRACT_OWNER_ONLY))
    (ok (var-set token-uri new-uri))
  )
)

;; Mints new tokens, only accessible by contract owner.
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-caller-contract-owner) (err ERR_CONTRACT_OWNER_ONLY))
    (ft-mint? abc amount recipient)
  )
)

;; Registers a new BTC address and initialize its total minted abc.
(define-public (regist-abc-user (btc-address (buff 40)))
  (begin
    (asserts! (is-caller-contract-owner) (err ERR_CONTRACT_OWNER_ONLY))
    (asserts! (is-eq (map-get? minted-abc-by-user {btc-address: btc-address}) none) (err ERR_USER_ALREADY_REGISTERED))
    (map-insert minted-abc-by-user {btc-address: btc-address} {total-minted-abc: u0})
    (ok true)
  )
)

;; Mints new tokens and record data, only accessible by contract owner.
;; The recipient should already be registered.
(define-public (mint-and-record (amount uint) (recipient principal) (btc-block uint) (btc-address (buff 40)))
  (begin
    (asserts! (is-caller-contract-owner) (err ERR_CONTRACT_OWNER_ONLY))
    (asserts! (not (is-eq (map-get? minted-abc-by-user {btc-address: btc-address}) none)) (err ERR_USER_NOT_REGISTERED))
    (try! (ft-mint? abc amount recipient))
    (map-set minted-block-info {block: btc-block} {btc-address: btc-address, btc-amount: amount, abc-amount: amount})
    (let ((current-btc 
      (get total-minted-abc (unwrap! (map-get? minted-abc-by-user {btc-address: btc-address}) (err ERR_USER_NOT_REGISTERED)))))
      (map-set minted-abc-by-user {btc-address: btc-address} {total-minted-abc: (+ current-btc amount)})                    
    )
    (ok true)
  )
)

;; Get the amount of minted by user's BTC address
(define-read-only (get-minted-abc-by-user (btc-address (buff 40)))
  (ok (get total-minted-abc (unwrap! (map-get? minted-abc-by-user {btc-address: btc-address}) (err ERR_USER_NOT_REGISTERED))))
)

;; Get the block info for a minted BTC block
(define-read-only (get-minted-block-info (btc-block uint))
  (ok (unwrap! (map-get? minted-block-info {block: btc-block}) (err ERR_BTC_BLOCK_NOT_MINTED)))
)