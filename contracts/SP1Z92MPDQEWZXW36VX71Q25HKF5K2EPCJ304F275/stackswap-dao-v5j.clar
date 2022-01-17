(define-constant ERR_NOT_AUTHORIZED u4104)

(define-map contracts
  (string-ascii 256)
  {
    address: principal, 
    qualified-name: principal 
  }
)

(begin
  
  (map-set contracts
    "governance"
    {
      address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275,
      qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-governance-v5j
    }
  )

  (map-set contracts
    "swap"
    {
      address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275,
      qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5j
    }
  )

  (map-set contracts
    "one-step-mint"
    {
      address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275,
      qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-v5j
    }
  )

  (map-set contracts
    "lp-deployer"
    {
      address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275,
      qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275
    }
  )

  (map-set contracts
    "farm-adder"
    {
      address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275,
      qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275
    }
  )

  (map-set contracts
    "staking"
    {
      address: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275,
      qualified-name: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-staking-v1
    }
  )
)


(define-data-var dao-owner principal tx-sender)
(define-data-var payout-address principal (var-get dao-owner)) 

(define-read-only (get-dao-owner)
  (var-get dao-owner)
)

(define-read-only (get-payout-address)
  (var-get payout-address)
)

(define-public (set-dao-owner (address principal))
  (begin
    (asserts! (is-eq contract-caller (var-get dao-owner)) (err ERR_NOT_AUTHORIZED))
    (ok (var-set dao-owner address))
  )
)

(define-public (set-payout-address (address principal))
  (begin
    (asserts! (is-eq contract-caller (var-get dao-owner)) (err ERR_NOT_AUTHORIZED))
    (ok (var-set payout-address address))
  )
)

(define-read-only (get-contract-address-by-name (name (string-ascii 256)))
  (get address (map-get? contracts name))
)

(define-read-only (get-qualified-name-by-name (name (string-ascii 256)))
  (get qualified-name (map-get? contracts name))
)

(define-public (set-contract-address (name (string-ascii 256)) (address principal) (qualified-name principal))
  (let (
    (current-contract (map-get? contracts name))
  )
    (asserts! 
      (or 
        (is-eq (unwrap-panic (get-qualified-name-by-name "governance")) contract-caller)
        (is-eq (as-contract tx-sender) contract-caller)
      )
      (err ERR_NOT_AUTHORIZED))
    (map-set contracts name { address: address, qualified-name: qualified-name })
    (ok true)

  )
)

(define-public (execute-proposals (contract-changes 
      (list 10 (tuple (name (string-ascii 256)) (address principal) (qualified-name principal)))))
    (begin 
      (asserts! (is-eq (unwrap-panic (get-qualified-name-by-name "governance")) contract-caller) (err ERR_NOT_AUTHORIZED))
      (map execute-proposal-change-contract contract-changes)
    (ok true)
  )
)

(define-private (execute-proposal-change-contract (change (tuple (name (string-ascii 256)) (address principal) (qualified-name principal))))
  (let (
    (name (get name change))
    (address (get address change))
    (qualified-name (get qualified-name change))
  )
    (if (not (is-eq name ""))
      (begin
        (try! (set-contract-address name address qualified-name))
        (ok true)
      )
      (ok false)
    )
  )
)

