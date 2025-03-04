(define-trait sip-010-trait
    (
        ;; Transfer from the caller to a new principal
        (transfer (uint principal principal (optional (buff 34))) (response bool uint))

        ;; the human readable name of the token
        (get-name () (response (string-ascii 32) uint))

        ;; the ticker symbol, or empty if none
        (get-symbol () (response (string-ascii 32) uint))

        ;; the number of decimals used, e.g. 6 would mean 1_000_000 represents 1 token
        (get-decimals () (response uint uint))

        ;; the balance of the passed principal
        (get-balance (principal) (response uint uint))

        ;; the current total supply (which does not need to be a constant)
        (get-total-supply () (response uint uint))

        ;; an optional URI that represents metadata of this token
        (get-token-uri () (response (optional (string-utf8 256)) uint))
    )
)

(define-trait nft-trait
    (
        ;; Last token ID, limited to uint range
        (get-last-token-id () (response uint uint))

        ;; URI for metadata associated with the token
        (get-token-uri (uint) (response (optional (string-ascii 256)) uint))

        ;; Owner of a given token identifier
        (get-owner (uint) (response (optional principal) uint))

        ;; Transfer from the sender to a new principal
        (transfer (uint principal principal) (response bool uint))
    )
)

(define-trait extension-trait
	(
		(callback (principal (buff 34)) (response bool uint))
	)
)

(define-trait proposal-trait
    (
        (execute (principal) (response bool uint))
    )
)

(define-trait executor-trait (
    ;; Execute a governance proposal
    (execute (<proposal-trait> principal) (response bool uint))

    ;; Enable or disable an extension contract
    (set-extension (principal bool) (response bool uint))
))

(define-trait treasury-trait
    (
        ;; STX deposits and withdrawals
        (deposit-stx (uint) (response bool uint))
        (withdraw-stx (uint principal) (response bool uint))

        ;; Fungible token deposits and withdrawals
        (deposit-ft (<sip-010-trait> uint) (response bool uint))
        (withdraw-ft (<sip-010-trait> uint principal) (response bool uint))

        ;; NFT deposits and withdrawals 
        (deposit-nft (<nft-trait> uint) (response bool uint))
        (withdraw-nft (<nft-trait> uint principal) (response bool uint))
    )
)

(define-trait messaging-trait
  (
    ;; send a message on-chain
    ;; @param msg the message to send (up to 1MB)
    ;; @param opcode optional operation code
    ;; @returns (response bool uint)
    (send ((string-ascii 1048576) (optional (buff 16))) (response bool uint))
  )
)

(define-trait resource-trait
  (
    (set-payment-address (principal principal) (response bool uint))
    (add-resource ((string-utf8 50) (string-utf8 255) uint) (response uint uint))
    (toggle-resource (uint) (response bool uint))
    (toggle-resource-by-name ((string-utf8 50)) (response bool uint))
  )
)

(define-trait invoice-trait
  (
    (pay-invoice (uint (optional (buff 34))) (response uint uint))
    (pay-invoice-by-resource-name ((string-utf8 50) (optional (buff 34))) (response uint uint))
  )
)

(define-trait bank-account-trait
 (
   ;; update configurable terms for the bank account
   ;; @param accountHolder optional new account holder principal
   ;; @param withdrawalPeriod optional new withdrawal period in blocks 
   ;; @param withdrawalAmount optional new withdrawal amount in microSTX
   ;; @param lastWithdrawalBlock optional override for last withdrawal block
   ;; @returns (response bool uint)
   (update-terms 
     ((optional principal) 
     (optional uint)
     (optional uint) 
     (optional uint)
     (optional (buff 16)))
     (response bool uint)
   )

   ;; deposit STX to the bank account
   ;; @param amount amount of microSTX to deposit
   ;; @returns (response bool uint)
   (deposit-stx (uint) (response bool uint))

   ;; withdraw STX from the bank account
   ;; @returns (response bool uint) 
   (withdraw-stx () (response bool uint))

   ;; get current account balance in microSTX
   ;; @returns uint
   (get-account-balance () (response uint uint))

   ;; get all current bank account terms
   ;; @returns {accountHolder: principal, lastWithdrawalBlock: uint, withdrawalAmount: uint, withdrawalPeriod: uint}
   (get-terms () 
     (response {
       accountHolder: principal,
       lastWithdrawalBlock: uint,
       withdrawalAmount: uint, 
       withdrawalPeriod: uint
     } uint)
   )
 )
)