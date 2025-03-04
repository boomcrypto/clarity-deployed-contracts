;; Token Contract for KryptoMind Token (KRYPT)

(define-fungible-token krypt-token)

;; Define contract owner
(define-constant contract-owner tx-sender)

;; Error constants
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-invalid-amount (err u102))

;; Metadata
(define-data-var token-name (string-ascii 32) "KryptoMind Token")
(define-data-var token-symbol (string-ascii 10) "KRYPT")
(define-data-var token-decimals uint u18)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://kryptomind.io/token-metadata"))

;; Token minting cap
(define-constant total-supply u1000000000000000000000) ;; 1 billion tokens with 18 decimals

;; Get token name
(define-read-only (get-name)
  (ok (var-get token-name))
)

;; Get token symbol
(define-read-only (get-symbol)
  (ok (var-get token-symbol))
)

;; Get token decimals
(define-read-only (get-decimals)
  (ok (var-get token-decimals))
)

;; Get token URI
(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; Get total supply
(define-read-only (get-total-supply)
  (ok total-supply)
)

;; Get token balance
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance krypt-token account))
)

;; Transfer tokens
(define-public (transfer 
  (amount uint) 
  (sender principal) 
  (recipient principal)
  (memo (optional (buff 256)))
)
  (begin
    ;; Check if sender has sufficient balance
    (try! (ft-transfer? krypt-token amount sender recipient))
    
    ;; Optional: Log transfer with memo if provided
    (match memo
      some-memo 
        (begin 
          (print {
            type: "token-transfer", 
            sender: sender, 
            recipient: recipient, 
            amount: amount, 
            memo: some-memo
          })
          (ok true)
        )
        (begin
          (print {
            type: "token-transfer", 
            sender: sender, 
            recipient: recipient, 
            amount: amount
          })
          (ok true)
        )
    )
  )
)

;; Mint tokens (only by contract owner)
(define-public (mint (amount uint) (recipient principal))
  (begin
    ;; Ensure only contract owner can mint
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    
    ;; Validate mint amount
    (asserts! (> amount u0) err-invalid-amount)
    
    ;; Mint tokens
    (try! (ft-mint? krypt-token amount recipient))
    
    (print {type: "token-mint", recipient: recipient, amount: amount})
    (ok true)
  )
)

;; Burn tokens
(define-public (burn (amount uint))
  (begin
    ;; Ensure sufficient balance
    (asserts! (>= (ft-get-balance krypt-token tx-sender) amount) err-insufficient-balance)
    
    ;; Burn tokens
    (try! (ft-burn? krypt-token amount tx-sender))
    
    (print {type: "token-burn", sender: tx-sender, amount: amount})
    (ok true)
  )
)

;; Permit mechanism for gasless transfers
(define-map allowances 
  {owner: principal, spender: principal} 
  {amount: uint}
)

;; Approve spending allowance
(define-public (approve (spender principal) (amount uint))
  (begin
    (map-set allowances {owner: tx-sender, spender: spender} {amount: amount})
    (print {type: "token-approval", owner: tx-sender, spender: spender, amount: amount})
    (ok true)
  )
)

;; Transfer from approved allowance
(define-public (transfer-from (owner principal) (recipient principal) (amount uint))
  (let 
    ((current-allowance (default-to {amount: u0} (map-get? allowances {owner: owner, spender: tx-sender}))))
    
    ;; Check allowance
    (asserts! (>= (get amount current-allowance) amount) err-insufficient-balance)
    
    ;; Transfer tokens
    (try! (ft-transfer? krypt-token amount owner recipient))
    
    ;; Update allowance
    (map-set allowances 
      {owner: owner, spender: tx-sender} 
      {amount: (- (get amount current-allowance) amount)}
    )
    
    (print {
      type: "token-transfer-from", 
      owner: owner, 
      recipient: recipient, 
      spender: tx-sender, 
      amount: amount
    })
    
    (ok true)
  )
)

;; Initialize contract
(begin
  ;; Mint initial supply to contract owner
  (ft-mint? krypt-token total-supply contract-owner)
)