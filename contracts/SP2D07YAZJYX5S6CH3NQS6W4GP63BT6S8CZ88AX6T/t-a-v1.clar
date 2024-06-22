;; title: set-experiment-v1
;; version: V-1

;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;
;;;;;; traits ;;;;;
;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;

;;;;;;;;;
;; New ;;
;;;;;;;;;
;; Import SIP-09 NFT trait 
(impl-trait .sip-09.nft-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Token Definition ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;
;; New ;;
;;;;;;;;;
;; Define the non-fungible token (NFT) called set-experiment-v1 with unique identifiers as unsigned integers
(define-non-fungible-token set-experiment-v1 uint)

;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Constants ;;;;;
;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;
;; New ;;
;;;;;;;;;
;; Constants for the token name and symbol, providing identifiers for the NFTs
(define-constant token-name "set-experiment-v1")
(define-constant token-symbol "set-experiment-v1")
(define-constant total-allowed-airdrops u100)

;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;
;;;; Errors ;;;;
;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;

(define-constant ERR-UNWRAP (err u101))
(define-constant ERR-NOT-AUTHORIZED (err u102))
(define-constant ERR-NOT-FOUND (err u117))
(define-constant ERR-AIRDROP-COMPLETE (err u155))

;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Variables ;;;;;
;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;
;; New ;;
;;;;;;;;;
;; Counter to keep track of the last minted NFT ID, ensuring unique identifiers
(define-data-var set-experiment-index uint u0)

(define-data-var total-airdrops-made uint u0)

;;;;;;;;;
;; New ;;
;;;;;;;;;
;; Variable to store the token URI, allowing for metadata association with the NFT
(define-data-var token-uri (string-ascii 246) "")

;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;
;;;;;; Maps ;;;;;
;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;

;;;;;;;;;
;; New ;;
;;;;;;;;;
;; This map tracks the primary id chosen by a user who owns multiple set-experiment ids.
;; It maps a user's principal to the ID of their primary id.
(define-map primary-id principal uint)

;;;;;;;;;
;; New ;;
;;;;;;;;;
;; Tracks all the set-experiment ids owned by a user. Each user is mapped to a list of id IDs.
;; This allows for easy enumeration of all ids owned by a particular user.
(define-map set-experiment-ids-by-principal principal (list 1000 uint))


;;;;;;;;;;;;;
;; Updated ;;
;;;;;;;;;;;;;
;; Contains detailed properties of ids, including registration and importation times, revocation status, and zonefile hash.
(define-map id-properties
    { id: (buff 48), idspace: (buff 20) }
    {
        registered-at: (optional uint),
        imported-at: (optional uint),
        revoked-at: (optional uint),
        zonefile-hash: (optional (buff 20)),
        locked: bool, 
        renewal-height: uint,
        stx-burn: uint,
        owner: principal,
    }
)

;;;;;;;;;
;; New ;;
;;;;;;;;;
(define-map index-to-id uint 
    {
        id: (buff 48), idspace: (buff 20)
    } 
)

;;;;;;;;;
;; New ;;
;;;;;;;;;
(define-map id-to-index 
    {
        id: (buff 48), idspace: (buff 20)
    } 
    uint
)

;;;;;;;;;;;;;
;; Updated ;;
;;;;;;;;;;;;;
;; Stores properties of idspaces, including their import principals, reveal and launch times, and pricing functions.
(define-map idspaces (buff 20)
    { 
        idspace-manager: (optional principal),
        manager-transferable: bool,
        idspace-import: principal,
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

;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;
;;;;;; Public ;;;;;
;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;

;;;;;;;;;
;; New ;;
;;;;;;;;;
;; @desc SIP-09 compliant function to transfer a token from one owner to another
;; @param id: the id of the nft being transferred, owner: the principal of the owner of the nft being transferred, recipient: the principal the nft is being transferred to
(define-public (transfer (id uint) (owner principal) (recipient principal))
    ;; Executes the NFT transfer from owner to recipient if all conditions are met.
    (nft-transfer? set-experiment-v1 id owner recipient)

)

;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;
;;;;; Read Only ;;;;
;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;

;; @desc SIP-09 compliant function to get the last minted token's ID
(define-read-only (get-last-token-id)
    ;; Returns the current value of set-experiment-index variable, which tracks the last token ID
    (ok (var-get set-experiment-index))
)

;; @desc SIP-09 compliant function to get token URI
(define-read-only (get-token-uri (id uint))
    ;; Returns a predefined set URI for the token metadata
    (ok (some (var-get token-uri)))
)

;; @desc SIP-09 compliant function to get the owner of a specific token by its ID
(define-read-only (get-owner (id uint))
    ;; Check and return the owner of the specified NFT
    (ok (nft-get-owner? set-experiment-v1 id))
)

;; Read-only function `get-idspace-properties` for retrieving properties of a specific idspace.
;; @params:
    ;; idspace (buff 20): The idspace whose properties are being queried.
(define-read-only (get-idspace-properties (idspace (buff 20)))
    (let 
        (
            ;; Fetch the properties of the specified idspace from the `idspaces` map.
            (idspace-props (unwrap! (map-get? idspaces idspace) ERR-NOT-FOUND))
        )
        ;; Returns the idspace along with its associated properties.
        (ok { idspace: idspace, properties: idspace-props })
    )
)


;; Defines a read-only function to fetch the unique ID of a set-experiment id given its id and the idspace it belongs to.
(define-read-only (get-id-from-set-experiment (id (buff 48)) (idspace (buff 20))) 
    ;; Attempts to retrieve the ID from the 'id-to-index' map using the provided id and idspace as the key.
    (map-get? id-to-index {id: id, idspace: idspace})
)

;; Defines a read-only function to fetch the unique ID of a set-experiment id given its id and the idspace it belongs to.
(define-read-only (get-set-experiment-from-id (id uint)) 
    ;; Attempts to retrieve the ID from the 'id-to-index' map using the provided id and idspace as the key.
    (map-get? index-to-id id)
)

;; Fetcher for all set-experiment ids owned by a principal
(define-read-only (get-all-ids-owned-by-principal (owner principal))
    (map-get? set-experiment-ids-by-principal owner)
)

;; Fetcher for primary id
(define-read-only (get-primary-id (owner principal))
    (map-get? primary-id owner)
)

(define-read-only (get-id-props (id (buff 48)) (idspace (buff 20)))
    (map-get? id-properties {id: id, idspace: idspace})
)

;; AIRDROP FUNCTION
;; NEW MNG-AIRDROP-id
;; A capped function for airdrop migration
(define-public (mng-airdrop-id (id (buff 48)) (idspace (buff 20)) (send-to principal)) 
    (let 
        (
            ;; Calculates the ID for the new id to be minted, incrementing the last used ID.
            (id-to-be-minted (+ (var-get set-experiment-index) u1))
            ;; Retrieves a list of all ids currently owned by the recipient. Defaults to an empty list if none are found.
            (all-users-ids-owned (default-to (list) (map-get? set-experiment-ids-by-principal send-to)))
            ;; Tries to retrieve the id and idspace to see if it already exists
            (id-props (map-get? id-properties {id: id, idspace: idspace}))
            ;; Get data from set-experiment v1 contract for on chain validation and map setting
            (id-v1-resolve (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve idspace id) ERR-UNWRAP))
            (v1-owner (get owner id-v1-resolve))
            (v1-zonefile (get zonefile-hash id-v1-resolve))
            (registered-at (get lease-started-at id-v1-resolve))
        ) 
        ;; asserts that the owner in v1 is the same as the one we are sending to
        (asserts! (is-eq send-to v1-owner) ERR-NOT-AUTHORIZED)
        ;; asserts that total-airdrops-made is lower or equal to total-allowed-airdrops
        (asserts! (<= (var-get total-airdrops-made) total-allowed-airdrops) ERR-AIRDROP-COMPLETE)
        ;; asserts contract-caller is the migration-airdrop contract
        (asserts! (is-eq contract-caller .m-a-v1) ERR-NOT-AUTHORIZED)
        ;; Updates the list of all ids owned by the recipient to include the new id ID.
        (map-set set-experiment-ids-by-principal send-to (unwrap! (as-max-len? (append all-users-ids-owned id-to-be-minted) u1000) ERR-UNWRAP))
        ;; Set the index 
        (var-set set-experiment-index id-to-be-minted)
        ;; Conditionally sets the newly minted id as the primary id if the recipient does not already have one.
        (match (map-get? primary-id send-to) 
            receiver
            false
            (map-set primary-id send-to id-to-be-minted)
        )
        ;; Sets properties for the newly registered id including registration time, price, owner, and associated zonefile hash.
        (map-set id-properties
            {
                id: id, idspace: idspace
            } 
            {
                registered-at: (some registered-at),
                imported-at: none,
                revoked-at: none,
                zonefile-hash: (some v1-zonefile),
                locked: false,
                renewal-height: u0,
                stx-burn: u0,
                owner: send-to,
            }
        )
        ;; Updates the airdrops made
        (var-set total-airdrops-made (+ (var-get total-airdrops-made) u1))
        ;; Links the newly minted ID to the id and idspace combination for reverse lookup.
        (map-set index-to-id id-to-be-minted {id: id, idspace: idspace})
        ;; Links the id and idspace combination to the newly minted ID for forward lookup.
        (map-set id-to-index {id: id, idspace: idspace} id-to-be-minted)
        ;; Mints the new set-experiment id as an NFT, assigned to the 'send-to' principal.
        (try! (nft-mint? set-experiment-v1 id-to-be-minted send-to))
        ;; Signals successful completion of the registration process.
        (ok true)
    )
)





