;; CryptoCash TOKEN CONTRACT
;; CryptoCash Protocol Version 1.0.1

;; CONTRACT OWNER

(define-constant CONTRACT_OWNER tx-sender)

;; TRAIT DEFINITIONS

(impl-trait 'SP7MKPEA5DVQQ1PQNYPC1P5YRF14CY3CWZF70R01.cryptocash-token-trait.cryptocash-token)
(use-trait coreTrait 'SP7MKPEA5DVQQ1PQNYPC1P5YRF14CY3CWZF70R01.cryptocash-core-trait.cryptocash-core)

;; ERROR CODES

(define-constant ERR_UNAUTHORIZED u2000)
(define-constant ERR_TOKEN_NOT_ACTIVATED u2001)
(define-constant ERR_TOKEN_ALREADY_ACTIVATED u2002)

(define-constant cryptocash-core 'SP7MKPEA5DVQQ1PQNYPC1P5YRF14CY3CWZF70R01.cryptocash-core)

;; SIP-010 DEFINITION

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token CC)

;; SIP-010 FUNCTIONS

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR_UNAUTHORIZED))
    (if (is-some memo)
      (print memo)
      none
    )
    (ft-transfer? CC amount from to)
  )
)

(define-read-only (get-name)
  (ok "CryptoCash")
)

(define-read-only (get-symbol)
  (ok "CC")
)

(define-read-only (get-decimals)
  (ok u0)
)

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance CC user))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply CC))
)

(define-read-only (get-token-uri)
  (ok (var-get tokenUri))
)

;; TOKEN CONFIGURATION

;; how many blocks until the next halving occurs
(define-constant TOKEN_HALVING_BLOCKS u210000)

;; store block height at each halving, set by register-user in core contract 
(define-data-var coinbaseThreshold1 uint u0)
(define-data-var coinbaseThreshold2 uint u0)
(define-data-var coinbaseThreshold3 uint u0)
(define-data-var coinbaseThreshold4 uint u0)
(define-data-var coinbaseThreshold5 uint u0)

;; once activated, thresholds cannot be updated again
(define-data-var tokenActivated bool false)

;; core contract states
(define-constant STATE_DEPLOYED u0)
(define-constant STATE_ACTIVE u1)
(define-constant STATE_INACTIVE u2)

;; one-time function to activate the token
(define-public (activate-token (stacksHeight uint))
  (begin
    (asserts! (is-eq CONTRACT_OWNER tx-sender) (err ERR_UNAUTHORIZED))
    (asserts! (not (var-get tokenActivated)) (err ERR_TOKEN_ALREADY_ACTIVATED))
    (var-set tokenActivated true)
    (var-set coinbaseThreshold1 (+ stacksHeight TOKEN_HALVING_BLOCKS))
    (var-set coinbaseThreshold2 (+ stacksHeight (* u2 TOKEN_HALVING_BLOCKS)))
    (var-set coinbaseThreshold3 (+ stacksHeight (* u3 TOKEN_HALVING_BLOCKS)))
    (var-set coinbaseThreshold4 (+ stacksHeight (* u4 TOKEN_HALVING_BLOCKS)))
    (var-set coinbaseThreshold5 (+ stacksHeight (* u5 TOKEN_HALVING_BLOCKS)))
    (ok true)
 )
)

;; return coinbase thresholds if token activated
(define-read-only (get-coinbase-thresholds)
  (let
    (
      (activated (var-get tokenActivated))
    )
    (asserts! activated (err ERR_TOKEN_NOT_ACTIVATED))
    (ok {
      coinbaseThreshold1: (var-get coinbaseThreshold1),
      coinbaseThreshold2: (var-get coinbaseThreshold2),
      coinbaseThreshold3: (var-get coinbaseThreshold3),
      coinbaseThreshold4: (var-get coinbaseThreshold4),
      coinbaseThreshold5: (var-get coinbaseThreshold5)
    })
  )
)

;; UTILITIES

(define-data-var tokenUri (optional (string-utf8 256)) (some u"https://stackers.cc/cryptocash.json"))

;; set token URI to new value, only accessible by Auth
(define-public (set-token-uri (newUri (optional (string-utf8 256))))
  (begin
    (asserts! (is-authorized-auth) (err ERR_UNAUTHORIZED))
    (ok (var-set tokenUri newUri))
  )
)

;; mint new tokens, only accessible by a Core contract
(define-public (mint (amount uint) (recipient principal))
  (let 
    (
      (check (is-eq contract-caller cryptocash-core))    
    )
    (if check 
      (ft-mint? CC amount recipient)
      (ok false)
    )
  )
)

(define-public (burn (amount uint) (owner principal))
  (begin
    (asserts! (is-eq tx-sender owner) (err ERR_UNAUTHORIZED))
    (ft-burn? CC amount owner)
  )
)

;; checks if caller is Auth contract
(define-private (is-authorized-auth)
  (is-eq tx-sender CONTRACT_OWNER)
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