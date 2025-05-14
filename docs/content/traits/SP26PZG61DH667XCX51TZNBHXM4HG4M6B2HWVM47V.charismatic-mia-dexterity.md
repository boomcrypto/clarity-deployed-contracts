---
title: "Trait charismatic-mia-dexterity"
draft: true
---
```
;; Charismatic Mia - LP Token, AMM DEX and Hold-to-Earn Engine
;; SP26PZG61DH667XCX51TZNBHXM4HG4M6B2HWVM47V.charismatic-mia-dexterity

;; Implement SIP-010 trait
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-traits-v1.sip010-ft-trait)

;; Define the LP token
(define-fungible-token index)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant CONTRACT (as-contract tx-sender))
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant MAX_SWAP_FEE u250000) ;; 25%
(define-constant PRECISION u1000000)
(define-constant ALPHA u950000)

;; Storage
(define-data-var owner principal DEPLOYER)
(define-data-var energy-burn-amount uint u10000000)
(define-data-var swap-fee uint u50000) ;; Default to 5.0%
(define-data-var token-uri (optional (string-utf8 256)) 
  (some u"https://charisma.rocks/api/v0/indexes/SP26PZG61DH667XCX51TZNBHXM4HG4M6B2HWVM47V.charismatic-mia-dexterity"))
(define-data-var first-start-block uint stacks-block-height)
(define-map last-tap-block principal uint)

;; Configuration functions
(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-eq contract-caller (var-get owner)) ERR_UNAUTHORIZED)
    (ok (var-set owner new-owner))))

(define-public (set-swap-fee (new-fee uint))
  (begin
    (asserts! (is-eq contract-caller (var-get owner)) ERR_UNAUTHORIZED)
    (asserts! (<= new-fee MAX_SWAP_FEE) ERR_UNAUTHORIZED)
    (ok (var-set swap-fee new-fee))))

(define-public (set-energy-burn-amount (new-amount uint))
  (begin
    (asserts! (is-eq contract-caller (var-get owner)) ERR_UNAUTHORIZED)
    (ok (var-set energy-burn-amount new-amount))))

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq contract-caller (var-get owner))
    (ok (var-set token-uri (some value))) 
    ERR_UNAUTHORIZED))

;; Core AMM operations
(define-private (calculate-output-amount (x uint) (y uint) (dx uint) (amp uint))
  (let (
    ;; Constant sum portion (better for similar values)
    (sum-term (/ (* dx y) x))
    ;; Constant product portion (better for different values)
    (product-term (/ (* dx y) (+ x dx)))
    ;; Weighted sum of both terms
    (weighted-output (+ (* (- PRECISION amp) sum-term) (* amp product-term))))
    (/ weighted-output PRECISION)))

(define-public (swap (forward bool) (amt-in uint))
  (let (
    (sender tx-sender)
    (reserve-in (unwrap-panic (if forward (contract-call? 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend get-balance CONTRACT) 
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token  get-balance CONTRACT))))
    (reserve-out (unwrap-panic (if forward (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token  get-balance CONTRACT) 
      (contract-call? 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend get-balance CONTRACT))))
    ;; Calculate raw output amount first
    (raw-out (calculate-output-amount reserve-in reserve-out amt-in ALPHA))
    ;; Check if energy was paid and apply fees to output amount
    (paid-energy (match (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-rulebook-v0 exhaust (var-get energy-burn-amount) sender) success true error false))
    (amt-out (if paid-energy raw-out (/ (* raw-out (- PRECISION (var-get swap-fee))) PRECISION))))
    ;; Execute the swap
    (try! (if forward (contract-call? 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend transfer amt-in sender CONTRACT none) 
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token  transfer amt-in sender CONTRACT none)))
    (try! (as-contract (if forward (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token  transfer amt-out CONTRACT sender none)
      (contract-call? 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend transfer amt-out CONTRACT sender none))))
    (ok {amt-in: amt-in, amt-out: amt-out})))

(define-public (mint (who principal) (amount uint))
  (let (
    (reserve0 (unwrap-panic (contract-call? 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend get-balance CONTRACT)))
    (reserve1 (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token  get-balance CONTRACT)))
    (total-supply (ft-get-supply index))
    (token0-amount (if (is-eq total-supply u0) amount (/ (* amount reserve0) total-supply)))
    (token1-amount (if (is-eq total-supply u0) amount (/ (* amount reserve1) total-supply))))
    (asserts! (is-eq tx-sender who) ERR_UNAUTHORIZED)
    (try! (contract-call? 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend transfer token0-amount who CONTRACT none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token  transfer token1-amount who CONTRACT none))
    (try! (ft-mint? index amount who))
    (ok {token0-amount: token0-amount, token1-amount: token1-amount, lp-amount: amount})))

(define-public (burn (who principal) (amount uint))
  (let (
    (reserve0 (unwrap-panic (contract-call? 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend get-balance CONTRACT)))
    (reserve1 (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token  get-balance CONTRACT)))
    (total-supply (ft-get-supply index))
    (token0-amount (/ (* amount reserve0) total-supply))
    (token1-amount (/ (* amount reserve1) total-supply)))
    (asserts! (is-eq tx-sender who) ERR_UNAUTHORIZED)
    (try! (ft-burn? index amount who))
    (try! (as-contract (contract-call? 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend transfer token0-amount CONTRACT who none)))
    (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token  transfer token1-amount CONTRACT who none)))
    (ok {token0-amount: token0-amount, token1-amount: token1-amount, lp-amount: amount})))

;; Read functions
(define-read-only (get-owner)
  (ok (var-get owner)))

(define-read-only (get-alpha)
  (ok ALPHA))

(define-read-only (get-tokens)
  (ok {token0: 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend, token1: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token }))

(define-read-only (get-swap-fee)
  (ok (var-get swap-fee)))

(define-read-only (get-reserves)
  (ok {
    token0: (unwrap-panic (contract-call? 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend get-balance CONTRACT)),
    token1: (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token  get-balance CONTRACT))
  }))

(define-read-only (get-quote (forward bool) (amt-in uint) (apply-fee bool))
  (let (
    (reserve-in (unwrap-panic (if forward (contract-call? 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend get-balance CONTRACT) 
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token  get-balance CONTRACT))))
    (reserve-out (unwrap-panic (if forward (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token  get-balance CONTRACT) 
      (contract-call? 'SP3YB4JCE0H9QCE63MQ199BM8GXWV24E13G9J381F.mia-meme-token-mobile-legend get-balance CONTRACT))))
    (raw-out (calculate-output-amount reserve-in reserve-out amt-in ALPHA))
    (output-amount (if apply-fee (/ (* raw-out (- PRECISION (var-get swap-fee))) PRECISION) raw-out)))
    (ok output-amount)))

;; SIP-010 Implementation
(define-read-only (get-name)
  (ok "Charismatic Mia"))

(define-read-only (get-symbol)
  (ok "CHAM"))

(define-read-only (get-decimals)
  (ok u6))

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance index who)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply index)))

(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender from) ERR_UNAUTHORIZED)
    (ft-transfer? index amount from to)))

;; Hold-to-Earn functions
(define-private (get-balance-at (data { address: principal, block: uint }))
    (let ((target-block (get block data)))
        (if (< target-block stacks-block-height)
            (let ((block-hash (unwrap-panic (get-stacks-block-info? id-header-hash target-block))))
                (at-block block-hash (unwrap-panic (get-balance (get address data)))))
                (unwrap-panic (get-balance (get address data))))))

(define-private (calculate-trapezoid-areas-39 (balances (list 39 uint)) (dx uint))
    (list
        (/ (* (+ (unwrap-panic (element-at balances u0)) (unwrap-panic (element-at balances u1))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u1)) (unwrap-panic (element-at balances u2))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u2)) (unwrap-panic (element-at balances u3))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u3)) (unwrap-panic (element-at balances u4))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u4)) (unwrap-panic (element-at balances u5))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u5)) (unwrap-panic (element-at balances u6))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u6)) (unwrap-panic (element-at balances u7))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u7)) (unwrap-panic (element-at balances u8))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u8)) (unwrap-panic (element-at balances u9))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u9)) (unwrap-panic (element-at balances u10))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u10)) (unwrap-panic (element-at balances u11))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u11)) (unwrap-panic (element-at balances u12))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u12)) (unwrap-panic (element-at balances u13))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u13)) (unwrap-panic (element-at balances u14))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u14)) (unwrap-panic (element-at balances u15))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u15)) (unwrap-panic (element-at balances u16))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u16)) (unwrap-panic (element-at balances u17))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u17)) (unwrap-panic (element-at balances u18))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u18)) (unwrap-panic (element-at balances u19))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u19)) (unwrap-panic (element-at balances u20))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u20)) (unwrap-panic (element-at balances u21))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u21)) (unwrap-panic (element-at balances u22))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u22)) (unwrap-panic (element-at balances u23))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u23)) (unwrap-panic (element-at balances u24))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u24)) (unwrap-panic (element-at balances u25))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u25)) (unwrap-panic (element-at balances u26))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u26)) (unwrap-panic (element-at balances u27))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u27)) (unwrap-panic (element-at balances u28))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u28)) (unwrap-panic (element-at balances u29))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u29)) (unwrap-panic (element-at balances u30))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u30)) (unwrap-panic (element-at balances u31))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u31)) (unwrap-panic (element-at balances u32))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u32)) (unwrap-panic (element-at balances u33))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u33)) (unwrap-panic (element-at balances u34))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u34)) (unwrap-panic (element-at balances u35))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u35)) (unwrap-panic (element-at balances u36))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u36)) (unwrap-panic (element-at balances u37))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u37)) (unwrap-panic (element-at balances u38))) dx) u2)))

(define-private (calculate-trapezoid-areas-19 (balances (list 19 uint)) (dx uint))
    (list
        (/ (* (+ (unwrap-panic (element-at balances u0)) (unwrap-panic (element-at balances u1))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u1)) (unwrap-panic (element-at balances u2))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u2)) (unwrap-panic (element-at balances u3))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u3)) (unwrap-panic (element-at balances u4))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u4)) (unwrap-panic (element-at balances u5))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u5)) (unwrap-panic (element-at balances u6))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u6)) (unwrap-panic (element-at balances u7))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u7)) (unwrap-panic (element-at balances u8))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u8)) (unwrap-panic (element-at balances u9))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u9)) (unwrap-panic (element-at balances u10))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u10)) (unwrap-panic (element-at balances u11))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u11)) (unwrap-panic (element-at balances u12))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u12)) (unwrap-panic (element-at balances u13))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u13)) (unwrap-panic (element-at balances u14))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u14)) (unwrap-panic (element-at balances u15))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u15)) (unwrap-panic (element-at balances u16))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u16)) (unwrap-panic (element-at balances u17))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u17)) (unwrap-panic (element-at balances u18))) dx) u2)))

(define-private (calculate-trapezoid-areas-9 (balances (list 9 uint)) (dx uint))
    (list
        (/ (* (+ (unwrap-panic (element-at balances u0)) (unwrap-panic (element-at balances u1))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u1)) (unwrap-panic (element-at balances u2))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u2)) (unwrap-panic (element-at balances u3))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u3)) (unwrap-panic (element-at balances u4))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u4)) (unwrap-panic (element-at balances u5))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u5)) (unwrap-panic (element-at balances u6))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u6)) (unwrap-panic (element-at balances u7))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u7)) (unwrap-panic (element-at balances u8))) dx) u2)))

(define-private (calculate-trapezoid-areas-5 (balances (list 5 uint)) (dx uint))
    (list
        (/ (* (+ (unwrap-panic (element-at balances u0)) (unwrap-panic (element-at balances u1))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u1)) (unwrap-panic (element-at balances u2))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u2)) (unwrap-panic (element-at balances u3))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u3)) (unwrap-panic (element-at balances u4))) dx) u2)))

(define-private (calculate-trapezoid-areas-2 (balances (list 2 uint)) (dx uint))
    (list
        (/ (* (+ (unwrap-panic (element-at balances u0)) (unwrap-panic (element-at balances u1))) dx) u2)))

(define-private (calculate-balance-integral-39 (address principal) (start-block uint) (end-block uint))
    (let (
        (sample-points (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.engine-coordinator generate-sample-points-39 address start-block end-block))
        (balances (map get-balance-at sample-points))
        (dx (/ (- end-block start-block) u38))
        (areas (calculate-trapezoid-areas-39 balances dx)))
        (fold + areas u0)))

(define-private (calculate-balance-integral-19 (address principal) (start-block uint) (end-block uint))
    (let (
        (sample-points (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.engine-coordinator generate-sample-points-19 address start-block end-block))
        (balances (map get-balance-at sample-points))
        (dx (/ (- end-block start-block) u18))
        (areas (calculate-trapezoid-areas-19 balances dx)))
        (fold + areas u0)))

(define-private (calculate-balance-integral-9 (address principal) (start-block uint) (end-block uint))
    (let (
        (sample-points (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.engine-coordinator generate-sample-points-9 address start-block end-block))
        (balances (map get-balance-at sample-points))
        (dx (/ (- end-block start-block) u8))
        (areas (calculate-trapezoid-areas-9 balances dx)))
        (fold + areas u0)))

(define-private (calculate-balance-integral-5 (address principal) (start-block uint) (end-block uint))
    (let (
        (sample-points (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.engine-coordinator generate-sample-points-5 address start-block end-block))
        (balances (map get-balance-at sample-points))
        (dx (/ (- end-block start-block) u4))
        (areas (calculate-trapezoid-areas-5 balances dx)))
        (fold + areas u0)))

(define-private (calculate-balance-integral-2 (address principal) (start-block uint) (end-block uint))
    (let (
        (sample-points (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.engine-coordinator generate-sample-points-2 address start-block end-block))
        (balances (map get-balance-at sample-points))
        (dx (/ (- end-block start-block) u1))
        (areas (calculate-trapezoid-areas-2 balances dx)))
        (fold + areas u0)))

(define-private (calculate-balance-integral (address principal) (start-block uint) (end-block uint))
    (let (
        (block-difference (- end-block start-block))
        (thresholds (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.engine-coordinator get-thresholds))))
        (if (>= block-difference (get threshold-39-point thresholds)) (calculate-balance-integral-39 address start-block end-block)
        (if (>= block-difference (get threshold-19-point thresholds)) (calculate-balance-integral-19 address start-block end-block)
        (if (>= block-difference (get threshold-9-point thresholds)) (calculate-balance-integral-9 address start-block end-block)
        (if (>= block-difference (get threshold-5-point thresholds)) (calculate-balance-integral-5 address start-block end-block)
        (calculate-balance-integral-2 address start-block end-block)))))))

(define-read-only (get-last-tap-block (address principal))
    (default-to (var-get first-start-block) (map-get? last-tap-block address)))

(define-public (tap)
  (let (
    (sender tx-sender)
    (end-block stacks-block-height)
    (start-block (get-last-tap-block sender))
    (balance-integral (calculate-balance-integral sender start-block end-block))
    (incentive-score (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.engine-coordinator get-incentive-score CONTRACT))
    (circulating-supply (unwrap-panic (get-total-supply)))
    (potential-energy (/ (* balance-integral incentive-score) circulating-supply)))
    (map-set last-tap-block sender end-block)
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-rulebook-v0 energize potential-energy sender)))

(begin (mint DEPLOYER u1000000))  

```
