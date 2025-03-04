(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-fungible-token wliabtc)

(define-data-var token-name (string-ascii 32) "liabtc Wrapper")
(define-data-var token-symbol (string-ascii 32) "wliabtc")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.alexlab.co/metadata/token-wliabtc.json"))

(define-data-var token-decimals uint u8)

;; errors
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-NOT-SUPPORTED (err u3001))

(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Base token integration

(define-read-only (get-base-token)
  'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-liabtc)

(define-read-only (get-base-decimals)
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-liabtc get-decimals))

(define-read-only (base-to-decimals (amount uint))
	(if (is-eq (unwrap-panic (get-base-decimals)) (unwrap-panic (get-decimals))) amount (/ (* amount (pow-decimals)) (pow u10 (unwrap-panic (get-base-decimals))))))

(define-read-only (decimals-to-base (amount uint))
	(if (is-eq (unwrap-panic (get-base-decimals)) (unwrap-panic (get-decimals))) amount (/ (* amount (pow u10 (unwrap-panic (get-base-decimals)))) (pow-decimals))))

(define-read-only (get-balance (who principal))
  (ok (base-to-decimals (unwrap-panic (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-liabtc get-balance who)))))

(define-read-only (get-total-supply)
  (ok (base-to-decimals (unwrap-panic (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-liabtc get-total-supply)))))

(define-read-only (get-share (who principal))
  (ok (base-to-decimals (unwrap-panic (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-liabtc get-share who)))))

(define-read-only (get-shares-to-tokens (amount uint))
  (base-to-decimals (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-liabtc get-shares-to-tokens (decimals-to-base amount))))

(define-read-only (get-tokens-to-shares (amount uint))
  (base-to-decimals (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-liabtc get-tokens-to-shares (decimals-to-base amount))))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)
    (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-liabtc transfer (decimals-to-base amount) sender recipient memo)))

(define-public (mint (amount uint) (recipient principal))
  ERR-NOT-SUPPORTED)

(define-public (burn (amount uint) (sender principal))
  ERR-NOT-SUPPORTED)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Governance
(define-read-only (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED)))

(define-public (set-name (new-name (string-ascii 32)))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set token-name new-name))))

(define-public (set-symbol (new-symbol (string-ascii 32)))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set token-symbol new-symbol))))

(define-public (set-decimals (new-decimals uint))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set token-decimals new-decimals))))

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set token-uri new-uri))))

;; Fixed point arithmetic
(define-constant ONE_8 u100000000)

(define-private (pow-decimals)
  (pow u10 (unwrap-panic (get-decimals))))

(define-read-only (fixed-to-decimals (amount uint))
	(if (is-eq (unwrap-panic (get-decimals)) u8) amount (/ (* amount (pow-decimals)) ONE_8)))

(define-private (decimals-to-fixed (amount uint))
	(if (is-eq (unwrap-panic (get-decimals)) u8) amount (/ (* amount ONE_8) (pow-decimals))))

(define-read-only (get-balance-fixed (account principal))
  (ok (decimals-to-fixed (unwrap-panic (get-balance account)))))

(define-read-only (get-total-supply-fixed)
  (ok (decimals-to-fixed (unwrap-panic (get-total-supply)))))

(define-read-only (get-share-fixed (account principal))
  (ok (decimals-to-fixed (unwrap-panic (get-share account)))))

(define-read-only (get-shares-to-tokens-fixed (amount uint))
  (decimals-to-fixed (get-shares-to-tokens (fixed-to-decimals amount))))

(define-read-only (get-tokens-to-shares-fixed (amount uint))
  (decimals-to-fixed (get-tokens-to-shares (fixed-to-decimals amount))))

(define-public (transfer-fixed (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (transfer (fixed-to-decimals amount) sender recipient memo))

(define-public (mint-fixed (amount uint) (recipient principal))
  (mint (fixed-to-decimals amount) recipient))

(define-public (burn-fixed (amount uint) (sender principal))
  (burn (fixed-to-decimals amount) sender))

;; Batch operations
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (transfer-from-tuple (recipient { to: principal, amount: uint }))
  (ok (unwrap! (transfer-fixed (get amount recipient) tx-sender (get to recipient) none) ERR-TRANSFER-FAILED)))

(define-public (send-many (recipients (list 200 { to: principal, amount: uint})))
  (fold check-err (map transfer-from-tuple recipients) (ok true))) 
