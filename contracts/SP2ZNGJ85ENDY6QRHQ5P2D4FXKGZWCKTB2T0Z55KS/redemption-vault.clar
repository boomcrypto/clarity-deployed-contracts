;; Charisma Redemption Vault
;; https://charisma.rocks

(define-constant err-unauthorized (err u401))
(define-constant err-liquidity-lock (err u402))
(define-constant err-not-blue-pilled (err u403))
(define-constant err-insufficient-ious (err u404))

(define-constant contract (as-contract tx-sender))
(define-constant max-claim-amount-welsh u10000)
(define-constant max-claim-amount-roo u100)

(define-data-var lock-enabled bool false)

;; --- Authorization checks

(define-read-only (is-dao-or-extension)
  (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
  (ok (asserts! (is-dao-or-extension) err-unauthorized))
)

(define-read-only (is-blue-pilled)
  (ok (asserts! (contract-call? .blue-pill-nft has-balance tx-sender) err-not-blue-pilled))
)

(define-read-only (get-available-welsh)
  (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance contract)
)

(define-read-only (get-available-roo)
  (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo get-balance contract)
)

(define-read-only (is-locked)
  (ok (var-get lock-enabled))
)

(define-public (toggle-lock)
  (begin
    (try! (is-authorized))
    (ok (var-set lock-enabled (not (var-get lock-enabled))))
  )
)

(define-public (redeem-welsh (amount uint))
  (let (
    (sender tx-sender)
    (available-tokens (unwrap-panic (get-available-welsh)))
    (claim-amount (if (> amount max-claim-amount-welsh) max-claim-amount-welsh amount))
    (final-amount (if (> claim-amount available-tokens) available-tokens claim-amount))
  )
    (asserts! (or (not (var-get lock-enabled)) (try! (is-blue-pilled))) err-not-blue-pilled)
    (asserts! (>= (unwrap-panic (contract-call? .synthetic-welsh get-balance sender)) final-amount) err-insufficient-ious)
    
    ;; Burn synthetic-welsh tokens
    (try! (contract-call? .synthetic-welsh burn final-amount))
    
    ;; Transfer welshcorgicoin tokens
    (as-contract (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer final-amount contract sender none))
  )
)

(define-public (redeem-roo (amount uint))
  (let (
    (sender tx-sender)
    (available-tokens (unwrap-panic (get-available-roo)))
    (claim-amount (if (> amount max-claim-amount-roo) max-claim-amount-roo amount))
    (final-amount (if (> claim-amount available-tokens) available-tokens claim-amount))
  )
    (asserts! (or (not (var-get lock-enabled)) (try! (is-blue-pilled))) err-not-blue-pilled)
    (asserts! (>= (unwrap-panic (contract-call? .synthetic-roo get-balance sender)) final-amount) err-insufficient-ious)
    
    ;; Burn synthetic-roo tokens
    (try! (contract-call? .synthetic-roo burn final-amount))
    
    ;; Transfer roo tokens
    (as-contract (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo transfer final-amount contract sender none))
  )
)

(define-public (deposit-welsh (amount uint))
  (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer amount tx-sender contract none)
)

(define-public (deposit-roo (amount uint))
  (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo transfer amount tx-sender contract none)
)