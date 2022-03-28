;; Implement the `ft-trait` trait defined in the `ft-trait` contract
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant TOTAL-SUPPLY u1380000000)
(define-fungible-token ice TOTAL-SUPPLY)

(define-constant contract-creator tx-sender)

(define-data-var ice-machine principal tx-sender)
(define-data-var initiated bool false)
(define-data-var token-uri (optional (string-utf8 256)) none)

(define-map last-actions principal {freeze: uint, melt: uint})
(define-constant ACTIONS-AT-DEPLOY {freeze: block-height, melt: block-height})

;; 5% of ice can melt within a year if not used
(define-constant ERR-UNAUTHORIZED u1)
(define-constant MELT-TIME u48000)
(define-constant MELT-RATE u4)
(define-constant REWARD-RATE u1)
(define-constant MIN-BALANCE u1618)

;; get the token balance of owner
(define-read-only (get-balance (user principal))
  (ok (ft-get-balance ice user)))

;; get the token balance of the caller
(define-read-only (get-caller-balance)
  (begin
    (ok (ft-get-balance ice tx-sender))))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply ice)))

;; returns the token name
(define-read-only (get-name)
  (ok "Ice Token"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "ICE"))

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u0))

;; transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err u4))
    (map-set last-actions sender (merge (get-last-actions sender) {freeze: block-height}))
    (map-set last-actions recipient (merge (get-last-actions recipient) {freeze: block-height}))
    (try! (ft-transfer? ice amount sender recipient))
    (print memo)
    (ok true)))

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender contract-creator) 
    (ok (var-set token-uri (some value))) 
    (err ERR-UNAUTHORIZED)))

(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

;;
;; melt functions
(define-read-only (get-last-actions (user principal))
  (default-to ACTIONS-AT-DEPLOY (map-get? last-actions user)))

;; melt tokens
(define-private (melt-ice (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (try! (ft-transfer? ice amount sender recipient))
    (print memo)
    (ok true)))
    
(define-public (heat-wave-at (user principal))
  (let (
      (user-actions (get-last-actions user))
      (user-balance (ft-get-balance ice user))
      ;; melt-amount and reward-amount can't be 0 because of MIN-BALANCE
      (melt-amount (/ (* user-balance  MELT-RATE) u100))
      (reward-amount (/ (* user-balance REWARD-RATE) u100))
    )
    (asserts! (> block-height (+ (get freeze user-actions) MELT-TIME)) ERR-TOO-COLD)
    (asserts! (> block-height (+ (get melt user-actions) MELT-TIME)) ERR-TOO-HOT)
    (asserts! (>= user-balance MIN-BALANCE) ERR-TOO-LOW)
    (map-set last-actions user (merge user-actions {melt: block-height}))
    (try! (melt-ice melt-amount user (var-get ice-machine) (some 0x686561742077617665206d656c74)))
    (try! (melt-ice reward-amount user tx-sender (some 0x68656174207761766520726577617264)))
    (ok true)
  )
)

(define-public (set-ice-machine (machine principal))
  (begin
    (asserts! (not (var-get initiated)) ERR-MACHINE-ALREADY-SET)
    (var-set ice-machine machine)
    (var-set initiated true)
    (ft-mint? ice TOTAL-SUPPLY machine)))

(define-constant ERR-TOO-COLD (err u501))
(define-constant ERR-TOO-HOT (err u502))
(define-constant ERR-TOO-LOW (err u503))
(define-constant ERR-MACHINE-ALREADY-SET (err u504))