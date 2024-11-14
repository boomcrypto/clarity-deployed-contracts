---
title: "Trait atb"
draft: true
---
```
;; traits
;; (new) Import SIP-09 NFT trait 
(impl-trait .sip-09.nft-trait)
;; (new) Import a custom commission trait for handling commissions for NFT marketplaces functions
(use-trait commission-trait .commission-trait.commission)

;; token definition
;; (new) Define the non-fungible token (NFT) called ATB-V2 with unique identifiers as unsigned integers
(define-non-fungible-token ATB-V2 uint)
;; Time-to-live (TTL) constants for atbspace preorders and atb preorders, and the duration for atb grace period.
;; The TTL for atbspace and atbs preorders. (1 day)
(define-constant PREORDER-CLAIMABILITY-TTL u144) 
;; The duration after revealing a atbspace within which it must be launched. (1 year)
(define-constant atbspace-LAUNCHABILITY-TTL u52595) 
;; The grace period duration for atb renewals post-expiration. (34 days)
(define-constant atb-GRACE-PERIOD-DURATION u5000) 
;; (new) The length of the hash should match this
(define-constant HASH160LEN u20)
;; Defines the price tiers for atbspaces based on their lengths.
(define-constant atbspace-PRICE-TIERS (list
    u640000000000
    u64000000000 u64000000000 
    u6400000000 u6400000000 u6400000000 u6400000000 
    u640000000 u640000000 u640000000 u640000000 u640000000 u640000000 u640000000 u640000000 u640000000 u640000000 u640000000 u640000000 u640000000)
)

;; (new) Constant to store the token URI, allowing for metadata association with the NFT
(define-constant token-uri "test")

;; Only authorized caller to flip the switch
(define-constant deployer tx-sender)

;; errors
(define-constant ERR-UNWRAP (err u101))
(define-constant ERR-NOT-AUTHORIZED (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-WRONG-COMMISSION (err u104))
(define-constant ERR-LISTED (err u105))
(define-constant ERR-NO-atb (err u106))
(define-constant ERR-HASH-MALFORMED (err u107))
(define-constant ERR-STX-BURNT-INSUFFICIENT (err u108))
(define-constant ERR-PREORDER-NOT-FOUND (err u109))
(define-constant ERR-CHARSET-INVALID (err u110))
(define-constant ERR-atbspace-ALREADY-EXISTS (err u111))
(define-constant ERR-PREORDER-CLAIMABILITY-EXPIRED (err u112))
(define-constant ERR-atbspace-NOT-FOUND (err u113))
(define-constant ERR-OPERATION-UNAUTHORIZED (err u114))
(define-constant ERR-atbspace-ALREADY-LAUNCHED (err u115))
(define-constant ERR-atbspace-PREORDER-LAUNCHABILITY-EXPIRED (err u116))
(define-constant ERR-atbspace-NOT-LAUNCHED (err u117))
(define-constant ERR-atb-NOT-AVAILABLE (err u118))
(define-constant ERR-atbspace-BLANK (err u119))
(define-constant ERR-atb-BLANK (err u120))
(define-constant ERR-atb-REVOKED (err u121))
(define-constant ERR-atb-PREORDERED-BEFORE-atbspace-LAUNCH (err u122))
(define-constant ERR-atbspace-HAS-MANAGER (err u123))
(define-constant ERR-OVERFLOW (err u124))
(define-constant ERR-NO-atbspace-MANAGER (err u125))
(define-constant ERR-FAST-MINTED-BEFORE (err u126))
(define-constant ERR-PREORDERED-BEFORE (err u127))
(define-constant ERR-atb-NOT-CLAIMABLE-YET (err u128))
(define-constant ERR-IMPORTED-BEFORE (err u129))
(define-constant ERR-LIFETIME-EQUAL-0 (err u130))
(define-constant ERR-MIGRATION-IN-PROGRESS (err u131))

;; variables
;; (new) Variable to see if migration is complete
(define-data-var migration-complete bool false)

;; (new) Counter to keep track of the last minted NFT ID, ensuring unique identifiers
(define-data-var atb-index uint u0)

;; maps
;; (new) Map to track market listings, associating NFT IDs with price and commission details
(define-map market uint {price: uint, commission: principal})

;; (new) Define a map to link NFT IDs to their respective atbs and atbspaces.
(define-map index-to-atb uint 
    {
        atb: (buff 48), atbspace: (buff 20)
    } 
)
;; (new) Define a map to link atbs and atbspaces to their respective NFT IDs.
(define-map atb-to-index 
    {
        atb: (buff 48), atbspace: (buff 20)
    } 
    uint
)

;; (updated) Contains detailed properties of atbs, including registration and importation times, revocation status, and zonefile hash.
(define-map atb-properties
    { atb: (buff 48), atbspace: (buff 20) }
    {
        registered-at: (optional uint),
        imported-at: (optional uint),
        ;; Updated this to be a boolean, since we do not need know when it was revoked, only if it is revoked
        revoked-at: bool,
        zonefile-hash: (optional (buff 20)),
        ;; The fqn used to make the earliest preorder at any given point
        hashed-salted-fqn-preorder: (optional (buff 20)),
        ;; Added this field in atb-properties to know exactly who has the earliest preorder at any given point
        preordered-by: (optional principal),
        renewal-height: uint,
        stx-burn: uint,
        owner: principal,
    }
)

;; (update) Stores properties of atbspaces, including their import principals, reveal and launch times, and pricing functions.
(define-map atbspaces (buff 20)
    { 
        atbspace-manager: (optional principal),
        manager-transferable: bool,
        manager-frozen: bool,
        atbspace-import: principal,
        revealed-at: uint,
        launched-at: (optional uint),
        lifetime: uint,
        can-update-price-function: bool,
        price-function: 
            {
                buckets: (list 16 uint),
                base: uint, 
                coeff: uint, 
                nonalpha-discount: uint, 
                no-vowel-discount: uint
            }
    }
)

;; Records atbspace preorder transactions with their creation times, and STX burned.
;; Removed the claimed field as it is not necessary
(define-map atbspace-preorders
    { hashed-salted-atbspace: (buff 20), buyer: principal }
    { created-at: uint, stx-burned: uint }
)

;; Tracks preorders, to avoid attacks
(define-map atbspace-single-preorder (buff 20) bool)

;; Tracks preorders, to avoid attacks
(define-map atb-single-preorder (buff 20) bool)

;; Tracks preorders for atbs, including their creation times, and STX burned.
(define-map atb-preorders
    { hashed-salted-fqn: (buff 20), buyer: principal }
    { created-at: uint, stx-burned: uint, claimed: bool}
)

;; It maps a user's principal to the ID of their primary atb.
(define-map primary-atb principal uint)


;; read-only
;; @desc (new) SIP-09 compliant function to get the last minted token's ID
(define-read-only (get-last-token-id)
    ;; Returns the current value of atb-index variable, which tracks the last token ID
    (ok (var-get atb-index))
)

(define-read-only (get-renewal-height (id uint))
    (let 
        (
            (atb-atbspace (unwrap! (get-atb-from-id id) ERR-NO-atb))
            (atbspace-props (unwrap! (map-get? atbspaces (get atbspace atb-atbspace)) ERR-atbspace-NOT-FOUND))
            (atb-props (unwrap! (map-get? atb-properties atb-atbspace) ERR-NO-atb))
            (renewal-height (get renewal-height atb-props))
            (atbspace-lifetime (get lifetime atbspace-props))
        )
        ;; Check if the atbspace requires renewals
        (asserts! (not (is-eq atbspace-lifetime u0)) ERR-LIFETIME-EQUAL-0) 
        ;; If the check passes then check the renewal-height of the atb
        (ok 
            (if (is-eq renewal-height u0)
                ;; If it is true then it means it was imported so return the atbspace launch blockheight + lifetime
                (+ (unwrap! (get launched-at atbspace-props) ERR-atbspace-NOT-LAUNCHED) atbspace-lifetime) 
                renewal-height
            )
        )
    )
)

;; @desc (new) SIP-09 compliant function to get token URI
(define-read-only (get-token-uri (id uint))
    ;; Returns a predefined set URI for the token metadata
    (ok (some token-uri))
)

;; @desc (new) SIP-09 compliant function to get the owner of a specific token by its ID
(define-read-only (get-owner (id uint))
    ;; Check and return the owner of the specified NFT
    (ok (nft-get-owner? ATB-V2 id))
)

;; Read-only function `get-atbspace-price` calculates the registration price for a atbspace based on its length.
;; @params:
    ;; atbspace (buff 20): The atbspace for which the price is being calculated.
(define-read-only (get-atbspace-price (atbspace (buff 20)))
    (let 
        (
            ;; Calculate the length of the atbspace.
            (atbspace-len (len atbspace))
        )
        ;; Ensure the atbspace is not blank, its length is greater than 0.
        (asserts! (> atbspace-len u0) ERR-atbspace-BLANK)
        ;; Retrieve the price for the atbspace based on its length from the atbspace-PRICE-TIERS list.
        ;; The price tier is determined by the minimum of 7 or the atbspace length minus one.
        (ok (unwrap! (element-at atbspace-PRICE-TIERS (min u7 (- atbspace-len u1))) ERR-UNWRAP))
    )
)

;; Read-only function `get-atb-price` calculates the registration price for a atb based on the price buckets of the atbspace
;; @params:
    ;; atbspace (buff 20): The atbspace for which the price is being calculated.
    ;; atb (buff 48): The atb for which the price is being calculated.
(define-read-only (get-atb-price (atbspace (buff 20)) (atb (buff 48)))
    (let 
        (
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
        )
        (ok (compute-atb-price atb (get price-function atbspace-props)))
    )
)

;; Read-only function `can-atbspace-be-registered` checks if a atbspace is available for registration.
;; @params:
    ;; atbspace (buff 20): The atbspace being checked for availability.
(define-read-only (can-atbspace-be-registered (atbspace (buff 20)))
    ;; Returns the result of `is-atbspace-available` directly, indicating if the atbspace can be registered.
    (ok (is-atbspace-available atbspace))
)

;; Read-only function `get-atbspace-properties` for retrieving properties of a specific atbspace.
;; @params:
    ;; atbspace (buff 20): The atbspace whose properties are being queried.
(define-read-only (get-atbspace-properties (atbspace (buff 20)))
    (let 
        (
            ;; Fetch the properties of the specified atbspace from the `atbspaces` map.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
        )
        ;; Returns the atbspace along with its associated properties.
        (ok { atbspace: atbspace, properties: atbspace-props })
    )
)

;; Read only function to get atb properties
(define-read-only (get-atb-info (atb (buff 48)) (atbspace (buff 20)))
    (map-get? atb-properties {atb: atb, atbspace: atbspace})
)

;; (new) Defines a read-only function to fetch the unique ID of a atb atb given its atb and the atbspace it belongs to.
(define-read-only (get-id-from-atb (atb (buff 48)) (atbspace (buff 20))) 
    ;; Attempts to retrieve the ID from the 'atb-to-index' map using the provided atb and atbspace as the key.
    (map-get? atb-to-index {atb: atb, atbspace: atbspace})
)

;; (new) Defines a read-only function to fetch the atb atb and the atbspace given a unique ID.
(define-read-only (get-atb-from-id (id uint)) 
    ;; Attempts to retrieve the atb and atbspace from the 'index-to-atb' map using the provided id as the key.
    (map-get? index-to-atb id)
)

;; (new) Fetcher for primary atb
(define-read-only (get-primary-atb (owner principal))
    (map-get? primary-atb owner)
)

;; public functions
;; @desc (new) SIP-09 compliant function to transfer a token from one owner to another.
;; @param id: ID of the NFT being transferred.
;; @param owner: Principal of the current owner of the NFT.
;; @param recipient: Principal of the recipient of the NFT.
(define-public (transfer (id uint) (owner principal) (recipient principal))
    (let 
        (
            ;; Get the atb and atbspace of the NFT.
            (atb-and-atbspace (unwrap! (get-atb-from-id id) ERR-NO-atb))
            (atbspace (get atbspace atb-and-atbspace))
            (atb (get atb atb-and-atbspace))
            ;; Get atbspace properties and manager.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            (manager-transfers (get manager-transferable atbspace-props))
            ;; Get atb properties and owner.
            (atb-props (unwrap! (map-get? atb-properties atb-and-atbspace) ERR-NO-atb))
            (registered-at-value (get registered-at atb-props))
            (nft-current-owner (unwrap! (nft-get-owner? ATB-V2 id) ERR-NO-atb))
        )
        ;; First check if the atb was registered
        (match registered-at-value
            is-registered
            ;; If it was registered, check if registered-at is lower than current blockheight
            ;; This check works to make sure that if a atb is fast-claimed they have to wait 1 block to transfer it
            (asserts! (< is-registered burn-block-height) ERR-OPERATION-UNAUTHORIZED)
            ;; If it is not registered then continue
            true 
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Check that the atbspace is launched
        (asserts! (is-some (get launched-at atbspace-props)) ERR-atbspace-NOT-LAUNCHED)
        ;; Check that the atb is not revoked
        (asserts! (not (get revoked-at atb-props)) ERR-atb-REVOKED)
        ;; Check owner and recipient is not the same
        (asserts! (not (is-eq nft-current-owner recipient)) ERR-OPERATION-UNAUTHORIZED)
        ;; We only need to check if manager transfers are true or false, if true then they have to do transfers through the manager contract that calls into mng-transfer, if false then they can call into this function
        (asserts! (not manager-transfers) ERR-NOT-AUTHORIZED)
        ;; Check contract-caller
        (asserts! (is-eq contract-caller nft-current-owner) ERR-NOT-AUTHORIZED)
        ;; Check if in fact the owner is-eq to nft-current-owner
        (asserts! (is-eq owner nft-current-owner) ERR-NOT-AUTHORIZED)
        ;; Ensures the NFT is not currently listed in the market.
        (asserts! (is-none (map-get? market id)) ERR-LISTED)
        ;; Update the atb properties with the new owner and reset the zonefile hash.
        (map-set atb-properties atb-and-atbspace (merge atb-props {zonefile-hash: none, owner: recipient}))
        ;; Update primary atb if needed for owner
        (update-primary-atb-owner id owner)
        ;; Update primary atb if needed for recipient
        (update-primary-atb-recipient id recipient)
        ;; Execute the NFT transfer.
        (nft-transfer? ATB-V2 id nft-current-owner recipient)
    )
)

;; @desc (new) manager function to be called by managed atbspaces that allows manager transfers.
;; @param id: ID of the NFT being transferred.
;; @param owner: Principal of the current owner of the NFT.
;; @param recipient: Principal of the recipient of the NFT.
(define-public (mng-transfer (id uint) (owner principal) (recipient principal))
    (let 
        (
            ;; Get the atb and atbspace of the NFT.
            (atb-and-atbspace (unwrap! (get-atb-from-id id) ERR-NO-atb))
            (atbspace (get atbspace atb-and-atbspace))
            (atb (get atb atb-and-atbspace))
            ;; Get atbspace properties and manager.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            (manager-transfers (get manager-transferable atbspace-props))
            (manager (get atbspace-manager atbspace-props))
            ;; Get atb properties and owner.
            (atb-props (unwrap! (map-get? atb-properties atb-and-atbspace) ERR-NO-atb))
            (registered-at-value (get registered-at atb-props))
            (nft-current-owner (unwrap! (nft-get-owner? ATB-V2 id) ERR-NO-atb))
        )
        ;; First check if the atb was registered
        (match registered-at-value
            is-registered
            ;; If it was registered, check if registered-at is lower than current blockheight
            ;; This check works to make sure that if a atb is fast-claimed they have to wait 1 block to transfer it
            (asserts! (< is-registered burn-block-height) ERR-OPERATION-UNAUTHORIZED)
            ;; If it is not registered then continue
            true 
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Check that the atbspace is launched
        (asserts! (is-some (get launched-at atbspace-props)) ERR-atbspace-NOT-LAUNCHED)
        ;; Check that the atb is not revoked
        (asserts! (not (get revoked-at atb-props)) ERR-atb-REVOKED)
        ;; Check owner and recipient is not the same
        (asserts! (not (is-eq nft-current-owner recipient)) ERR-OPERATION-UNAUTHORIZED)
        ;; We only need to check if manager transfers are true or false, if true then continue, if false then they can call into `transfer` function
        (asserts! manager-transfers ERR-NOT-AUTHORIZED)
        ;; Check contract-caller, we unwrap-panic because if manager-transfers is true then there has to be a manager
        (asserts! (is-eq contract-caller (unwrap-panic manager)) ERR-NOT-AUTHORIZED)
        ;; Check if in fact the owner is-eq to nft-current-owner
        (asserts! (is-eq owner nft-current-owner) ERR-NOT-AUTHORIZED)
        ;; Ensures the NFT is not currently listed in the market.
        (asserts! (is-none (map-get? market id)) ERR-LISTED)
        ;; Update primary atb if needed for owner
        (update-primary-atb-owner id owner)
        ;; Update primary atb if needed for recipient
        (update-primary-atb-recipient id recipient)
        ;; Update the atb properties with the new owner and reset the zonefile hash.
        (map-set atb-properties atb-and-atbspace (merge atb-props {zonefile-hash: none, owner: recipient}))
        ;; Execute the NFT transfer.
        (nft-transfer? ATB-V2 id nft-current-owner recipient)
    )
)

;; @desc (new) Function to list an NFT for sale.
;; @param id: ID of the NFT being listed.
;; @param price: Listing price.
;; @param comm-trait: Address of the commission-trait.
(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
    (let
        (
            ;; Get the atb and atbspace of the NFT.
            (atb-and-atbspace (unwrap! (map-get? index-to-atb id) ERR-NO-atb))
            (atbspace (get atbspace atb-and-atbspace))
            ;; Get atbspace properties and manager.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            (atbspace-manager (get atbspace-manager atbspace-props))
            ;; Get atb properties and registered-at value.
            (atb-props (unwrap! (map-get? atb-properties atb-and-atbspace) ERR-NO-atb))
            (registered-at-value (get registered-at atb-props))
            ;; Creates a listing record with price and commission details
            (listing {price: price, commission: (contract-of comm-trait)})
        )
        ;; Checks if the atb was registered
        (match registered-at-value
            is-registered
            ;; If it was registered, check if registered-at is lower than current blockheight
            ;; Same as transfers, this check works to make sure that if a atb is fast-claimed they have to wait 1 block to list it
            (asserts! (< is-registered burn-block-height) ERR-OPERATION-UNAUTHORIZED)
            ;; If it is not registered then continue
            true 
        )
        ;; Check if there is a atbspace manager
        (match atbspace-manager 
            manager 
            ;; If there is then check that the contract-caller is the manager
            (asserts! (is-eq manager contract-caller) ERR-NOT-AUTHORIZED)
            ;; If there isn't assert that the owner is the contract-caller
            (asserts! (is-eq (some contract-caller) (nft-get-owner? ATB-V2 id)) ERR-NOT-AUTHORIZED)
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Updates the market map with the new listing details
        (map-set market id listing)
        ;; Prints listing details
        (ok (print (merge listing {a: "list-in-ustx", id: id})))
    )
)

;; @desc (new) Function to remove an NFT listing from the market.
;; @param id: ID of the NFT being unlisted.
(define-public (unlist-in-ustx (id uint))
    (let
        (
            ;; Get the atb and atbspace of the NFT.
            (atb-and-atbspace (unwrap! (map-get? index-to-atb id) ERR-NO-atb))
            (atbspace (get atbspace atb-and-atbspace))
            ;; Verify if the NFT is listed in the market.
            (market-map (unwrap! (map-get? market id) ERR-NOT-LISTED))
            ;; Get atbspace properties and manager.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            (atbspace-manager (get atbspace-manager atbspace-props))
        )
        ;; Check if there is a atbspace manager
        (match atbspace-manager 
            manager 
            ;; If there is then check that the contract-caller is the manager
            (asserts! (is-eq manager contract-caller) ERR-NOT-AUTHORIZED)
            ;; If there isn't assert that the owner is the contract-caller
            (asserts! (is-eq (some contract-caller) (nft-get-owner? ATB-V2 id)) ERR-NOT-AUTHORIZED)
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Deletes the listing from the market map
        (map-delete market id)
        ;; Prints unlisting details
        (ok (print {a: "unlist-in-ustx", id: id}))
    )
)   

;; @desc (new) Function to buy an NFT listed for sale, transferring ownership and handling commission.
;; @param id: ID of the NFT being purchased.
;; @param comm-trait: Address of the commission-trait.
(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
    (let
        (
            ;; Retrieves current owner and listing details
            (owner (unwrap! (nft-get-owner? ATB-V2 id) ERR-NO-atb))
            (listing (unwrap! (map-get? market id) ERR-NOT-LISTED))
            (price (get price listing))
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Verifies the commission details match the listing
        (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
        ;; Transfers STX from buyer to seller
        (try! (stx-transfer? price contract-caller owner))
        ;; Handle commission payment
        (try! (contract-call? comm-trait pay id price))
        ;; Transfers the NFT to the buyer
        ;; This function differs from the `transfer` method by not checking who the contract-caller is, otherwise trasnfers would never be executed
        (try! (purchase-transfer id owner contract-caller))
        ;; Removes the listing from the market map
        (map-delete market id)
        ;; Prints purchase details
        (ok (print {a: "buy-in-ustx", id: id}))
    )
)

;; @desc (new) Sets the primary atb for the caller to a specific atb atb they own.
;; @param primary-atb-id: ID of the atb to be set as primary.
(define-public (set-primary-atb (primary-atb-id uint))
    (begin 
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Verify the contract-caller is the owner of the atb.
        (asserts! (is-eq (unwrap! (nft-get-owner? ATB-V2 primary-atb-id) ERR-NO-atb) contract-caller) ERR-NOT-AUTHORIZED)
        ;; Update the contract-caller's primary atb.
        (map-set primary-atb contract-caller primary-atb-id)
        ;; Return true upon successful execution.
        (ok true)
    )
)

;; @desc (new) Defines a public function to burn an NFT, under managed atbspaces.
;; @param id: ID of the NFT to be burned.
(define-public (mng-burn (id uint)) 
    (let 
        (
            ;; Get the atb details associated with the given ID.
            (atb-and-atbspace (unwrap! (get-atb-from-id id) ERR-NO-atb))
            ;; Get the owner of the atb.
            (owner (unwrap! (nft-get-owner? ATB-V2 id) ERR-UNWRAP)) 
        ) 
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure the caller is the current atbspace manager.
        (asserts! (is-eq contract-caller (unwrap! (get atbspace-manager (unwrap! (map-get? atbspaces (get atbspace atb-and-atbspace)) ERR-atbspace-NOT-FOUND)) ERR-NO-atbspace-MANAGER)) ERR-NOT-AUTHORIZED)
        ;; Unlist the NFT if it is listed.
        (match (map-get? market id)
            listed-atb 
            (map-delete market id) 
            true
        )
        ;; Update primary atb if needed for the owner of the atb
        (update-primary-atb-owner id owner)
        ;; Delete the atb from all maps:
        ;; Remove the atb-to-index.
        (map-delete atb-to-index atb-and-atbspace)
        ;; Remove the index-to-atb.
        (map-delete index-to-atb id)
        ;; Remove the atb-properties.
        (map-delete atb-properties atb-and-atbspace)
        ;; Executes the burn operation for the specified NFT.
        (nft-burn? ATB-V2 id (unwrap! (nft-get-owner? ATB-V2 id) ERR-UNWRAP))
    )
)

;; @desc (new) Transfers the management role of a specific atbspace to a new principal.
;; @param new-manager: Principal of the new manager.
;; @param atbspace: Buffer of the atbspace.
(define-public (mng-manager-transfer (new-manager (optional principal)) (atbspace (buff 20)))
    (let 
        (
            ;; Retrieve atbspace properties and current manager.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS) 
        ;; Ensure the caller is the current atbspace manager.
        (asserts! (is-eq contract-caller (unwrap! (get atbspace-manager atbspace-props) ERR-NO-atbspace-MANAGER)) ERR-NOT-AUTHORIZED)
        ;; Ensure manager can be changed
        (asserts! (not (get manager-frozen atbspace-props)) ERR-NOT-AUTHORIZED)
        ;; Update the atbspace manager to the new manager.
        (ok 
            (map-set atbspaces atbspace 
                (merge 
                    atbspace-props 
                    {atbspace-manager: new-manager}
                )
            )
        )
    )
)

;; @desc (new) freezes the ability to make manager transfers
;; @param atbspace: Buffer of the atbspace.
(define-public (freeze-manager (atbspace (buff 20)))
    (let 
        (
            ;; Retrieve atbspace properties and current manager.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure the caller is the current atbspace manager.
        (asserts! (is-eq contract-caller (unwrap! (get atbspace-manager atbspace-props) ERR-NO-atbspace-MANAGER)) ERR-NOT-AUTHORIZED)
        ;; Update the atbspace manager to the new manager.
        (ok 
            (map-set atbspaces atbspace 
                (merge 
                    atbspace-props 
                    {manager-frozen: true}
                )
            )
        )

    )
)

;;;; atbspaceS
;; @desc Public function `atbspace-preorder` initiates the registration process for a atbspace by sending a transaction with a salted hash of the atbspace.
;; This transaction burns the registration fee as a commitment.
;; @params: hashed-salted-atbspace (buff 20): The hashed and salted atbspace being preordered.
;; @params: stx-to-burn (uint): The amount of STX tokens to be burned as part of the preorder process.
(define-public (atbspace-preorder (hashed-salted-atbspace (buff 20)) (stx-to-burn uint))
    (begin
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS) 
        ;; Validate that the hashed-salted-atbspace is exactly 20 bytes long.
        (asserts! (is-eq (len hashed-salted-atbspace) HASH160LEN) ERR-HASH-MALFORMED)
        ;; Check if the same hashed-salted-fqn has been used before
        (asserts! (is-none (map-get? atbspace-single-preorder hashed-salted-atbspace)) ERR-PREORDERED-BEFORE)
        ;; Confirm that the STX amount to be burned is positive
        (asserts! (> stx-to-burn u0) ERR-STX-BURNT-INSUFFICIENT)
        ;; Execute the token burn operation.
        (try! (stx-burn? stx-to-burn contract-caller))
        ;; Record the preorder details in the `atbspace-preorders` map
        (map-set atbspace-preorders
            { hashed-salted-atbspace: hashed-salted-atbspace, buyer: contract-caller }
            { created-at: burn-block-height, stx-burned: stx-to-burn }
        )
        ;; Sets the map with just the hashed-salted-atbspace as the key
        (map-set atbspace-single-preorder hashed-salted-atbspace true)
        ;; Return the block height at which the preorder claimability expires.
        (ok (+ burn-block-height PREORDER-CLAIMABILITY-TTL))
    )
)

;; @desc Public function `atbspace-reveal` completes the second step in the atbspace registration process.
;; It associates the revealed atbspace with its corresponding preorder, establishes the atbspace's pricing function, and sets its lifetime and ownership details.
;; @param: atbspace (buff 20): The atbspace being revealed.
;; @param: atbspace-salt (buff 20): The salt used during the preorder to generate a unique hash.
;; @param: p-func-base, p-func-coeff, p-func-b1 to p-func-b16: Parameters defining the price function for registering atbs within this atbspace.
;; @param: p-func-non-alpha-discount (uint): Discount applied to atbs with non-alphabetic characters.
;; @param: p-func-no-vowel-discount (uint): Discount applied to atbs without vowels.
;; @param: lifetime (uint): Duration that atbs within this atbspace are valid before needing renewal.
;; @param: atbspace-import (principal): The principal authorized to import atbs into this atbspace.
;; @param: atbspace-manager (optional principal): The principal authorized to manage the atbspace.
(define-public (atbspace-reveal 
    (atbspace (buff 20)) 
    (atbspace-salt (buff 20)) 
    (p-func-base uint) 
    (p-func-coeff uint) 
    (p-func-b1 uint) 
    (p-func-b2 uint) 
    (p-func-b3 uint) 
    (p-func-b4 uint) 
    (p-func-b5 uint) 
    (p-func-b6 uint) 
    (p-func-b7 uint) 
    (p-func-b8 uint) 
    (p-func-b9 uint) 
    (p-func-b10 uint) 
    (p-func-b11 uint) 
    (p-func-b12 uint) 
    (p-func-b13 uint) 
    (p-func-b14 uint) 
    (p-func-b15 uint) 
    (p-func-b16 uint) 
    (p-func-non-alpha-discount uint) 
    (p-func-no-vowel-discount uint) 
    (lifetime uint) 
    (atbspace-import principal) 
    (atbspace-manager (optional principal)) 
    (can-update-price bool) 
    (manager-transfers bool) 
    (manager-frozen bool)
)
    (let 
        (
            ;; Generate the hashed, salted atbspace identifier to match with its preorder.
            (hashed-salted-atbspace (hash160 (concat atbspace atbspace-salt)))
            ;; Define the price function based on the provided parameters.
            (price-function  
                {
                    buckets: (list p-func-b1 p-func-b2 p-func-b3 p-func-b4 p-func-b5 p-func-b6 p-func-b7 p-func-b8 p-func-b9 p-func-b10 p-func-b11 p-func-b12 p-func-b13 p-func-b14 p-func-b15 p-func-b16),
                    base: p-func-base,
                    coeff: p-func-coeff,
                    nonalpha-discount: p-func-non-alpha-discount,
                    no-vowel-discount: p-func-no-vowel-discount
                }
            )
            ;; Retrieve the preorder record to ensure it exists and is valid for the revealing atbspace.
            (preorder (unwrap! (map-get? atbspace-preorders { hashed-salted-atbspace: hashed-salted-atbspace, buyer: contract-caller}) ERR-PREORDER-NOT-FOUND))
            ;; Calculate the atbspace's registration price for validation.
            (atbspace-price (try! (get-atbspace-price atbspace)))
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure the atbspace consists of valid characters only.
        (asserts! (not (has-invalid-chars atbspace)) ERR-CHARSET-INVALID)
        ;; Check that the atbspace is available for reveal.
        (asserts! (unwrap! (can-atbspace-be-registered atbspace) ERR-atbspace-ALREADY-EXISTS) ERR-atbspace-ALREADY-EXISTS)
        ;; Verify the burned amount during preorder meets or exceeds the atbspace's registration price.
        (asserts! (>= (get stx-burned preorder) atbspace-price) ERR-STX-BURNT-INSUFFICIENT)
        ;; Confirm the reveal action is performed within the allowed timeframe from the preorder.
        (asserts! (< burn-block-height (+ (get created-at preorder) PREORDER-CLAIMABILITY-TTL)) ERR-PREORDER-CLAIMABILITY-EXPIRED)
        ;; Ensure at least 1 block has passed after the preorder to avoid atbspace sniping.
        (asserts! (>= burn-block-height (+ (get created-at preorder) u1)) ERR-OPERATION-UNAUTHORIZED)
        ;; Check if the atbspace manager is assigned
        (match atbspace-manager 
            atbspace-m
            ;; If atbspace-manager is assigned, then assign everything except the lifetime, that is set to u0 sinces renewals will be made in the atbspace manager contract and set the can update price function to false, since no changes will ever need to be made there.
            (map-set atbspaces atbspace
                {
                    atbspace-manager: atbspace-manager,
                    manager-transferable: manager-transfers,
                    manager-frozen: manager-frozen,
                    atbspace-import: atbspace-import,
                    revealed-at: burn-block-height,
                    launched-at: none,
                    lifetime: u0,
                    can-update-price-function: can-update-price,
                    price-function: price-function 
                }
            )
            ;; If no manager is assigned
            (map-set atbspaces atbspace
                {
                    atbspace-manager: none,
                    manager-transferable: manager-transfers,
                    manager-frozen: manager-frozen,
                    atbspace-import: atbspace-import,
                    revealed-at: burn-block-height,
                    launched-at: none,
                    lifetime: lifetime,
                    can-update-price-function: can-update-price,
                    price-function: price-function 
                }
            )
        )  
        ;; Confirm successful reveal of the atbspace
        (ok true)
    )
)

;; @desc Public function `atbspace-launch` marks a atbspace as launched and available for public atb registrations.
;; @param: atbspace (buff 20): The atbspace to be launched and made available for public registrations.
(define-public (atbspace-launch (atbspace (buff 20)))
    (let 
        (
            ;; Retrieve the properties of the atbspace to ensure it exists and to check its current state.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure the transaction sender is the atbspace's designated import principal.
        (asserts! (is-eq (get atbspace-import atbspace-props) contract-caller) ERR-OPERATION-UNAUTHORIZED)
        ;; Verify the atbspace has not already been launched.
        (asserts! (is-none (get launched-at atbspace-props)) ERR-atbspace-ALREADY-LAUNCHED)
        ;; Confirm that the action is taken within the permissible time frame since the atbspace was revealed.
        (asserts! (< burn-block-height (+ (get revealed-at atbspace-props) atbspace-LAUNCHABILITY-TTL)) ERR-atbspace-PREORDER-LAUNCHABILITY-EXPIRED)
        ;; Update the `atbspaces` map with the newly launched status.
        (map-set atbspaces atbspace (merge atbspace-props { launched-at: (some burn-block-height) }))      
        ;; Emit an event to indicate the atbspace is now ready and launched.
        (print { atbspace: atbspace, status: "ready", properties: (map-get? atbspaces atbspace) })
        ;; Confirm the successful launch of the atbspace.
        (ok true)
    )
)

;; @desc (new) Public function `turn-off-manager-transfers` disables manager transfers for a atbspace (callable only once).
;; @param: atbspace (buff 20): The atbspace for which manager transfers will be disabled.
(define-public (turn-off-manager-transfers (atbspace (buff 20)))
    (let 
        (
            ;; Retrieve the properties of the atbspace and manager.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            (atbspace-manager (unwrap! (get atbspace-manager atbspace-props) ERR-NO-atbspace-MANAGER))
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure the function caller is the atbspace manager.
        (asserts! (is-eq contract-caller atbspace-manager) ERR-NOT-AUTHORIZED)
        ;; Disable manager transfers.
        (map-set atbspaces atbspace (merge atbspace-props {manager-transferable: false}))
        ;; Confirm successful execution.
        (ok true)
    )
)

;; @desc Public function `atb-import` allows the insertion of atbs into a atbspace that has been revealed but not yet launched.
;; This facilitates pre-populating the atbspace with specific atbs, assigning owners and zone file hashes to them.
;; @param: atbspace (buff 20): The atbspace into which the atb is being imported.
;; @param: atb (buff 48): The atb being imported into the atbspace.
;; @param: beneficiary (principal): The principal who will own the imported atb.
;; @param: zonefile-hash (buff 20): The hash of the zone file associated with the imported atb.
;; @param: stx-burn (uint): The amount of STX tokens to be burned as part of the import process.
(define-public (atb-import (atbspace (buff 20)) (atb (buff 48)) (beneficiary principal) (zonefile-hash (buff 20)))
    (let 
        (
            ;; Fetch properties of the specified atbspace.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            ;; Fetch the latest index to mint
            (current-mint (+ (var-get atb-index) u1))
            (price (if (is-none (get atbspace-manager atbspace-props))
                        (try! (compute-atb-price atb (get price-function atbspace-props)))
                        u0
                    )
            )
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure the atb is not already registered.
        (asserts! (is-none (map-get? atb-properties {atb: atb, atbspace: atbspace})) ERR-atb-NOT-AVAILABLE)
        ;; Verify that the atb contains only valid characters.
        (asserts! (not (has-invalid-chars atb)) ERR-CHARSET-INVALID)
        ;; Ensure the contract-caller is the atbspace's designated import principal or the atbspace manager
        (asserts! (or (is-eq (get atbspace-import atbspace-props) contract-caller) (is-eq (get atbspace-manager atbspace-props) (some contract-caller))) ERR-OPERATION-UNAUTHORIZED)
        ;; Check that the atbspace has not been launched yet, as atbs can only be imported to atbspaces that are revealed but not launched.
        (asserts! (is-none (get launched-at atbspace-props)) ERR-atbspace-ALREADY-LAUNCHED)
        ;; Confirm that the import is occurring within the allowed timeframe since the atbspace was revealed.
        (asserts! (< burn-block-height (+ (get revealed-at atbspace-props) atbspace-LAUNCHABILITY-TTL)) ERR-atbspace-PREORDER-LAUNCHABILITY-EXPIRED)
        ;; Set the atb properties
        (map-set atb-properties {atb: atb, atbspace: atbspace}
            {
                registered-at: none,
                imported-at: (some burn-block-height),
                revoked-at: false,
                zonefile-hash: (some zonefile-hash),
                hashed-salted-fqn-preorder: none,
                preordered-by: none,
                renewal-height: u0,
                stx-burn: price,
                owner: beneficiary,
            }
        )
        (map-set atb-to-index {atb: atb, atbspace: atbspace} current-mint)
        (map-set index-to-atb current-mint {atb: atb, atbspace: atbspace})
        ;; Update primary atb if needed for send-to
        (update-primary-atb-recipient current-mint beneficiary)
        ;; Update the index of the minting
        (var-set atb-index current-mint)
        ;; Mint the atb to the beneficiary
        (try! (nft-mint? ATB-V2 current-mint beneficiary))
        ;; Log the new atb registration
        (print 
            {
                topic: "new-atb",
                owner: beneficiary,
                atb: {atb: atb, atbspace: atbspace},
                id: current-mint,
            }
        )
        ;; Confirm successful import of the atb.
        (ok true)
    )
)

;; @desc Public function `atbspace-update-price` updates the pricing function for a specific atbspace.
;; @param: atbspace (buff 20): The atbspace for which the price function is being updated.
;; @param: p-func-base (uint): The base price used in the pricing function.
;; @param: p-func-coeff (uint): The coefficient used in the pricing function.
;; @param: p-func-b1 to p-func-b16 (uint): The bucket-specific multipliers for the pricing function.
;; @param: p-func-non-alpha-discount (uint): The discount applied for non-alphabetic characters.
;; @param: p-func-no-vowel-discount (uint): The discount applied when no vowels are present.
(define-public (atbspace-update-price 
    (atbspace (buff 20)) 
    (p-func-base uint) 
    (p-func-coeff uint) 
    (p-func-b1 uint) 
    (p-func-b2 uint) 
    (p-func-b3 uint) 
    (p-func-b4 uint) 
    (p-func-b5 uint) 
    (p-func-b6 uint) 
    (p-func-b7 uint) 
    (p-func-b8 uint) 
    (p-func-b9 uint) 
    (p-func-b10 uint) 
    (p-func-b11 uint) 
    (p-func-b12 uint) 
    (p-func-b13 uint) 
    (p-func-b14 uint) 
    (p-func-b15 uint) 
    (p-func-b16 uint) 
    (p-func-non-alpha-discount uint) 
    (p-func-no-vowel-discount uint)
)
    (let 
        (
            ;; Retrieve the current properties of the atbspace.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            ;; Construct the new price function.
            (price-function 
                {
                    buckets: (list p-func-b1 p-func-b2 p-func-b3 p-func-b4 p-func-b5 p-func-b6 p-func-b7 p-func-b8 p-func-b9 p-func-b10 p-func-b11 p-func-b12 p-func-b13 p-func-b14 p-func-b15 p-func-b16),
                    base: p-func-base,
                    coeff: p-func-coeff,
                    nonalpha-discount: p-func-non-alpha-discount,
                    no-vowel-discount: p-func-no-vowel-discount
                }
            )
        )
        (match (get atbspace-manager atbspace-props) 
            manager
            ;; Ensure that the transaction sender is the atbspace's designated import principal.
            (asserts! (is-eq manager contract-caller) ERR-OPERATION-UNAUTHORIZED)
            ;; Ensure that the contract-caller is the atbspace's designated import principal.
            (asserts! (is-eq (get atbspace-import atbspace-props) contract-caller) ERR-OPERATION-UNAUTHORIZED)
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Verify the atbspace's price function can still be updated.
        (asserts! (get can-update-price-function atbspace-props) ERR-OPERATION-UNAUTHORIZED)
        ;; Update the atbspace's record in the `atbspaces` map with the new price function.
        (map-set atbspaces atbspace (merge atbspace-props { price-function: price-function }))
        ;; Confirm the successful update of the price function.
        (ok true)
    )
)

;; @desc Public function `atbspace-freeze-price` disables the ability to update the price function for a given atbspace.
;; @param: atbspace (buff 20): The target atbspace for which the price function update capability is being revoked.
(define-public (atbspace-freeze-price (atbspace (buff 20)))
    (let 
        (
            ;; Retrieve the properties of the specified atbspace to verify its existence and fetch its current settings.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
        )
        (match (get atbspace-manager atbspace-props) 
            manager 
            ;; Ensure that the transaction sender is the same as the atbspace's designated import principal.
            (asserts! (is-eq manager contract-caller) ERR-OPERATION-UNAUTHORIZED)
            ;; Ensure that the contract-caller is the same as the atbspace's designated import principal.
            (asserts! (is-eq (get atbspace-import atbspace-props) contract-caller) ERR-OPERATION-UNAUTHORIZED)
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Update the atbspace properties in the `atbspaces` map, setting `can-update-price-function` to false.
        (map-set atbspaces atbspace 
            (merge atbspace-props { can-update-price-function: false })
        )
        ;; Return a success confirmation.
        (ok true)
    )
)

;; @desc (new) A 'fast' one-block registration function: (atb-claim-fast)
;; Warning: this *is* snipeable, for a slower but un-snipeable claim, use the pre-order & register functions
;; @param: atb (buff 48): The atb being claimed.
;; @param: atbspace (buff 20): The atbspace under which the atb is being claimed.
;; @param: zonefile-hash (buff 20): The hash of the zone file associated with the atb.
;; @param: stx-burn (uint): The amount of STX to burn for the claim.
;; @param: send-to (principal): The principal to whom the atb will be sent.
(define-public (atb-claim-fast (atb (buff 48)) (atbspace (buff 20)) (zonefile-hash (buff 20)) (send-to principal)) 
    (let 
        (
            ;; Retrieve atbspace properties.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            (current-atbspace-manager (get atbspace-manager atbspace-props))
            ;; Calculates the ID for the new atb to be minted.
            (id-to-be-minted (+ (var-get atb-index) u1))
            ;; Check if the atb already exists.
            (atb-props (map-get? atb-properties {atb: atb, atbspace: atbspace}))
            ;; new to get the price of the atb
            (atb-price (if (is-none current-atbspace-manager)
                            (try! (compute-atb-price atb (get price-function atbspace-props)))
                            u0
                        )
            )
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure the atb is not already registered.
        (asserts! (is-none atb-props) ERR-atb-NOT-AVAILABLE)
        ;; Verify that the atb contains only valid characters.
        (asserts! (not (has-invalid-chars atb)) ERR-CHARSET-INVALID)
        ;; Ensure that the atbspace is launched
        (asserts! (is-some (get launched-at atbspace-props)) ERR-atbspace-NOT-LAUNCHED)
        ;; Check atbspace manager
        (match current-atbspace-manager 
            manager 
            ;; If manager, check contract-caller is manager
            (asserts! (is-eq contract-caller manager) ERR-NOT-AUTHORIZED)
            ;; If no manager
            (begin 
                ;; Asserts contract-caller is the send-to if not a managed atbspace
                (asserts! (is-eq contract-caller send-to) ERR-NOT-AUTHORIZED)
                ;; Updated this to burn the actual ammount of the atb-price
                (try! (stx-burn? atb-price send-to))
            )
        )
        ;; Update the index
        (var-set atb-index id-to-be-minted)
        ;; Sets properties for the newly registered atb.
        (map-set atb-properties
            {
                atb: atb, atbspace: atbspace
            } 
            {
               
                registered-at: (some (+ burn-block-height u1)),
                imported-at: none,
                revoked-at: false,
                zonefile-hash: (some zonefile-hash),
                hashed-salted-fqn-preorder: none,
                preordered-by: none,
                ;; Updated this to actually start with the registered-at date/block, and also to be u0 if it is a managed atbspace
                renewal-height: (if (is-some current-atbspace-manager)
                                    u0
                                    (+ (get lifetime atbspace-props) burn-block-height u1)
                                ),
                stx-burn: atb-price,
                owner: send-to,
            }
        )
        (map-set atb-to-index {atb: atb, atbspace: atbspace} id-to-be-minted) 
        (map-set index-to-atb id-to-be-minted {atb: atb, atbspace: atbspace}) 
        ;; Update primary atb if needed for send-to
        (update-primary-atb-recipient id-to-be-minted send-to)
        ;; Mints the new atb atb.
        (try! (nft-mint? ATB-V2 id-to-be-minted send-to))
        ;; Log the new atb registration
        (print 
            {
                topic: "new-atb",
                owner: send-to,
                atb: {atb: atb, atbspace: atbspace},
                id: id-to-be-minted,
            }
        )
        ;; Signals successful completion.
        (ok id-to-be-minted)
    )
)

;; @desc Defines a public function `atb-preorder` for preordering atb atbs by burning the registration fee and submitting the salted hash.
;; Callable by anyone; the actual check for authorization happens in the `atb-register` function.
;; @param: hashed-salted-fqn (buff 20): The hashed and salted fully qualified atb.
;; @param: stx-to-burn (uint): The amount of STX to burn for the preorder.
(define-public (atb-preorder (hashed-salted-fqn (buff 20)) (stx-to-burn uint))
    (begin
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS) 
        ;; Validate the length of the hashed-salted FQN.
        (asserts! (is-eq (len hashed-salted-fqn) HASH160LEN) ERR-HASH-MALFORMED)
        ;; Ensures that the amount of STX specified to burn is greater than zero.
        (asserts! (> stx-to-burn u0) ERR-STX-BURNT-INSUFFICIENT)
        ;; Check if the same hashed-salted-fqn has been used before
        (asserts! (is-none (map-get? atb-single-preorder hashed-salted-fqn)) ERR-PREORDERED-BEFORE)
        ;; Transfers the specified amount of stx to the atb contract to burn on register
        (try! (stx-transfer? stx-to-burn contract-caller .ATB-V2))
        ;; Records the preorder in the 'atb-preorders' map.
        (map-set atb-preorders
            { hashed-salted-fqn: hashed-salted-fqn, buyer: contract-caller }
            { created-at: burn-block-height, stx-burned: stx-to-burn, claimed: false}
        )
        ;; Sets the map with just the hashed-salted-fqn as the key
        (map-set atb-single-preorder hashed-salted-fqn true)
        ;; Returns the block height at which the preorder's claimability period will expire.
        (ok (+ burn-block-height PREORDER-CLAIMABILITY-TTL))
    )
)

;; @desc Public function `atb-register` finalizes the registration of a atb atb for users from unmanaged atbspaces.
;; @param: atbspace (buff 20): The atbspace to which the atb belongs.
;; @param: atb (buff 48): The atb to be registered.
;; @param: salt (buff 20): The salt used during the preorder.
;; @param: zonefile-hash (buff 20): The hash of the zone file.
(define-public (atb-register (atbspace (buff 20)) (atb (buff 48)) (salt (buff 20)) (zonefile-hash (buff 20)))
    (let 
        (
            ;; Generate a unique identifier for the atb by hashing the fully-qualified atb with salt
            (hashed-salted-fqn (hash160 (concat (concat (concat atb 0x2e) atbspace) salt)))
            ;; Retrieve the preorder details for this atb
            (preorder (unwrap! (map-get? atb-preorders { hashed-salted-fqn: hashed-salted-fqn, buyer: contract-caller }) ERR-PREORDER-NOT-FOUND))
            ;; Fetch the properties of the atbspace
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            ;; Get the amount of burned STX
            (stx-burned (get stx-burned preorder))
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure that the atbspace is launched
        (asserts! (is-some (get launched-at atbspace-props)) ERR-atbspace-NOT-LAUNCHED)
        ;; Ensure the preorder hasn't been claimed before
        (asserts! (not (get claimed preorder)) ERR-OPERATION-UNAUTHORIZED)
        ;; Check that the atbspace doesn't have a manager (implying it's open for registration)
        (asserts! (is-none (get atbspace-manager atbspace-props)) ERR-NOT-AUTHORIZED)
        ;; Verify that the preorder was made after the atbspace was launched
        (asserts! (> (get created-at preorder) (unwrap! (get launched-at atbspace-props) ERR-UNWRAP)) ERR-atb-PREORDERED-BEFORE-atbspace-LAUNCH)
        ;; Ensure the registration is happening within the allowed time window after preorder
        (asserts! (< burn-block-height (+ (get created-at preorder) PREORDER-CLAIMABILITY-TTL)) ERR-PREORDER-CLAIMABILITY-EXPIRED)
        ;; Make sure at least one block has passed since the preorder (prevents front-running)
        (asserts! (> burn-block-height (+ (get created-at preorder) u1)) ERR-atb-NOT-CLAIMABLE-YET)
        ;; Verify that enough STX was burned during preorder to cover the atb price
        (asserts! (is-eq stx-burned (try! (compute-atb-price atb (get price-function atbspace-props)))) ERR-STX-BURNT-INSUFFICIENT)
        ;; Verify that the atb contains only valid characters.
        (asserts! (not (has-invalid-chars atb)) ERR-CHARSET-INVALID)
        ;; Mark the preorder as claimed to prevent double-spending
        (map-set atb-preorders { hashed-salted-fqn: hashed-salted-fqn, buyer: contract-caller } (merge preorder {claimed: true}))
        ;; Check if the atb already exists
        (match (map-get? atb-properties {atb: atb, atbspace: atbspace})
            atb-props-exist
            ;; If the atb exists 
            (handle-existing-atb atb-props-exist hashed-salted-fqn (get created-at preorder) stx-burned atb atbspace zonefile-hash (get lifetime atbspace-props))
            ;; If the atb does not exist
            (register-new-atb (+ (var-get atb-index) u1) hashed-salted-fqn zonefile-hash stx-burned atb atbspace (get lifetime atbspace-props))    
        )
    )
)

;; @desc (new) Defines a public function `claim-preorder` for claiming back the STX commited to be burnt on registration.
;; This should only be allowed to go through if preorder-claimability-ttl has passed
;; @param: hashed-salted-fqn (buff 20): The hashed and salted fully qualified atb.
(define-public (claim-preorder (hashed-salted-fqn (buff 20)))
    (let
        (
            ;; Retrieves the preorder details.
            (preorder (unwrap! (map-get? atb-preorders { hashed-salted-fqn: hashed-salted-fqn, buyer: contract-caller }) ERR-PREORDER-NOT-FOUND))
            (claimer contract-caller)
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS) 
        ;; Check if the preorder-claimability-ttl has passed
        (asserts! (> burn-block-height (+ (get created-at preorder) PREORDER-CLAIMABILITY-TTL)) ERR-OPERATION-UNAUTHORIZED)
        ;; Asserts that the preorder has not been claimed
        (asserts! (not (get claimed preorder)) ERR-OPERATION-UNAUTHORIZED)
        ;; Transfers back the specified amount of stx from the atb contract to the contract-caller
        (try! (as-contract (stx-transfer? (get stx-burned preorder) .ATB-V2 claimer)))
        ;; Deletes the preorder in the 'atb-preorders' map.
        (map-delete atb-preorders { hashed-salted-fqn: hashed-salted-fqn, buyer: contract-caller })
        ;; Remove the entry from the atb-single-preorder map
        (map-delete atb-single-preorder hashed-salted-fqn)
        ;; Returns ok true
        (ok true)
    )
)

;; @desc (new) This function is similar to `atb-preorder` but only for atbspace managers, without the burning of STX tokens.
;; Intended only for managers as mng-atb-register & atb-register will validate.
;; @param: hashed-salted-fqn (buff 20): The hashed and salted fully-qualified atb (FQN) being preordered.
(define-public (mng-atb-preorder (hashed-salted-fqn (buff 20)))
    (begin
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Validates that the length of the hashed and salted FQN is exactly 20 bytes.
        (asserts! (is-eq (len hashed-salted-fqn) HASH160LEN) ERR-HASH-MALFORMED)
        ;; Check if the same hashed-salted-fqn has been used before
        (asserts! (is-none (map-get? atb-single-preorder hashed-salted-fqn)) ERR-PREORDERED-BEFORE)
        ;; Records the preorder in the 'atb-preorders' map. Buyer set to contract-caller
        (map-set atb-preorders
            { hashed-salted-fqn: hashed-salted-fqn, buyer: contract-caller }
            { created-at: burn-block-height, stx-burned: u0, claimed: false }
        )
        ;; Sets the map with just the hashed-salted-fqn as the key
        (map-set atb-single-preorder hashed-salted-fqn true)
        ;; Returns the block height at which the preorder's claimability period will expire.
        (ok (+ burn-block-height PREORDER-CLAIMABILITY-TTL))
    )
)

;; @desc (new) This function uses provided details to verify the preorder, register the atb, and assign it initial properties.
;; This should only allow Managers from MANAGED atbspaces to register atbs.
;; @param: atbspace (buff 20): The atbspace for the atb.
;; @param: atb (buff 48): The atb being registered.
;; @param: salt (buff 20): The salt used in hashing.
;; @param: zonefile-hash (buff 20): The hash of the zone file.
;; @param: send-to (principal): The principal to whom the atb will be registered.
(define-public (mng-atb-register (atbspace (buff 20)) (atb (buff 48)) (salt (buff 20)) (zonefile-hash (buff 20)) (send-to principal))
    (let 
        (
            ;; Generates the hashed, salted fully-qualified atb.
            (hashed-salted-fqn (hash160 (concat (concat (concat atb 0x2e) atbspace) salt)))
            ;; Retrieves the existing properties of the atbspace to confirm its existence and management details.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            (current-atbspace-manager (unwrap! (get atbspace-manager atbspace-props) ERR-NO-atbspace-MANAGER))
            ;; Retrieves the preorder information using the hashed-salted FQN to verify the preorder exists
            (preorder (unwrap! (map-get? atb-preorders { hashed-salted-fqn: hashed-salted-fqn, buyer: current-atbspace-manager }) ERR-PREORDER-NOT-FOUND))
            ;; Calculates the ID for the new atb to be minted.
            (id-to-be-minted (+ (var-get atb-index) u1))
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure the preorder has not been claimed before
        (asserts! (not (get claimed preorder)) ERR-OPERATION-UNAUTHORIZED)
        ;; Ensure the atb is not already registered
        (asserts! (is-none (map-get? atb-properties {atb: atb, atbspace: atbspace})) ERR-atb-NOT-AVAILABLE)
        ;; Verify that the atb contains only valid characters.
        (asserts! (not (has-invalid-chars atb)) ERR-CHARSET-INVALID)
        ;; Verifies that the caller is the atbspace manager.
        (asserts! (is-eq contract-caller current-atbspace-manager) ERR-NOT-AUTHORIZED)
        ;; Validates that the preorder was made after the atbspace was officially launched.
        (asserts! (> (get created-at preorder) (unwrap! (get launched-at atbspace-props) ERR-UNWRAP)) ERR-atb-PREORDERED-BEFORE-atbspace-LAUNCH)
        ;; Verifies the registration is completed within the claimability period.
        (asserts! (< burn-block-height (+ (get created-at preorder) PREORDER-CLAIMABILITY-TTL)) ERR-PREORDER-CLAIMABILITY-EXPIRED)
        ;; Sets properties for the newly registered atb.
        (map-set atb-properties
            {
                atb: atb, atbspace: atbspace
            } 
            {
                registered-at: (some burn-block-height),
                imported-at: none,
                revoked-at: false,
                zonefile-hash: (some zonefile-hash),
                hashed-salted-fqn-preorder: (some hashed-salted-fqn),
                preordered-by: (some send-to),
                ;; Updated this to be u0, so that renewals are handled through the atbspace manager 
                renewal-height: u0,
                stx-burn: u0,
                owner: send-to,
            }
        )
        (map-set atb-to-index {atb: atb, atbspace: atbspace} id-to-be-minted)
        (map-set index-to-atb id-to-be-minted {atb: atb, atbspace: atbspace})
        ;; Update primary atb if needed for send-to
        (update-primary-atb-recipient id-to-be-minted send-to)
        ;; Updates atb-index variable to the newly minted ID.
        (var-set atb-index id-to-be-minted)
        ;; Update map to claimed for preorder, to avoid people reclaiming stx from an already registered atb
        (map-set atb-preorders { hashed-salted-fqn: hashed-salted-fqn, buyer: current-atbspace-manager } (merge preorder {claimed: true}))
        ;; Mints the atb atb as an NFT to the send-to address, finalizing the registration.
        (try! (nft-mint? ATB-V2 id-to-be-minted send-to))
        ;; Log the new atb registration
        (print 
            {
                topic: "new-atb",
                owner: send-to,
                atb: {atb: atb, atbspace: atbspace},
                id: id-to-be-minted,
            }
        )
        ;; Confirms successful registration of the atb.
        (ok id-to-be-minted)
    )
)

;; @desc Public function `update-zonefile-hash` for changing the zone file hash associated with a atb.
;; This operation is typically used to update the zone file contents of a atb, such as when deploying a new Gaia hub.
;; @param: atbspace (buff 20): The atbspace of the atb whose zone file hash is being updated.
;; @param: atb (buff 48): The atb whose zone file hash is being updated.
;; @param: zonefile-hash (buff 20): The new zone file hash to be associated with the atb.
(define-public (update-zonefile-hash (atbspace (buff 20)) (atb (buff 48)) (zonefile-hash (buff 20)))
    (let 
        (
            ;; Get index from atb and atbspace
            (index-id (unwrap! (get-id-from-atb atb atbspace) ERR-NO-atb))
            ;; Get the owner
            (owner (unwrap! (nft-get-owner? ATB-V2 index-id) ERR-UNWRAP))
            ;; Get atb props
            (atb-props (unwrap! (map-get? atb-properties {atb: atb, atbspace: atbspace}) ERR-NO-atb))
            (renewal (get renewal-height atb-props))
            (current-zone-file (get zonefile-hash atb-props))
            (revoked (get revoked-at atb-props))
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Assert we are actually updating the zonefile
        (asserts! (not (is-eq (some zonefile-hash) current-zone-file)) ERR-OPERATION-UNAUTHORIZED)
        ;; Asserts the atb has not been revoked.
        (asserts! (not revoked) ERR-atb-REVOKED)
        ;; Zonefile updates should happen throught the atbspace manager contract
        ;; Check if there is a atbspace manager
        (match (get atbspace-manager (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            manager 
            ;; If there is then check that the contract-caller is the manager
            (asserts! (is-eq manager contract-caller) ERR-NOT-AUTHORIZED)
            ;; If there isn't assert that the owner is the contract-caller
            (asserts! (is-eq (some contract-caller) (nft-get-owner? ATB-V2 index-id)) ERR-NOT-AUTHORIZED)
        )
        ;; Assert that the atb is in valid time or grace period
        (asserts! (<= burn-block-height (+ renewal atb-GRACE-PERIOD-DURATION)) ERR-OPERATION-UNAUTHORIZED)
        ;; Update the zonefile hash
        (map-set atb-properties {atb: atb, atbspace: atbspace}
            (merge
                atb-props
                {zonefile-hash: (some zonefile-hash)}
            )
        )
        ;; Confirm successful completion of the zone file hash update.
        (ok true)
    )
)

;; @desc Public function `atb-revoke` for making a atb unresolvable.
;; @param: atbspace (buff 20): The atbspace of the atb to be revoked.
;; @param: atb (buff 48): The actual atb to be revoked.
(define-public (atb-revoke (atbspace (buff 20)) (atb (buff 48)))
    (let 
        (
            ;; Retrieve the properties of the atbspace to ensure it exists and is valid for registration.
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            (atbspace-manager (get atbspace-manager atbspace-props))
            ;; retreive the atb props
            (atb-props (unwrap! (map-get? atb-properties {atb: atb, atbspace: atbspace}) ERR-NO-atb))
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure the caller is authorized to revoke the atb.
        (asserts! 
            (match atbspace-manager 
                manager 
                (is-eq contract-caller manager)
                (is-eq contract-caller (get atbspace-import atbspace-props))
            ) 
            ERR-NOT-AUTHORIZED
        )
        ;; Mark the atb as revoked.
        (map-set atb-properties {atb: atb, atbspace: atbspace}
            (merge 
                atb-props
                {
                    revoked-at: true,
                    zonefile-hash: none,
                } 
            )
        )
        ;; Return a success response indicating the atb has been successfully revoked.
        (ok true)
    )
)

;; Public function `atb-renewal` for renewing ownership of a atb.
;; @param: atbspace (buff 20): The atbspace of the atb to be renewed.
;; @param: atb (buff 48): The actual atb to be renewed.
;; @param: stx-to-burn (uint): The amount of STX tokens to be burned for renewal.
;; @param: zonefile-hash (optional (buff 20)): The new zone file hash to be associated with the atb.
(define-public (atb-renewal (atbspace (buff 20)) (atb (buff 48)) (zonefile-hash (optional (buff 20))))
    (let 
        (
            ;; Get the unique identifier for this atb
            (atbv-index (unwrap! (get-id-from-atb atb atbspace) ERR-NO-atb))
            ;; Retrieve the properties of the atbspace
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            ;; Get the manager of the atbspace, if any
            (atbspace-manager (get atbspace-manager atbspace-props))
            ;; Get the current owner of the atb
            (owner (unwrap! (nft-get-owner? ATB-V2 atbv-index) ERR-NO-atb))
            ;; Retrieve the properties of the atb
            (atb-props (unwrap! (map-get? atb-properties { atb: atb, atbspace: atbspace }) ERR-NO-atb))
            ;; Get the lifetime of atbs in this atbspace
            (lifetime (get lifetime atbspace-props))
            ;; Get the current renewal height of the atb
            (renewal-height (try! (get-renewal-height atbv-index)))
            ;; Calculate the new renewal height based on current block height
            (new-renewal-height (+ burn-block-height lifetime))
        )
        ;; Check if migration is complete
        (asserts! (var-get migration-complete) ERR-MIGRATION-IN-PROGRESS)
        ;; Verify that the atbspace has been launched
        (asserts! (is-some (get launched-at atbspace-props)) ERR-atbspace-NOT-LAUNCHED)
        ;; Ensure the atbspace doesn't have a manager
        (asserts! (is-none atbspace-manager) ERR-atbspace-HAS-MANAGER)
        ;; Check if renewals are required for this atbspace
        (asserts! (> lifetime u0) ERR-LIFETIME-EQUAL-0)
        ;; Verify that the atb has not been revoked
        (asserts! (not (get revoked-at atb-props)) ERR-atb-REVOKED) 
        ;; Handle renewal based on whether it's within the grace period or not
        (if (< burn-block-height (+ renewal-height atb-GRACE-PERIOD-DURATION))   
            (try! (handle-renewal-in-grace-period atb atbspace atb-props owner lifetime new-renewal-height))
            (try! (handle-renewal-after-grace-period atb atbspace atb-props owner atbv-index new-renewal-height))
        )
        ;; Burn the specified amount of STX
        (try! (stx-burn? (try! (compute-atb-price atb (get price-function atbspace-props))) contract-caller))
        ;; update the new stx-burn to the one paid in renewal
        (map-set atb-properties { atb: atb, atbspace: atbspace } (merge (unwrap-panic (map-get? atb-properties { atb: atb, atbspace: atbspace })) {stx-burn: (try! (compute-atb-price atb (get price-function atbspace-props)))}))
        ;; Update the zonefile hash if provided
        (match zonefile-hash
            zonefile (try! (update-zonefile-hash atbspace atb zonefile))
            false
        )
        ;; Return success
        (ok true)
    )
)

;; Private function to handle renewals within the grace period
(define-private (handle-renewal-in-grace-period 
    (atb (buff 48)) 
    (atbspace (buff 20)) 
    (atb-props 
        {
            registered-at: (optional uint), 
            imported-at: (optional uint), 
            revoked-at: bool, 
            zonefile-hash: (optional (buff 20)), 
            hashed-salted-fqn-preorder: (optional (buff 20)), 
            preordered-by: (optional principal), 
            renewal-height: uint, 
            stx-burn: uint, 
            owner: principal
        }
    ) 
    (owner principal) 
    (lifetime uint) 
    (new-renewal-height uint)
)
    (begin
        ;; Ensure only the owner can renew within the grace period
        (asserts! (is-eq contract-caller owner) ERR-NOT-AUTHORIZED)
        ;; Update the atb properties with the new renewal height
        (map-set atb-properties {atb: atb, atbspace: atbspace} 
            (merge atb-props 
                {
                    renewal-height: 
                        ;; If still within lifetime, extend from current renewal height; otherwise, use new renewal height
                        (if (< burn-block-height (unwrap-panic (get-renewal-height (unwrap-panic (get-id-from-atb atb atbspace)))))
                            (+ (unwrap-panic (get-renewal-height (unwrap-panic (get-id-from-atb atb atbspace)))) lifetime)
                            new-renewal-height
                        )
                }
            )
        )
        (ok true)
    )
)

;; Private function to handle renewals after the grace period
(define-private (handle-renewal-after-grace-period 
    (atb (buff 48)) 
    (atbspace (buff 20)) 
    (atb-props 
        {
            registered-at: (optional uint), 
            imported-at: (optional uint), 
            revoked-at: bool, 
            zonefile-hash: (optional (buff 20)), 
            hashed-salted-fqn-preorder: (optional (buff 20)), 
            preordered-by: (optional principal), 
            renewal-height: uint, 
            stx-burn: uint, 
            owner: principal
        }
    ) 
    (owner principal) 
    (atbv-index uint) 
    (new-renewal-height uint)
)
    (if (is-eq contract-caller owner)
        ;; If the owner is renewing, simply update the renewal height
        (ok 
            (map-set atb-properties {atb: atb, atbspace: atbspace}
                (merge atb-props {renewal-height: new-renewal-height})
            )
        )
        ;; If someone else is renewing (taking over the atb)
        (begin 
            ;; Check if the atb is listed on the market and remove the listing if it is
            (match (map-get? market atbv-index)
                listed-atb 
                (map-delete market atbv-index) 
                true
            )
            (map-set atb-properties {atb: atb, atbspace: atbspace}
                    (merge atb-props {renewal-height: new-renewal-height})
            )
            ;; Update the atb properties with the new renewal height and owner
            (ok (try! (purchase-transfer atbv-index owner contract-caller)))

        )
    )  
)

;; Returns the minimum of two uint values.
(define-private (min (a uint) (b uint))
    ;; If 'a' is less than or equal to 'b', return 'a', else return 'b'.
    (if (<= a b) a b)  
)

;; Returns the maximum of two uint values.
(define-private (max (a uint) (b uint))
    ;; If 'a' is greater than 'b', return 'a', else return 'b'.
    (if (> a b) a b)  
)

;; Retrieves an exponent value from a list of buckets based on the provided index.
(define-private (get-exp-at-index (buckets (list 16 uint)) (index uint))
    ;; Retrieves the element at the specified index.
    (unwrap-panic (element-at buckets index))  
)

;; Determines if a character is a digit (0-9).
(define-private (is-digit (char (buff 1)))
    (or 
        ;; Checks if the character is between '0' and '9' using hex values.
        (is-eq char 0x30) ;; 0
        (is-eq char 0x31) ;; 1
        (is-eq char 0x32) ;; 2
        (is-eq char 0x33) ;; 3
        (is-eq char 0x34) ;; 4
        (is-eq char 0x35) ;; 5
        (is-eq char 0x36) ;; 6
        (is-eq char 0x37) ;; 7
        (is-eq char 0x38) ;; 8
        (is-eq char 0x39) ;; 9
    )
) 

;; Checks if a character is a lowercase alphabetic character (a-z).
(define-private (is-lowercase-alpha (char (buff 1)))
    (or 
        ;; Checks for each lowercase letter using hex values.
        (is-eq char 0x61) ;; a
        (is-eq char 0x62) ;; b
        (is-eq char 0x63) ;; c
        (is-eq char 0x64) ;; d
        (is-eq char 0x65) ;; e
        (is-eq char 0x66) ;; f
        (is-eq char 0x67) ;; g
        (is-eq char 0x68) ;; h
        (is-eq char 0x69) ;; i
        (is-eq char 0x6a) ;; j
        (is-eq char 0x6b) ;; k
        (is-eq char 0x6c) ;; l
        (is-eq char 0x6d) ;; m
        (is-eq char 0x6e) ;; n
        (is-eq char 0x6f) ;; o
        (is-eq char 0x70) ;; p
        (is-eq char 0x71) ;; q
        (is-eq char 0x72) ;; r
        (is-eq char 0x73) ;; s
        (is-eq char 0x74) ;; t
        (is-eq char 0x75) ;; u
        (is-eq char 0x76) ;; v
        (is-eq char 0x77) ;; w
        (is-eq char 0x78) ;; x
        (is-eq char 0x79) ;; y
        (is-eq char 0x7a) ;; z
    )
) 

;; Determines if a character is a vowel (a, e, i, o, u, and y).
(define-private (is-vowel (char (buff 1)))
    (or 
        (is-eq char 0x61) ;; a
        (is-eq char 0x65) ;; e
        (is-eq char 0x69) ;; i
        (is-eq char 0x6f) ;; o
        (is-eq char 0x75) ;; u
        (is-eq char 0x79) ;; y
    )
)

;; Identifies if a character is a special character, specifically '-' or '_'.
(define-private (is-special-char (char (buff 1)))
    (or 
        (is-eq char 0x2d) ;; -
        (is-eq char 0x5f)) ;; _
) 

;; Determines if a character is valid within a atb, based on allowed character sets.
(define-private (is-char-valid (char (buff 1)))
    (or (is-lowercase-alpha char) (is-digit char) (is-special-char char))
)

;; Checks if a character is non-alphabetic, either a digit or a special character.
(define-private (is-nonalpha (char (buff 1)))
    (or (is-digit char) (is-special-char char))
)

;; Evaluates if a atb contains any vowel characters.
(define-private (has-vowels-chars (atb (buff 48)))
    (> (len (filter is-vowel atb)) u0)
)

;; Determines if a atb contains non-alphabetic characters.
(define-private (has-nonalpha-chars (atb (buff 48)))
    (> (len (filter is-nonalpha atb)) u0)
)

;; Identifies if a atb contains any characters that are not considered valid.
(define-private (has-invalid-chars (atb (buff 48)))
    (< (len (filter is-char-valid atb)) (len atb))
)

;; Private helper function `is-atbspace-available` checks if a atbspace is available for registration or other operations.
;; It considers if the atbspace has been launched and whether it has expired.
;; @params:
    ;; atbspace (buff 20): The atbspace to check for availability.
(define-private (is-atbspace-available (atbspace (buff 20)))
    ;; Check if the atbspace exists
    (match (map-get? atbspaces atbspace) 
        atbspace-props
        ;; If it exists
        ;; Check if the atbspace has been launched.
        (match (get launched-at atbspace-props) 
            launched
            ;; If the atbspace is launched, it's considered unavailable if it hasn't expired.
            false
            ;; Check if the atbspace is expired by comparing the current block height to the reveal time plus the launchability TTL.
            (> burn-block-height (+ (get revealed-at atbspace-props) atbspace-LAUNCHABILITY-TTL))
        )
        ;; If the atbspace doesn't exist in the map, it's considered available.
        true
    )
)

;; Private helper function `compute-atb-price` calculates the registration price for a atb based on its length and character composition.
;; It utilizes a configurable pricing function that can adjust prices based on the atb's characteristics.
;; @params:
;;     atb (buff 48): The atb for which the price is being calculated.
;;     price-function (tuple): A tuple containing the parameters of the pricing function, including:
;;         buckets (list 16 uint): A list defining price multipliers for different atb lengths.
;;         base (uint): The base price multiplier.
;;         coeff (uint): A coefficient that adjusts the base price.
;;         nonalpha-discount (uint): A discount applied to atbs containing non-alphabetic characters.
;;         no-vowel-discount (uint): A discount applied to atbs lacking vowel characters.
(define-private (compute-atb-price (atb (buff 48)) (price-function {buckets: (list 16 uint), base: uint, coeff: uint, nonalpha-discount: uint, no-vowel-discount: uint}))
    (let 
        (
            ;; Determine the appropriate exponent based on the atb's length.
            ;; This corresponds to a specific bucket in the pricing function.
            ;; The length of the atb is used to index into the buckets list, with a maximum index of 15.
            (exponent (get-exp-at-index (get buckets price-function) (min u15 (- (len atb) u1)))) 
            ;; Calculate the no-vowel discount.
            ;; If the atb has no vowels, apply the no-vowel discount from the price function.
            ;; Otherwise, use 1 indicating no discount.
            (no-vowel-discount (if (not (has-vowels-chars atb)) (get no-vowel-discount price-function) u1))
            ;; Calculate the non-alphabetic character discount.
            ;; If the atb contains non-alphabetic characters, apply the non-alpha discount from the price function.
            ;; Otherwise, use 1 indicating no discount.
            (nonalpha-discount (if (has-nonalpha-chars atb) (get nonalpha-discount price-function) u1))
            (len-atb (len atb))
        )
        (asserts! (> len-atb u0) ERR-atb-BLANK)
        ;; Compute the final price.
        ;; The base price, adjusted by the coefficient and exponent, is divided by the greater of the two discounts (non-alpha or no-vowel).
        ;; The result is then multiplied by 10 to adjust for unit precision.
        (ok (* (/ (* (get coeff price-function) (pow (get base price-function) exponent)) (max nonalpha-discount no-vowel-discount)) u10))
    )
)

;; This function is similar to the 'transfer' function but does not check that the owner is the contract-caller.
;; @param id: the id of the nft being transferred.
;; @param owner: the principal of the current owner of the nft being transferred.
;; @param recipient: the principal of the recipient to whom the nft is being transferred.
(define-private (purchase-transfer (id uint) (owner principal) (recipient principal))
    (let 
        (
            ;; Attempts to retrieve the atb and atbspace associated with the given NFT ID.
            (atb-and-atbspace (unwrap! (map-get? index-to-atb id) ERR-NO-atb))
            ;; Retrieves the properties of the atb within the atbspace.
            (atb-props (unwrap! (map-get? atb-properties atb-and-atbspace) ERR-NO-atb))
        )
        ;; Check owner and recipient is not the same
        (asserts! (not (is-eq owner recipient)) ERR-OPERATION-UNAUTHORIZED)
        (asserts! (is-eq owner (get owner atb-props)) ERR-NOT-AUTHORIZED)
        ;; Update primary atb if needed for owner
        (update-primary-atb-owner id owner)
        ;; Update primary atb if needed for recipient
        (update-primary-atb-recipient id recipient)
        ;; Updates the atb properties map with the new information.
        ;; Maintains existing properties but sets the zonefile hash to none for a clean slate and updates the owner to the recipient.
        (map-set atb-properties atb-and-atbspace (merge atb-props {zonefile-hash: none, owner: recipient}))
        ;; Executes the NFT transfer from the current owner to the recipient.
        (nft-transfer? ATB-V2 id owner recipient)
    )
)

;; Private function to update the primary atb of an address when transfering a atb
;; If the id is = to the primary atb then it means that a transfer is happening and we should delete it
(define-private (update-primary-atb-owner (id uint) (owner principal)) 
    ;; Check if the owner is transferring the primary atb
    (if (is-eq (map-get? primary-atb owner) (some id)) 
        ;; If it is, then delete the primary atb map
        (map-delete primary-atb owner)
        ;; If it is not, do nothing, keep the current primary atb
        false
    )
)

;; Private function to update the primary atb of an address when recieving
(define-private (update-primary-atb-recipient (id uint) (recipient principal)) 
    ;; Check if recipient has a primary atb
    (match (map-get? primary-atb recipient)
        recipient-primary-atb
        ;; If recipient has a primary atb do nothing
        true
        ;; If recipient doesn't have a primary atb
        (map-set primary-atb recipient id)
    )
)

(define-private (handle-existing-atb 
    (atb-props 
        {
            registered-at: (optional uint), 
            imported-at: (optional uint), 
            revoked-at: bool, 
            zonefile-hash: (optional (buff 20)), 
            hashed-salted-fqn-preorder: (optional (buff 20)), 
            preordered-by: (optional principal), 
            renewal-height: uint, 
            stx-burn: uint, 
            owner: principal
        }
    ) 
    (hashed-salted-fqn (buff 20)) 
    (contract-caller-preorder-height uint) 
    (stx-burned uint) (atb (buff 48)) 
    (atbspace (buff 20)) 
    (zonefile-hash (buff 20))
    (renewal uint)
)
    (let 
        (
            ;; Retrieve the index of the existing atb
            (atbv-index (unwrap-panic (map-get? atb-to-index {atb: atb, atbspace: atbspace})))
        )
        ;; Straight up check if the atb was imported
        (asserts! (is-none (get imported-at atb-props)) ERR-IMPORTED-BEFORE)
        ;; If the check passes then it is registered, we can straight up check the hashed-salted-fqn-preorder
        (match (get hashed-salted-fqn-preorder atb-props)
            fqn 
            ;; Compare both preorder's height
            (asserts! (> (unwrap-panic (get created-at (map-get? atb-preorders {hashed-salted-fqn: fqn, buyer: (unwrap-panic (get preordered-by atb-props))}))) contract-caller-preorder-height) ERR-PREORDERED-BEFORE)
            ;; Compare registered with preorder height
            (asserts! (> (unwrap-panic (get registered-at atb-props)) contract-caller-preorder-height) ERR-FAST-MINTED-BEFORE)
        )
        ;; Update the atb properties with the new preorder information since it is the best preorder
        (map-set atb-properties {atb: atb, atbspace: atbspace} (merge atb-props {hashed-salted-fqn-preorder: (some hashed-salted-fqn), preordered-by: (some contract-caller), registered-at: (some burn-block-height), renewal-height: (+ burn-block-height renewal), stx-burn: stx-burned}))
        (try! (as-contract (stx-transfer? stx-burned .ATB-V2 (get owner atb-props))))
        ;; Transfer ownership of the atb to the new owner
        (try! (purchase-transfer atbv-index (get owner atb-props) contract-caller))
        (try! (update-zonefile-hash atbspace atb zonefile-hash))
        ;; Log the atb transfer event
        (print {topic: "new-atb", owner: contract-caller, atb: {atb: atb, atbspace: atbspace}, id: atbv-index})
        ;; Return the atb index
        (ok atbv-index)
    )
)

(define-private (register-new-atb (id-to-be-minted uint) (hashed-salted-fqn (buff 20)) (zonefile-hash (buff 20)) (stx-burned uint) (atb (buff 48)) (atbspace (buff 20)) (lifetime uint))
    (begin
        ;; Set the properties for the newly registered atb
        (map-set atb-properties
            {atb: atb, atbspace: atbspace} 
            {
                registered-at: (some burn-block-height),
                imported-at: none,
                revoked-at: false,
                zonefile-hash: (some zonefile-hash),
                hashed-salted-fqn-preorder: (some hashed-salted-fqn),
                preordered-by: (some contract-caller),
                renewal-height: (+ lifetime burn-block-height),
                stx-burn: stx-burned,
                owner: contract-caller,
            }
        )
        ;; Update the index-to-atb and atb-to-index mappings
        (map-set index-to-atb id-to-be-minted {atb: atb, atbspace: atbspace})
        (map-set atb-to-index {atb: atb, atbspace: atbspace} id-to-be-minted)
        ;; Increment the atb index
        (var-set atb-index id-to-be-minted)
        ;; Update the primary atb for the new owner if necessary
        (update-primary-atb-recipient id-to-be-minted contract-caller)
        ;; Mint a new NFT for the atb atb
        (try! (nft-mint? ATB-V2 id-to-be-minted contract-caller))
        ;; Burn the STX paid for the atb registration
        (try! (as-contract (stx-burn? stx-burned .ATB-V2)))
        ;; Log the new atb registration event
        (print {topic: "new-atb", owner: contract-caller, atb: {atb: atb, atbspace: atbspace}, id: id-to-be-minted})
        ;; Return the ID of the newly minted atb
        (ok id-to-be-minted)
    )
)

;; Migration Functions
(define-public (atbspace-airdrop 
    (atbspace (buff 20))
    (pricing {base: uint, buckets: (list 16 uint), coeff: uint, no-vowel-discount: uint, nonalpha-discount: uint}) 
    (lifetime uint) 
    (atbspace-import principal) 
    (atbspace-manager (optional principal)) 
    (can-update-price bool) 
    (manager-transfers bool) 
    (manager-frozen bool)
    (revealed-at uint)
    (launched-at (optional uint))
)
    (begin
        ;; Check if migration is complete
        (asserts! (not (var-get migration-complete)) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure the contract-caller is the airdrop contract.
        (asserts! (is-eq .migration-airdrop-atb contract-caller) ERR-OPERATION-UNAUTHORIZED)
        ;; Ensure the atbspace consists of valid characters only.
        (asserts! (not (has-invalid-chars atbspace)) ERR-CHARSET-INVALID)
        ;; Check that the atbspace is available for reveal.
        (asserts! (unwrap! (can-atbspace-be-registered atbspace) ERR-atbspace-ALREADY-EXISTS) ERR-atbspace-ALREADY-EXISTS)
        ;; Set all properties
        (map-set atbspaces atbspace
            {
                atbspace-manager: atbspace-manager,
                manager-transferable: manager-transfers,
                manager-frozen: manager-frozen,
                atbspace-import: atbspace-import,
                revealed-at: revealed-at,
                launched-at: launched-at,
                lifetime: lifetime,
                can-update-price-function: can-update-price,
                price-function: pricing 
            }
        )
        ;; Confirm successful airdrop of the atbspace
        (ok atbspace)
    )
)

(define-public (atb-airdrop
    (atb (buff 48))
    (atbspace (buff 20))
    (imported-at (optional uint)) 
    (registered-at (optional uint)) 
    (revoked-at bool) 
    (zonefile-hash (optional (buff 20)))
    (renewal-height uint)
    (owner principal)
)
    (let
        (
            (mint-index (+ u1 (var-get atb-index)))
            (atbspace-props (unwrap! (map-get? atbspaces atbspace) ERR-atbspace-NOT-FOUND))
            (pricing (get price-function atbspace-props))
            (atb-price (try! (compute-atb-price atb pricing)))
        )
        ;; Check if migration is complete
        (asserts! (not (var-get migration-complete)) ERR-MIGRATION-IN-PROGRESS)
        ;; Ensure the contract-caller is the airdrop contract.
        (asserts! (is-eq .migration-airdrop-atb contract-caller) ERR-OPERATION-UNAUTHORIZED)
        ;; Ensure the atb does not exist
        (asserts! (is-none (map-get? atb-to-index {atb: atb, atbspace: atbspace})) ERR-atb-NOT-AVAILABLE)
        ;; Set all properties
        (map-set atb-to-index {atb: atb, atbspace: atbspace} mint-index)
        (map-set index-to-atb mint-index {atb: atb, atbspace: atbspace})
        (map-set atb-properties {atb: atb, atbspace: atbspace}
            {
                registered-at: registered-at,
                imported-at: imported-at,
                ;; set to true or false
                revoked-at: revoked-at,
                zonefile-hash: zonefile-hash,
                ;; Set to none new property
                hashed-salted-fqn-preorder: none,
                ;; Set to none new property
                preordered-by: none,
                renewal-height: renewal-height,
                stx-burn: atb-price,
                owner: owner,
            }
        )
        ;; Update the index 
        (var-set atb-index mint-index)
        ;; Update the primary atb of the recipient
        (update-primary-atb-recipient mint-index owner)
        ;; Mint the atb to the owner
        (try! (nft-mint? ATB-V2 mint-index owner))
        ;; Confirm successful airdrop of the atbspace
        (ok mint-index)
    )
)

(define-public (flip-migration-complete)
    (ok 
        (begin 
            (asserts! (is-eq contract-caller deployer) ERR-NOT-AUTHORIZED) 
            (var-set migration-complete true)
        )
    )
)
```
