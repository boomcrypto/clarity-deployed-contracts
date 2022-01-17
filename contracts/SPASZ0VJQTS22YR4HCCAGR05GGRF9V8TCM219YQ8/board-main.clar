(use-trait board-main-ft-trait .board-main-ft-trait.board-main-ft-trait)
(use-trait board-main-nft-trait .board-main-nft-trait.board-main-nft-trait)

;; maps
(define-map contracts
  { name: (string-ascii 256) }
  {
    address: principal,
    qualified-name: principal,
  }
)
(define-map contracts-data
  { qualified-name: principal }
  {
    can-mint: bool,
    can-burn: bool
  }
)

;; errors
(define-constant ERR-NOT-AUTHORIZED (err u99404))


;; 
;; Getters
;; 

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


;;
;; Update active contracts
;; 

;; Update maps
(define-public (change-contract (name (string-ascii 256)) (address principal) (qualified-name principal) (can-mint bool) (can-burn bool))
  (let (
    (current-contract (map-get? contracts { name: name }))
  )
    (begin
      (asserts! (is-eq contract-caller (unwrap-panic (get-qualified-name-by-name "board-main-manager"))) ERR-NOT-AUTHORIZED)

      ;; Update contracts
      (map-set contracts { name: name } { address: address, qualified-name: qualified-name })

      ;; Update contracts-data
      (if (is-some current-contract)
        (map-set contracts-data { qualified-name: (unwrap-panic (get qualified-name current-contract)) } { can-mint: false, can-burn: false })
        false
      )
      (map-set contracts-data { qualified-name: qualified-name } { can-mint: can-mint, can-burn: can-burn })
      (ok true)
    )
  )
)


;;
;; Mint / Burn
;; 

;; Mint protocol FT tokens
(define-public (mint-ft-token (token <board-main-ft-trait>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq (get-contract-can-mint-by-qualified-name contract-caller) true) ERR-NOT-AUTHORIZED)
    (contract-call? token main-mint amount recipient)
  )
)

;; Burn protocol FT tokens
(define-public (burn-ft-token (token <board-main-ft-trait>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq (get-contract-can-burn-by-qualified-name contract-caller) true) ERR-NOT-AUTHORIZED)
    (contract-call? token main-burn amount recipient)
  )
)

;; Mint protocol NFT tokens
(define-public (mint-nft-token (token <board-main-nft-trait>) (recipient principal))
  (begin
    (asserts! (is-eq (get-contract-can-mint-by-qualified-name contract-caller) true) ERR-NOT-AUTHORIZED)
    (contract-call? token main-mint recipient)
  )
)

;; Burn protocol NFT tokens
(define-public (burn-nft-token (token <board-main-nft-trait>) (token-id uint) (recipient principal))
  (begin
    (asserts! (is-eq (get-contract-can-burn-by-qualified-name contract-caller) true) ERR-NOT-AUTHORIZED)
    (contract-call? token main-burn token-id recipient)
  )
)


;;
;; Init
;; 

;; Initialize the contract
(begin
  
  (map-set contracts
    { name: "board-migration-1" }
    {
      address: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8,
      qualified-name: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.board-migration-1
    }
  )
  (map-set contracts-data
    { qualified-name: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.board-migration-1 }
    {
      can-mint: true,
      can-burn: false
    }
  )

  (map-set contracts
    { name: "board-main-manager" }
    {
      address: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8,
      qualified-name: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.board-main-manager
    }
  )
  (map-set contracts-data
    { qualified-name: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.board-main-manager }
    {
      can-mint: false,
      can-burn: false
    }
  )

  (map-set contracts
    { name: "board-stake" }
    {
      address: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8,
      qualified-name: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.board-stake
    }
  )
  (map-set contracts-data
    { qualified-name: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.board-stake }
    {
      can-mint: true,
      can-burn: false
    }
  )

  (map-set contracts
    { name: "board-tiles" }
    {
      address: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8,
      qualified-name: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.board-tiles
    }
  )
  (map-set contracts-data
    { qualified-name: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.board-tiles }
    {
      can-mint: false,
      can-burn: false
    }
  )

    (map-set contracts
    { name: "board-tiles-manager" }
    {
      address: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8,
      qualified-name: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.board-tiles-manager
    }
  )
  (map-set contracts-data
    { qualified-name: 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.board-tiles-manager }
    {
      can-mint: true,
      can-burn: true
    }
  )

)
