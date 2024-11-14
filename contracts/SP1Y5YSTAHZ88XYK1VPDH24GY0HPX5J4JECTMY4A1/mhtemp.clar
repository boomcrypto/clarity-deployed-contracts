;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(use-trait share-fee-to-trait .univ2-share-fee-to-trait.share-fee-to-trait)

(use-trait pool-trait     .curve-pool-trait_v1_0_0.curve-pool-trait)
(use-trait lp-token-trait .curve-lp-token-trait_v1_0_0.curve-lp-token-trait)
(use-trait fees-trait     .curve-fees-trait_v1_0_0.curve-fees-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-constant err-router-preconditions  (err u200))
(define-constant err-router-postconditions (err u201))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; winning
(define-constant WSTX-AEUSDC u6)

(define-public
 (wstx-to-usdh
  (wstx         <ft-trait>)
  (aeusdc       <ft-trait>)
  (usdh         <ft-trait>)
  (share-fee-to <share-fee-to-trait>)
  (usdh-aeusdc  <pool-trait>)
  (fees         <fees-trait>)
  (amt-in       uint) ;;wstx
  (amt-out-min  uint) ;;usdh
  )
 (let ((swap1
        (try!
         (contract-call?
          .univ2-router
          swap-exact-tokens-for-tokens
          WSTX-AEUSDC wstx aeusdc wstx aeusdc share-fee-to amt-in u1)))
       (swap2
        (try!
         (contract-call?
          usdh-aeusdc
          swap
          aeusdc usdh fees (get amt-out swap1) u1)))
       )
   (ok {swap1: swap1, swap2: swap2})))


(define-public
 (usdh-to-wstx
  (usdh         <ft-trait>)
  (aeusdc       <ft-trait>)
  (wstx         <ft-trait>)
  (share-fee-to <share-fee-to-trait>)
  (usdh-aeusdc  <pool-trait>)
  (fees         <fees-trait>)
  (amt-in       uint) ;;usdh
  (amt-out-min  uint) ;;wstx
  )
 (let ((swap1
        (try!
         (contract-call?
          usdh-aeusdc
          swap
          usdh aeusdc fees amt-in u1)))
       (swap2
        (try!
         (contract-call?
          .univ2-router
          swap-exact-tokens-for-tokens
          WSTX-AEUSDC wstx aeusdc aeusdc wstx share-fee-to (get amt-out swap1) u1)))
       )
   (ok {swap1: swap1, swap2: swap2})))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (define-read-only
;;  (mint-burn-law
;;   (pool     <pool-trait>)
;;   (lp-token <lp-token-trait>)
;;   (dx       uint)
;;   (dy       uint))
;;  (let ((s (contract-call? pool do-get-pool))
;;        (x (get r0 s))
;;        (y (get r1 s))
;;        (A (get A  s))
;;        (u (try! (contract-call? lp-token get-total-supply)))
;;        (v (contract-call? .curve-math_v1_0_0 mint x dx y dy u A))
;;        (z (contract-call? .curve-math_v1_0_0 burn (+ x dx) (+ y dy) (+ u v) v))
;;        )
;;    {dx: dx,
;;     dy: dy,
;;     s : s,
;;     u : u,
;;     v : v,
;;     z : z}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public
 (swap-and-mint
  (pool     <pool-trait>)
  (fees     <fees-trait>)
  (lp-token <lp-token-trait>)
  (token0   <ft-trait>)
  (token1   <ft-trait>)
  (amt0     uint)
  (amt1     uint))
 (let ((ss0       (is-eq amt1 u0))
       (ss1       (is-eq amt0 u0))
       (token-in  (if ss0 token0 token1))
       (token-out (if ss0 token1 token0))
       ;; arbitrary / could be optimized
       (amt-in    (if ss0 (/ amt0 u100) (/ amt1 u100))) )
   (if (or ss0 ss1)
       (let ((ev (try! (contract-call? pool swap token-in token-out fees amt-in u1)))
             (amt0-final (if ss0 (- amt0 amt-in) (get amt-out ev)))
             (amt1-final (if ss1 (- amt1 amt-in) (get amt-out ev))) )
         (contract-call? pool mint token0 token1 lp-token amt0-final amt1-final))
       (contract-call? pool mint token0 token1 lp-token amt0 amt1)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public
 (burn-and-swap
  (pool     <pool-trait>)
  (fees     <fees-trait>)
  (lp-token <lp-token-trait>)
  (token0   <ft-trait>)
  (token1   <ft-trait>)
  (liq      uint)
  (want0    bool)
  (want1    bool))
 (let ((burn (try! (contract-call? pool burn token0 token1 lp-token liq))))
   (asserts! (not (and want0 want1)) err-router-preconditions)
   ;; no union types :/
   (if (or want0 want1)
       (let ((token-in  (if want0 token1 token0))
             (token-out (if want0 token0 token1))
             (amt-in    (if want0 (get amt1 burn) (get amt0 burn)))
             (swap      (try! (contract-call? pool swap token-in token-out fees amt-in u1))) )
         (ok true))
       (ok true)) ))

;;; eof
