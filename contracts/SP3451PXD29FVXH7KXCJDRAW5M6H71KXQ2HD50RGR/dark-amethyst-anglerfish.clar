;; title: testing
;; version:
;; summary:
;; description:

;; traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
(use-trait univ2v2-pool-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-trait_v1_0_0.univ2-pool-trait)
(use-trait univ2v2-fees-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-fees-trait_v1_0_0.univ2-fees-trait)
(use-trait curve-pool-trait   'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-pool-trait_v1_0_0.curve-pool-trait)
(use-trait curve-fees-trait   'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-fees-trait_v1_0_0.curve-fees-trait)

;; constants
(define-constant ERR-EXCEEDS-MAX-SLIPPAGE (err u2005))
(define-constant ERR-TOKEN-IN (err u1000000))
(define-constant ERR-TOKEN-OUT (err u1000001))
(define-constant ERR-NOT-AUTHORIZED (err u810000000))
(define-constant ERR-INVALID-POINT (err u820000000))

;; data vars
(define-data-var fee-point uint u100)
(define-data-var fee-receiver principal tx-sender)
(define-data-var contract-owner principal tx-sender)

(define-public (set-fee-point (point uint))
    (begin 
        (try! (check-is-owner))
        (try! (check-is-valid-point point))
        ;; #[allow(unchecked_data)]
        (ok (var-set fee-point point))
    )
)

(define-public (set-fee-receiver (receiver principal))
  (begin
    (try! (check-is-owner))
    ;; #[allow(unchecked_data)]
    (ok (var-set fee-receiver receiver))
  )
)

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    ;; #[allow(unchecked_data)]
    (ok (var-set contract-owner owner))
  )
)

(define-private (check-is-owner)
    (ok (asserts! (is-eq contract-caller (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-valid-point (p uint))
    (ok (asserts! (<= p u10000) ERR-INVALID-POINT))
)

(define-private (get-sender)
    (begin 
        (asserts! (is-eq contract-caller tx-sender) ERR-NOT-AUTHORIZED)
        (ok tx-sender)
    )
)

;; read only functions
(define-read-only (get-fee-point)
    (ok (var-get fee-point))
)

(define-read-only (get-fee-receiver)
  (ok (var-get fee-receiver))
)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-private (balance-of-this (token <ft-trait>)) 
    ;; #[allow(unchecked_data)]
    (contract-call? token get-balance (as-contract tx-sender))
)

(define-private (transfer-in-internal (token <ft-trait>) (amount uint))
    ;; #[allow(unchecked_data)]
    (let 
        (
            (sender tx-sender) 
        )
        (ok 
            (or 
                (is-eq amount u0) 
                (try! (contract-call? token transfer amount sender (as-contract tx-sender) none))
            )
        )
    )
)

(define-private (transfer-out-internal (token <ft-trait>) (receiver principal) (amount uint))
    ;; #[allow(unchecked_data)]
    (ok 
        (or 
            (is-eq amount u0) 
            (as-contract (try! (contract-call? token transfer amount (as-contract tx-sender) receiver none)))
        )
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public
  (apply
   (in-as-fee   bool)
   (amt-out-min uint)

   (path   (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
   (amt-in uint)

   ;; ctx
   (token1         (optional <ft-trait>))
   (token2         (optional <ft-trait>))
   (token3         (optional <ft-trait>))
   (token4         (optional <ft-trait>))
   (token5         (optional <ft-trait>))

   ;; v1
   (share-fee-to   (optional <share-fee-to-trait>))

   ;; v2
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
   (curve-fees-4   (optional <curve-fees-trait>)))

   (let
      (
        (token-in (unwrap! token1 ERR-TOKEN-IN))
        (token-out (unwrap! (if (is-some token5) token5 (if (is-some token4) token4 (if (is-some token3) token3 token2))) ERR-TOKEN-OUT))
      )
      (if in-as-fee
          (let 
            (
                (sender (try! (get-sender)))
                (amt-fee (/ (* amt-in (var-get fee-point)) u10000))
                (amt-swap-in (- amt-in amt-fee))
                (amt-out (try! (apply-internal token-in token-out amt-in amt-swap-in path token1 token2 token3 token4 token5 share-fee-to 
                                                univ2v2-pool-1 univ2v2-pool-2 univ2v2-pool-3 univ2v2-pool-4
                                                univ2v2-fees-1 univ2v2-fees-2 univ2v2-fees-3 univ2v2-fees-4
                                                curve-pool-1 curve-pool-2 curve-pool-3 curve-pool-4
                                                curve-fees-1 curve-fees-2 curve-fees-3 curve-fees-4)))
                (extra-fee (try! (balance-of-this token-in)))
            )
            (asserts! (<= amt-out-min amt-out) ERR-EXCEEDS-MAX-SLIPPAGE)
            (try! (transfer-out-internal token-out sender amt-out))
            (print {extra-fee: extra-fee, receiver: (var-get fee-receiver), amt-in: amt-swap-in, amt-out: amt-out})
            (ok (try! (transfer-out-internal token-in (var-get fee-receiver) extra-fee)))
          )
          (let 
            (
                (sender (try! (get-sender)))
                (amt-swap-out (try! (apply-internal token-in token-out amt-in amt-in path token1 token2 token3 token4 token5 share-fee-to 
                                                univ2v2-pool-1 univ2v2-pool-2 univ2v2-pool-3 univ2v2-pool-4
                                                univ2v2-fees-1 univ2v2-fees-2 univ2v2-fees-3 univ2v2-fees-4
                                                curve-pool-1 curve-pool-2 curve-pool-3 curve-pool-4
                                                curve-fees-1 curve-fees-2 curve-fees-3 curve-fees-4)))
                (extra-fee (/ (* amt-swap-out (var-get fee-point)) u10000))
                (amt-out (- amt-swap-out extra-fee))
            )
            (asserts! (<= amt-out-min amt-out) ERR-EXCEEDS-MAX-SLIPPAGE)
            (try! (transfer-out-internal token-out sender amt-out))
            (print {extra-fee: extra-fee, receiver: (var-get fee-receiver), amt-in: amt-in, amt-out: amt-out})
            (ok (try! (transfer-out-internal token-out (var-get fee-receiver) extra-fee)))
          )
      )
   )
)

(define-private (apply-internal
    (token-in    <ft-trait>)
    (token-out   <ft-trait>)
    (amt-in      uint)
    (amt-swap-in uint)

    (path   (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))

    ;; ctx
    (token1         (optional <ft-trait>))
    (token2         (optional <ft-trait>))
    (token3         (optional <ft-trait>))
    (token4         (optional <ft-trait>))
    (token5         (optional <ft-trait>))

    ;; v1
    (share-fee-to   (optional <share-fee-to-trait>))

    ;; v2
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
    )
    ;; #[allow(unchecked_data)]
    (begin
      (try! (transfer-in-internal token-in amt-in))
      (try! (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.path-apply_v1_2_0 apply 
                                            path amt-swap-in token1 token2 token3 token4 token5 share-fee-to 
                                            univ2v2-pool-1 univ2v2-pool-2 univ2v2-pool-3 univ2v2-pool-4
                                            univ2v2-fees-1 univ2v2-fees-2 univ2v2-fees-3 univ2v2-fees-4
                                            curve-pool-1 curve-pool-2 curve-pool-3 curve-pool-4
                                            curve-fees-1 curve-fees-2 curve-fees-3 curve-fees-4)))
      (ok (try! (balance-of-this token-out)))
    )
)