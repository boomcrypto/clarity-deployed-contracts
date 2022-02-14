(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token Punks-Army uint)

(define-constant cntrct-owner tx-sender)

(define-constant avaible_multiple_mint true)
(define-constant multiple_whitelist true)

;; ERRORS
(define-constant err-not-contract-owner (err u401)) 
(define-constant err-attribute-added (err u422)) 
(define-constant err-just-open-event (err u422)) 
(define-constant err-minting-closed (err u403)) 
(define-constant err-no-more-punk (err u422)) 
(define-constant err-not-allowed-minting (err u403)) 


(define-map mint_event_participant principal bool)
(define-data-var whitelist (list 220 principal) (list ) )



(define-data-var mint_event_id uint u0)
(define-data-var mint_event {
	id: uint,
	is_open: bool,
	public_value: uint, ;; u0 = public, u1 = private only for whitelist
	opener: (optional principal),
	address_mint: uint,
  	mint_price: uint
  } {
  	id: (var-get mint_event_id),
	is_open: false,
	public_value: u0, 
	opener: none,
	address_mint: u0,
  	mint_price: u0
  }
)
(define-map mint_event_map { mint_event_id: uint, address: principal }
  {
  	minted: uint
  }
)

(define-map punk {punk-id: uint}
  {
  	metadata_url: (string-ascii 256)
  }
)

(define-private (get-time)
   (unwrap-panic (get-block-info? time (- block-height u1))))

(define-data-var last-punk-id uint u0)
(define-data-var last-nft-id uint u0)


(define-read-only ( is_nft_contract_owner )
	( is-eq tx-sender cntrct-owner  )
)


(define-public ( is_caller_nft_contract_owner )
	(ok (is-eq tx-sender cntrct-owner)  )
)

(define-private (add-punk-to-chain 
		(metadata_url (string-ascii 256))
	) 
	(let ((punk_id ( + (var-get last-punk-id) u1 ) ))
		(begin
			(var-set last-punk-id punk_id )
			(map-set 
				punk {punk-id: punk_id }
				{
					metadata_url: metadata_url
				}
			)
			punk_id
		) 
	) 
)

(define-private (add-punk-to-chain-from-map 
		(
			element { 
				metadata_url: (string-ascii 256)
			}
		)
	) 
	(add-punk-to-chain (get metadata_url element)
		;;(get name element) (get description element) (get image element) (get external_url element) (get edition element) (get attributes element) 
	)
)

(define-public (create-punk 
		(metadata_url (string-ascii 256))
	)
	(begin
		(asserts! ( is_nft_contract_owner ) err-not-contract-owner )
		(add-punk-to-chain metadata_url 
		)
		(ok (var-get last-punk-id) )
	) 
)

(define-public (create-multiple-punk 
		(punk_list (list 2500 { 
				metadata_url: (string-ascii 256)
			}))
	) 
	(begin
		(asserts! ( is_nft_contract_owner ) err-not-contract-owner )
		(map add-punk-to-chain-from-map punk_list)
		(ok (var-get last-punk-id) )
	) 
)

(define-public (set_punk_metadata_url 
		(punk_id uint)
	  	(metadata_url (string-ascii 256))
	) 
	(let ((punk_obj (map-get? punk { punk-id: punk_id }) ))
		(begin
			(asserts! ( is_nft_contract_owner ) err-not-contract-owner )
			(map-set 
				punk {punk-id: punk_id }
				(merge 
					(unwrap-panic punk_obj )
					{
						metadata_url: metadata_url
					}
				)
			)
			(ok punk_id )
		) 
	) 
)

(define-read-only (is_open_minting)
	(get is_open ( var-get mint_event ))
)

(define-read-only (get_last_minted)
	(ok (var-get last-nft-id))
)
(define-read-only (get_last_punk)
	(ok (var-get last-punk-id))
)

(define-public (open_mint_event
		(mint_price uint)
		(public_value uint)
		(address_mint uint)
	)
	(begin 
		(asserts! ( is_nft_contract_owner ) err-not-contract-owner )
		(asserts! (is-eq (is_open_minting) false )  err-just-open-event )
		(var-set mint_event {
					id: (+ (var-get mint_event_id) u1),
					opener: (some tx-sender),
					public_value: public_value,
					mint_price: mint_price,
					address_mint: address_mint,
					is_open: true
				}
		)
		(var-set mint_event_id (+ (var-get mint_event_id) u1))
		(ok ( var-get mint_event ) )
	)
)

(define-public (edit_mint_event
		(mint_price uint)
		(public_value uint)
		(address_mint uint)
	)
	(begin 
		(asserts! ( is_nft_contract_owner ) err-not-contract-owner )
		(var-set mint_event {
					id: (var-get mint_event_id),
					opener: (some tx-sender),
					public_value: public_value,
					mint_price: mint_price,
					address_mint: address_mint,
					is_open: true
				}
		)
		(ok ( var-get mint_event ) )
	)
)

(define-public (close_mint_event)
	(begin 
		(asserts! ( is_nft_contract_owner ) err-not-contract-owner )
		(asserts! (is_open_minting)  err-just-open-event )
		(var-set mint_event {
					id: (var-get mint_event_id),
					opener: none,
					public_value: u0,
					mint_price: u0,
					address_mint: u0,
					is_open: false
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
		(asserts! ( is_nft_contract_owner ) err-not-contract-owner )
		(try! (add_address_in_whitelist address) )
		(ok address)
	)
)

(define-public (add_multiple_addresses_to_mint_event
		(addresses (list 220 principal) )
	)
	(begin 
		(asserts! ( is_nft_contract_owner ) err-not-contract-owner )
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
		(asserts! ( is_nft_contract_owner ) err-not-contract-owner )
		(try! (remove_address_in_whitelist address) )
		(ok address)
	)
)

(define-public (empty_whitelist
	)
	(begin 
		(asserts! ( is_nft_contract_owner ) err-not-contract-owner )
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

(define-private (has_ended_avaible_mint_slots)
	(if (and
			(not (is-eq u0 (get address_mint ( var-get mint_event ) ) ) )
			(>=
				(default-to u0 
					(get minted 
						(
							map-get? mint_event_map { mint_event_id: (var-get mint_event_id), address: tx-sender } 
						) 
					) 
				)
				(get address_mint ( var-get mint_event ) )
			)
		) 
		false 
		true
	)
)

(define-private (is_avaible_address_minting)
	(if (and
			(is-eq u0 (get public_value ( var-get mint_event ) ) )
			(is-none ( is_address_in_minters tx-sender) )
		) 
		false 
		(has_ended_avaible_mint_slots)
	)
)

(define-private (have_to_pay)
	(if
		(and
			(< u0 (get mint_price ( var-get mint_event ) ))
			(not (is-eq tx-sender cntrct-owner ))
		)
		true
		false
	)
)

(define-private (mint_punk (punk-id uint) (new-owner principal))
	(begin
		(map-set mint_event_map 
			{ mint_event_id: (var-get mint_event_id), address: tx-sender } 
			{ minted: (+ u1 (default-to u0 
						(get minted 
							(
								map-get? mint_event_map { mint_event_id: (var-get mint_event_id), address: tx-sender } 
							) 
						) 
					)
				) 
			}
		)
		(nft-mint? Punks-Army punk-id new-owner)
	)
)

(define-private (charge-stx)
	(if ( have_to_pay )
  	(match (stx-transfer? (get mint_price ( var-get mint_event ) ) tx-sender cntrct-owner )
      success true
      error false)
  	true)
)

(define-private (charge-multiple-stx (n_claimed uint))
	(if ( have_to_pay )
  	(match (stx-transfer? (* (get mint_price ( var-get mint_event ) ) n_claimed) tx-sender cntrct-owner )
      success true
      error false)
  	true)
)

(define-private (mint-a-token 
	(number uint)
)
	(let ((new_punk_id (+ (var-get last-nft-id) u1) ))
		(asserts! (is-ok (mint_punk new_punk_id tx-sender)) (err u405) )
		(ok (var-set last-nft-id new_punk_id ))
	)
)

(define-public (claim_punk 
	)
	(begin 
		;; IS OPEN MINTING?
		(asserts! ( is_open_minting ) err-minting-closed )
		(asserts! ( is_avaible_address_minting ) err-minting-closed )
		(asserts! ( > (var-get last-punk-id) (var-get last-nft-id) ) err-no-more-punk )
		(asserts! (> (stx-get-balance tx-sender) (get mint_price ( var-get mint_event ) ) ) (err u402) )
		(asserts! (charge-stx) (err u402) )
		(ok (mint-a-token u1))
	)
)

;; claim multiple punk
(define-public (claim_multiple 
		(claims_list (list 100 uint))
	)
	(begin 
		(asserts! ( is_open_minting ) err-minting-closed )
		(asserts! ( is_avaible_address_minting ) err-minting-closed )
		(asserts! (> (var-get last-punk-id) (+ (var-get last-nft-id) (len claims_list) ) ) err-no-more-punk )
		(asserts! (> (stx-get-balance tx-sender) (* (get mint_price ( var-get mint_event ) ) (len claims_list) ) ) (err u402) )
		(asserts! (<= (+ (default-to u0 
						(get minted 
							(
								map-get? mint_event_map { mint_event_id: (var-get mint_event_id), address: tx-sender } 
							) 
						)
					) 
					(len claims_list)
				) 
				(if (is-eq u0
						(get address_mint ( var-get mint_event ) )
					)
					u100
					(get address_mint ( var-get mint_event ) )
				)
			) (err u422)
		)
		(asserts! (charge-multiple-stx (len claims_list)) (err u402) )
		(map mint-a-token claims_list)
		(ok (len claims_list))
	)
)


(define-public (gift (amount uint)
	)
	(stx-transfer? amount tx-sender cntrct-owner)
)

(define-public (gift-ct (amount uint)
	)
	(stx-transfer? amount tx-sender (as-contract cntrct-owner) )
)


(define-public 
	(transfer 
		(token-id uint) 
		(sender principal) 
		(recipient principal)
	)  
	(begin     
		(asserts! (is-eq tx-sender sender) (err u403))     
		(nft-transfer? Punks-Army token-id sender recipient))
)
;; BURN A TOKEN
(define-public 
	(burn-token 
		(token-id uint) 
	)  
	(begin     
		(asserts! (is-eq (some tx-sender) (nft-get-owner? Punks-Army token-id) ) (err u403))     
		(nft-burn? Punks-Army token-id tx-sender))
)

(
	define-read-only (get-owner (punk-id uint))  
	(ok (nft-get-owner? Punks-Army punk-id))
)

;; SIP009: Get the last token ID
(define-read-only 
	(get-last-token-id)  
	(ok (var-get last-nft-id))
)

;; SIP009: Get the token IMAGE URI
(define-read-only 
	(get-token-uri (punk-id uint))  
	(ok (
			get metadata_url ( map-get? punk { punk-id: punk-id } )
		)
	)
)

(define-read-only 
	(get-punk (punk-id uint))  
	(ok (
			map-get? punk { punk-id: punk-id }
		)
	)
)

(define-read-only 
	(whitelist_addresses)  
	(ok (var-get whitelist))
)

(define-read-only 
	(has_multiple_whitelist)  
	(ok multiple_whitelist)
)

(define-read-only 
	(has_avaible_multiple_mint)  
	(ok avaible_multiple_mint)
)

(define-read-only 
	(minting_resume)  
	(ok {
		last_nft_id: (var-get last-nft-id),
		last_punk_id: (var-get last-punk-id),
		mint_event: (var-get mint_event),
		is_contract_owner: (is_nft_contract_owner),
		can_mint_address: (is_avaible_address_minting),
		balance: (stx-get-balance tx-sender),
		minted_tokens: (default-to u0 
					(get minted 
						(
							map-get? mint_event_map { mint_event_id: (var-get mint_event_id), address: tx-sender } 
						) 
					) 
				),
		avaible_multiple_mint: avaible_multiple_mint,
		multiple_whitelist: multiple_whitelist
	})
)
