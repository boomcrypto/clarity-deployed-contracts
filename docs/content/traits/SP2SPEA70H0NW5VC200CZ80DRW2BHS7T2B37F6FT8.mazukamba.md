---
title: "Trait mazukamba"
draft: true
---
```
(define-constant TOKEN_NAME "Mazukamba")
(define-constant TOKEN_SYMBOL "MAZU")
(define-constant DECIMALS u6)
(define-constant TOTAL_SUPPLY u100000000000000000) ;; 100,000,000,000 with 6 decimals
(define-constant TAX_RATE u6) ;; 6% tax
(define-constant BASIS_POINTS u100)

(define-constant DEPLOYER 'SP2SPEA70H0NW5VC200CZ80DRW2BHS7T2B37F6FT8)
(define-constant INITIAL_MARKETING_WALLET 'SP3KYAXAP8S712335K1ST7ZB1X0DRDZF4W90CDGRT)

;; Storage for balances and allowances
(define-map balances {address: principal} {balance: uint})
(define-map allowances {owner: principal, spender: principal} {amount: uint})

;; Data variables for marketing wallet and token image URL
(define-data-var marketing-wallet principal INITIAL_MARKETING_WALLET)
(define-data-var token-image-url (string-ascii 256) "https://mazukamba.com/favicon.png")
(define-data-var minted-supply uint u0)

;; SIP-010 Required Functions

;; Returns the token name
(define-read-only (name)
    (ok TOKEN_NAME)
)

;; Returns the token symbol
(define-read-only (symbol)
    (ok TOKEN_SYMBOL)
)

;; Returns the number of decimals
(define-read-only (decimals)
    (ok DECIMALS)
)

;; Returns the total supply
(define-read-only (total-supply)
    (ok TOTAL_SUPPLY)
)

;; Returns the balance of a specific address
(define-read-only (balance-of (owner principal))
    (ok (default-to u0 (get balance (map-get? balances {address: owner}))))
)

;; Mint Function (Deployer Only)
(define-public (mint (recipient principal) (amount uint))
    (begin
        ;; Ensure only the deployer can call this function
        (asserts! (is-eq tx-sender DEPLOYER) (err u100)) ;; Unauthorized
        ;; Ensure total minted supply does not exceed the total supply
        (asserts! (<= (+ (var-get minted-supply) amount) TOTAL_SUPPLY) (err u101)) ;; Exceeds total supply
        ;; Update the recipient's balance
        (map-set balances {address: recipient}
            {balance: (+ (default-to u0 (get balance (map-get? balances {address: recipient}))) amount)})
        ;; Update the minted supply
        (var-set minted-supply (+ (var-get minted-supply) amount))
        (ok true)
    )
)

;; Transfers tokens from the sender to the recipient
(define-public (transfer (recipient principal) (amount uint))
    (let (
        (sender-balance (default-to u0 (get balance (map-get? balances {address: tx-sender}))))

        (tax (/ (* amount TAX_RATE) BASIS_POINTS)) ;; 6% tax
        (net-amount (- amount tax))
    )
        (begin
            (asserts! (>= sender-balance amount) (err u102)) ;; Insufficient balance
            ;; Deduct tax and transfer to marketing wallet
            (map-set balances {address: (var-get marketing-wallet)}
                {balance: (+ (default-to u0 (get balance (map-get? balances {address: (var-get marketing-wallet)}))) tax)})
            ;; Deduct from sender
            (map-set balances {address: tx-sender} {balance: (- sender-balance amount)})
            ;; Add to recipient
            (map-set balances {address: recipient}
                {balance: (+ (default-to u0 (get balance (map-get? balances {address: recipient}))) net-amount)})
            (ok true)
        )
    )
)

;; Burn Function: Removes tokens from circulation
(define-public (burn (amount uint))
    (let (
        (sender-balance (default-to u0 (get balance (map-get? balances {address: tx-sender}))))
    )
        (begin
            ;; Ensure the sender has enough tokens to burn
            (asserts! (>= sender-balance amount) (err u104)) ;; Insufficient balance
            ;; Deduct the tokens from the sender's balance
            (map-set balances {address: tx-sender} {balance: (- sender-balance amount)})
            ;; Optionally reduce the minted supply
            ;; (var-set minted-supply (- (var-get minted-supply) amount))
            (ok true)
        )
    )
)

;; Optional Functions (Not Required by SIP-010)

;; Administrative Function to Change Token Image
(define-public (set-token-image-url (image-url (string-ascii 256)))
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) (err u103)) ;; Only deployer can update the image URL
        (var-set token-image-url image-url)
        (ok true)
    )
)

;; View Function: Get Token Image URL
(define-read-only (get-token-image-url)
    (ok (var-get token-image-url))
)
```
