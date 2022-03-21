;; Interface definitions
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait .operable.operable)

(use-trait com10 .commission-trait-sip10.commission)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-data-var CONTRACT_OWNER principal tx-sender)
(define-data-var mint-counter uint u0)
(define-data-var token-uri (string-ascii 246) "ipfs://QmXBaNb1XmLcXbcZ7TgJ85yuJMHnUA3vG7mWEVniL4WYge/thisisnumberone-{id}.json")
(define-data-var metadata-frozen bool false)

;; constants
(define-constant MINT-PRICE u100000)

(define-constant COLLECTION_MAX_SUPPLY u5)

(define-constant ERR_METADATA_FROZEN (err u101))
(define-constant ERR_COULDNT_GET_NFT_OWNER (err u103))
(define-constant ERR_PRICE_WAS_ZERO (err u104))
(define-constant ERR_NFT_NOT_LISTED_FOR_SALE (err u105))
(define-constant ERR_NFT_LISTED (err u107))
(define-constant ERR_COLLECTION_LIMIT_REACHED (err u108))
(define-constant ERR_MINT_PASS_LIMIT_REACHED (err u109))
(define-constant ERR_WRONG_COMMISSION (err u111))
(define-constant ERR_WRONG_TOKEN (err u112))
(define-constant ERR_UNKNOWN_TENDER (err u113))
(define-constant ERR_BATCH_SIZE_EXCEEDED u114)

(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_OWNER (err u402))
(define-constant ERR_NOT_ADMINISTRATOR (err u403))
(define-constant ERR_NOT_FOUND (err u404))

(define-non-fungible-token thisisnumberone uint)

;; data structures

(define-map mint-commission 
    principal ;; tender
    {
        price: uint,
        address: principal,
        commissionAddress: principal,
        commissionRate: uint
    }
)
;; {owner, operator, id} -> boolean
;; if {owner, operator, id}->true in map, then operator can perform actions on behalf of owner for this id
(define-map approvals {owner: principal, operator: principal, id: uint} bool)

;; id -> {price (in token), commission trait}
;; if id is not in map, it is not listed for sale
(define-map market uint {price: uint, commission: principal, token: principal})

;; whitelist address -> # they can mint
(define-map mint-pass principal uint)

;; SIP-09: get last token id
(define-read-only (get-last-token-id)
  (ok (var-get mint-counter))
)

;; SIP-09: URI for metadata associated with the token
(define-read-only (get-token-uri (id uint))
    (ok (some (var-get token-uri)))
)

;; SIP-09: Gets the owner of the 'Specified token ID.
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? thisisnumberone id))
)

;; SIP-09: Transfer
(define-public (transfer (id uint) (owner principal) (recipient principal))
    (begin
        (asserts! (unwrap! (is-approved id contract-caller) ERR_NOT_AUTHORIZED) ERR_NOT_AUTHORIZED)
        (asserts! (is-none (map-get? market id)) ERR_NFT_LISTED)
        (map-delete approvals {owner: owner, operator: contract-caller, id: id})
        (nft-transfer? thisisnumberone id owner recipient)
    )
)

;; operable
(define-read-only (is-approved (id uint) (operator principal))
    (let ((owner (unwrap! (nft-get-owner? thisisnumberone id) ERR_COULDNT_GET_NFT_OWNER)))
        (ok (is-owned-or-approved id operator owner))
    )
)

;; operable
(define-public (set-approved (id uint) (operator principal) (approved bool))
    (let ((owner (unwrap! (nft-get-owner? thisisnumberone id) ERR_COULDNT_GET_NFT_OWNER)))
        (asserts! (is-eq owner contract-caller) ERR_NOT_OWNER)
        (ok (map-set approvals {owner: contract-caller, operator: operator, id: id} approved))
    )
)

;; public methods
(define-public (set-mint-commission (tender <ft-trait>) (price uint) (address principal) (commissionAddress principal) (commissionRate uint))
    (begin
        (asserts! (is-eq contract-caller (var-get CONTRACT_OWNER)) ERR_NOT_ADMINISTRATOR)
        (ok (map-set mint-commission
            (contract-of tender)
            {
                price: price,
                address: address,
                commissionAddress: commissionAddress,
                commissionRate: commissionRate
            }
        ))
    )
)
(define-public (remove-mint-commission (tender <ft-trait>))
    (begin
        (asserts! (is-eq contract-caller (var-get CONTRACT_OWNER)) ERR_NOT_ADMINISTRATOR)
        (ok (map-delete mint-commission (contract-of tender)))
    )
)

(define-public (mint-with (token <ft-trait>))
    (let (
            (pricing (unwrap! (map-get? mint-commission (contract-of token)) ERR_UNKNOWN_TENDER))
            (price (get price pricing))
            (artistAddress (get address pricing))
            (commissionAddress (get commissionAddress pricing))
            (commissionAmount (/ (* price (get commissionRate pricing)) u10000))
            (artistAmount (- price commissionAmount))
            (newMintCounter (+ (var-get mint-counter) u1))
            (mintPassBalance (get-mint-pass-balance contract-caller))
        )
        (asserts! (<= newMintCounter COLLECTION_MAX_SUPPLY) ERR_COLLECTION_LIMIT_REACHED)
        (asserts! (> mintPassBalance u0) ERR_MINT_PASS_LIMIT_REACHED)
        
        (and (> artistAmount u0) (try! (contract-call? token transfer artistAmount contract-caller artistAddress none)))
        (and (> commissionAmount u0) (try! (contract-call? token transfer commissionAmount contract-caller commissionAddress none)))

        (try! (nft-mint? thisisnumberone newMintCounter contract-caller))
        (var-set mint-counter newMintCounter)
        (map-set mint-pass contract-caller (- mintPassBalance u1))
        (ok newMintCounter)
    )
)

;; only size of list matters, content of list doesn't matter
(define-public (mint-with-many (entries uint) (token <ft-trait>))
    (begin
        (try! (if (<= u1 entries) (mint-with token) (ok u0)))
        (try! (if (<= u2 entries) (mint-with token) (ok u0)))
        (try! (if (<= u3 entries) (mint-with token) (ok u0)))
        (try! (if (<= u4 entries) (mint-with token) (ok u0)))
        (try! (if (<= u5 entries) (mint-with token) (ok u0)))
        (ok true)
    )
)

(define-public (set-mint-pass (account principal) (limit uint))
    (begin
        (asserts! (is-eq (var-get CONTRACT_OWNER) contract-caller) ERR_NOT_ADMINISTRATOR)
        (ok (map-set mint-pass account limit))
    )
)

(define-public (batch-set-mint-pass (entries (list 200 {account: principal, limit: uint})))
   (begin
        (asserts! (is-eq (var-get CONTRACT_OWNER) contract-caller) ERR_NOT_ADMINISTRATOR)
        (map set-mint-pass-helper entries)
        (ok true)
    )
)

(define-private (set-mint-pass-helper (entry {account: principal, limit: uint}))
    (map-set mint-pass (get account entry) (get limit entry))
)

;; marketplace function
(define-public (list-in-token (id uint) (price uint) (comm <com10>) (token <ft-trait>))
    (let ((listing {price: price, commission: (contract-of comm), token: (contract-of token)})) 
        (asserts! (is-eq contract-caller (unwrap! (nft-get-owner? thisisnumberone id) ERR_COULDNT_GET_NFT_OWNER)) ERR_NOT_OWNER)
        (asserts! (> price u0) ERR_PRICE_WAS_ZERO)
        (ok (map-set market id listing))
    )
)

;; marketplace function
(define-public (unlist-in-token (id uint))
    (begin
        (asserts! (is-eq contract-caller (unwrap! (nft-get-owner? thisisnumberone id) ERR_COULDNT_GET_NFT_OWNER)) ERR_NOT_OWNER)
        (ok (map-delete market id))
    )
)

;; marketplace function
(define-public (buy-in-token (id uint) (comm <com10>) (token <ft-trait>))
    (let 
        (
            (listing (unwrap! (map-get? market id) ERR_NFT_NOT_LISTED_FOR_SALE))
            (owner (unwrap! (nft-get-owner? thisisnumberone id) ERR_COULDNT_GET_NFT_OWNER))
            (buyer contract-caller)
            (price (get price listing))
        )
        (asserts! (is-eq (contract-of token) (get token listing)) ERR_WRONG_TOKEN)
        (asserts! (is-eq (contract-of comm) (get commission listing)) ERR_WRONG_COMMISSION)
        (try! (contract-call? token transfer price contract-caller owner none))
        (try! (contract-call? comm pay token id price))
        (try! (nft-transfer? thisisnumberone id owner buyer))
        (map-delete market id)
        (ok true)
    )
)

(define-public (burn (id uint))
    (let ((owner (unwrap! (nft-get-owner? thisisnumberone id) ERR_COULDNT_GET_NFT_OWNER)))
        (asserts! (is-eq owner contract-caller) ERR_NOT_OWNER)
        (map-delete market id)
        (nft-burn? thisisnumberone id contract-caller)
    )
)

;; the contract CONTRACT_OWNER can change the contract CONTRACT_OWNER
(define-public (set-administrator (new-administrator principal))
    (begin
        (asserts! (is-eq (var-get CONTRACT_OWNER) contract-caller) ERR_NOT_ADMINISTRATOR)
        (ok (var-set CONTRACT_OWNER new-administrator))
    )
)

(define-public (set-token-uri (new-token-uri (string-ascii 80)))
    (begin
        (asserts! (is-eq contract-caller (var-get CONTRACT_OWNER)) ERR_NOT_ADMINISTRATOR)
        (asserts! (not (var-get metadata-frozen)) ERR_METADATA_FROZEN)
        (var-set token-uri new-token-uri)
        (ok true))
)

(define-public (freeze-metadata)
    (begin
        (asserts! (is-eq contract-caller (var-get CONTRACT_OWNER)) ERR_NOT_ADMINISTRATOR)
        (var-set metadata-frozen true)
        (ok true)
    )
)

;; read only methods
(define-read-only (get-listing-in-token (id uint))
    (map-get? market id)
)

(define-read-only (get-mint-pass-balance (account principal))
    (default-to u0
        (map-get? mint-pass account)
    )
)

;; private methods
(define-private (is-owned-or-approved (id uint) (operator principal) (owner principal))
    (default-to
        (is-eq owner operator)
        (map-get? approvals {owner: owner, operator: operator, id: id})
    )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior 
        ok-value result
        err-value (err err-value)
    )
)

;; TODO: add all whitelists
(map-set mint-pass 'SP1R1061ZT6KPJXQ7PAXPFB6ZAZ6ZWW28GBQA1W0F u5)
