;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Trading Platform Wrapper Contract
;; Charges 2% fee on trades and forwards to the underlying router
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
(use-trait univ2v2-pool-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-trait_v1_0_0.univ2-pool-trait)
(use-trait univ2v2-fees-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-fees-trait_v1_0_0.univ2-fees-trait)
(use-trait curve-pool-trait   'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-pool-trait_v1_0_0.curve-pool-trait)
(use-trait curve-fees-trait   'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-fees-trait_v1_0_0.curve-fees-trait)
(use-trait ststx-pool-trait   'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-pool-trait_ststx.curve-pool-trait)
(use-trait ststx-proxy-trait  'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-proxy-trait_ststx.curve-proxy-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Constants
(define-constant ERR-INVALID-AMOUNT (err u400))

;; Fee configuration (2% = 200 basis points)
(define-constant FEE-BASIS-POINTS u200)
(define-constant BASIS-POINTS-DIVISOR u10000)

;; Fee recipient wallet address - replace with your actual wallet address
(define-constant FEE-RECIPIENT 'SP18HGJPA6R3D8AD7SQT16M5G6WCQA5SAJCF101RN) ;; Replace with your wallet address

;; Underlying router contract - replace with actual deployed address
(define-constant ROUTER-CONTRACT 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Helper functions

(define-read-only (calculate-fee (amount uint))
  (/ (* amount FEE-BASIS-POINTS) BASIS-POINTS-DIVISOR))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Main trading function with fee collection

(define-public 
  (trade-with-fee
   (path   (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
   (amt-in uint)
   
   ;; All the same parameters as the original contract
   (token1         (optional <ft-trait>))
   (token2         (optional <ft-trait>))
   (token3         (optional <ft-trait>))
   (token4         (optional <ft-trait>))
   (token5         (optional <ft-trait>))

   (share-fee-to   (optional <share-fee-to-trait>))

   (univ2v2-pool-1 (optional <univ2v2-pool-trait>))
   (univ2v2-pool-2 (optional <univ2v2-pool-trait>))
   (univ2v2-pool-3 (optional <univ2v2-pool-trait>))
   (univ2v2-pool-4 (optional <univ2v2-pool-trait>))

   (univ2v2-fees-1 (optional <univ2v2-fees-trait>))
   (univ2v2-fees-2 (optional <univ2v2-fees-trait>))
   (univ2v2-fees-3 (optional <univ2v2-fees-trait>))
   (univ2v2-fees-4 (optional <univ2v2-fees-trait>))

   (curve-pool-1   (optional <curve-pool-trait>))
   (curve-pool-2   (optional <curve-pool-trait>))
   (curve-pool-3   (optional <curve-pool-trait>))
   (curve-pool-4   (optional <curve-pool-trait>))

   (curve-fees-1   (optional <curve-fees-trait>))
   (curve-fees-2   (optional <curve-fees-trait>))
   (curve-fees-3   (optional <curve-fees-trait>))
   (curve-fees-4   (optional <curve-fees-trait>))

   (ststx-pool-1   (optional <ststx-pool-trait>))
   (ststx-pool-2   (optional <ststx-pool-trait>))
   (ststx-pool-3   (optional <ststx-pool-trait>))
   (ststx-pool-4   (optional <ststx-pool-trait>))

   (ststx-proxy-1   (optional <ststx-proxy-trait>))
   (ststx-proxy-2   (optional <ststx-proxy-trait>))
   (ststx-proxy-3   (optional <ststx-proxy-trait>))
   (ststx-proxy-4   (optional <ststx-proxy-trait>))
   )
  
  (let ((fee-amount (calculate-fee amt-in)))
    
    ;; Validate input amount
    (asserts! (> amt-in u0) ERR-INVALID-AMOUNT)
    
    ;; Collect fee in STX from the caller
    (try! (stx-transfer? fee-amount tx-sender FEE-RECIPIENT))
    
    ;; Call the underlying router contract - just like your charisma example
    (let ((trade-result 
           (try! (contract-call? 
                   ROUTER-CONTRACT
                   apply
                   path
                   amt-in
                   token1 token2 token3 token4 token5
                   share-fee-to
                   univ2v2-pool-1 univ2v2-pool-2 univ2v2-pool-3 univ2v2-pool-4
                   univ2v2-fees-1 univ2v2-fees-2 univ2v2-fees-3 univ2v2-fees-4
                   curve-pool-1 curve-pool-2 curve-pool-3 curve-pool-4
                   curve-fees-1 curve-fees-2 curve-fees-3 curve-fees-4
                   ststx-pool-1 ststx-pool-2 ststx-pool-3 ststx-pool-4
                   ststx-proxy-1 ststx-proxy-2 ststx-proxy-3 ststx-proxy-4))))
      
      ;; Print event for tracking
      (print {event: "trade-with-fee", 
              user: tx-sender, 
              fee-amount: fee-amount, 
              input-amount: amt-in,
              output-amount: (get amt-out (get swap4 trade-result))})
      
      (ok trade-result))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Alternative: Fee based on trade output value
;; This charges fee on the output amount instead of input

(define-public 
  (trade-with-output-fee
   (path   (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
   (amt-in uint)
   (min-fee-stx uint) ;; Minimum STX fee the user agrees to pay
   
   ;; All the same parameters...
   (token1         (optional <ft-trait>))
   (token2         (optional <ft-trait>))
   (token3         (optional <ft-trait>))
   (token4         (optional <ft-trait>))
   (token5         (optional <ft-trait>))
   (share-fee-to   (optional <share-fee-to-trait>))
   (univ2v2-pool-1 (optional <univ2v2-pool-trait>))
   (univ2v2-pool-2 (optional <univ2v2-pool-trait>))
   (univ2v2-pool-3 (optional <univ2v2-pool-trait>))
   (univ2v2-pool-4 (optional <univ2v2-pool-trait>))
   (univ2v2-fees-1 (optional <univ2v2-fees-trait>))
   (univ2v2-fees-2 (optional <univ2v2-fees-trait>))
   (univ2v2-fees-3 (optional <univ2v2-fees-trait>))
   (univ2v2-fees-4 (optional <univ2v2-fees-trait>))
   (curve-pool-1   (optional <curve-pool-trait>))
   (curve-pool-2   (optional <curve-pool-trait>))
   (curve-pool-3   (optional <curve-pool-trait>))
   (curve-pool-4   (optional <curve-pool-trait>))
   (curve-fees-1   (optional <curve-fees-trait>))
   (curve-fees-2   (optional <curve-fees-trait>))
   (curve-fees-3   (optional <curve-fees-trait>))
   (curve-fees-4   (optional <curve-fees-trait>))
   (ststx-pool-1   (optional <ststx-pool-trait>))
   (ststx-pool-2   (optional <ststx-pool-trait>))
   (ststx-pool-3   (optional <ststx-pool-trait>))
   (ststx-pool-4   (optional <ststx-pool-trait>))
   (ststx-proxy-1   (optional <ststx-proxy-trait>))
   (ststx-proxy-2   (optional <ststx-proxy-trait>))
   (ststx-proxy-3   (optional <ststx-proxy-trait>))
   (ststx-proxy-4   (optional <ststx-proxy-trait>))
   )
  
  (let ((trade-result 
         (try! (contract-call? 
                 ROUTER-CONTRACT
                 apply
                 path
                 amt-in
                 token1 token2 token3 token4 token5
                 share-fee-to
                 univ2v2-pool-1 univ2v2-pool-2 univ2v2-pool-3 univ2v2-pool-4
                 univ2v2-fees-1 univ2v2-fees-2 univ2v2-fees-3 univ2v2-fees-4
                 curve-pool-1 curve-pool-2 curve-pool-3 curve-pool-4
                 curve-fees-1 curve-fees-2 curve-fees-3 curve-fees-4
                 ststx-pool-1 ststx-pool-2 ststx-pool-3 ststx-pool-4
                 ststx-proxy-1 ststx-proxy-2 ststx-proxy-3 ststx-proxy-4)))
        (final-output (get amt-out (get swap4 trade-result)))
        (calculated-fee (calculate-fee final-output))
        (actual-fee (if (> calculated-fee min-fee-stx) calculated-fee min-fee-stx)))
    
    ;; Collect fee based on output value
    (try! (stx-transfer? actual-fee tx-sender FEE-RECIPIENT))
    
    (ok trade-result)))

;;; eof