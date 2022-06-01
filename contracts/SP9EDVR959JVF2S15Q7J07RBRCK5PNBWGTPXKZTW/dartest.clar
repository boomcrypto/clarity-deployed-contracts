;; -----------------------------------------------------------------------------
;;  M A R K E T P L A C E  by <redacted>
;; -----------------------------------------------------------------------------

;;(use-trait nft-trait .nft-trait.nft-trait) ;; SIP-009 NFT trait
;;(impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait.nft-trait)  ;; testnet, devnet, Clarity console
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait) ;; mainnet
;;(use-trait nft-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait.nft-trait)  ;; testnet, devnet, Clarity console

(define-constant ERR_UNAUTHORIZED        (err u401))
(define-constant ERR_UNWRAP_GET_OWNER    (err u402))
(define-constant ERR_TRANSFER_TO_ESCROW  (err u403))
(define-constant ERR_TRANSFER_TO_BUYER   (err u404))
(define-constant ERR_NFT_NOT_FOR_SALE    (err u405))
(define-constant ERR_PAY_SELLER          (err u406))
(define-constant ERR_PAY_COMMISSION      (err u407))
(define-constant ERR_PAY_ROYALTY         (err u408))
(define-constant ERR_NFT_NOT_WHITELISTED (err u409))

(define-constant MARKETPLACE_OWNER tx-sender)  ;; <enter marketplace address here>
(define-constant CONTRACT_PRINCIPAL (as-contract tx-sender))  
(define-data-var marketplace-commission-rate uint u0)  ;; current marketplace commission rate

(define-map Listings
  { ;; listing-key
    list-nft-contract: principal,
    list-nft-id: uint 
  } 
  { ;;listing-value
    list-nft-owner: principal,
    list-price: uint,                 ;; unit price in STX token, to be refactored to accept any whitelisted SIP-010 token.
    list-commission-amount: uint,     ;; sales commission paid to marketplace owner.  pre-calculated during NFT listing creation.
    list-royalty-address: principal,  ;; creator of the NFT collection.
    list-royalty-amount: uint         ;; royalties paid to the creator. pre-calculated during NFT listing creation.
  
    ;; Amounts will be precalculated, meaning commissions and royalties will never change once NFT is listed.
    ;; If the NFT collection creator decided to change the royalty percentage, the existing
    ;; listing will not be affected.  This avoids customer confusion and possible support nightmare.
    ;; Same is applied to commission.

  }
)

(define-map WhitelistNftCollection
  { whitelist-nft: principal }  ;; NFT contract
  {
    royalty-address: principal,   ;; address to receive royalty fees
    royalty-rate: uint,           ;; royalty percentage rate
    royalty-minimum: uint,        ;; placeholder for now, in case needed.
    royalty-maximum: uint,        ;; placeholder for now, in case needed.
    listing-minimum: uint,        ;; listing minimum price.  placeholder for now, in case needed.
    collection-owner: principal   ;; NFT collection owner, to enable self-maintain (e.g. change royalty amount). placeholder for now.
  }
)

;; ----------------------------------------------------------------------------
;; Add to map. Use map-set to override existing listing entry.
;; List an NFT into the marketplace:
;;  1. Check if tx-sender owns the NFT to be listed.
;;  2. Check if NFT is part of whitelisted NFT collection.
;;  3. Get/set corresponding royalty values from collection whitelist.
;;  4. Get/set marketplace commission rate.
;; ----------------------------------------------------------------------------
(define-public (list-nft (nft-contract <nft-trait>) (nft-id uint) (price uint))
    (let 
      ( 
        (nft-owner (unwrap! (get-owner nft-contract nft-id) ERR_UNWRAP_GET_OWNER))

        ;; ---- get whitelist info ---
        (whitelist-key {
          whitelist-nft: (contract-of nft-contract)
        })
        (whitelist-value (unwrap! (map-get? WhitelistNftCollection whitelist-key) ERR_NFT_NOT_WHITELISTED))
        (royalty-address (get royalty-address whitelist-value))
        (royalty-rate (get royalty-rate whitelist-value))
        (royalty-amount (/ (* price royalty-rate) u100))
        (commission-amount (/ (* price (var-get marketplace-commission-rate)) u100))

        ;; include here sip-010 ft tokens for payment - logic is very similar to whitelisted nft

        ;; ---- set listing info ---
        (listing-key {
          list-nft-contract: (contract-of nft-contract), 
          list-nft-id: nft-id
        })
        (listing-value {
          list-nft-owner: tx-sender, ;; succeeding asserts! fails if tx-sender not nft owner 
          list-price: price, 
          list-commission-amount: commission-amount, 
          list-royalty-address: royalty-address, ;; nft collection whitelisted address
          list-royalty-amount: royalty-amount
        })
      )
      (asserts! (is-eq nft-owner tx-sender) ERR_UNAUTHORIZED)
      (map-set Listings listing-key listing-value)  ;; add NFT to Listings map, overwrite duplicate key.
      (try! (escrow-nft-to-marketplace nft-contract nft-id))

      (print { 
        action: "list-nft",
        payload: {
        nft-contract: nft-contract,
        nft-id: nft-id,
        price: price
        }
      })

     (ok (merge listing-key listing-value))  ;; return to caller
    )
)

;; ----------------------------------------------------------------------------
;; Buy NFT
;;  1. Check if NFT is in the listings.
;;  2. Transfer FT from tx-sender/buyer to:
;;       - seller
;;       - royalty fees to NFT creator
;;       - marketplace commission 
;;  3. Transfer NFT from escrow (contract principal) to buyer
;;  4. Delete NFT from map Listings.
;;  5. Congrats and enjoy your NFT!  :)
;; ----------------------------------------------------------------------------
(define-public (buy-nft (nft-contract <nft-trait>) (nft-id uint))
    (let 
      ( 
        (listing-key {
          list-nft-contract: (contract-of nft-contract), 
          list-nft-id: nft-id
        })
        (listing-value (unwrap! (map-get? Listings listing-key) ERR_NFT_NOT_FOR_SALE))
        (list-nft-owner (get list-nft-owner listing-value))
        (list-price (get list-price listing-value))
        (list-commission-amount (get list-commission-amount listing-value))
        (list-royalty-address (get list-royalty-address listing-value))
        (list-royalty-amount (get list-royalty-amount listing-value))
        (pay-to-seller-amount (- (- list-price list-commission-amount) list-royalty-amount))
      )

    (unwrap! (stx-transfer? pay-to-seller-amount tx-sender list-nft-owner) ERR_PAY_SELLER )  
    (unwrap! (stx-transfer? list-commission-amount tx-sender MARKETPLACE_OWNER) ERR_PAY_COMMISSION)
    (unwrap! (stx-transfer? list-royalty-amount tx-sender list-royalty-address) ERR_PAY_ROYALTY)

    (try! (transfer-nft-to-buyer nft-contract nft-id))
    (map-delete Listings listing-key)

      (print { 
        action: "buy-nft",
        payload: {
          nft-contract: nft-contract,
          nft-id: nft-id
        },
        info: {
          price: list-price,
          list-commission-amount: list-commission-amount,
          list-royalty-amount: list-royalty-amount,
          pay-to-seller-amount: pay-to-seller-amount
        }
      })

     (ok listing-key)
    )
)

(define-private (get-owner (nft <nft-trait>) (nft-id uint))
  (unwrap-panic (contract-call? nft get-owner nft-id)) ;; need to test this unwrap-panic scenario
)

(define-private (escrow-nft-to-marketplace (nft-contract <nft-trait>) (nft-id uint))
  (begin
    (unwrap! (contract-call? nft-contract transfer nft-id tx-sender CONTRACT_PRINCIPAL) ERR_TRANSFER_TO_ESCROW)
    (ok true)
  )
)

(define-private (transfer-nft-to-buyer (nft-contract <nft-trait>) (nft-id uint))
    (let ((buyer tx-sender))
    (as-contract (contract-call? nft-contract transfer nft-id CONTRACT_PRINCIPAL buyer))
  )
)

;; ------------------------------------------------------------------
;;  NFT Collection Whitelist functions 
;; ------------------------------------------------------------------
(define-public (add-whitelist-collection (nft-contract principal) (royalty-rate uint) (royalty-address principal))
  (begin
    (asserts! (is-eq tx-sender MARKETPLACE_OWNER) ERR_UNAUTHORIZED)  ;; guard rail
    (map-set WhitelistNftCollection
      { whitelist-nft: nft-contract }
      {
        royalty-address: royalty-address,  ;; hardcode to tx-sender for now 
        royalty-rate: royalty-rate,      
        royalty-minimum: u0,
        royalty-maximum: u0,
        listing-minimum: u0,
        collection-owner: MARKETPLACE_OWNER  ;; hardcode for now
      }
    )
    (ok true)
  )
)

;; ------------------------------------------------------------------
;;  Following lines executed at deployment time.
;; ------------------------------------------------------------------
(var-set marketplace-commission-rate u5)  ;; initial commission rate, can be updated by marketplace owner
;;(try! (add-whitelist-collection 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0 u10))
;;(try! (add-whitelist-collection  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-cat-in-the-hat  u50  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM))
(try! (add-whitelist-collection  'ST1S06MKADCKV8B18PZYC3F64CHQR2G9YPJ83BGB2.kids-nft  u50  'ST1XBS03PFDTV1HSD7BY02V6VG16VTNRDP8GEN2VK))

(print { 
  action: "At deployment!",
  marketplace-commission-rate: (var-get marketplace-commission-rate)
})


;; ------------------------------------------------------------------
;;  For testing only
;; ------------------------------------------------------------------
(define-read-only (echo (shout-out (string-ascii 100))) (ok (concat "Right back at you - " shout-out)))  ;; echo
(define-read-only (get-contract-caller) (ok contract-caller ))           ;; returns contract-caller
(define-read-only (get-tx-sender) (ok tx-sender ))                       ;; returns tx-sender