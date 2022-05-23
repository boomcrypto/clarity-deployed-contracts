(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait sip-010-trait 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.sip-010-trait.sip-010-trait)

(define-non-fungible-token Punks-Army-Monkeys uint)

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
(define-constant permission-denied-err (err u403))
(define-constant contract-err (err u500))


(define-map mint_event_participant principal bool)
(define-data-var whitelist (list 220 principal) (list ) )

(define-data-var lock-stx-acquire bool false)

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

(define-public (set-lock-stx-acquire (val bool))
  (ok (var-set lock-stx-acquire val))
)


;; SET COMMISSION PERCENTAGE FOR CONTRACTS
(define-data-var current-commissioning-amount uint u0)
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
(define-private (give-commission-token (address principal) (token-contract <sip-010-trait>))
  (let (
      (commission-amount (default-to u0 (get commission (map-get? commission-contracts-map address) ) ))
    )
    (if 
      (and 
        (> commission-amount u0)
        (> (var-get current-commissioning-amount) u0)
      )
      (if 
        (is-ok (as-contract (contract-call? token-contract transfer 
          (* (/ (var-get current-commissioning-amount) u100) commission-amount )
          (as-contract tx-sender) 
          address 
          none
        ) ) )
        token-contract
        token-contract
      )
      token-contract
    )
  )
)


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


(define-public (remove-address-from-commission
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (map-delete commission-contracts-map address)
    (var-set current-removing-commission (some address) )
    (map filter-remove-from-commission (var-get commission-contracts) )
    (ok true)
  )
)

(define-read-only (list-commission-addresses)
  (ok (var-get commission-contracts))
  )

(define-data-var package-id uint u1)
(define-data-var packages-list (list 1000 uint) (list))
(define-map packages uint { nftpaid: uint, nftget: uint, qty: uint, order: uint, bought: uint })
(define-public (add-package (nftpaid uint) (nftget uint) (qty uint) (order uint))
  (begin
    (map-insert packages (var-get package-id) {nftpaid: nftpaid, nftget: nftget, qty: qty, order: order, bought: u0})
    (var-set packages-list (unwrap-panic (as-max-len? (append (var-get packages-list) (var-get package-id)) u1000) ) )
    (var-set package-id (+ (var-get package-id) u1) )
    (ok (- (var-get package-id) u1) )
  )
)
(define-public (edit-package (id uint) (nftpaid uint) (nftget uint) (qty uint) (order uint))
  (begin
    (map-set packages id {nftpaid: nftpaid, nftget: nftget, qty: qty, order: order, bought: (get bought (unwrap-panic (map-get? packages id)))})
    (ok id )
  )
)

(define-data-var current-removing-package uint u0)
(define-private (remove-package-id-from-list (id uint))
  (not (is-eq id (var-get current-removing-package)))
)
(define-public (remove-package (id uint))
  (begin
    (map-delete packages id)
    (var-set current-removing-package id)
    (var-set packages-list (filter remove-package-id-from-list (var-get packages-list)))
    (ok id )
  )
)

(define-read-only (get-package-info (id uint))
  (merge (default-to {nftpaid: u0, nftget: u0, qty: u0, order: u0, bought: u0} (map-get? packages id ) ) {id: id})
  )
(define-read-only (get-packages-list)
  (map get-package-info (var-get packages-list))
  )

;; mint price in stx and token
(define-map token-mint-price principal {amount: uint, token-contract: principal, token-name: (string-ascii 256)} )
(define-data-var stx-price uint u0)


(define-public (set-stx-price (amount uint))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (var-set stx-price amount)
    (ok true)
  )
)

(define-public (set-token-price (token-contract <sip-010-trait>) (amount uint) (token-name (string-ascii 256)))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (if
      (is-none (map-get? token-mint-price (contract-of token-contract)))
      (begin 
        (add-token-to-avaible-list token-contract)
        (map-insert token-mint-price (contract-of token-contract) {
          amount: amount, 
          token-contract: (contract-of token-contract), 
          token-name: token-name
        } )
      )
      (map-set token-mint-price (contract-of token-contract) {
          amount: amount, 
          token-contract: (contract-of token-contract), 
          token-name: token-name
        })
    )
    (ok true)
  )
)

(define-public (remove-token-price (token-contract <sip-010-trait>) )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (if
      (is-none (map-get? token-mint-price (contract-of token-contract)))
      true
      (begin 
        (remove-token-from-avaible-list token-contract)
        (map-delete token-mint-price (contract-of token-contract))
      )
    )
    (ok true)
  )
)

(define-read-only (get-token-mint-price (token-contract <sip-010-trait>))
  (get amount (unwrap-panic (map-get? token-mint-price (contract-of token-contract))))
)

(define-private (is-avaible-token (token-contract <sip-010-trait>))
    (index-of (var-get avaible-token-list) (contract-of token-contract))
  )
(define-private (add-token-to-avaible-list (token-contract <sip-010-trait>))
    (var-set avaible-token-list 
      (unwrap-panic (as-max-len? (append (var-get avaible-token-list) (contract-of token-contract) ) u1000) )
    )
  )

(define-data-var current-new-avaible-token-list (list 1000 principal) (list))
(define-private (mapping-remove-avaible-token (address principal) (token-contract <sip-010-trait>))
    (if
      (not (is-eq address (contract-of token-contract)))
      (begin 
        (var-set current-new-avaible-token-list 
          (unwrap-panic (as-max-len? (append (var-get current-new-avaible-token-list) address) u1000) )
        )
        token-contract
      )
      token-contract
    )
  )
(define-private (remove-token-from-avaible-list (token-contract <sip-010-trait>))
  (begin
    (var-set current-new-avaible-token-list (list))
    (fold mapping-remove-avaible-token (var-get avaible-token-list) token-contract)
    (var-set avaible-token-list (var-get current-new-avaible-token-list))
  )
)

(define-data-var avaible-token-list (list 1000 principal) (list))
(define-private (avaible-token-mapper (token-contract principal))
    (map-get? token-mint-price token-contract)
  )
(define-read-only (get-avaible-tokens)
  (map avaible-token-mapper (var-get avaible-token-list))
)

(define-data-var mint_event_id uint u0)
(define-data-var mint_event {
    id: uint,
    is_open: bool,
    public_value: uint, ;; u0 = public, u1 = private only for whitelist
    opener: (optional principal),
    address_mint: uint
  } {
    id: (var-get mint_event_id),
    is_open: false,
    public_value: u0, 
    opener: none,
    address_mint: u0
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
  ( is-administrative tx-sender  )
)


(define-public ( is_caller_nft_contract_owner )
  (ok (is-administrative tx-sender)  )
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
    (asserts! (is-administrative tx-sender) permission-denied-err)
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
    (asserts! (is-administrative tx-sender) permission-denied-err)
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
      (asserts! (is-administrative tx-sender) permission-denied-err)
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
    (public_value uint)
    (address_mint uint)
  )
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (is-eq (is_open_minting) false )  err-just-open-event )
    (var-set mint_event {
          id: (+ (var-get mint_event_id) u1),
          opener: (some tx-sender),
          public_value: public_value,
          address_mint: address_mint,
          is_open: true
        }
    )
    (var-set mint_event_id (+ (var-get mint_event_id) u1))
    (ok ( var-get mint_event ) )
  )
)

(define-public (edit_mint_event
    (public_value uint)
    (address_mint uint)
  )
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (var-set mint_event {
          id: (var-get mint_event_id),
          opener: (some tx-sender),
          public_value: public_value,
          address_mint: address_mint,
          is_open: true
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
    (< u0 (var-get stx-price))
    true
    false
  )
)

(define-private (have_to_pay_token (token-contract <sip-010-trait>))
  (if
    (< u0 (get-token-mint-price token-contract))
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
    (nft-mint? Punks-Army-Monkeys punk-id new-owner)
  )
)

(define-private (charge-stx)
  (if ( have_to_pay )
    (match (stx-transfer? (var-get stx-price) tx-sender (as-contract tx-sender) )
      success (
          begin
          (var-set current-commissioning-amount (var-get stx-price) )
          (map give-commission (var-get commission-contracts))
          true
        )
      error false)
    true)
)


(define-private (charge-token (token-contract <sip-010-trait>) )
  (if ( have_to_pay_token token-contract )
    (match (contract-call? token-contract transfer (get-token-mint-price token-contract) tx-sender (as-contract tx-sender) none )
      success (
          begin
          (var-set current-commissioning-amount (get-token-mint-price token-contract) )
          (fold give-commission-token (var-get commission-contracts) token-contract)
          true
        )
      error false)
    true)
)


(define-private (charge-multiple-stx (n_claimed uint))
  (if ( have_to_pay )
    (match (stx-transfer? (* (var-get stx-price) n_claimed) tx-sender (as-contract tx-sender) )
      success (
          begin
          (var-set current-commissioning-amount (* (var-get stx-price) n_claimed) )
          (map give-commission (var-get commission-contracts))
          true
        )
      error false)
    true)
)


(define-private (charge-multiple-token (n_claimed uint) (token-contract <sip-010-trait>))
  (if ( have_to_pay_token token-contract )
    (match (contract-call? token-contract transfer (* (get-token-mint-price token-contract) n_claimed) tx-sender (as-contract tx-sender) none )
      success (
        begin
        (var-set current-commissioning-amount (* (get-token-mint-price token-contract) n_claimed) )
        (fold give-commission-token (var-get commission-contracts) token-contract)
        true
      )
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
    (asserts! (not (var-get lock-stx-acquire)) (err u999))
    (asserts! ( is_open_minting ) err-minting-closed )
    (asserts! ( is_avaible_address_minting ) err-minting-closed )
    (asserts! ( > (var-get last-punk-id) (var-get last-nft-id) ) err-no-more-punk )
    (asserts! (> (stx-get-balance tx-sender) (var-get stx-price) ) (err u402) )
    (asserts! (charge-stx) (err u402) )
    (ok (mint-a-token u1))
  )
)

;; claim multiple punk
(define-public (claim_multiple 
    (claims_list (list 100 uint))
  )
  (begin 
    (asserts! (not (var-get lock-stx-acquire)) (err u999))
    (asserts! ( is_open_minting ) err-minting-closed )
    (asserts! ( is_avaible_address_minting ) err-minting-closed )
    (asserts! (>= (var-get last-punk-id) (+ (var-get last-nft-id) (len claims_list) ) ) err-no-more-punk )
    (asserts! (> (stx-get-balance tx-sender) (* (var-get stx-price) (len claims_list) ) ) (err u402) )
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

(define-public (buy_package (packageid uint) (claims_list (list 100 uint)))
  (let (
      (package (unwrap-panic (map-get? packages packageid)))
    )
    (asserts! (not (var-get lock-stx-acquire)) (err u999))
    (asserts! ( is_open_minting ) err-minting-closed )
    (asserts! ( is-eq (get nftget package) (len claims_list)) (err u20) )
    (asserts! ( > (get qty package) (get bought package)) (err u21) )
    (asserts! ( is_avaible_address_minting ) err-minting-closed )
    (asserts! (>= (var-get last-punk-id) (+ (var-get last-nft-id) (len claims_list) ) ) err-no-more-punk )
    (asserts! (> (stx-get-balance tx-sender) (* (var-get stx-price) (get nftpaid package) ) ) (err u402) )
    (asserts! (charge-multiple-stx (get nftpaid package)) (err u402) )
    (asserts! (map-set packages packageid (merge package {bought: (+ (get bought package) u1)})) (err u22))
    (map mint-a-token claims_list)
    (ok (len claims_list))
  )
)



(define-private (get-token-balance (address principal) (token-contract <sip-010-trait>))
  (unwrap-panic (contract-call? token-contract get-balance address ))
)


(define-public (claim_punk_with_token (token-contract <sip-010-trait>)
  )
  (begin 
    ;; IS OPEN MINTING?
    (asserts! ( is_open_minting ) err-minting-closed )
    (asserts! ( is_avaible_address_minting ) err-minting-closed )
    (asserts! ( > (var-get last-punk-id) (var-get last-nft-id) ) err-no-more-punk )
    (asserts! (>= (get-token-balance tx-sender token-contract) (get-token-mint-price token-contract) ) (err u402) )
    (asserts! (charge-token token-contract) (err u402) )
    (ok (mint-a-token u1))
  )
)

;; claim multiple punk
(define-public (claim_multiple_with_token 
    (claims_list (list 100 uint))
    (token-contract <sip-010-trait>)
  )
  (begin 
    (asserts! ( is_open_minting ) err-minting-closed )
    (asserts! ( is_avaible_address_minting ) err-minting-closed )
    (asserts! (>= (var-get last-punk-id) (+ (var-get last-nft-id) (len claims_list) ) ) err-no-more-punk )
    (asserts! (>= (get-token-balance tx-sender token-contract) (* (get-token-mint-price token-contract) (len claims_list) ) ) (err u402) )
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
    (asserts! (charge-multiple-token (len claims_list) token-contract) (err u402) )
    (map mint-a-token claims_list)
    (ok (len claims_list))
  )
)

(define-public (buy_package_with_token (packageid uint) (token-contract <sip-010-trait>) (claims_list (list 100 uint)))
  (let (
      (package (unwrap-panic (map-get? packages packageid)))
    )
    (asserts! ( is_open_minting ) err-minting-closed )
    (asserts! ( is-eq (get nftget package) (len claims_list)) (err u20) )
    (asserts! ( > (get qty package) (get bought package)) (err u21) )
    (asserts! ( is_avaible_address_minting ) err-minting-closed )
    (asserts! (>= (var-get last-punk-id) (+ (var-get last-nft-id) (len claims_list) ) ) err-no-more-punk )
    (asserts! (> (get-token-balance tx-sender token-contract) (* (get-token-mint-price token-contract) (get nftpaid package) ) ) (err u402) )
    (asserts! (charge-multiple-token (get nftpaid package) token-contract) (err u402) )
    (asserts! (map-set packages packageid (merge package {bought: (+ (get bought package) u1)})) (err u22))
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
    (asserts! (is-none (map-get? delegated-nft token-id)) (err u401))         
    (nft-transfer? Punks-Army-Monkeys token-id sender recipient))
)
;; BURN A TOKEN
(define-public 
  (burn-token 
    (token-id uint) 
  )  
  (begin     
    (asserts! (is-eq (some tx-sender) (nft-get-owner? Punks-Army-Monkeys token-id) ) (err u403)) 
    (asserts! (is-none (map-get? delegated-nft token-id)) (err u401))    
    (nft-burn? Punks-Army-Monkeys token-id tx-sender))
)

(
  define-read-only (get-owner (punk-id uint))  
  (ok (nft-get-owner? Punks-Army-Monkeys punk-id))
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
    is_contract_owner: (is-administrative tx-sender),
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
    multiple_whitelist: multiple_whitelist,
    stx-price: (var-get stx-price),
    locked-stx-buy: (var-get lock-stx-acquire)
  })
)


;; TRANSFER STX TO ADDRESS
(define-public (transfer-stx
    (address principal) (amount uint)
  )
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (ok (as-contract (stx-transfer? amount (as-contract tx-sender) address ) ) )
  )
)

;; TRANSFER TOKEN TO ADDRESS
(define-public (transfer-token
    (address principal) (amount uint) (token-contract <sip-010-trait>)
  )
  (begin 
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (ok (as-contract (contract-call? token-contract transfer amount (as-contract tx-sender) address none ) ) )
  )
)



;; NFTOKEN DELEGATE
(define-map delegated-nft uint principal)
(define-public (delegate-nft (token-id uint) (sender principal) (recipient principal) )
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))  
    (asserts! (is-eq tx-sender (unwrap-panic (nft-get-owner? Punks-Army-Monkeys token-id)) ) (err u401))  
    (ok (map-insert delegated-nft token-id recipient))
  )
)
(define-public (undelegate-nft (token-id uint) (sender principal) )
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))  
    (asserts! (is-eq tx-sender (unwrap-panic (map-get? delegated-nft token-id)) ) (err u401))  
    (ok (map-delete delegated-nft token-id ))
  )
)
(define-read-only (get-delegator (token-id uint))
	(ok (map-get? delegated-nft token-id))
)