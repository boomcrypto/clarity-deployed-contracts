(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)


(define-constant permission-denied-err (err u403))
(define-constant err-collection-not-found (err u404))
(define-constant err-upgrade-not-found (err u404))
(define-constant contract-err (err u500))
(define-constant err-invalid-value (err u422))
(define-constant err-not-paid (err u402))

(define-constant punk-collection-wrong (err u1))
(define-constant weapon-collection-wrong (err u2))

;; set no price
(define-data-var upgrade-price uint u0 )

(define-constant cntrct-owner tx-sender)




(define-constant punk-collection-main 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs )
(define-constant weapon-collection-main 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-Upgrade-NFTs )
(define-data-var current-upgrade-id uint u0 )



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

(define-data-var burnt-punks (list 1000 uint) (list) )
(define-data-var burnt-weapons (list 1000 uint) (list) )



(define-data-var to-updgrade-ids (list 1000 uint) (list) )

(define-map upgrade-list uint {
  punk-id: uint,
  weapon-id: uint,
  status: uint, ;; u0 = to upgrade u1 = ugraded
  owner: principal,
  metadata-url: (string-ascii 256), 
  new-nft-id: uint
})





(define-private (have_to_pay)
  (if
    (< u0 (var-get upgrade-price))
    true
    false
  )
)
(define-private (charge-multiple-stx)
  (if ( have_to_pay )
    (match (stx-transfer? (var-get upgrade-price) tx-sender cntrct-owner )
      success true
      error false)
    true)
)






(define-map upgrade-owners principal {
  upgrade-ids: (list 100 uint)
})
(define-private (add-upgrade-id-to-owner (upgrade-id uint))
  (let (
      (map-current-element (map-get? upgrade-owners tx-sender) )
    )
      (if 
        (is-none map-current-element)
        (map-insert upgrade-owners tx-sender { upgrade-ids: (unwrap-panic (as-max-len? (list upgrade-id) u100) ) })
        (map-set upgrade-owners tx-sender {
            upgrade-ids: (unwrap-panic (as-max-len? (append (unwrap-panic (get upgrade-ids map-current-element)) upgrade-id) u100) )
          })
      )
    )
)



;; ASK UPGRADE REQUEST
(define-public (upgrade (punk-id uint) (punk-collection <nft-trait>) (weapon-id uint) (weapon-collection <nft-trait>) )
  (begin 
    (asserts! (is-eq punk-collection-main (contract-of punk-collection) ) punk-collection-wrong)
    (asserts! (is-eq weapon-collection-main (contract-of weapon-collection) ) weapon-collection-wrong)
    (asserts! (charge-multiple-stx) err-not-paid)
    (asserts! (is-ok (contract-call? punk-collection transfer punk-id tx-sender (as-contract tx-sender) )) contract-err)
    (asserts! (is-ok (contract-call? weapon-collection transfer weapon-id tx-sender (as-contract tx-sender) )) contract-err)
    (asserts! (var-set current-upgrade-id (+ (var-get current-upgrade-id) u1) ) contract-err)
    (asserts! (map-insert upgrade-list (var-get current-upgrade-id) {
        punk-id: punk-id,
        weapon-id: weapon-id,
        status: u0,
        owner: tx-sender,
        metadata-url: "",
        new-nft-id: u0
      } ) contract-err)
    (asserts! (var-set to-updgrade-ids (unwrap-panic (as-max-len? (append (var-get to-updgrade-ids) (var-get current-upgrade-id)) u1000) )) contract-err )
    (asserts! (add-upgrade-id-to-owner (var-get current-upgrade-id) ) (err u1))
    (ok (var-get current-upgrade-id))
  )
)



;; REMOVE UPGRADE REQUEST
(define-data-var current-removing-upgrade-id uint u0 )
(define-private (filter-remove-upgrade-id (up-id uint))
    (
      not (is-eq up-id (var-get current-removing-upgrade-id))
    )
  )
(define-public (refuse-upgrade (upgrade-id uint) (punk-collection <nft-trait>) (weapon-collection <nft-trait>) )
  (let (
      (upgrade-element (unwrap-panic (map-get? upgrade-list upgrade-id) ) )
    )
    (begin 
      (asserts! (is-administrative tx-sender) permission-denied-err)
      (asserts! (is-ok (as-contract (contract-call? punk-collection transfer (get punk-id upgrade-element) (as-contract tx-sender) (get owner upgrade-element) ) ) ) contract-err)
      (asserts! (is-ok (as-contract (contract-call? weapon-collection transfer (get weapon-id upgrade-element) (as-contract tx-sender) (get owner upgrade-element) ) ) ) contract-err)
      (asserts! (var-set current-removing-upgrade-id upgrade-id ) contract-err )
      (asserts! (var-set to-updgrade-ids (filter filter-remove-upgrade-id (var-get to-updgrade-ids) ) ) contract-err )
      
      (asserts! (map-set upgrade-owners (get owner upgrade-element) {
          upgrade-ids: (filter filter-remove-upgrade-id (get upgrade-ids (unwrap-panic (map-get? upgrade-owners (get owner upgrade-element))) )) 
        }
      ) (err u12))
      (asserts! (map-delete upgrade-list upgrade-id) contract-err )

      (ok upgrade-id)
    )
  )
)

;; DO UPGRADE ADDING METADATA URL
(define-public (do-upgrade (upgrade-id uint) (upgrade-metadata-url (string-ascii 256)) (punk-collection <nft-trait>) (weapon-collection <nft-trait>))
  (let (
      (upgrade-element (unwrap-panic (map-get? upgrade-list upgrade-id) ) )
    )
    (begin 
      (asserts! (is-administrative tx-sender) permission-denied-err)
      (let (
          (insert-response (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs create-punk upgrade-metadata-url ))
        )
        (begin
          
          (asserts! (is-ok (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs claim_punk ) ) (err u1))
          
          (asserts! (is-ok (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs burn-token (get punk-id upgrade-element) ) ) ) (err u2))
          (asserts! (var-set burnt-punks (unwrap-panic (as-max-len? (append (var-get burnt-punks) (get punk-id upgrade-element)) u1000) )) contract-err )
          
          (asserts! (is-ok (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-Upgrade-NFTs burn-token (get weapon-id upgrade-element) ) ) ) (err u3))
          (asserts! (var-set burnt-weapons (unwrap-panic (as-max-len? (append (var-get burnt-weapons) (get weapon-id upgrade-element)) u1000) )) contract-err )
          
          (if (not (is-eq tx-sender (get owner upgrade-element) ))
          	  (asserts! (is-ok (contract-call? 
	            'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs 
	            transfer 
	            (unwrap! (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs get-last-token-id ) (err u10))
	            tx-sender
	            (get owner upgrade-element) 
	            ) ) (err u4))
          	  (asserts! true (err u0))
          	)
          
          (asserts! (var-set current-removing-upgrade-id upgrade-id ) (err u5) )
          (asserts! (var-set to-updgrade-ids (filter filter-remove-upgrade-id (var-get to-updgrade-ids) ) ) (err u6) )
          (asserts! (map-set upgrade-list upgrade-id (merge upgrade-element {status: u2, metadata-url: upgrade-metadata-url, new-nft-id: (unwrap! (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.Punks-Army-NFTs get-last-token-id ) (err u10))}) ) (err u7) )
          
          (ok upgrade-id)

        )
      )
    )
  )
)

(define-public (set-price (price uint))
  (begin 
    (asserts! (is-administrative tx-sender) (err u1))
    (ok (var-set upgrade-price price))
  )
)


(define-read-only (list-to-upgrade-ids)
    (ok (var-get to-updgrade-ids))
  )

(define-read-only (list-burnt-punks)
    (ok (var-get burnt-punks))
  )

(define-read-only (list-burnt-weapons)
    (ok (var-get burnt-weapons))
  )

(define-read-only (current-price)
    (ok (var-get upgrade-price))
  )

(define-read-only (owner-upgrade-data (owner principal))
    (ok (get upgrade-ids (map-get? upgrade-owners owner ) ))
  )

(define-read-only (get-upgrade-info (upgrade-id uint))
    (ok (map-get? upgrade-list upgrade-id))
  )


(define-read-only (contract-datas)
    (ok {
      to-upgrade-ids: (var-get to-updgrade-ids),
      burnt-punks: (var-get burnt-punks),
      burnt-weapons: (var-get burnt-weapons),
      upgrade-price: (var-get upgrade-price)
    })
)


