(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant cntrct-owner tx-sender)

(define-constant permission-denied-err (err u403))
(define-constant contract-err (err u500))

;; admin contracts
(define-data-var administrative-contracts (list 100 principal) (list) )
(define-data-var current-removing-administrative (optional principal) none )
;; is address an administrative address
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


(define-map nft-rarity { collection: (optional principal), nft-id: uint } { rarity: uint, rank: uint } )
(define-data-var current_contract (optional principal) none)

(define-private (insert-nft (nft-data {nft-id: uint, rarity: uint, rank: uint}) )
	(map-set nft-rarity {
			collection: (as-contract (var-get current_contract)), 
			nft-id: (get nft-id nft-data)
		} 
		{
			rarity: (get rarity nft-data), 
			rank: (get rank nft-data)
		}
	)
)

(define-public (set-multiple-rarity (nft-list (list 1000 { nft-id: uint, rarity: uint, rank: uint }) ) (collection <nft-trait>) )
	(begin
		(var-set current_contract (some (contract-of collection)) )
		(map insert-nft nft-list)
		(ok (len nft-list))
	)
)

(define-read-only (get-nft-values (nft-id uint) (collection principal ) )
	(ok (unwrap-panic (map-get? nft-rarity { collection: (some collection), nft-id: nft-id })))
)