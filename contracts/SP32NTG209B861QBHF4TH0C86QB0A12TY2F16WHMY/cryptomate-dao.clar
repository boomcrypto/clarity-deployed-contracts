(use-trait dao-token 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-dao-token-trait.dao-token-trait)

(define-constant ERR-NOT-AUTHORIZED u4104)
(define-data-var is-initialized-governance bool false)

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

(define-read-only (get-contract-address-by-name (name (string-ascii 256)))
  (get address (map-get? contracts { name: name }))
)

(define-read-only (get-qualified-name-by-name (name (string-ascii 256)))
  (get qualified-name (map-get? contracts { name: name }))
)

(define-read-only (get-contract-can-mint-by-qualified-name (qualified-name principal))
  (default-to 
    false
    (get can-mint (map-get? contracts-data { qualified-name: qualified-name }))
  )
)

(define-read-only (get-contract-can-burn-by-qualified-name (qualified-name principal))
  (default-to 
    false
    (get can-burn (map-get? contracts-data { qualified-name: qualified-name }))
  )
)


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

(define-public (mint-token (token <dao-token>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq (get-contract-can-mint-by-qualified-name contract-caller) true) (err ERR-NOT-AUTHORIZED))
    (contract-call? token mint-for-dao amount recipient)
  )
)

(define-public (burn-token (token <dao-token>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq (get-contract-can-burn-by-qualified-name contract-caller) true) (err ERR-NOT-AUTHORIZED))
    (contract-call? token burn-for-dao amount recipient)
  )
)
(define-public (initialize-governance)
  (begin 
    (asserts! (is-eq tx-sender (var-get dao-owner)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set is-initialized-governance true))
  )
)

(define-public (set-governance (name (string-ascii 256)) (address principal) (qualified-name principal) (can-mint bool) (can-burn bool))
  (begin 
      (asserts! (is-eq tx-sender (var-get dao-owner)) (err ERR-NOT-AUTHORIZED))
      (asserts! (not (var-get is-initialized-governance)) (err ERR-NOT-AUTHORIZED))
      (map-set contracts
        { name: name }
        {
          address: address,
          qualified-name: qualified-name
        }
      ) 

      (map-set contracts-data
        { qualified-name: qualified-name }
        {
          can-mint: can-mint,
          can-burn: can-burn
        }
      )
      (ok true)
  )
)

(begin
  
  (map-set contracts
    { name: "swap" }
    {
      address: 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY,
      qualified-name: 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-swap }
    {
      can-mint: false,
      can-burn: false
    }
  )

  (map-set contracts
    { name: "one-step-mint" }
    {
      address: 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY,
      qualified-name: 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-one-step-mint
    }
  )
  (map-set contracts-data
    { qualified-name: 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.cryptomate-one-step-mint }
    {
      can-mint: false,
      can-burn: false
    }
  )

  (map-set contracts
    { name: "lp-deployer" }
    {
      address: 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY,
      qualified-name: 'SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY
    }
  )
)