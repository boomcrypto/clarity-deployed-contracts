;; constants
;;

(define-constant ERR-INVALID-LIQUIDITY (err u2003))
(define-constant ERR-REWARD-CYCLE-NOT-COMPLETED (err u10017))
(define-constant ERR-STAKING-NOT-AVAILABLE (err u10015))
(define-constant ERR-GET-BALANCE-FIXED-FAIL (err u6001))
(define-constant ERR-NOT-ACTIVATED (err u2043))
(define-constant ERR-ACTIVATED (err u2044))
(define-constant ERR-USER-ID-NOT-FOUND (err u10003))
(define-constant ERR-INSUFFICIENT-BALANCE (err u2045))
(define-constant ERR-INVALID-PERCENT (err u5000))
(define-fungible-token auto-alex)

(define-data-var end-cycle uint u340282366920938463463374607431768211455)
(define-data-var start-block uint u340282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)
(define-data-var token-decimals uint u8)
(define-data-var total-supply uint u0)

(define-private (get-reward-cycle (stack-height uint))
  (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.alex-reserve-pool get-reward-cycle 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token stack-height)
)
(define-private (stake-tokens (amount-tokens uint) (lock-period uint))
  (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.alex-reserve-pool stake-tokens 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token amount-tokens lock-period)
)
;; @desc fixed-to-decimals
;; @params amount
;; @returns uint
(define-read-only (fixed-to-decimals (amount uint))
  (/ (* amount (pow-decimals)) ONE_8)
)
(define-read-only (get-decimals)
	(ok (var-get token-decimals))
)
(define-private (pow-decimals)
  (pow u10 (unwrap-panic (get-decimals)))
)
(define-public (add-to-position (dx uint)) 
  (let
    (            
      (current-cycle (unwrap! (get-reward-cycle block-height) ERR-STAKING-NOT-AVAILABLE))
    )
    (asserts! (> (var-get end-cycle) current-cycle) ERR-STAKING-NOT-AVAILABLE)
    (asserts! (>= block-height (var-get start-block)) ERR-NOT-ACTIVATED)        
    (asserts! (> dx u0) ERR-INVALID-LIQUIDITY)
    
    (let
      (
        (sender tx-sender)
        (cycles-to-stake (if (> (var-get end-cycle) (+ current-cycle u32)) u32 (- (var-get end-cycle) current-cycle)))
        (new-supply (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position dx)))        
        (new-total-supply (+ (var-get total-supply) new-supply))
      )
      ;; transfer dx to contract to stake for max cycles
      (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token transfer-fixed dx sender (as-contract tx-sender) none))
      (as-contract (try! (stake-tokens dx cycles-to-stake)))
        
      ;; mint pool token and send to tx-sender
      (var-set total-supply new-total-supply)
	    (try! (ft-mint? auto-alex (fixed-to-decimals new-supply) sender))
      (print { object: "pool", action: "position-added", data: {new-supply: new-supply, total-supply: new-total-supply }})
      (ok new-supply)
    )
  )
)
