;; "The world is full of foolish gamblers and they will not do as well as the patient investors." Charlie Munger
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


;; Errors 
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMETERS u403)
(define-constant ERR-NOT-ENOUGH-FUND u101)
;; HODL to the moon
(define-fungible-token HODL)
;; Initialize function to mint max supply to owner
;; $HOLD TGE / Total 100B
(begin
  (try! (ft-mint? HODL u200000000000000000 tx-sender)) 
)
;; Define the owner address
(define-data-var owner-address principal tx-sender) 
(define-data-var treasury-address principal 'SPHNNSBV7Q29CJ0KCEGVGT5N3G9S7Z99KGGSMFW2)
(define-data-var dev-wallet-address principal 'SP1EY26NDX3FFDS868DVVYR018RK4462BM8BNTWE3)

(define-data-var tax_off bool false)



;; Tax %
(define-data-var total-tax uint u10)
;; Fee % base on tax amount
(define-data-var treasury-fee uint u40)
(define-data-var burn-fee uint u40)
(define-data-var dev-fee uint u20)

;; Whitelist to bypass tax - use for exchange wallet
(define-map whitelist
  { address: principal }
  { is-whitelisted: bool }
)


;; Transfer function with tax deduction and redistribution including whitelist
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (let ((is-whitelisted (default-to false (get is-whitelisted (map-get? whitelist { address: sender })))))
  ;; If sender is whitelisted or tax is off, perform transfer without tax
    (if (or is-whitelisted (var-get tax_off)) 
      (match (ft-transfer? HODL amount sender recipient)
        success (ok success)
        transfer-error (err transfer-error))
  ;; If sender is not whitelisted and tax is on, apply tax
      (let ((tax-amount (/ (* amount (var-get total-tax)) u100))
            (transfer-amount (- amount tax-amount)))
        (asserts! (>= amount tax-amount) (err ERR-NOT-ENOUGH-FUND)) ;; Ensure enough funds for tax deduction
        (asserts! (is-eq sender tx-sender) (err ERR-UNAUTHORIZED))
        (match (ft-transfer? HODL transfer-amount sender recipient)
          success
            ;; Handle taxes and check for errors
            (match (distribute-taxes tax-amount sender)
              taxes-distributed (ok success) ;; Return success if taxes are distributed without error
              tax-error (err tax-error)) ;; Return the error from distribute-taxes
          transfer-error (err transfer-error))))))


;; Helper function to distribute taxes
(define-private (distribute-taxes (tax-amount uint) (sender principal))
  (let (
         (treasury-tax (/ (* tax-amount (var-get treasury-fee)) u100))
        (burn-tax (/ (* tax-amount (var-get burn-fee)) u100))
        (dev-tax (/ (* tax-amount (var-get dev-fee)) u100))
        
        )
    (match (ft-transfer? HODL treasury-tax sender (var-get treasury-address))
      treasury-success
        (match (ft-burn? HODL burn-tax sender ) 
          burn-success
            (match (ft-transfer? HODL dev-tax sender (var-get dev-wallet-address))
              dev-success (ok true)
              dev-error (err dev-error))
          burn-error (err burn-error))
      treasury-error (err treasury-error))))

;; --------- send-many function
(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  ;; Assert that only the owner can call this function
  (begin
    (asserts! (is-eq tx-sender (var-get owner-address))
              (err u401))  ;; u401 can be replaced with a more descriptive error code or message

    ;; Process each recipient in the list
    (fold check-err
      (map send-token recipients)
      (ok true)
    )
  )
)

;; Helper function to check for errors during the processing of each payment
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior
    ok-value result
    err-value (err err-value)
  )
)

;; Helper function to send tokens to a recipient, including an optional memo
(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

;; Function that performs the actual token transfer, handling optional memos
(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let
    ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

;; --------- Function to add an address to the whitelist
(define-public (add-to-whitelist (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner-address)) (err ERR-NOT-OWNER))
    (map-set whitelist { address: address } { is-whitelisted: true })
    (ok true)
  ))

;; Function to remove an address from the whitelist
(define-public (remove-from-whitelist (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner-address)) (err ERR-NOT-OWNER))
    (map-set whitelist { address: address } { is-whitelisted: false })
    (ok true)
  ))

;; Function to change treasury address (only callable by owner)
(define-public (set-treasury-address (new-address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner-address)) (err ERR-NOT-OWNER)) ;; Check if the sender is the owner
    (var-set treasury-address new-address)
    (ok true)))

;; Function to change developer wallet address (only callable by owner)
(define-public (set-dev-wallet-address (new-address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner-address)) (err ERR-NOT-OWNER)) ;; Check if the sender is the owner
    (var-set dev-wallet-address new-address)
    (ok true)))
;; transfer ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    ;; Checks if the sender is the current owner
    (if (is-eq tx-sender (var-get owner-address))
      (begin
        ;; Sets the new owner
        (var-set owner-address new-owner)
        ;; Returns success message
        (ok "Ownership transferred successfully"))
      ;; Error if the sender is not the owner
      (err ERR-NOT-OWNER)))
)

;; Setter function to adjust the tax_off status
(define-public (set-tax-off (status bool))
  (begin
    ;; Here you might want to include authorization checks, such as:
    (asserts! (is-eq tx-sender (var-get owner-address)) (err ERR-UNAUTHORIZED))
    (ok (var-set tax_off status))))

;; ----- Function to set total tax
(define-public (set-total-tax (new-tax uint))
  (begin
    (asserts! (is-eq tx-sender (var-get owner-address)) (err ERR-UNAUTHORIZED)) ;; Only owner can change
    (ok (var-set total-tax new-tax))))

;; Function to set treasury fee
(define-public (set-treasury-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender (var-get owner-address)) (err ERR-UNAUTHORIZED)) ;; Only owner can change
    (ok (var-set treasury-fee new-fee))))

;; Function to set burn fee
(define-public (set-burn-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender (var-get owner-address)) (err ERR-UNAUTHORIZED)) ;; Only owner can change
    (ok (var-set burn-fee new-fee))))

;; Function to set dev fee
(define-public (set-dev-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender (var-get owner-address)) (err ERR-UNAUTHORIZED)) ;; Only owner can change
    (ok (var-set dev-fee new-fee))))


;; Get treasury-address | dev-wallet-address | owner-address | whitelist
(define-read-only (get-treasury-address)
  (var-get treasury-address))

(define-read-only (get-dev-wallet-address)
  (var-get dev-wallet-address))

(define-read-only (get-owner-address)
  (var-get owner-address))

(define-read-only (check-address-whitelisted (address principal))
  (let ((whitelist-status (map-get? whitelist { address: address })))
    (ok (default-to false (get is-whitelisted whitelist-status)))
  ))
(define-read-only (get-tax-status)
  (var-get tax_off))

 ;; Read-only function to get total tax
(define-read-only (get-total-tax)
  (ok (var-get total-tax)))

;; Read-only function to get treasury fee
(define-read-only (get-treasury-fee)
  (ok (var-get treasury-fee)))

;; Read-only function to get burn fee
(define-read-only (get-burn-fee)
  (ok (var-get burn-fee)))

;; Read-only function to get dev fee
(define-read-only (get-dev-fee)
  (ok (var-get dev-fee))) 

;; SIP010 required functions
(define-read-only (get-name)
    (ok (var-get token-name)))

(define-read-only (get-symbol)
    (ok (var-get token-symbol)))

(define-read-only (get-decimals)
    (ok (var-get token-decimals)))

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance HODL user)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply HODL)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))



;; DEFINE METADATA
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://jsonkeeper.com/b/BJO9"))
(define-data-var token-name (string-ascii 32) "HOLD HODL HODL")
(define-data-var token-symbol (string-ascii 32) "HODL")
(define-data-var token-decimals uint u6)

;; EDIT 
(define-public 
    (set-metadata 
        (uri (optional (string-utf8 256))) 
        (name (string-ascii 32))
        (symbol (string-ascii 32))
        (decimals uint))
    (begin
        (asserts! (is-eq tx-sender (var-get owner-address)) (err ERR-UNAUTHORIZED))
        (asserts! 
            (and 
                (is-some uri)
                (> (len name) u0)
                (> (len symbol) u0)
                (<= decimals u6))
            (err ERR-INVALID-PARAMETERS))
        (var-set token-uri uri)
        (var-set token-name name)
        (var-set token-symbol symbol)
        (var-set token-decimals decimals)
        (print 
            {
                notification: "token-metadata-update",
                payload: {
                    token-class: "ft", 
                    contract-id: (as-contract tx-sender) 
                }
            })
(ok true)))
