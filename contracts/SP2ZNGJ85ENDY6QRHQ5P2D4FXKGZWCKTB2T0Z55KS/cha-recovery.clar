;; --- Claim tracking maps ---
(define-map claimed-a principal bool)
(define-map claimed-b principal bool)
(define-map claimed-c principal bool)
(define-map claimed-d principal bool)

;; --- Utility functions ---
(define-private (check-and-set-claimed-a (user principal))
  (match (map-get? claimed-a user)
    claimed false
    (begin
      (map-set claimed-a user true)
      true)))

(define-private (check-and-set-claimed-b (user principal))
  (match (map-get? claimed-b user)
    claimed false
    (begin
      (map-set claimed-b user true)
      true)))

(define-private (check-and-set-claimed-c (user principal))
  (match (map-get? claimed-c user)
    claimed false
    (begin
      (map-set claimed-c user true)
      true)))

(define-private (check-and-set-claimed-d (user principal))
  (match (map-get? claimed-d user)
    claimed false
    (begin
      (map-set claimed-d user true)
      true)))

;; --- Claim amount functions ---
(define-read-only (get-claim-amount-a (user principal))
  (contract-call? .gbab-v0 get-cha-at-block user u166688))

(define-read-only (get-claim-amount-b (user principal))
  (let ((amount (contract-call? .gbab-v0 get-scha-at-block user u166688)))
    (ok (/ (* u11 (unwrap-panic amount)) u10))))

(define-read-only (get-claim-amount-c (user principal))
  (contract-call? .gbab-v0 get-wcha-at-block user u166688))

(define-read-only (get-claim-amount-d (user principal))
  (let ((amount (contract-call? .gbab-v0 get-staked-scha-at-block user u166688)))
    (ok (/ (* u11 (unwrap-panic amount)) u10))))

;; --- Mint functions ---
(define-public (mint-a)
  (let (
    (user tx-sender)
    (amount (unwrap-panic (get-claim-amount-a user))))
    (if (and (> amount u0) (check-and-set-claimed-a user))
      (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint amount user)
      (err u0)))) ;; Either already claimed or no balance

(define-public (mint-b)
  (let (
    (user tx-sender)
    (amount (unwrap-panic (get-claim-amount-b user))))
    (if (and (> amount u0) (check-and-set-claimed-b user))
      (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint amount user)
      (err u1)))) ;; Either already claimed or no balance

(define-public (mint-c)
  (let (
    (user tx-sender)
    (amount (unwrap-panic (get-claim-amount-c user))))
    (if (and (> amount u0) (check-and-set-claimed-c user))
      (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint amount user)
      (err u2)))) ;; Either already claimed or no balance

(define-public (mint-d)
  (let (
    (user tx-sender)
    (amount (unwrap-panic (get-claim-amount-d user))))
    (if (and (> amount u0) (check-and-set-claimed-d user))
      (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint amount user)
      (err u3)))) ;; Either already claimed or no balance

;; --- Read-only functions ---
(define-read-only (has-claimed-a (user principal))
  (default-to false (map-get? claimed-a user)))

(define-read-only (has-claimed-b (user principal))
  (default-to false (map-get? claimed-b user)))

(define-read-only (has-claimed-c (user principal))
  (default-to false (map-get? claimed-c user)))

(define-read-only (has-claimed-d (user principal))
  (default-to false (map-get? claimed-d user)))

(define-read-only (get-all-claims (user principal))
  {
    a: (has-claimed-a user),
    b: (has-claimed-b user),
    c: (has-claimed-c user),
    d: (has-claimed-d user)
  })