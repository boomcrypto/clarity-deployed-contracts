;; Agent Account Registry
;; Auto-registration with attestation levels
(use-trait agent-account 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-agent-account-traits.aibtc-account-config)

(define-constant ATTESTOR_DEPLOYER 'SP2Z94F6QX847PMXTPJJ2ZCCN79JZDW3PJ4E6ZABY)
(define-constant ATTESTOR_1 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22)
(define-constant ATTESTOR_2 'SP2GHGQRWSTM89SQMZXTQJ0GRHV93MSX9J84J7BEA)

(define-constant ATTESTORS (list  ATTESTOR_1 ATTESTOR_2))

(define-constant ERR_NOT_AUTHORIZED_DEPLOYER (err u802))
(define-constant ERR_ALREADY_REGISTERED (err u803))
(define-constant ERR_NOT_ATTESTOR (err u804))
(define-constant ERR_GET_CONFIG_FAILED (err u805))
(define-constant ERR_ACCOUNT_NOT_FOUND (err u806))
(define-constant ERR_INVALID_AGENT_TYPE (err u807))
(define-constant ERR_INVALID_OWNER_TYPE (err u808))

;; agent-account -> {owner, agent, attestation-level}
(define-map agent-account-registry
  principal 
  {
    owner: principal,
    agent: principal,
    attestation-level: uint 
  }
)

(define-map owner-to-agent-account principal principal)
(define-map agent-to-agent-account principal principal)

(define-map agent-account-attestations
  { account: principal, attestor: principal }
  bool
)

(define-public (auto-register-agent-account (owner principal) (agent principal))
  (begin  
    (asserts! (is-eq tx-sender ATTESTOR_DEPLOYER) ERR_NOT_AUTHORIZED_DEPLOYER)
    (try! (validate-principals contract-caller owner))
    (do-register-account contract-caller owner agent)
  )
)

(define-public (register-agent-account (account <agent-account>))
  (let (
    (agent-account-address (contract-of account))
    (ai-config (unwrap! (contract-call? account get-config) ERR_GET_CONFIG_FAILED))
    (owner (get owner ai-config))
    (agent (get agent ai-config))
  )
    (asserts! (is-eq tx-sender ATTESTOR_DEPLOYER) ERR_NOT_AUTHORIZED_DEPLOYER)
    (try! (validate-principals agent-account-address owner))
    (do-register-account agent-account-address owner agent)
  )
)

(define-private (do-register-account (account principal) (owner principal) (agent principal))
  (begin
    (asserts! (map-insert agent-account-registry account {
      owner: owner,
      agent: agent,
      attestation-level: u1}) ERR_ALREADY_REGISTERED)
    (asserts! (map-insert owner-to-agent-account owner account) ERR_ALREADY_REGISTERED)
    (asserts! (map-insert agent-to-agent-account agent account) ERR_ALREADY_REGISTERED)
    (print {
      notification: "agent-account-registered",
      payload: {
        account: account,
        owner: owner,
        agent: agent,
        attestation-level: u1}
    })
    (ok account)
  )
)

(define-private (validate-principals (account principal) (owner principal))
  (let (
    (account-parts (unwrap-panic (principal-destruct? account)))
    (owner-parts (unwrap-panic (principal-destruct? owner)))
  )
    (begin
      (asserts! (is-some (get name account-parts)) ERR_INVALID_AGENT_TYPE)
      (asserts! (is-none (get name owner-parts)) ERR_INVALID_OWNER_TYPE)
      (ok true)
    )
  )
)

(define-public (attest-agent-account (account principal))
  (let ((registry-entry (unwrap! (map-get? agent-account-registry account) ERR_ACCOUNT_NOT_FOUND))
    (current-level (get attestation-level registry-entry))
    (new-level (+ current-level u1)))
    (asserts! (is-attestor tx-sender) ERR_NOT_ATTESTOR)    
    (asserts! (map-insert agent-account-attestations { account: account, attestor: tx-sender } true) ERR_ALREADY_REGISTERED)
    (map-set agent-account-registry account (merge registry-entry { attestation-level: new-level }))   
      (print {
        notification: "account-attested",
          payload: {
            account: account,
            attestor: tx-sender,
            new-attestation-level: new-level,
            max-attestation-level: u3 }
      })
      (ok new-level) 
  )
)

(define-read-only (get-registry-config)
  {
    attestor-deployer: ATTESTOR_DEPLOYER,
    attestors: ATTESTORS,
    max-attestation-level: u3 
  }
)

(define-read-only (get-agent-account-by-owner (owner principal))
  (map-get? owner-to-agent-account owner)
)

(define-read-only (get-agent-account-by-agent (agent principal))
  (map-get? agent-to-agent-account agent)
)

(define-read-only (get-agent-account-info (account principal))
  (map-get? agent-account-registry account)
)

(define-read-only (get-attestation-level (account principal))
  (match (map-get? agent-account-registry account)
    registry-entry (some (get attestation-level registry-entry))
    none
  )
)

(define-read-only (is-account-attested (account principal) (min-level uint))
  (match (get-attestation-level account)
    level (>= level min-level)
    false
  )
)

(define-read-only (is-attestor (who principal))
  (is-some (index-of ATTESTORS who))
)

(define-read-only (is-attestor-from-list (who principal))
  (ok (asserts! (is-some (index-of? ATTESTORS who)) ERR_NOT_ATTESTOR))
)

(define-read-only (has-attestor-signed (account principal) (attestor principal))
  (default-to false (map-get? agent-account-attestations { account: account, attestor: attestor }))
)

(define-read-only (get-account-attestors (account principal))
  {
    attestor-deployer: (is-account-attested account u1),
    attestor-1: (has-attestor-signed account ATTESTOR_1),
    attestor-2: (has-attestor-signed account ATTESTOR_2)
  }
)