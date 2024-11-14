;; Raven Reduction
;;
;; This contract calculates fee discounts based on Raven NFT ownership within the Charisma ecosystem.
;; It provides functionality to determine a user's highest-owned Raven ID and calculate the corresponding
;; burn fee reduction.
;;
;; The discount is proportional to the Raven ID owned, with higher IDs providing greater reductions.
;; This incentivizes ownership of higher-tier Raven NFTs and provides tangible benefits within the ecosystem.

;; Constants
(define-constant MAX-RAVEN-ID u100)
(define-constant MAX-BURN-REDUCTION u500000) ;; 50% reduction (with 6 decimal places)
(define-constant FEE-SCALE u1000000) ;; 1 DMG (with 6 decimal places)

;; Public function
(define-read-only (get-burn-reduction (user principal))
  (let
    (
      (raven-id (get-user-raven-id user))
      (reduction-rate (/ (* raven-id MAX-BURN-REDUCTION) MAX-RAVEN-ID))
    )
    reduction-rate
  )
)

;; Private functions
(define-private (get-user-raven-id (user principal))
  (let ((find-raven-id (fold check-raven-ownership (list 
    u100 u99 u98 u97 u96 u95 u94 u93 u92 u91 u90 u89 u88 u87 u86 u85 u84 u83 u82 u81 u80
    u79 u78 u77 u76 u75 u74 u73 u72 u71 u70 u69 u68 u67 u66 u65 u64 u63 u62 u61 u60
    u59 u58 u57 u56 u55 u54 u53 u52 u51 u50 u49 u48 u47 u46 u45 u44 u43 u42 u41 u40
    u39 u38 u37 u36 u35 u34 u33 u32 u31 u30 u29 u28 u27 u26 u25 u24 u23 u22 u21 u20
    u19 u18 u17 u16 u15 u14 u13 u12 u11 u10 u9 u8 u7 u6 u5 u4 u3 u2 u1
  ) u0 )))
    find-raven-id)
)

(define-private (check-raven-ownership (id uint) (highest-owned uint))
  (let 
    (
      (owner (unwrap-panic (contract-call? .odins-raven get-owner id)))
    )
    (if (and 
          (is-eq highest-owned u0)
          (is-some owner)
          (is-eq tx-sender (unwrap! owner highest-owned))
        )
      id
      highest-owned
    )
  )
)