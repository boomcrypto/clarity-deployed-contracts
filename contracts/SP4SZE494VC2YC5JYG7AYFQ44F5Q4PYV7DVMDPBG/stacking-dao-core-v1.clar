;; @contract Core
;; @version 1

(use-trait reserve-trait .reserve-trait-v1.reserve-trait)
(use-trait commission-trait .commission-trait-v1.commission-trait)
(use-trait staking-trait .staking-trait-v1.staking-trait)

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_WRONG_CYCLE_ID u19001)
(define-constant ERR_SHUTDOWN u19002)
(define-constant ERR_WITHDRAW_NOT_NFT_OWNER u19004)
(define-constant ERR_WITHDRAW_NFT_DOES_NOT_EXIST u19005)
(define-constant ERR_MAX_COMMISSION u19006)
(define-constant ERR_GET_OWNER u19007)

(define-constant MAX_COMMISSION u2000) ;; 20% in basis points

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var commission uint u500) ;; 5% in basis points

(define-data-var shutdown-deposits bool false)

;;-------------------------------------
;; Maps 
;;-------------------------------------

(define-map cycle-info
  { 
    cycle-id: uint 
  }
  {
    deposited: uint,        ;; STX
    withdraw-init: uint,    ;; STX
    withdraw-out: uint,     ;; STX
    rewards: uint,          ;; STX
    commission: uint        ;; STX
  }
)

(define-map withdrawals-by-nft
  { 
    nft-id: uint
  }
  {
    cycle-id: uint, 
    stx-amount: uint,
    ststx-amount: uint
  }
)

;;-------------------------------------
;; Getters 
;;-------------------------------------

(define-read-only (get-commission)
  (var-get commission)
)

(define-read-only (get-shutdown-deposits)
  (var-get shutdown-deposits)
)

(define-read-only (get-cycle-info (cycle-id uint))
  (default-to
    {
      deposited: u0,
      withdraw-init: u0,
      withdraw-out: u0,
      rewards: u0,
      commission: u0
    }
    (map-get? cycle-info { cycle-id: cycle-id })
  )
)

(define-read-only (get-withdrawals-by-nft (nft-id uint))
  (default-to
    {
      cycle-id: u0,
      stx-amount: u0,
      ststx-amount: u0
    }
    (map-get? withdrawals-by-nft { nft-id: nft-id })
  )
)

(define-read-only (get-burn-height)
  burn-block-height
)

(define-read-only (get-pox-cycle)
  (contract-call? 'SP000000000000000000002Q6VF78.pox-3 current-pox-reward-cycle)
)

(define-read-only (get-stx-balance (address principal))
  (stx-get-balance address)
)

;; Get first cycle in which user can withdraw
;; It's the current cycle if prepare phase not started, otherwise the next cycle
(define-read-only (get-next-withdraw-cycle)
  (let (
    (current-cycle (get-pox-cycle))
    (prepare-length (get prepare-cycle-length (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info))))
    (start-block-next-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-3 reward-cycle-to-burn-height (+ current-cycle u1)))
  )
    (if (> burn-block-height (- start-block-next-cycle prepare-length))
      ;; Prepare phase
      (+ current-cycle u2)
      ;; Normal
      (+ current-cycle u1)
    )
  )
)

;;-------------------------------------
;; STX per stSTX  
;;-------------------------------------

(define-public (get-stx-per-ststx (reserve-contract <reserve-trait>))
  (let (
    (stx-amount (unwrap-panic (contract-call? reserve-contract get-total-stx)))
  )
    (try! (contract-call? .dao check-is-protocol (contract-of reserve-contract)))
    (ok (get-stx-per-ststx-helper stx-amount))
  )
)

(define-read-only (get-stx-per-ststx-helper (stx-amount uint))
  (let (
    (ststx-supply (unwrap-panic (contract-call? .ststx-token get-total-supply)))
  )
    (if (is-eq ststx-supply u0)
      u1000000
      (/ (* stx-amount u1000000) ststx-supply)
    )
  )
)

;;-------------------------------------
;; User  
;;-------------------------------------

;; Deposit STX for stSTX
(define-public (deposit (reserve-contract <reserve-trait>) (stx-amount uint) (referrer (optional principal)))
  (let (
    (cycle-id (get-pox-cycle))
    (current-cycle-info (get-cycle-info cycle-id))

    (stx-ststx (try! (get-stx-per-ststx reserve-contract)))
    (ststx-to-receive (/ (* stx-amount u1000000) stx-ststx))
  )
    (try! (contract-call? .dao check-is-enabled))
    (asserts! (not (get-shutdown-deposits)) (err ERR_SHUTDOWN))

    (map-set cycle-info { cycle-id: cycle-id } (merge current-cycle-info { deposited: (+ (get deposited current-cycle-info) stx-amount) }))
    (print { action: "deposit", data: { stacker: tx-sender, referrer: referrer, amount: ststx-to-receive, block-height: block-height } })

    (try! (stx-transfer? stx-amount tx-sender (contract-of reserve-contract)))
    (try! (contract-call? .ststx-token mint-for-protocol ststx-to-receive tx-sender))

    (ok ststx-to-receive)
  )
)

;; Initiate withdrawal, given stSTX amount. Can update amount as long as cycle not started.
;; The stSTX tokens are transferred to this contract, and are burned on the actual withdrawal.
;; An NFT is minted for the user as a token representation of the withdrawal.
(define-public (init-withdraw (reserve-contract <reserve-trait>) (ststx-amount uint))
  (let (
    (sender tx-sender)
    (withdrawal-cycle (get-next-withdraw-cycle))
    (current-cycle-info (get-cycle-info withdrawal-cycle))

    (stx-ststx (unwrap-panic (get-stx-per-ststx reserve-contract)))
    (stx-to-receive (/ (* ststx-amount stx-ststx) u1000000))
    (total-stx (unwrap-panic (contract-call? reserve-contract get-total-stx)))

    (new-withdraw-init (+ (get withdraw-init current-cycle-info) stx-to-receive))

    (nft-id (unwrap-panic (contract-call? .ststx-withdraw-nft get-last-token-id)))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve-contract)))

    ;; Transfer stSTX token to contract, only burn on actual withdraw
    (try! (as-contract (contract-call? reserve-contract lock-stx-for-withdrawal stx-to-receive)))
    (try! (contract-call? .ststx-token transfer ststx-amount tx-sender (as-contract tx-sender) none))
    (try! (as-contract (contract-call? .ststx-withdraw-nft mint-for-protocol sender)))

    (map-set withdrawals-by-nft { nft-id: nft-id } { stx-amount: stx-to-receive, ststx-amount: ststx-amount, cycle-id: withdrawal-cycle })
    (map-set cycle-info { cycle-id: withdrawal-cycle } (merge current-cycle-info { withdraw-init: new-withdraw-init }))

    (ok nft-id)
  )
)

;; Actual withdrawal for given NFT. 
;; The NFT and stSTX tokens will be burned and the user will receive STX tokens.
(define-public (withdraw (reserve-contract <reserve-trait>) (nft-id uint))
  (let (
    (receiver tx-sender)
    (cycle-id (get-pox-cycle))

    (withdrawal-entry (get-withdrawals-by-nft nft-id))
    (withdrawal-cycle (get cycle-id withdrawal-entry))

    (start-block-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-3 reward-cycle-to-burn-height withdrawal-cycle))
    (pox-prepare-length (get prepare-cycle-length (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info))))
    (unlock-burn-height (+ pox-prepare-length start-block-cycle))

    (withdrawal-cycle-info (get-cycle-info withdrawal-cycle ))

    (stx-to-receive (get stx-amount withdrawal-entry))
    (nft-owner (unwrap! (contract-call? .ststx-withdraw-nft get-owner nft-id) (err ERR_GET_OWNER)))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve-contract)))
    (asserts! (is-some nft-owner) (err ERR_WITHDRAW_NFT_DOES_NOT_EXIST))
    (asserts! (is-eq (unwrap! nft-owner (err ERR_GET_OWNER)) tx-sender) (err ERR_WITHDRAW_NOT_NFT_OWNER))
    (asserts! (>= cycle-id withdrawal-cycle) (err ERR_WRONG_CYCLE_ID))
    (asserts! (> burn-block-height unlock-burn-height) (err ERR_WRONG_CYCLE_ID))

    ;; STX to user, burn stSTX
    (try! (as-contract (contract-call? reserve-contract request-stx-for-withdrawal stx-to-receive receiver)))
    (try! (contract-call? .ststx-token burn-for-protocol (get ststx-amount withdrawal-entry) (as-contract tx-sender)))
    (try! (as-contract (contract-call? .ststx-withdraw-nft burn-for-protocol nft-id)))

    ;; Update withdrawals maps so user can not withdraw again
    (print { action: "withdraw", data: { stacker: tx-sender, amount: (get ststx-amount withdrawal-entry), block-height: block-height } })
    (map-delete withdrawals-by-nft { nft-id: nft-id })
    (map-set cycle-info { cycle-id: withdrawal-cycle } (merge withdrawal-cycle-info { 
      withdraw-out: (+ (get withdraw-out withdrawal-cycle-info) stx-to-receive),
    }))

    (ok stx-to-receive)
  )
)

;; Add rewards in STX for given cycle.
;; The stacking rewards will be swapped to STX and added via this method.
;; Stacking rewards management is a manual process.
(define-public (add-rewards 
  (commission-contract <commission-trait>) 
  (staking-contract <staking-trait>) 
  (reserve principal) 
  (stx-amount uint) 
  (cycle-id uint)
)
  (let (
    (current-cycle-info (get-cycle-info cycle-id))
    (commission-amount (/ (* stx-amount (var-get commission)) u10000))
    (rewards-left (- stx-amount commission-amount))
  )
    (try! (contract-call? .dao check-is-enabled))
    (try! (contract-call? .dao check-is-protocol reserve))
    (try! (contract-call? .dao check-is-protocol (contract-of commission-contract)))
    (try! (contract-call? .dao check-is-protocol (contract-of staking-contract)))

    (map-set cycle-info { cycle-id: cycle-id } (merge current-cycle-info { 
      rewards: (+ (get rewards current-cycle-info) rewards-left),
      commission: (+ (get commission current-cycle-info) commission-amount)
    }))

    (if (> commission-amount u0)
      (try! (contract-call? commission-contract add-commission staking-contract commission-amount))
      u0
    )
    (try! (stx-transfer? rewards-left tx-sender reserve))

    (ok stx-amount)
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-commission (new-commission uint))
  (begin
    (try! (contract-call? .dao check-is-protocol tx-sender))
    (asserts! (<= new-commission MAX_COMMISSION) (err ERR_MAX_COMMISSION))

    (var-set commission new-commission)
    (ok true)
  )
)

(define-public (set-shutdown-deposits (shutdown bool))
  (begin
    (try! (contract-call? .dao check-is-protocol tx-sender))
    
    (var-set shutdown-deposits shutdown)
    (ok true)
  )
)
