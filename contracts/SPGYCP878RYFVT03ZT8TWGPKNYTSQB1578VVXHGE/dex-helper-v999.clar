;; Define data variables for swap amounts
(define-data-var swap1-amt-in uint u25000000)
(define-data-var swap1-amt-out-min uint u25000000)
(define-data-var swap2-amt-in uint u25000000)
(define-data-var swap2-amt-out-min uint u25000000)
(define-data-var swap3-amt-in uint u25000000)
(define-data-var swap3-amt-out-min uint u25000000)
(define-data-var swap4-amt-in uint u25000000)
(define-data-var swap4-amt-out-min uint u25000000)

;; Define the contract owner
(define-constant contract-owner tx-sender)

;; Map to store authorized users
(define-map authorized-users principal bool)

;; Check if the caller is the contract owner
(define-private (is-contract-owner)
  (is-eq tx-sender contract-owner))

;; Check if the caller is authorized
(define-private (is-authorized)
  (or (is-contract-owner) (default-to false (map-get? authorized-users tx-sender))))

;; Function to add an authorized user (only callable by contract owner)
(define-public (add-authorized-user (user principal))
  (begin
    (asserts! (is-contract-owner) (err u100))
    (ok (map-set authorized-users user true))))

;; Function to remove an authorized user (only callable by contract owner)
(define-public (remove-authorized-user (user principal))
  (begin
    (asserts! (is-contract-owner) (err u101))
    (ok (map-delete authorized-users user))))

;; Function to update swap amounts (only callable by authorized users)
(define-public (update-swap-amounts 
  (new-swap1-in uint) (new-swap1-out uint)
  (new-swap2-in uint) (new-swap2-out uint)
  (new-swap3-in uint) (new-swap3-out uint)
  (new-swap4-in uint) (new-swap4-out uint))
  (begin
    (asserts! (is-authorized) (err u102))
    (var-set swap1-amt-in new-swap1-in)
    (var-set swap1-amt-out-min new-swap1-out)
    (var-set swap2-amt-in new-swap2-in)
    (var-set swap2-amt-out-min new-swap2-out)
    (var-set swap3-amt-in new-swap3-in)
    (var-set swap3-amt-out-min new-swap3-out)
    (var-set swap4-amt-in new-swap4-in)
    (var-set swap4-amt-out-min new-swap4-out)
    (ok true)))

;; First swap function
(define-public (perform-swap-1)
  (begin
    (asserts! (is-authorized) (err u103))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 swap-4
      (var-get swap1-amt-in)
      (var-get swap1-amt-out-min)
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to
    )))

;; Second swap function
(define-public (perform-swap-2)
  (begin
    (asserts! (is-authorized) (err u104))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 swap-4
      (var-get swap2-amt-in)
      (var-get swap2-amt-out-min)
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to
    )))

;; Third swap function (new)
(define-public (perform-swap-3)
  (begin
    (asserts! (is-authorized) (err u105))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 swap-4
      (var-get swap3-amt-in)
      (var-get swap3-amt-out-min)
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-roo
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to
    )))

;; Fourth swap function (new)
(define-public (perform-swap-4)
  (begin
    (asserts! (is-authorized) (err u106))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 swap-4
      (var-get swap4-amt-in)
      (var-get swap4-amt-out-min)
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-roo
      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to
    )))

;; Function to check CHA balance at a specific block
(define-read-only (cha-balance-check (address principal) (block uint))
  (let
    (
      (block-hash (unwrap! (get-block-info? id-header-hash block) (err u500)))
      (cha-balance (at-block block-hash (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token get-balance address) (err u501))))
    )
    (ok cha-balance)
  )
)

;; Function to calculate balance change between two blocks
(define-public (cha-balance-change (address principal) (start-block uint) (end-block uint))
  (let
    (
      (start-balance (unwrap! (cha-balance-check address start-block) (err u502)))
      (end-balance (unwrap! (cha-balance-check address end-block) (err u503)))
    )
    (ok {
      start-balance: start-balance,
      end-balance: end-balance,
      change: (- end-balance start-balance)
    })
  )
)

;; Function to wrap CHA tokens and transfer them
(define-public (wat (amount uint) (recipient principal))
  (begin
    (asserts! (is-authorized) (err u600))
    (asserts! (> amount u0) (err u601))
    (let
      (
        (wrap-result (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token wrap amount)))
        (transfer-result (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer amount tx-sender recipient none)))
      )
      (ok { wrap-result: wrap-result, transfer-result: transfer-result })
    )
  )
)