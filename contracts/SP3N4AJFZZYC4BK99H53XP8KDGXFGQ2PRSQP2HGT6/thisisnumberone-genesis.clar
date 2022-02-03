;; Interface definitions
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait .operable.operable)

;; TODO: either deploy it on admin address, or use an existing mainnet one
(use-trait commission-trait .commission-trait.commission)

;; contract variables
(define-data-var administrator principal tx-sender)

(define-data-var mint-counter uint u0)

(define-data-var token-uri (string-ascii 246) "ipfs://QmaAEbacfobkuEUFvxRX88a7dS4xMu9bVaMiuC5pj5xze2/genesis-{id}.json")
(define-data-var metadata-frozen bool false)

;; constants
(define-constant MINT-PRICE u1000000)

(define-constant token-name "thisisnumberone")
(define-constant token-symbol "#1")
(define-constant COLLECTION-MAX-SUPPLY u5)

(define-constant ERR-METADATA-FROZEN (err u101))
(define-constant ERR-COULDNT-GET-V1-DATA (err u102))
(define-constant ERR-COULDNT-GET-NFT-OWNER (err u103))
(define-constant ERR-PRICE-WAS-ZERO (err u104))
(define-constant ERR-NFT-NOT-LISTED-FOR-SALE (err u105))
(define-constant ERR-PAYMENT-ADDRESS (err u106))
(define-constant ERR-NFT-LISTED (err u107))
(define-constant ERR-COLLECTION-LIMIT-REACHED (err u108))
(define-constant ERR-MINT-PASS-LIMIT-REACHED (err u109))
(define-constant ERR-ADD-MINT-PASS (err u110))
(define-constant ERR-WRONG-COMMISSION (err u111))

(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-OWNER (err u402))
(define-constant ERR-NOT-ADMINISTRATOR (err u403))
(define-constant ERR-NOT-FOUND (err u404))

(define-constant wallet-1 'SP1WJY09D3DEE45B1PY8TAV838VCH9HNEJW0QPFND)

(define-non-fungible-token thisisnumberone uint)

;; data structures

;; {owner, operator, id} -> boolean
;; if {owner, operator, id}->true in map, then operator can perform actions on behalf of owner for this id
(define-map approvals {owner: principal, operator: principal, id: uint} bool)
(define-map approvals-all {owner: principal, operator: principal} bool)

;; id -> {price (in ustx), commission trait}
;; if id is not in map, it is not listed for sale
(define-map market uint {price: uint, commission: principal})

;; whitelist address -> # they can mint
(define-map mint-pass principal uint)

;; SIP-09: get last token id
(define-read-only (get-last-token-id)
  (ok (- (var-get mint-counter) u1))
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
        (asserts! (unwrap! (is-approved id contract-caller) ERR-NOT-AUTHORIZED) ERR-NOT-AUTHORIZED)
        (asserts! (is-none (map-get? market id)) ERR-NFT-LISTED)
        (nft-transfer? thisisnumberone id owner recipient)
    )
)

;; operable
(define-read-only (is-approved (id uint) (operator principal))
    (let ((owner (unwrap! (nft-get-owner? thisisnumberone id) ERR-COULDNT-GET-NFT-OWNER)))
        (ok (is-owned-or-approved id operator owner))
    )
)

;; operable
(define-public (set-approved (id uint) (operator principal) (approved bool))
    (ok (map-set approvals {owner: contract-caller, operator: operator, id: id} approved))
)

(define-public (set-approved-all (operator principal) (approved bool))
    (ok (map-set approvals-all {owner: contract-caller, operator: operator} approved))
)

;; public methods
(define-public (mint-token)
    (let (
            (mintCounter (var-get mint-counter))
            (mintPassBalance (get-mint-pass-balance contract-caller))
        )
        (asserts! (< mintCounter COLLECTION-MAX-SUPPLY) ERR-COLLECTION-LIMIT-REACHED)
        (asserts! (> mintPassBalance u0) ERR-MINT-PASS-LIMIT-REACHED)

        (try! (paymint-split MINT-PRICE contract-caller))
        (try! (nft-mint? thisisnumberone mintCounter contract-caller))
        (var-set mint-counter (+ mintCounter u1))
        (map-set mint-pass contract-caller (- mintPassBalance u1))
        (ok true)
    )
)

;; only size of list matters, content of list doesn't matter
(define-public (batch-mint-token (entries (list 20 uint)))
    (fold check-err
        (map mint-token-helper entries)
        (ok true)
    )
)

;; fail-safe: allow admin to airdrop to recipient, hopefully will never be used
(define-public (admin-mint-airdrop (recipient principal) (id uint))
    (begin
        (asserts! (< id COLLECTION-MAX-SUPPLY) ERR-COLLECTION-LIMIT-REACHED)
        (asserts! (is-eq contract-caller (var-get administrator)) ERR-NOT-ADMINISTRATOR)
        (try! (nft-mint? thisisnumberone id recipient))
        (ok true)
    )
)

(define-public (set-mint-pass (account principal) (limit uint))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) ERR-NOT-ADMINISTRATOR)
        (ok (map-set mint-pass account limit))
    )
)

(define-public (batch-set-mint-pass (entries (list 200 {account: principal, limit: uint})))
    (fold check-err
        (map set-mint-pass-helper entries)
        (ok true)
    )
)

;; marketplace function
(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
    (let ((listing {price: price, commission: (contract-of comm)})) 
        (asserts! (is-eq contract-caller (unwrap! (nft-get-owner? thisisnumberone id) ERR-COULDNT-GET-NFT-OWNER)) ERR-NOT-OWNER)
        (asserts! (> price u0) ERR-PRICE-WAS-ZERO)
        (ok (map-set market id listing))
    )
)

;; marketplace function
(define-public (unlist-in-ustx (id uint))
    (begin 
        (asserts! (is-eq contract-caller (unwrap! (nft-get-owner? thisisnumberone id) ERR-COULDNT-GET-NFT-OWNER)) ERR-NOT-OWNER)
        (ok (map-delete market id))
    )
)

;; marketplace function
(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
    (let 
        (
            (listing (unwrap! (map-get? market id) ERR-NFT-NOT-LISTED-FOR-SALE))
            (owner (unwrap! (nft-get-owner? thisisnumberone id) ERR-COULDNT-GET-NFT-OWNER))
            (buyer contract-caller)
            (price (get price listing))
        )
        (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
        (try! (stx-transfer? price contract-caller owner))
        (try! (contract-call? comm pay id price))
        (try! (nft-transfer? thisisnumberone id owner buyer))
        (map-delete market id)
        (ok true)
    )
)

(define-public (burn (id uint))
    (let ((owner (unwrap! (nft-get-owner? thisisnumberone id) ERR-COULDNT-GET-NFT-OWNER)))
        (asserts! (is-eq owner contract-caller) ERR-NOT-OWNER)
        (map-delete market id)
        (nft-burn? thisisnumberone id contract-caller)
    )
)

;; the contract administrator can change the contract administrator
(define-public (set-administrator (new-administrator principal))
    (begin
        (asserts! (is-eq (var-get administrator) contract-caller) ERR-NOT-ADMINISTRATOR)
        (ok (var-set administrator new-administrator))
    )
)

(define-public (set-token-uri (new-token-uri (string-ascii 80)))
    (begin
        (asserts! (is-eq contract-caller (var-get administrator)) ERR-NOT-ADMINISTRATOR)
        (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
        (var-set token-uri new-token-uri)
        (ok true))
)

(define-public (freeze-metadata)
    (begin
        (asserts! (is-eq contract-caller (var-get administrator)) ERR-NOT-ADMINISTRATOR)
        (var-set metadata-frozen true)
        (ok true)
    )
)

;; read only methods
(define-read-only (get-listing-in-ustx (id uint))
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
        (default-to
            (is-eq owner operator)
            (map-get? approvals-all {owner: owner, operator: operator})
        )
        (map-get? approvals {owner: owner, operator: operator, id: id})
    )
)

(define-private (paymint-split (mintPrice uint) (payer principal)) 
    (begin
        (try! (stx-transfer? mintPrice payer wallet-1))
        (ok true)
    )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior 
        ok-value result
        err-value (err err-value)
    )
)

;; unused param on purpose
(define-private (mint-token-helper (entry uint))
    (mint-token)
)

(define-private (set-mint-pass-helper (entry {account: principal, limit: uint}))
    (set-mint-pass (get account entry) (get limit entry))
)

;; TODO: add all whitelists
(map-set mint-pass 'SP1R1061ZT6KPJXQ7PAXPFB6ZAZ6ZWW28GBQA1W0F u5)
