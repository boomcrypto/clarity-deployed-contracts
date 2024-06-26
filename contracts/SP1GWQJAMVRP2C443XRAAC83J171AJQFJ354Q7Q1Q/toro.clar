;; This contract implements the SIP-010 community-standard Fungible Token trait.
(define-trait sip010-ft-trait
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


;; Define the FT, with no maximum supply
(define-fungible-token toro u2100000000000000)

;; Define errors
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))

;; Define constants for contract
(define-constant CONTRACT_OWNER tx-sender)
(define-constant TOKEN_URI u"https://arweave.net/xJvMfBLp8gQ0skquODho7UcC_BqQ5On7bVenRlBinsU") ;; utf-8 string with token metadata host
(define-constant TOKEN_NAME "toro")
(define-constant TOKEN_SYMBOL "TORO")
(define-constant TOKEN_DECIMALS u8) ;; 8 units displayed past decimal, e.g. 1.0000_0000 = 1 token


;; SIP-010 function: Get the token balance of a specified principal
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance toro who))
)

;; SIP-010 function: Returns the total supply of fungible token
(define-read-only (get-total-supply)
  (ok (ft-get-supply toro))
)

;; SIP-010 function: Returns the human-readable token name
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

;; SIP-010 function: Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

;; SIP-010 function: Returns number of decimals to display
(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

;; SIP-010 function: Returns the URI containing token metadata
(define-read-only (get-token-uri)
  (ok (some TOKEN_URI))
)

;; Mint new tokens and send them to a recipient.
;; Only the contract deployer can perform this operation.
;; commented out to remove any additional minting
;;(define-public (mint (amount uint) (recipient principal))
;;  (begin
;;    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
;;    (ft-mint? toro amount recipient)
;;  )
;;)

;; SIP-010 function: Transfers tokens to a recipient
;; Sender must be the same as the caller to prevent principals from transferring tokens they do not own.
(define-public (transfer
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
  (begin
    ;; #[filter(amount, recipient)]
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
    (try! (ft-transfer? toro amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)