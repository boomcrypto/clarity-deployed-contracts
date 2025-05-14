;; keeper-action-10-v-1-1

;; Implement keeper action trait
(impl-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-action-trait-v-1-1.keeper-action-trait)

;; Use all required traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait keeper-action-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-action-trait-v-1-1.keeper-action-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait xyk-staking-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-staking-trait-v-1-2.xyk-staking-trait)
(use-trait xyk-emissions-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-emissions-trait-v-1-2.xyk-emissions-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait stableswap-staking-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-trait-v-1-2.stableswap-staking-trait)
(use-trait stableswap-emissions-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-emissions-trait-v-1-2.stableswap-emissions-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u10001))
(define-constant ERR_MINIMUM_RECEIVED (err u10002))
(define-constant ERR_INVALID_HELPER_DATA (err u10003))
(define-constant ERR_INVALID_PARAMETER_LIST (err u10004))
(define-constant ERR_INVALID_LIST_ELEMENT (err u10005))

;; Get output for execute-action function
(define-public (get-output
    (amount uint) (min-received uint)
    (fee-recipient principal) (owner-address principal)
    (bitcoin-address (buff 64)) (keeper-address principal)
    (token-list (optional (list 26 <ft-trait>)))
    (xyk-pool-list (optional (list 26 <xyk-pool-trait>)))
    (xyk-staking-list (optional (list 26 <xyk-staking-trait>)))
    (xyk-emissions-list (optional (list 26 <xyk-emissions-trait>)))
    (stableswap-pool-list (optional (list 26 <stableswap-pool-trait>)))
    (stableswap-staking-list (optional (list 26 <stableswap-staking-trait>)))
    (stableswap-emissions-list (optional (list 26 <stableswap-emissions-trait>)))
    (uint-list (optional (list 26 uint)))
    (bool-list (optional (list 26 bool)))
    (principal-list (optional (list 26 principal)))
  )
  (ok u0)
)

;; Get minimum amount for execute-action function
(define-public (get-minimum
    (amount uint) (min-received uint)
    (fee-recipient principal) (owner-address principal)
    (bitcoin-address (buff 64)) (keeper-address principal)
    (token-list (optional (list 26 <ft-trait>)))
    (xyk-pool-list (optional (list 26 <xyk-pool-trait>)))
    (xyk-staking-list (optional (list 26 <xyk-staking-trait>)))
    (xyk-emissions-list (optional (list 26 <xyk-emissions-trait>)))
    (stableswap-pool-list (optional (list 26 <stableswap-pool-trait>)))
    (stableswap-staking-list (optional (list 26 <stableswap-staking-trait>)))
    (stableswap-emissions-list (optional (list 26 <stableswap-emissions-trait>)))
    (uint-list (optional (list 26 uint)))
    (bool-list (optional (list 26 bool)))
    (principal-list (optional (list 26 principal)))
  )
  (ok u0)
)

;; Perform execute-action function
(define-public (execute-action 
    (amount uint) (min-received uint)
    (fee-recipient principal) (owner-address principal)
    (bitcoin-address (buff 64)) (keeper-address principal)
    (token-list (optional (list 26 <ft-trait>)))
    (xyk-pool-list (optional (list 26 <xyk-pool-trait>)))
    (xyk-staking-list (optional (list 26 <xyk-staking-trait>)))
    (xyk-emissions-list (optional (list 26 <xyk-emissions-trait>)))
    (stableswap-pool-list (optional (list 26 <stableswap-pool-trait>)))
    (stableswap-staking-list (optional (list 26 <stableswap-staking-trait>)))
    (stableswap-emissions-list (optional (list 26 <stableswap-emissions-trait>)))
    (uint-list (optional (list 26 uint)))
    (bool-list (optional (list 26 bool)))
    (principal-list (optional (list 26 principal)))
  )
  (let (
    ;; Unwrap required lists from parameters
    (unwrapped-token-list (unwrap! token-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-xyk-emissions-list (unwrap! xyk-emissions-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-stableswap-emissions-list (unwrap! stableswap-emissions-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-uint-list (unwrap! uint-list ERR_INVALID_PARAMETER_LIST))
    (unwrapped-bool-list (unwrap! bool-list ERR_INVALID_PARAMETER_LIST))

    ;; Get token a trait
    (token-trait-a (unwrap! (element-at? unwrapped-token-list u0) ERR_INVALID_LIST_ELEMENT))

    ;; Get transfer-to-owner
    (transfer-to-owner (default-to true (element-at? unwrapped-bool-list u0)))

    ;; Get number of cycles to claim
    (cycles-to-claim (unwrap! (element-at? unwrapped-uint-list u0) ERR_INVALID_LIST_ELEMENT))

    ;; Claim rewards from XYK or Stableswap emissions contract
    (claim-rewards-result (if (is-eq (len unwrapped-xyk-emissions-list) u1)
      (try! (xyk-claim-rewards-multi owner-address unwrapped-xyk-emissions-list amount cycles-to-claim))
      (if (is-eq (len unwrapped-stableswap-emissions-list) u1) (try! (stableswap-claim-rewards-multi owner-address unwrapped-stableswap-emissions-list amount cycles-to-claim)) u0)
    ))

    ;; Get keeper fee and calculate updated amount
    (keeper-fee-amount (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.keeper-4-helper-v-1-1 get-keeper-fee-amount claim-rewards-result) ERR_INVALID_HELPER_DATA))
    (amount-after-keeper-fee (- claim-rewards-result keeper-fee-amount))

    ;; Transfer keeper fee from the contract to fee-recipient
    (transfer-keeper-fee (if (> keeper-fee-amount u0)
      (try! (contract-call? token-trait-a transfer keeper-fee-amount tx-sender fee-recipient none))
      false
    ))
  )
    ;; Transfer amount-after-keeper-fee rewards from the contract to owner-address if transfer-to-owner is true
    (if (and transfer-to-owner (> amount-after-keeper-fee u0)) (try! (contract-call? token-trait-a transfer amount-after-keeper-fee tx-sender owner-address none)) false)

    (begin
      ;; Print action data and return stake-lp-result
      (print {
        action: "execute-action",
        contract: (as-contract tx-sender),
        caller: tx-sender,
        data: {
          keeper-fee-amount: keeper-fee-amount,
          transfer-to-owner: transfer-to-owner,
          cycles-to-claim: cycles-to-claim,
          claim-rewards-result: claim-rewards-result
        }
      })
      (ok claim-rewards-result)
    )
  )
)

;; Define CYCLES_LIST
(define-constant CYCLES_LIST (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20
                             u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40
                             u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60
                             u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80
                             u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100
                             u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116
                             u117 u118 u119 u120))

;; Data vars used for generating list of cycles to claim
(define-data-var helper-value uint u0)
(define-data-var helper-list (list 12000 uint) (list ))

;; Claim rewards at multiple cycles from 1 XYK emissions contract
(define-private (xyk-claim-rewards-multi
  (owner-address principal)
  (xyk-emissions-traits (list 26 <xyk-emissions-trait>))
  (starting-cycle uint) (cycles-to-claim uint)
)
  (let (
    ;; Get XYK emissions trait
    (em-trait (unwrap! (element-at? xyk-emissions-traits u0) ERR_INVALID_LIST_ELEMENT))
    
    ;; Generate list of cycles to claim
    (helper-value-for-filter (var-set helper-value cycles-to-claim))
    (filtered-cycles-list (filter filter-values-lte-helper-value CYCLES_LIST))
    (helper-value-for-map (var-set helper-value starting-cycle))
    (cycles-to-claim-list (filter filter-out-values-contained-in-helper-list (map sum-with-helper-value filtered-cycles-list)))

    ;; List of emissions traits for map
    (emissions-trait-list (list em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait))

    ;; Claim rewards and calculate total-rewards-claimed
    (claim-rewards-result (map xyk-claim-rewards emissions-trait-list cycles-to-claim-list))
    (total-rewards-claimed (fold + claim-rewards-result u0))
  )
    ;; Return total-rewards-claimed
    (ok total-rewards-claimed)
  )
)

;; Claim rewards at multiple cycles from 1 Stableswap emissions contract
(define-private (stableswap-claim-rewards-multi
  (owner-address principal)
  (stableswap-emissions-traits (list 26 <stableswap-emissions-trait>))
  (starting-cycle uint) (cycles-to-claim uint)
)
  (let (
    ;; Get Stableswap emissions trait
    (em-trait (unwrap! (element-at? stableswap-emissions-traits u0) ERR_INVALID_LIST_ELEMENT))

    ;; Generate list of cycles to claim
    (helper-value-for-filter (var-set helper-value cycles-to-claim))
    (filtered-cycles-list (filter filter-values-lte-helper-value CYCLES_LIST))
    (helper-value-for-map (var-set helper-value starting-cycle))
    (cycles-to-claim-list (filter filter-out-values-contained-in-helper-list (map sum-with-helper-value filtered-cycles-list)))

    ;; List of emissions traits for map
    (emissions-trait-list (list em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait
                          em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait em-trait))

    ;; Claim rewards and calculate total-rewards-claimed
    (claim-rewards-result (map stableswap-claim-rewards emissions-trait-list cycles-to-claim-list))
    (total-rewards-claimed (fold + claim-rewards-result u0))
  )
    ;; Return total-rewards-claimed
    (ok total-rewards-claimed)
  )
)

;; Claim rewards at 1 cycle from 1 XYK emissions contract
(define-private (xyk-claim-rewards (emissions-trait <xyk-emissions-trait>) (cycle uint))
  (begin
    (match (contract-call? emissions-trait claim-rewards cycle)
      result (get user-rewards result)
      error u0
    )
  )
)

;; Claim rewards at 1 cycle from 1 Stableswap emissions contract
(define-private (stableswap-claim-rewards (emissions-trait <stableswap-emissions-trait>) (cycle uint))
  (begin
    (match (contract-call? emissions-trait claim-rewards cycle)
      result (get user-rewards result)
      error u0
    )
  )
)

;; Helper functions used for generating list of cycles to claim
(define-private (sum-with-helper-value (value uint)) 
  (+ (var-get helper-value) value)
)
(define-private (filter-values-lte-helper-value (value uint)) 
  (<= value (var-get helper-value))
)
(define-private (filter-out-values-contained-in-helper-list (value uint)) 
  (not (is-some (index-of (var-get helper-list) value)))
)