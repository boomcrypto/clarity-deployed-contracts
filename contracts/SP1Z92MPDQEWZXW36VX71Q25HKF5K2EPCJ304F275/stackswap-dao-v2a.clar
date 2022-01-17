(use-trait dao-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-token-trait-v1a.dao-token-trait)

;; stackswap dao
;; 
;; Keep contracts used in protocol. 


;; Errors
(define-constant ERR-NOT-AUTHORIZED u4104)

;; Contract addresses
(define-map contracts
  { name: (string-ascii 256) }
  {
    address: principal, 
    qualified-name: principal 
  }
)
(define-map contracts-data
  { qualified-name: principal }
  {
    can-mint: bool,
    can-burn: bool
  }
)

;; Variables
(define-data-var dao-owner principal tx-sender)
(define-data-var payout-address principal (var-get dao-owner)) ;; to which address the foundation is paid

(define-read-only (get-dao-owner)
  (var-get dao-owner)
)

(define-read-only (get-payout-address)
  (var-get payout-address)
)

(define-public (set-dao-owner (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get dao-owner)) (err ERR-NOT-AUTHORIZED))

    (ok (var-set dao-owner address))
  )
)

(define-public (set-payout-address (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get dao-owner)) (err ERR-NOT-AUTHORIZED))

    (ok (var-set payout-address address))
  )
)

;; Get contract address
(define-read-only (get-contract-address-by-name (name (string-ascii 256)))
  (get address (map-get? contracts { name: name }))
)

;; Get contract qualified name
(define-read-only (get-qualified-name-by-name (name (string-ascii 256)))
  (get qualified-name (map-get? contracts { name: name }))
)

;; Check if contract can mint
(define-read-only (get-contract-can-mint-by-qualified-name (qualified-name principal))
  (default-to 
    false
    (get can-mint (map-get? contracts-data { qualified-name: qualified-name }))
  )
)

;; Check if contract can burn
(define-read-only (get-contract-can-burn-by-qualified-name (qualified-name principal))
  (default-to 
    false
    (get can-burn (map-get? contracts-data { qualified-name: qualified-name }))
  )
)

;; Governance contract can setup DAO contracts
(define-public (set-contract-address (name (string-ascii 256)) (address principal) (qualified-name principal) (can-mint bool) (can-burn bool))
  (let (
    (current-contract (map-get? contracts { name: name }))
  )
    (begin
      (asserts! (is-eq (unwrap-panic (get-qualified-name-by-name "governance")) contract-caller) (err ERR-NOT-AUTHORIZED))

      (map-set contracts { name: name } { address: address, qualified-name: qualified-name })
      (if (is-some current-contract)
        (map-set contracts-data { qualified-name: (unwrap-panic (get qualified-name current-contract)) } { can-mint: false, can-burn: false })
        false
      )
      (map-set contracts-data { qualified-name: qualified-name } { can-mint: can-mint, can-burn: can-burn })
      (ok true)
    )
  )
)

;; Mint protocol tokens
(define-public (mint-token (token <dao-token>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq (get-contract-can-mint-by-qualified-name contract-caller) true) (err ERR-NOT-AUTHORIZED))
    (contract-call? token mint-for-dao amount recipient)
  )
)

;; Burn protocol tokens
(define-public (burn-token (token <dao-token>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq (get-contract-can-burn-by-qualified-name contract-caller) true) (err ERR-NOT-AUTHORIZED))
    (contract-call? token burn-for-dao amount recipient)
  )
)


;; ---------------------------------------------------------
;; Contract initialisation
;; ---------------------------------------------------------

;; Initialize the contract
(begin
  ;; Add initial contracts
  
  (map-set contracts
    { name: "governance" }
    {
      address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275,
      qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-governance-v2a
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-governance-v2a }
    {
      can-mint: true,
      can-burn: true
    }
  )


  (map-set contracts
    { name: "swap" }
    {
      address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275,
      qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v3a
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v3a }
    {
      can-mint: false,
      can-burn: false
    }
  )

  (map-set contracts
    { name: "one-step-mint" }
    {
      address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275,
      qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-v2a
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-v2a }
    {
      can-mint: false,
      can-burn: false
    }
  )

  (map-set contracts
    { name: "lp-deployer" }
    {
      address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275,
      qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275
    }
  )
  ;; (map-set contracts-data
  ;;   { qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275 }
  ;;   {
  ;;     can-mint: true,
  ;;     can-burn: true
  ;;   }
  ;; )

)
