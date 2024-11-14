;; --- Token Recovery Contracts ---
;; SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.charisma-left-index
;; index token claims
;; SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.back-to-the-charisma
;; lp token claims

;; --- Claim tracking maps ---
(define-map claimed-a principal bool)
(define-map claimed-b principal bool)
(define-map claimed-c principal bool)

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

;; --- Claim amount functions ---
(define-public (get-claim-amount-index (user principal))
  (ok (unwrap-panic (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.charisma-left-index calculate-total-balance user u166688))))

(define-public (get-claim-amount-lp (user principal))
  (let
  (
    (lp-amounts (unwrap-panic (contract-call? .back-to-the-charisma check-lp user)))
    (scs (get scs lp-amounts))
    (stx-scs (get stx scs))
    (scha-scs (get scha scs))
    (wcs (get wcs lp-amounts))
    (stx-wcs (get stx wcs))
    (wcha-wcs (get wcha wcs))
  )
  (ok {
    cha: (+ (/ (* scha-scs u11) u10) wcha-wcs),
    stx: (+ stx-scs stx-wcs),
  })
  )
)

;; --- Mint functions ---
(define-public (mint-a)
  (let (
    (user tx-sender)
    (amount (unwrap-panic (get-claim-amount-index user))))
    (if (and (> amount u0) (check-and-set-claimed-a user))
      (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint amount user)
      (err u1)))) ;; Either already claimed or no balance

(define-public (mint-b)
  (let (
    (user tx-sender)
    (amount (get cha (unwrap-panic (get-claim-amount-lp user)))))
    (if (and (> amount u0) (check-and-set-claimed-b user))
      (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint amount user)
      (err u1)))) ;; Either already claimed or no balance

(define-public (mint-c)
  (let (
    (user tx-sender)
    (amount (get stx (unwrap-panic (get-claim-amount-lp user)))))
    (if (and (> amount u0) (check-and-set-claimed-c user))
      (contract-call? .synthetic-stx mint amount user)
      (err u1)))) ;; Either already claimed or no balance

;; --- Read-only functions ---
(define-read-only (has-claimed-a (user principal))
  (default-to false (map-get? claimed-a user)))

(define-read-only (has-claimed-b (user principal))
  (default-to false (map-get? claimed-b user)))

(define-read-only (has-claimed-c (user principal))
  (default-to false (map-get? claimed-c user)))

(define-read-only (get-all-claims (user principal))
  {
    a: (has-claimed-a user),
    b: (has-claimed-b user),
    c: (has-claimed-c user)
  })