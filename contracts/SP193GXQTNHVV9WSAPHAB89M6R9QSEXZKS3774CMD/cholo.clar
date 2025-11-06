;; title: CHOLO
;; version: 0.0.1
;; summary: $CHOLO fungible token with fixed supply.
;; description: First memecoin created in LATAM anchored to Bitcoin L2 Stacks.

;; SIP-010 STANDARD
(define-trait sip-010-trait
    (
        (get-balance (principal) (response uint uint))
        (get-total-supply () (response uint uint))
        (get-decimals () (response uint uint))
        (get-symbol () (response (string-ascii 12) uint))
        (get-name () (response (string-ascii 32) uint))
        (get-token-uri () (response (optional (string-utf8 256)) uint))
        
        (transfer (uint principal principal (optional (buff 34))) (response bool uint))
        (mint (uint principal) (response bool uint))
    )
)

(define-fungible-token cholo)

;; ERROR CODES
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_INVALID_RECIPIENT (err u103))
(define-constant ERR_MAX_SUPPLY_EXCEEDED (err u104))
(define-constant ERR_INVALID_OWNER (err u105))

;; VARS & CONS
(define-data-var cholo-owner principal tx-sender)
(define-data-var total-minted uint u0)
(define-data-var token-uri (string-utf8 256) u"https://cholo.meme/bafkreibwuiavedbqjkvksvulm3focfv7ic2kd63c6lu5frtklteiys2mnq")
(define-constant TOKEN_NAME "CHOLO")
(define-constant TOKEN_SYMBOL "CHOLO")
(define-constant TOKEN_DECIMALS u8)
(define-constant MAX_SUPPLY u888888888888888888) ;; 8B supply
(define-constant BURN_ADDRESS 'SP000000000000000000002Q6VF78)

;; READ-ONLY FUN
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance cholo who))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply cholo))
)

(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

;; PUBLIC FUN
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (var-get cholo-owner)) ERR_OWNER_ONLY)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (not (is-eq recipient BURN_ADDRESS)) ERR_INVALID_RECIPIENT)
    (let (
      (current-minted (var-get total-minted))
      (new-total (+ current-minted amount))
    )
      (asserts! (<= new-total MAX_SUPPLY) ERR_MAX_SUPPLY_EXCEEDED)
      (try! (ft-mint? cholo amount recipient))
      (var-set total-minted new-total)
      (ok true)
    )
  )
)

(define-public (transfer
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT) 
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER) 
    (asserts! (not (is-eq recipient BURN_ADDRESS)) ERR_INVALID_RECIPIENT) 
    (try! (ft-transfer? cholo amount sender recipient))
    (ok true)
  )
)

(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get cholo-owner)) ERR_OWNER_ONLY)
    (asserts! (not (is-eq new-owner BURN_ADDRESS)) ERR_INVALID_OWNER)
    (var-set cholo-owner new-owner)
    (ok true)
  )
)

(define-public (set-token-uri (new-uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get cholo-owner)) ERR_OWNER_ONLY)
    (var-set token-uri new-uri)
    (ok true)
  )
)

;; INIT
(begin
    (try! (ft-mint? cholo MAX_SUPPLY tx-sender))
    (var-set total-minted MAX_SUPPLY)
)