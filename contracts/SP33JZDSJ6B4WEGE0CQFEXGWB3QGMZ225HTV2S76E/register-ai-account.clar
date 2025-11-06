;; AI Account Registry Contract
;; Adapted from dex allowlist mechanism for operator-gated AI account registration

(use-trait ai-account 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.aibtc-agent-account-traits-mock.aibtc-account)
;; not deployed yet: SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtc-agent-account-traits

;; Constants
(define-constant SIGNALS_REQUIRED u2)  ;; Need 2 operators to approve
(define-constant APPROVAL_WINDOW u1008) ;; ~1 week in blocks

;; Errors
(define-constant ERR_NOT_OPERATOR (err u801))
(define-constant ERR_PROPOSAL_NOT_FOUND (err u802))
(define-constant ERR_PROPOSAL_EXECUTED (err u803))
(define-constant ERR_PROPOSAL_EXPIRED (err u804))
(define-constant ERR_ALREADY_SIGNALED (err u805))
(define-constant ERR_USER_ALREADY_REGISTERED (err u806))
(define-constant ERR_ACCOUNT_ALREADY_REGISTERED (err u807))
(define-constant ERR-GET-CONFIG (err u808))
(define-constant ERR_INVALID_OWNER (err u809))

;; State variables
(define-data-var next-proposal-id uint u1)

;; ---- Operator list mechanism ----
(define-read-only (is-operator (who principal))
  (or 
    (is-eq who 'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ)  ;; Operator 1
    (is-eq who 'SP3VES970E3ZGHQEZ69R8PY62VP3R0C8CTQ8DAMQW)  ;; Operator 2  
    (is-eq who 'SP3PEBWZ8PQK1M82MS4DVD3V9DE9ZS6F25S6PEF0R)  ;; Operator 3
    ;; (is-eq who 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC)  ;; Operator 4
    ;; (is-eq who 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22)  ;; Operator 5
  )
)

;; Maps
(define-map registration-proposals
  uint
  {
    ai-account: principal,
    owner: principal,
    agent: principal,
    proposed-at: uint,
    signals: uint,
    executed: bool
  }
)

(define-map account-proposals principal uint) ;; to find a proposal id easily

(define-map proposal-signals
  { proposal-id: uint, operator: principal }
  bool
)

;; Final registry: owner to ai account
(define-map owner-ai-accounts principal principal)
(define-map ai-account-owners principal {owner: principal, agent: principal})


;; ---- Registration Functions ----

(define-public (propose-ai-account-registration
    (account <ai-account>)
    (owner principal)
    (agent principal)
  )
  (let ((proposal-id (var-get next-proposal-id))
        (ai-config (unwrap! (contract-call? account get-configuration) ERR-GET-CONFIG)) ;; get-config with proper trait config cf testnet
        (ai-owner (get owner ai-config)))
    (asserts! (is-operator tx-sender) ERR_NOT_OPERATOR)
    (asserts! (is-eq owner ai-owner) ERR_INVALID_OWNER)

    ;; Prevent double registration
    (asserts! (is-none (map-get? owner-ai-accounts owner)) ERR_USER_ALREADY_REGISTERED) ;; one registration per user forever
    (asserts! (is-none (map-get? account-proposals (contract-of account))) ERR_ACCOUNT_ALREADY_REGISTERED) ;; one registration per account forever

      ;; Store proposal
      (map-set registration-proposals proposal-id { 
        ai-account: (contract-of account),
        owner: owner,
        agent: agent,
        proposed-at: burn-block-height,
        signals: u1,
        executed: false
      })
      
      (map-set proposal-signals { proposal-id: proposal-id, operator: tx-sender } true)
      (var-set next-proposal-id (+ proposal-id u1))
      
      (print {
        type: "ai-account-proposal",
        proposal-id: proposal-id,
        ai-account: (contract-of account),
        owner: owner,
        agent: agent,
        proposer: tx-sender
      })
      
      (ok proposal-id)
    )
)

(define-public (signal-registration-approval (proposal-id uint))
  (let (
    (proposal (unwrap! (map-get? registration-proposals proposal-id) ERR_PROPOSAL_NOT_FOUND))
    (current-signals (get signals proposal))
    (owner-proposed (get owner proposal))
    (ai-account-proposed (get ai-account proposal))
  )
    (asserts! (is-operator tx-sender) ERR_NOT_OPERATOR)
    (asserts! (not (get executed proposal)) ERR_PROPOSAL_EXECUTED)
    (asserts! (<= burn-block-height (+ (get proposed-at proposal) APPROVAL_WINDOW)) ERR_PROPOSAL_EXPIRED)
    (asserts! (is-none (map-get? proposal-signals { proposal-id: proposal-id, operator: tx-sender })) ERR_ALREADY_SIGNALED)
    
    ;; Prevent double registration
    (asserts! (is-none (map-get? owner-ai-accounts owner-proposed)) ERR_USER_ALREADY_REGISTERED) ;; one registration per user forever
    (asserts! (is-none (map-get? account-proposals ai-account-proposed)) ERR_ACCOUNT_ALREADY_REGISTERED) ;; one registration per account forever
    
    (let ((new-signals (+ current-signals u1)))
      (map-set proposal-signals { proposal-id: proposal-id, operator: tx-sender } true)
      (map-set registration-proposals proposal-id
        (merge proposal { signals: new-signals })
      )
      
      ;; Auto-execute if we have enough signals (2 operators)
      (if (>= new-signals SIGNALS_REQUIRED)
        (let 
          ((agent-proposed (get agent proposal)))
          ;; Register the AI account
          (map-set owner-ai-accounts owner-proposed ai-account-proposed)
          (map-set account-proposals ai-account-proposed proposal-id)
          (map-set ai-account-owners ai-account-proposed {owner: owner-proposed, agent: agent-proposed})
          (map-set registration-proposals proposal-id
            (merge proposal { signals: new-signals, executed: true }) 
          )
          (print {
            type: "ai-account-registered",
            proposal-id: proposal-id,
            ai-account: ai-account-proposed,
            owner: owner-proposed,
            agent: agent-proposed,
            signals: new-signals
          })
        )
        (print {
          type: "registration-signal",
          proposal-id: proposal-id,
          ai-account: (get ai-account proposal),
          owner: (get owner proposal),
          agent: (get agent proposal),
          signals: new-signals
        })
      )
      
      (ok new-signals)
    )
  )
)

;; ---- Pool Integration Functions ----

;; For btc2aibtc pool to get ai-account from owner
(define-read-only (get-ai-account-by-owner (owner principal))
  (map-get? owner-ai-accounts owner)
)

;; For off chain attestators to get owner agent from ai-account
(define-read-only (get-owners-by-ai-account (account principal))
  (map-get? ai-account-owners account)
)

;; For off chain attestator to get proposal-id from ai-account
(define-read-only (get-proposal-id-by-ai-account (account principal))
  (map-get? account-proposals account)
)

;; ---- Read-only functions ----

(define-read-only (get-registration-proposal (proposal-id uint))
  (map-get? registration-proposals proposal-id)
)

(define-read-only (has-signaled (proposal-id uint) (operator principal))
  (default-to false (map-get? proposal-signals { proposal-id: proposal-id, operator: operator }))
)

(define-read-only (is-user-registered (owner principal))
  (is-some (map-get? owner-ai-accounts owner))
)