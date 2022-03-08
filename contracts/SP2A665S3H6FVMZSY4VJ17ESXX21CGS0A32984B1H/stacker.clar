(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait token-trait 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.token-trait.token-trait)

(define-constant permission-denied-err (err u403))
(define-constant err-collection-not-found (err u404))
(define-constant contract-err (err u500))
(define-constant err-invalid-value (err u422))


(define-constant cntrct-owner tx-sender)
(define-data-var daily-blocks uint u144)

(define-public (set-daily-blocks (num uint))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (ok (var-set daily-blocks num))
  )
)

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


;; bonus contracts
;; bonus percentage is x100 to manage 0.01%: 1% is 100, 0.01% is u1
(define-map bonus-contracts-map principal {bonus: uint, daily-step: uint})
(define-data-var bonus-contracts (list 1000 principal) (list) )
(define-data-var current-removing-bonus (optional principal) none )
;; is address a bonus address
(define-private (is-bonus (address principal))
    (or
      (is-eq cntrct-owner address )
      (not (is-none (index-of (var-get bonus-contracts) address)) )
    )
  )
(define-read-only (is-bonus-address (address principal))
  (begin
    (asserts! (is-bonus address) permission-denied-err)
    (ok u1)
  )
)
(define-private (add-multiple-bonus-address (address principal) (context {percentage: uint, daily-step: uint}))
  (begin
    (var-set bonus-contracts (unwrap-panic (as-max-len? (append (var-get bonus-contracts) address) u1000) ))
    (map-set bonus-contracts-map address {bonus: (get percentage context), daily-step: (get daily-step context)})
    context
  )
)
(define-public (add-address-to-bonus
    (address (list 200 principal))
    (percentage uint)
    (daily-step uint)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (fold add-multiple-bonus-address address {percentage: percentage, daily-step: daily-step})
    (ok true)
  )
)
(define-private (filter-remove-from-bonus 
    (address principal )
  )
  (
    not (is-eq (some address) (var-get current-removing-bonus))
  )
)
;; set bonus to removing address
(define-private (give-address-bonus (staking-id uint))
  (let (
    (stacking-data (get-token-minted staking-id))
    (address-bonus (get address-bonus stacking-data))
  )
    (if 
      (> address-bonus u0)
      (is-ok (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken mint (unwrap-panic (var-get current-removing-bonus)) address-bonus )))
      true
    )
  )
)
(define-public (remove-address-from-bonus
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (var-set current-removing-bonus (some address) ) (err u2) )
    (
      if
      (is-some (map-get? stacking-addresses address))
      (map give-address-bonus (get nfts (unwrap-panic (map-get? stacking-addresses address) ) ))
      (list)
    )
    (asserts! (var-set bonus-contracts (filter filter-remove-from-bonus (var-get bonus-contracts) ) ) (err u4) )
    (asserts! (map-delete bonus-contracts-map address) (err u4))
    (ok true)
  )
)
(define-public (remove-multiple-address-from-bonus
    (address (list 200 principal))
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (map remove-address-from-bonus address)
    (ok true)
  )
)
(define-read-only (address-bonuses)
  (ok (var-get bonus-contracts))
)



(define-map collection-values principal
  {
    min-import: uint, ;; es. 1
    max-import: uint, ;; es. 3
    collection-total: uint, ;; es. 1000
    max-rank: uint, ;; es. 1000
    bonus-daily-step: uint, ;; number of concecutive days of staking
    bonus-percentage: uint ;; percentage min 0 max 100
  }
)
(define-data-var collections (list 1000 principal) (list))
(define-data-var removing-collection (optional principal) none )
(define-public (add-collection (contract <nft-trait>) (collection-data { 
    min-import: uint, ;; es. 1
    max-import: uint, ;; es. 3
    collection-total: uint, ;; es. 1000
    max-rank: uint, ;; es. 1000
    bonus-daily-step: uint, ;; number of concecutive days of staking
    bonus-percentage: uint
  }))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (var-set collections (unwrap-panic (as-max-len? (append (var-get collections) (contract-of contract) ) u1000)))
    (map-set collection-values (contract-of contract) collection-data)
    (ok (var-get collections) )
  )
)
(define-private (filter-collection-contract (contract principal))
  (
    if 
    (is-eq (unwrap-panic (var-get removing-collection)) contract)
    false
    true
  )
)
(define-public (remove-collection (contract <nft-trait>))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (var-set removing-collection (some (contract-of contract)) )
    (var-set collections (filter filter-collection-contract (var-get collections) ))
    (ok (var-get collections) )
  )
)
(define-private (is-open-collection (contract <nft-trait>))
  (if
    (is-none (index-of (var-get collections) (contract-of contract)))
    false
    true
  )
)
;; get collection lists
(define-read-only (collection-list)
  (var-get collections)
)
(define-private (get-collection-parameters (collection principal))
    (merge (unwrap-panic (map-get? collection-values collection)) {collection: collection})
  )
(define-read-only (full-collection-list)
  (ok (map get-collection-parameters (var-get collections)) )
)






;; stacking data id
(define-data-var stacking-id uint u0)
(define-map stacking-map uint
  {
    nft-id: uint,
    nft-collection: principal,
    owner: principal,
    timestamp: uint
  }
)

(define-map stacking-addresses principal
  {
    nfts: (list 1000 uint)
  }
)

;; get single stacking info
(define-private (get-nft-data-from-id (stacking-nft-id uint))
  (map-get? stacking-map stacking-nft-id)
)
;; get address stacking nfts
(define-read-only (get-address-staking-nfts (address principal))
  (begin
    (ok (map get-nft-data-from-id (default-to (list) (get nfts (map-get? stacking-addresses address) ) ) ))
  )
)


(define-private (add-nft-id-to-address (stacking-map-id uint))
  (let (
      (map-current-element (map-get? stacking-addresses tx-sender) )
    )
      (if 
        (is-none map-current-element)
        (map-insert stacking-addresses tx-sender { nfts: (unwrap-panic (as-max-len? (list stacking-map-id) u1000) ) })
        (map-set stacking-addresses tx-sender {
            nfts: (unwrap-panic (as-max-len? (append (unwrap-panic (get nfts map-current-element)) stacking-map-id) u1000) )
          })
      )
    )
)
(define-public (stake (nft-id uint) (collection <nft-trait>))
  (begin
    (asserts! (not (is-none (index-of (var-get collections) (contract-of collection) ))) err-collection-not-found)
    (var-set stacking-id (+ (var-get stacking-id) u1) )
    (asserts! (map-insert stacking-map (var-get stacking-id) {
        nft-id: nft-id,
        nft-collection: (contract-of collection),
        owner: tx-sender,
        timestamp: block-height
      }) contract-err)
    (asserts! (add-nft-id-to-address (var-get stacking-id)) contract-err)
    (asserts! (is-ok (contract-call? collection transfer nft-id tx-sender (as-contract tx-sender) )) contract-err)
    (ok (map-get? stacking-map (var-get stacking-id)))
  )
)
(define-private (get-staking-nft (staking-id uint))
  (merge (unwrap-panic (map-get? stacking-map staking-id)) { staking-id: staking-id})
  )
(define-read-only (current-staking (address principal))
  (ok (map get-staking-nft (get nfts (unwrap-panic (map-get? stacking-addresses address) ) )))
  )

(define-data-var current-removing-staking-id uint u0)
(define-private (remove-nft-id-stake (curr-id uint))
  (if
    (is-eq curr-id (var-get current-removing-staking-id) )
    false
    true
    )
  )
;; release tokens minted
(define-private (get-token-minted (staking-id uint))
  (let (
      (staking-mapped (unwrap-panic (map-get? stacking-map staking-id)))
      (collection-data (unwrap-panic (map-get? collection-values (get nft-collection staking-mapped ))))
      (nft-rarity (unwrap-panic (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.rarity get-nft-values (get nft-id staking-mapped) (get nft-collection staking-mapped) )) )
      (blocks-till-stake (- block-height (get timestamp staking-mapped)))
      (blocks-days (/ blocks-till-stake (var-get daily-blocks)))
      (rank (get rank nft-rarity))
      (nft-daily-value 
        (+
          (*
            (/ (* (- (get max-import collection-data) (get min-import collection-data)) u1000000) (get collection-total collection-data))
            (- (+ (get collection-total collection-data) u1) (get rank nft-rarity) )  
          )
          (* ( get min-import collection-data ) u1000000)
        )
      )
      (nft-single-block-value (
          /
          nft-daily-value
          (var-get daily-blocks)
        )
      )
      (nft-minted (
          *
          blocks-till-stake
          nft-single-block-value
        )
      )
      (nft-bonus (*
            (/ blocks-days (get bonus-daily-step collection-data))
            (* (/ nft-minted u100) (get bonus-percentage collection-data) )
          )
      )
      (nft-bonus-address-bonus 
        (if (is-some (map-get? bonus-contracts-map (get owner staking-mapped) ))
          (*
            (/ blocks-days (get daily-step (unwrap-panic (map-get? bonus-contracts-map (get owner staking-mapped))) ) )
            (/ (* (/ (+ nft-minted nft-bonus) u100) (get bonus (unwrap-panic (map-get? bonus-contracts-map (get owner staking-mapped))) )) u100)
          )
          u0
        )
      )
    )
    {
      nft-daily-value: nft-daily-value,
      nft-single-block-value: nft-single-block-value,
      blocks-days: blocks-days,
      blocks-till-stake: blocks-till-stake,
      bonus: nft-bonus,
      minted: nft-minted,
      address-bonus: nft-bonus-address-bonus,
      rank: rank
    }
  )
)
(define-public (claim (staking-id uint) (collection <nft-trait>))
  (let (
      (owner tx-sender)
      (minting-data (get-token-minted staking-id))
      (minted-value (get minted minting-data))
      (bonus-value (get bonus minting-data))
      (address-bonus (get address-bonus minting-data))
    )
    (asserts! (not (is-none (index-of ( get nfts (unwrap-panic (map-get? stacking-addresses tx-sender) ) ) staking-id ))) (err u404))
    (asserts! (is-eq (contract-of collection) (unwrap-panic (get nft-collection (map-get? stacking-map staking-id))) ) (err u404))
    (asserts! (is-ok (as-contract (contract-call? collection transfer (unwrap-panic (get nft-id (map-get? stacking-map staking-id))) (as-contract tx-sender) owner )) ) (err u500))
    (var-set current-removing-staking-id staking-id)
    (map-set stacking-addresses tx-sender {
        nfts: (filter remove-nft-id-stake (get nfts (unwrap-panic (map-get? stacking-addresses tx-sender)) )) 
      }
    )
    (map-delete stacking-map staking-id)
    (
      if
      (> minted-value u0)
      (is-ok (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken mint owner minted-value )))
      true
    )
    (
      if
      (> bonus-value u0)
      (is-ok (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken mint owner bonus-value )) )
      true
    )
    (
      if
      (> address-bonus u0)
      (is-ok (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken mint owner address-bonus )) )
      true
    )
    (ok true)
  )
)

(define-read-only (get-staking-status (staking-id uint))
  (begin
    (asserts! (not (is-none (map-get? stacking-map staking-id))) (err u404))
    (ok (get-token-minted staking-id))
  )
)
