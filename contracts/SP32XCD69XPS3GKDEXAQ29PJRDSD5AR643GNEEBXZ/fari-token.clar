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

(define-fungible-token fari-token)

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (begin
    (ok (ft-get-balance fari-token owner))))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply fari-token)))

;; returns the token name
(define-read-only (get-name)
  (ok "Fari Token"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "FARI"))

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u8))

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? fari-token amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-public (get-token-uri)
  (ok (some u"https://www.bitfari.org/token/")))

;; Mint this token to a few people when deployed
;; development team
(ft-mint? fari-token u10000000 'SP3SW54K3QMDZ0BB34KXQ62FNFKDBYB4RMTHJ19SG)

;; bitfari foundation treasury
;; 10% to be distributed to the community for development, promotions, etc.
;; 90% reserved for network operation, distributed programmatically to screen operators, auditors, customers, etc.
(ft-mint? fari-token u90000000 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA)