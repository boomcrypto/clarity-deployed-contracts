---
title: "Trait raven-wisdom"
draft: true
---
```
;; Raven Wisdom
;;
;; This contract calculates fee discounts based on Raven NFT ownership within the Charisma ecosystem.
;; It provides functionality to determine a user's highest-owned Raven ID and calculate the corresponding
;; burn fee reduction.
;;
;; The discount is proportional to the Raven ID owned, with higher IDs providing greater reductions.
;; This incentivizes ownership of higher-tier Raven NFTs and provides tangible benefits within the ecosystem.

;; Constants
(define-constant MAX-RAVEN-ID u100)
(define-constant BASE-REDUCTION u250000) ;; 25% reduction (with 6 decimal places)
(define-constant MAX-BURN-REDUCTION u250000) ;; 25% reduction (with 6 decimal places)
(define-constant FEE-SCALE u1000000) ;; 1 DMG (with 6 decimal places)

;; Public function
(define-read-only (apply (amount uint) (user principal))
  (let ((reduction (get-burn-reduction user)))
    (- amount (/ (* amount reduction) FEE-SCALE))))

;; Private functions
    
(define-private (get-burn-reduction (user principal))
 (let ((raven-id (get-user-raven-id user)))
    (if (is-eq raven-id u0) u0
    (+ (/ (* raven-id MAX-BURN-REDUCTION) MAX-RAVEN-ID) BASE-REDUCTION))))

(define-private (get-user-raven-id (user principal))
 (let ((find-raven-id (fold check-raven-ownership (list 
   {id: u100, user: user}
   {id: u99, user: user}
   {id: u98, user: user}
   {id: u97, user: user}
   {id: u96, user: user}
   {id: u95, user: user}
   {id: u94, user: user}
   {id: u93, user: user}
   {id: u92, user: user}
   {id: u91, user: user}
   {id: u90, user: user}
   {id: u89, user: user}
   {id: u88, user: user}
   {id: u87, user: user}
   {id: u86, user: user}
   {id: u85, user: user}
   {id: u84, user: user}
   {id: u83, user: user}
   {id: u82, user: user}
   {id: u81, user: user}
   {id: u80, user: user}
   {id: u79, user: user}
   {id: u78, user: user}
   {id: u77, user: user}
   {id: u76, user: user}
   {id: u75, user: user}
   {id: u74, user: user}
   {id: u73, user: user}
   {id: u72, user: user}
   {id: u71, user: user}
   {id: u70, user: user}
   {id: u69, user: user}
   {id: u68, user: user}
   {id: u67, user: user}
   {id: u66, user: user}
   {id: u65, user: user}
   {id: u64, user: user}
   {id: u63, user: user}
   {id: u62, user: user}
   {id: u61, user: user}
   {id: u60, user: user}
   {id: u59, user: user}
   {id: u58, user: user}
   {id: u57, user: user}
   {id: u56, user: user}
   {id: u55, user: user}
   {id: u54, user: user}
   {id: u53, user: user}
   {id: u52, user: user}
   {id: u51, user: user}
   {id: u50, user: user}
   {id: u49, user: user}
   {id: u48, user: user}
   {id: u47, user: user}
   {id: u46, user: user}
   {id: u45, user: user}
   {id: u44, user: user}
   {id: u43, user: user}
   {id: u42, user: user}
   {id: u41, user: user}
   {id: u40, user: user}
   {id: u39, user: user}
   {id: u38, user: user}
   {id: u37, user: user}
   {id: u36, user: user}
   {id: u35, user: user}
   {id: u34, user: user}
   {id: u33, user: user}
   {id: u32, user: user}
   {id: u31, user: user}
   {id: u30, user: user}
   {id: u29, user: user}
   {id: u28, user: user}
   {id: u27, user: user}
   {id: u26, user: user}
   {id: u25, user: user}
   {id: u24, user: user}
   {id: u23, user: user}
   {id: u22, user: user}
   {id: u21, user: user}
   {id: u20, user: user}
   {id: u19, user: user}
   {id: u18, user: user}
   {id: u17, user: user}
   {id: u16, user: user}
   {id: u15, user: user}
   {id: u14, user: user}
   {id: u13, user: user}
   {id: u12, user: user}
   {id: u11, user: user}
   {id: u10, user: user}
   {id: u9, user: user}
   {id: u8, user: user}
   {id: u7, user: user}
   {id: u6, user: user}
   {id: u5, user: user}
   {id: u4, user: user}
   {id: u3, user: user}
   {id: u2, user: user}
   {id: u1, user: user}
 ) u0 )))
   find-raven-id)
)

(define-private (check-raven-ownership (index {id: uint, user: principal}) (highest-owned uint))
 (let ((owner (unwrap-panic (contract-call? .odins-raven get-owner (get id index)))))
    (if (and (is-eq highest-owned u0) (is-some owner) (is-eq (get user index) (unwrap! owner highest-owned)))
      (get id index)
      highest-owned)))
```
