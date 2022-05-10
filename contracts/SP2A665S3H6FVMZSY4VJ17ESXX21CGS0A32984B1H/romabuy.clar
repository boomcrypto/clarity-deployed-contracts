(use-trait token-trait 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.token-trait.token-trait)

(define-constant stake-cycle-not-found (err u404))
(define-constant stake-cycle-closed (err u403))
(define-constant stake-cycle-open (err u403))
(define-constant sender-just-staking-for-cycle (err u403))
(define-constant permission-denied-err (err u403))
(define-constant err-collection-not-found (err u404))
(define-constant contract-err (err u500))
(define-constant err-invalid-value (err u422))
(define-constant no-stx-transfers (err u12))
(define-constant err-just-open-event (err u422)) 
(define-constant err-minting-closed (err u403)) 



(define-constant multiple_whitelist true)
(define-constant cntrct-owner tx-sender)


(define-data-var administrative-contracts (list 100 principal) (list) )
(define-data-var current-removing-administrative (optional principal) none )
(define-private (is-administrative (address principal))
  (or
    (is-eq cntrct-owner address )
    (not (is-none (index-of (var-get administrative-contracts) address)) )
  )
)
(define-read-only (is-admin (address principal))
  (begin
    (asserts! (is-administrative address) permission-denied-err)
    (ok u1)
  )
)
(define-public (add-address-to-administrative
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (var-set administrative-contracts (unwrap-panic (as-max-len? (append (var-get administrative-contracts) address) u100) )) contract-err )
    (ok true)
  )
)
(define-private (filter-remove-from-administrative 
    (address principal )
  )
  (
    not (is-eq (some address) (var-get current-removing-administrative))
  )
)
(define-public (remove-address-from-adminstrative
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (var-set current-removing-administrative (some address) ) contract-err )
    (asserts! (var-set administrative-contracts (filter filter-remove-from-administrative (var-get administrative-contracts) ) ) contract-err )
    (ok true)
  )
)




;; SET COMMISSION PERCENTAGE FOR CONTRACTS
(define-map commission-contracts-map principal {commission: uint})
(define-data-var commission-contracts (list 1000 principal) (list) )
(define-data-var current-removing-commission (optional principal) none )

(define-private (is-commission (address principal))
    (or
      (is-eq cntrct-owner address )
      (not (is-none (index-of (var-get commission-contracts) address)) )
    )
  )
(define-read-only (is-commission-address (address principal))
  (begin
    (asserts! (is-commission address) permission-denied-err)
    (ok u1)
  )
)
(define-private (add-multiple-commission-address (address principal) (context {percentage: uint}))
  (begin
    (var-set commission-contracts (unwrap-panic (as-max-len? (append (var-get commission-contracts) address) u1000) ))
    (map-set commission-contracts-map address {commission: (get percentage context)})
    context
  )
)
(define-public (add-address-to-commission
    (address (list 200 principal))
    (percentage uint)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (fold add-multiple-commission-address address {percentage: percentage})
    (ok true)
  )
)
(define-private (filter-remove-from-commission 
    (address principal )
  )
  (
    not (is-eq (some address) (var-get current-removing-commission))
  )
)

(define-map mint_event_participant principal bool)
(define-data-var whitelist (list 220 principal) (list ) )


(define-data-var mint_event_id uint u0)
(define-data-var mint_event {
    id: uint,
    is_open: bool,
    public_value: uint, ;; u0 = public, u1 = private only for whitelist
    opener: (optional principal),
    mint_price: uint,
    max-token: uint,
    minted: uint
  } {
    id: (var-get mint_event_id),
    is_open: false,
    public_value: u0, 
    opener: none,
    mint_price: u0,
    max-token: u0,
    minted: u0
  }
)
(define-map mint_event_map { mint_event_id: uint, address: principal }
  {
    minted: uint
  }
)

(define-read-only (is_open_minting)
  (and 
    (< (get minted (var-get mint_event)) (get max-token (var-get mint_event)))
    (get is_open ( var-get mint_event ))
  )
)

(define-public (open_mint_event
    (mint_price uint)
    (public_value uint)
    (max-token uint)
  )
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (is-eq (is_open_minting) false )  err-just-open-event )
    (var-set mint_event {
          id: (+ (var-get mint_event_id) u1),
          opener: (some tx-sender),
          public_value: public_value,
          mint_price: mint_price,
          max-token: max-token,
          is_open: true,
          minted: (get minted (var-get mint_event))
        }
    )
    (var-set mint_event_id (+ (var-get mint_event_id) u1))
    (ok ( var-get mint_event ) )
  )
)

(define-public (edit_mint_event
    (mint_price uint)
    (public_value uint)
    (max-token uint)
  )
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (var-set mint_event {
          id: (var-get mint_event_id),
          opener: (some tx-sender),
          public_value: public_value,
          mint_price: mint_price,
          max-token: max-token,
          is_open: true,
          minted: (get minted (var-get mint_event))
        }
    )
    (ok ( var-get mint_event ) )
  )
)

(define-public (close_mint_event)
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (is_open_minting)  err-just-open-event )
    (var-set mint_event {
          id: (var-get mint_event_id),
          opener: none,
          public_value: u0,
          mint_price: u0,
          max-token: u0,
          is_open: false,
          minted: (get minted (var-get mint_event))
        }
    )
    (ok (var-get mint_event ) )
  )
)


(define-private (add_address_in_whitelist
    (address principal)
  )
  (begin
    (asserts! (map-insert mint_event_participant address true) (err u1) )
    (asserts! (var-set whitelist (unwrap-panic (as-max-len? (append (var-get whitelist) address) u220) )) (err u2 ) )
    (ok true)
  )
)

(define-public (add_address_to_mint_event
    (address principal)
  )
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (try! (add_address_in_whitelist address) )
    (ok address)
  )
)

(define-public (add_multiple_addresses_to_mint_event
    (addresses (list 220 principal) )
  )
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (map add_address_in_whitelist addresses)
    (ok (len addresses))
  )
)

(define-private (remove_address_in_whitelist
    (address principal)
  )
  (begin
    (asserts! (map-delete mint_event_participant address ) (err u1) )
    (asserts! (var-set current_removing_from_whitelist (some address) ) (err u2) )
    (asserts! (var-set whitelist (filter remove_from_whitelist (var-get whitelist) ) ) (err u3) )
    (ok true)
  )
)

(define-data-var current_removing_from_whitelist (optional principal) none )
(define-private (remove_from_whitelist 
    (address principal )
  )
  (
    not (is-eq (some address) (var-get current_removing_from_whitelist))
  )
)
(define-public (remove_address_to_mint_event
    (address principal )
  )
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (try! (remove_address_in_whitelist address) )
    (ok address)
  )
)

(define-public (empty_whitelist
  )
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (map remove_address_in_whitelist ( var-get whitelist ) )
    (ok (var-get whitelist))
  )
)

(define-read-only (is_address_in_minters (address principal)) 
  ( map-get? mint_event_participant address )
)

(define-read-only 
  (current_mint_event)  
  (var-get mint_event)
)

(define-public (transfer-stx
    (address principal) (amount uint)
  )
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (ok (stx-transfer? amount (as-contract tx-sender) address ))
  )
)


(define-private (is_avaible_address_minting (amount uint))
  (if (and
      (is-eq u0 (get public_value ( var-get mint_event ) ) )
      (is-none ( is_address_in_minters tx-sender) )
    ) 
    false 
    (> (get max-token (var-get mint_event)) (+ (get minted (var-get mint_event)) amount) )
  )
)

(define-private (charge-stx (amount uint))
  (if (>
      (get mint_price ( var-get mint_event ) )
      u0
    )
    (match (stx-transfer? (* (get mint_price ( var-get mint_event ) ) amount) tx-sender (as-contract tx-sender) )
      success true
      error false)
    true)
)

;; BUY ROMA TOKEN
(define-public (buy (amount uint) 
  )
  (begin 
    (asserts! ( is_open_minting ) err-minting-closed )
    (asserts! ( is_avaible_address_minting amount ) err-minting-closed )
    (asserts! (<= (+ (get minted (var-get mint_event)) amount) (get max-token (var-get mint_event)) ) (err u402))
    (asserts! (> (stx-get-balance tx-sender) (* (get mint_price ( var-get mint_event ) ) amount) ) (err u402) )
    (asserts! (charge-stx amount) (err u402) )
    (asserts! 
      (is-ok (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken mint tx-sender amount )))
      (err u0))
    (var-set current-commissioning-amount amount)
    (map give-commission (var-get commission-contracts))
    (ok amount)
  )
)

(define-private (give-commission (address principal))
  (let (
      (commission-amount (default-to u0 (get commission (map-get? commission-contracts-map address) ) ))
    )
    (if 
      (and 
        (> commission-amount u0)
        (> (var-get current-commissioning-amount) u0)
      )
      (is-ok (as-contract (stx-transfer? 
        (* (/ (var-get current-commissioning-amount) u100) commission-amount )
        (as-contract tx-sender) 
        address 
      ) ) )
      true
    )
  )
)
(define-data-var current-commissioning-amount uint u0)


(define-read-only 
  (whitelist_addresses)  
  (ok (var-get whitelist))
)

(define-read-only 
  (has_multiple_whitelist)  
  (ok multiple_whitelist)
)

(define-read-only 
  (minting_resume)  
  (ok {
    mint_event: (var-get mint_event),
    is_admin: (is-administrative tx-sender),
    can_mint_address: (is_avaible_address_minting),
    balance: (stx-get-balance tx-sender),
    minted_tokens: (get minted (var-get mint_event)),
    multiple_whitelist: multiple_whitelist
  })
)