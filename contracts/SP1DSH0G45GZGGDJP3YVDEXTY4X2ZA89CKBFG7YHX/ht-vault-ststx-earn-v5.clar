;; @contract Vault
;; @version 1

;;-------------------------------------
;; Errors 
;;-------------------------------------

(define-constant ERR_NO_ENTRY_FOR_ID (err u3001)) 
(define-constant ERR_NO_CLAIM_FOR_CLAIM_ID (err u3002)) 
(define-constant ERR_DEPOSITS_NOT_ALLOWED (err u3003))
(define-constant ERR_INVALID_AMOUNT (err u3004))
(define-constant ERR_VAULT_CAPACITY_EXCEEDED (err u3005))
(define-constant ERR_AMOUNT_BELOW_MIN (err u3006))
(define-constant ERR_ONLY_CORE_CONTRACT_ALLOWED (err u3007))
(define-constant ERR_NOT_ENOUGH_TOKENS_RESERVED_FOR_CLAIMS (err u3008))
(define-constant ERR_NOT_ENOUGH_UNDERLYING_RESERVED_FOR_CLAIMS (err u3009))
(define-constant ERR_INSUFFICIENT_CONTRACT_FUNDS (err u3010))
(define-constant ERR_MAX_CLAIMS (err u3011))

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant vault (as-contract tx-sender))

(define-constant token-base (pow u10 u6))
(define-constant bps-base u10000) ;; 1 bps = 0,01%

;;-------------------------------------
;; Variables 
;;-------------------------------------

(define-data-var total-pending-deposits uint u0)
(define-data-var underlying-reserved-for-claims uint u0) ;; for unclaimd withdrawals
(define-data-var tokens-reserved-for-claims uint u0) ;; for unclaimed deposits

(define-data-var claim-amount-helper uint u0)
(define-data-var claim-principal-helper principal tx-sender)
(define-data-var claim-id-helper uint u0)

(define-data-var current-claim-id uint u0)
(define-data-var current-epoch-id uint u0)

;;-------------------------------------
;; Maps 
;;-------------------------------------

(define-map claims 
  { 
    claim-id: uint 
  } 
  { 
    address: principal,
    epoch-id: uint,
    underlying-amount: uint, ;; for deposit claims
    token-amount: uint ;; for withdrawal claims
  }
)

(define-map claims-for-address 
  { 
    address: principal 
  } 
  { 
    deposit-claims: (list 1000 uint), ;; containing claim-ids
    withdrawal-claims: (list 1000 uint), ;; containing claim-ids
  }
)

(define-map epoch-info-for-claims
  { 
    epoch-id: uint 
  } 
  { 
    underlying-per-token-settled: (optional uint)
  }
)

;;-------------------------------------
;; Getters 
;;-------------------------------------

(define-read-only (get-epoch-info-for-claims (epoch-id uint)) 
  (ok (unwrap! (map-get? epoch-info-for-claims { epoch-id: epoch-id }) ERR_NO_ENTRY_FOR_ID)))

(define-read-only (get-claim (claim-id uint))
  (ok (unwrap! (map-get? claims { claim-id: claim-id }) ERR_NO_CLAIM_FOR_CLAIM_ID)))

(define-read-only (get-claims-for-address (address principal)) 
  (default-to 
    { deposit-claims: (list), withdrawal-claims: (list) } 
    (map-get? claims-for-address { address: address })))

(define-read-only (get-total-pending-deposits)
  (var-get total-pending-deposits))

(define-read-only (get-underlying-reserved-for-claims)
  (var-get underlying-reserved-for-claims))

(define-read-only (get-tokens-reserved-for-claims)
  (var-get tokens-reserved-for-claims))

(define-read-only (get-total-pending-withdrawals) 
  (unwrap-panic (as-contract (contract-call? .ht-token-ststx-earn-v5 get-balance tx-sender))))

(define-read-only (get-total-tokens)
  (unwrap-panic (contract-call? .ht-token-ststx-earn-v5 get-total-supply)))

(define-read-only (get-total-tokens-active)
  (+ (get-total-tokens) (get-tokens-reserved-for-claims)))
 
(define-read-only (get-total-underlying)
  (unwrap-panic (as-contract (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token get-balance tx-sender))))

(define-read-only (get-total-underlying-active)
  (- (- (get-total-underlying) (get-total-pending-deposits)) (get-underlying-reserved-for-claims)))

(define-read-only (get-current-claim-id) 
  (var-get current-claim-id))

(define-read-only (get-current-epoch-id) 
  (var-get current-epoch-id))
  
;;-------------------------------------
;; Deposits & Withdrawals 
;;-------------------------------------

(define-public (queue-deposit
  (amount uint)) ;; underlying
  (let (
    (claim-id (+ (get-current-claim-id) u1))
    (hq-data (contract-call? .ht-hq-ststx-earn-v5 get-deposit-data)))
    (asserts! (get deposits-allowed hq-data) ERR_DEPOSITS_NOT_ALLOWED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (<= (+ (+ amount (var-get total-pending-deposits)) (get-total-underlying-active)) (get vault-capacity hq-data)) ERR_VAULT_CAPACITY_EXCEEDED)
    (asserts! (>= amount (get min-deposit-amount hq-data)) ERR_AMOUNT_BELOW_MIN)
    (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token transfer amount tx-sender vault none))
    (var-set total-pending-deposits (+ (var-get total-pending-deposits) amount))
    (map-insert claims { claim-id: claim-id }  
      {
        address: tx-sender,
        epoch-id: (get-current-epoch-id),
        underlying-amount: amount,
        token-amount: u0
      }
    )
    (var-set current-claim-id claim-id)
    (add-claim-id tx-sender claim-id true)))

(define-public (activate-pending-deposit-claims)
  (begin
    (asserts! (is-eq tx-sender .ht-core-ststx-earn-v5) ERR_ONLY_CORE_CONTRACT_ALLOWED)
    (var-set tokens-reserved-for-claims (+ 
      (var-get tokens-reserved-for-claims) 
      (/ (* (var-get total-pending-deposits) token-base) (get-underlying-per-token))))
    (ok (var-set total-pending-deposits u0))))

(define-public (queue-withdrawal 
  (amount uint)) ;; token
  (let (
    (claim-id (+ (get-current-claim-id) u1)))
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .ht-token-ststx-earn-v5 transfer amount tx-sender vault none))
    (map-insert claims { claim-id: claim-id } 
      {
        address: tx-sender,
        epoch-id: (get-current-epoch-id),
        underlying-amount: u0,
        token-amount: amount,
      }
    )
    (var-set current-claim-id claim-id)
    (add-claim-id tx-sender claim-id false)))

(define-public (activate-pending-withdrawal-claims)
  (let (
    (current-total-pending-withdrawals (get-total-pending-withdrawals)))
    (asserts! (is-eq tx-sender .ht-core-ststx-earn-v5) ERR_ONLY_CORE_CONTRACT_ALLOWED)
    (var-set underlying-reserved-for-claims (+ 
      (var-get underlying-reserved-for-claims) 
      (/ (* current-total-pending-withdrawals (get-underlying-per-token)) token-base)))
    (if (> current-total-pending-withdrawals u0)
      (try! (as-contract (contract-call? .ht-token-ststx-earn-v5 burn-for-vault current-total-pending-withdrawals (as-contract tx-sender))))
      true
    )
    (ok true)))

(define-public (claim (entry { address: principal, claim-deposits: bool, claim-withdrawals: bool })) 
  (let (
    (address (get address entry))
    (current-claims (get-claims-for-address address))
    (deposit-claims (get deposit-claims current-claims))
    (withdrawal-claims (get withdrawal-claims current-claims)))
    (var-set claim-principal-helper address)
    (if (and (> (len deposit-claims) u0) (get claim-deposits entry))
      (begin
        (var-set claim-amount-helper u0)
        (map claim-processor deposit-claims)
        (asserts! (>= (var-get tokens-reserved-for-claims) (var-get claim-amount-helper)) ERR_NOT_ENOUGH_TOKENS_RESERVED_FOR_CLAIMS)
        (if (> (var-get claim-amount-helper) u0) (try! (as-contract (contract-call? .ht-token-ststx-earn-v5 mint-for-vault (var-get claim-amount-helper) address))) true)
        (var-set tokens-reserved-for-claims (- (var-get tokens-reserved-for-claims) (var-get claim-amount-helper)))
      )
      true
    )
    (if (and (> (len withdrawal-claims) u0) (get claim-withdrawals entry))
      (begin
        (var-set claim-amount-helper u0)
        (map claim-processor withdrawal-claims)
        (asserts! (>= (var-get underlying-reserved-for-claims) (var-get claim-amount-helper)) ERR_NOT_ENOUGH_UNDERLYING_RESERVED_FOR_CLAIMS)
        (let (
          (current-withdrawal-fee (get current (try! (contract-call? .ht-hq-ststx-earn-v5 get-fees "withdrawal"))))
          (withdrawal-amount (var-get claim-amount-helper))
          (fee-amount (/ (* withdrawal-amount current-withdrawal-fee) bps-base))
          (withdrawal-amount-left (- withdrawal-amount fee-amount))
          (fee-address (contract-call? .ht-hq-ststx-earn-v5 get-fee-address)))
          (if (> (var-get claim-amount-helper) u0)
            (try! (as-contract (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token transfer withdrawal-amount-left tx-sender address none)))
            true
          )
          (if (> fee-amount u0)
            (try! (as-contract (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token transfer fee-amount tx-sender fee-address none)))
            true
          )
          (var-set underlying-reserved-for-claims (- (var-get underlying-reserved-for-claims) withdrawal-amount)))
      )
      true
    )
    (ok true)))

(define-private (claim-processor (claim-id uint)) 
  (let (
    (current-claim (try! (get-claim claim-id)))
    (token-amount (get token-amount current-claim))
    (underlying-amount (get underlying-amount current-claim))
    (epoch-info (try! (get-epoch-info-for-claims (get epoch-id current-claim)))))
    (match (get underlying-per-token-settled epoch-info)
      underlying-per-token
      (begin 
        (if (> underlying-amount u0)
          (begin 
            (var-set claim-amount-helper (+ (var-get claim-amount-helper) (/ (* underlying-amount token-base) underlying-per-token)))
            (unwrap-panic (remove-claim-id (var-get claim-principal-helper) claim-id true))
          )
          (begin
            (var-set claim-amount-helper (+ (var-get claim-amount-helper) (/ (* token-amount underlying-per-token) token-base)))
            (unwrap-panic (remove-claim-id (var-get claim-principal-helper) claim-id false))
          )
        )
        (try! (delete-claim claim-id))
      )
      true
    )
    (ok true)))
 
(define-public (claim-many (entries (list 1000 { address: principal, claim-deposits: bool, claim-withdrawals: bool })))
  (ok (map claim entries)))

(define-read-only (get-underlying-per-token)
  (let (
    (current-total-underlying-active (get-total-underlying-active))
    (current-total-tokens-active (get-total-tokens-active)))
    (if (and (> current-total-underlying-active u0) (> current-total-tokens-active u0))   
      (/ 
        (* 
          current-total-underlying-active
          token-base
        )
        current-total-tokens-active
      )
      token-base
    )))

;;-------------------------------------
;; Trading
;;-------------------------------------

(define-public (deposit-funds
  (amount uint) 
  (depositor principal)) 
  (begin
    (asserts! (is-eq contract-caller .ht-core-ststx-earn-v5) ERR_ONLY_CORE_CONTRACT_ALLOWED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token transfer amount depositor vault none))
    (ok true)))

(define-public (payout-funds 
  (amount uint) 
  (recipient principal))
  (begin
    (asserts! (is-eq tx-sender .ht-core-ststx-earn-v5) ERR_ONLY_CORE_CONTRACT_ALLOWED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (>= (get-total-underlying) amount) ERR_INSUFFICIENT_CONTRACT_FUNDS)
    (try! (as-contract (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token transfer amount tx-sender recipient none)))
    (ok true)))

;;-------------------------------------
;; Epoch Info
;;-------------------------------------

(define-public (initialize)
  (ok (map-insert epoch-info-for-claims { epoch-id: u0 } 
    { 
      underlying-per-token-settled: none
    }
  )))

(define-public (create-epoch-info-for-claims)
  (let (
    (new-epoch-id (+ (get-current-epoch-id) u1))) 
    (asserts! (is-eq tx-sender .ht-core-ststx-earn-v5) ERR_ONLY_CORE_CONTRACT_ALLOWED)
    (map-insert epoch-info-for-claims { epoch-id: new-epoch-id } 
      { 
        underlying-per-token-settled: none
      }
    )
  (ok (var-set current-epoch-id new-epoch-id))))

(define-public (update-epoch-info-for-claims)
  (begin 
    (asserts! (is-eq tx-sender .ht-core-ststx-earn-v5) ERR_ONLY_CORE_CONTRACT_ALLOWED)
    (ok (map-set epoch-info-for-claims { epoch-id: (get-current-epoch-id) } 
      { 
        underlying-per-token-settled: (some (get-underlying-per-token))
      }
    ))))

;;-------------------------------------
;; Helper 
;;-------------------------------------

(define-private (delete-claim (claim-id uint)) 
  (begin 
    (unwrap! (ok (map-delete claims { claim-id: claim-id })) (err u7777))
    (ok true)))

(define-private (remove-claim-id (address principal) (claim-id uint) (is-deposit bool))
  (let (
    (current-claims (get-claims-for-address address)))
    (var-set claim-id-helper claim-id) 
    (ok (map-set claims-for-address { address: address } 
      (if is-deposit
        (merge current-claims { deposit-claims: (filter remove-claim-id-helper (get deposit-claims current-claims)) })
        (merge current-claims { withdrawal-claims: (filter remove-claim-id-helper (get withdrawal-claims current-claims)) }))
    ))))

(define-private (remove-claim-id-helper (list-item uint))
  (not (is-eq (var-get claim-id-helper) list-item)))

(define-private (add-claim-id (address principal) (claim-id uint) (is-deposit bool))
  (let (
    (current-claims (get-claims-for-address address)))
    (ok (map-set claims-for-address { address: address } 
      (if is-deposit
        (merge current-claims
          { deposit-claims: (unwrap! (as-max-len? (append (get deposit-claims current-claims) claim-id) u1000) ERR_MAX_CLAIMS) }
        )
        (merge current-claims
          { withdrawal-claims: (unwrap! (as-max-len? (append (get withdrawal-claims current-claims) claim-id) u1000) ERR_MAX_CLAIMS) }
        )
      )
    ))))