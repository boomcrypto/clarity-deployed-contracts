;; Import
;; trait to implement
;; on mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; on testnet
;;(impl-trait 'ST2PABAF9FTAJYNFZH93XENAJ8FVY99RRM4DF2YCW.nft-trait.nft-trait)
;; local
;;(impl-trait .nft-trait.nft-trait)
;; Non Fungible Token, modeled after ERC-721(this is the name that appears in wallet, global)
(define-non-fungible-token OpenArtSource uint)

;; Storage
(define-map tokens-spender
  uint
  principal)
(define-map tokens-count
  principal
  uint)
(define-map accounts-operator
  (tuple (operator principal) (account principal))
  (tuple (is-approved bool)))
(define-map tokens-meta-uri
  uint
  (string-ascii 256)
)
;; Store the last issued token ID
(define-data-var last-token-id uint u0)

;; Store contract admins(simulate ethereum only_owner like usage)
(define-map admins principal bool)

;; # of admin, control accidental removing all admins
(define-data-var admin-count uint u0)

(define-map last-token-count
  principal
  uint)

(define-map tokens-owned
  { owner: principal, idx: uint } ;; principal and owner slot#(0...)
  uint ;; token id
)

(define-map tokens-slot
  { owner: principal, token-id: uint } ;; principal and token id
  uint ;; slot#
)

(define-constant UINT_LIST (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 ))

(define-private (not-zero (a uint))
  (> a u0)
)

(define-private (add-base (a uint) (l (list 10 uint)))
  (get result (fold build-add-base l {base: a, result: (filter not-zero (list u0))}))
)

(define-private (build-add-base (elem uint) (data { base: uint, result: (list 10 uint)}))
  (let 
    ((base (get base data)))
    (merge data { result: (unwrap-panic (as-max-len? (append (get result data) (+ elem base)) u10)) })
  )
)


(define-private (block-range (upperLimit uint))
  (get result (fold build-block-range UINT_LIST {upperLimit: upperLimit, result: (filter not-zero (list u0))}))
)

(define-private (build-block-range (elem uint) (data { upperLimit: uint, result: (list 100 uint)}))
  (if (<= elem (get upperLimit data))
    (merge data { result: (unwrap-panic (as-max-len? (concat (get result data) (add-base (* (- elem u1) u10) UINT_LIST)) u100)) })
    data
  )
)

(define-private (range (upperLimit uint))
  (let
    ((blocks (+ (/ upperLimit u10) u1)))
    (get result (fold build-range (block-range blocks) {upperLimit: upperLimit, result: (filter not-zero (list u0))}))
  )
)

(define-private (build-range (elem uint) (data { upperLimit: uint, result: (list 100 uint)}))
  (if (<= elem (get upperLimit data))
    (merge data { result: (unwrap-panic (as-max-len? (append (get result data) elem) u100)) })
    data
  )
)

;; Internals

;; Gets the amount of tokens owned by the specified address.
(define-private (balance-of (account principal))
  (default-to u0 (map-get? tokens-count account)))

;; Gets the approved address for a token ID, or zero if no address set (approved method in ERC721)
(define-private (is-spender-approved (spender principal) (token-id uint))
  (let ((approved-spender
         (unwrap! (map-get? tokens-spender token-id)
                   false))) ;; return false if no specified spender
    (is-eq spender approved-spender)))

;; Tells whether an operator is approved by a given owner (isApprovedForAll method in ERC721)
(define-private (is-operator-approved (account principal) (operator principal))
  (default-to false
    (get is-approved
         (map-get? accounts-operator {operator: operator, account: account}))))

(define-private (is-owner (actor principal) (token-id uint))
  (is-eq actor
       ;; if no owner, return false
       (unwrap! (nft-get-owner? OpenArtSource token-id) false)))

;; Returns whether the given actor can transfer a given token ID.
;; To be optimized
(define-private (can-transfer (actor principal) (token-id uint))
  (or
   (is-owner actor token-id)
   (is-spender-approved actor token-id)
   (is-operator-approved (unwrap! (nft-get-owner? OpenArtSource token-id) false) actor)))

;; Internal - add token to owner list(for loop based lookup )
(define-private (add-token (owner principal) (token-id uint))
  (let
    (
      (newIdx (+ (default-to u0 (map-get? last-token-count owner)) u1))
    )
    (map-insert tokens-owned { owner: owner, idx: newIdx } token-id) 
    (map-insert tokens-slot { owner: owner, token-id: token-id } newIdx)
    (map-set last-token-count owner newIdx)
    (ok true)
  )
)

;; Internal - remove token from owner list(for loop based lookup )
(define-private (remove-token (owner principal) (token-id uint))
  (let
    (
      (idx (unwrap-panic (map-get? tokens-slot {owner: owner, token-id: token-id })))
      (lastidx (unwrap-panic (map-get? last-token-count owner)))
      (last-owned-token-id (unwrap-panic (map-get? tokens-owned { owner: owner, idx: lastidx })))
    )
    (map-set tokens-owned { owner: owner, idx: idx } last-owned-token-id)
    (map-set tokens-slot { owner: owner, token-id: last-owned-token-id } idx)
    (map-delete tokens-slot { owner: owner, token-id: token-id })
    (map-delete tokens-owned { owner: owner, idx: lastidx })
    (map-set last-token-count owner (- lastidx u1))
    (ok true)
  )
)

;; Internal - Register token
(define-private (mint (new-owner principal) (token-uri (string-ascii 256)))
  (let ((token-id (+ u1 (var-get last-token-id))))
    (let ((current-balance (balance-of new-owner)))
        (match (nft-mint? OpenArtSource token-id new-owner)
          success
            (begin
              (var-set last-token-id token-id)
              (map-set tokens-count
                new-owner
                (+ u1 current-balance))
              (map-set tokens-meta-uri
                token-id
                token-uri)
              (unwrap-panic (add-token new-owner token-id))
              (ok success))
          error (nft-mint-err error)))))

;; Internal - Tranfer token
(define-private (transfer-token (token-id uint) (owner principal) (new-owner principal))
  (let
    ((current-balance-owner (balance-of owner))
      (current-balance-new-owner (balance-of new-owner)))
    (begin
      (map-delete tokens-spender
        token-id)
      (map-set tokens-count
        owner
        (- current-balance-owner u1))
      (unwrap-panic (remove-token owner token-id))
      (map-set tokens-count
        new-owner
        (+ current-balance-new-owner u1))
      (unwrap-panic (add-token new-owner token-id))
      (match (nft-transfer? OpenArtSource token-id owner new-owner)
        success (ok success)
        error (nft-transfer-err error)))))

;; Read only

(define-read-only (is-admin)
  (or
    (default-to false (map-get? admins tx-sender))
    (default-to false (map-get? admins contract-caller))
  )
)

(define-read-only (get-token-owned-at (owner principal) (idx uint))
  (unwrap-panic (map-get? tokens-owned {owner: owner, idx: idx}))
)

(define-read-only (get-tokens-owned (owner principal))
  (let
    ((token-count (default-to u0 (map-get? last-token-count owner))))
    (if (> token-count u0)
      (get result (fold build-owner-tokens (range token-count) {owner: owner, result: (filter not-zero (list u0))}))
      (filter not-zero (list u0))
    )
  )
)

(define-private (build-owner-tokens (elem uint) (data { owner: principal, result: (list 100 uint)}))
  (let ((owner (get owner data)))
    (merge data { result: (unwrap-panic (as-max-len? (append (get result data) (get-token-owned-at owner elem)) u100)) })
  )
)

;; Public functions

;; Claim a new NFT
(define-public (claim (token-uri (string-ascii 256)))
  (mint tx-sender token-uri))

;; mint a token to specific owner
(define-public (mint-for (recipient principal) (token-uri (string-ascii 256)))
  (begin
    (asserts! (is-admin) not-admin-err)
    (mint recipient token-uri))
)

;; mint a token to specific owner
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) not-admin-err)
    (if (default-to false (map-get? admins new-admin))
      (ok true)
      (begin
        (map-set admins new-admin true)
        (var-set admin-count (+ (var-get admin-count) u1))
        (ok true)
      )
    )
  )
)

;; mint a token to specific owner
(define-public (remove-admin (old-admin principal) (allow-no-admin bool))
  (begin
    (asserts! (is-admin) not-admin-err)
    (if (default-to false (map-get? admins old-admin))
      false
      (begin
        (map-delete admins old-admin)
        (var-set admin-count (- (var-get admin-count) u1))
        true
      )
    )
    (asserts! (or allow-no-admin (> (var-get admin-count) u0)) not-admin-err)
    (ok true)
  )
)

;; Approves another address to transfer the given token ID (approve method in ERC721)
;; To be optimized
(define-public (set-spender-approval (spender principal) (token-id uint))
  (if (is-eq spender tx-sender)
      sender-equals-recipient-err
      (if (or (is-owner tx-sender token-id)
              (is-operator-approved
               (unwrap! (nft-get-owner? OpenArtSource token-id) nft-not-found-err)
               tx-sender))
          (begin
            (map-set tokens-spender
                        token-id
                        spender)
            (ok token-id))
          not-approved-spender-err)))

;; Sets or unsets the approval of a given operator (setApprovalForAll method in ERC721)
(define-public (set-operator-approval (operator principal) (is-approved bool))
  (if (is-eq operator tx-sender)
      sender-equals-recipient-err
      (begin
        (map-set accounts-operator
                    {operator: operator, account: tx-sender}
                    {is-approved: is-approved})
        (ok true))))

;; Transfers the ownership of a given token ID to another address.
(define-public (transfer-from (token-id uint) (owner principal) (recipient principal))
  (begin
    (asserts! (can-transfer tx-sender token-id) not-approved-spender-err)
    (asserts! (is-owner owner token-id) nft-not-owned-err)
    (asserts! (not (is-eq recipient owner)) sender-equals-recipient-err)
    (transfer-token token-id owner recipient)))

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (transfer-from token-id tx-sender recipient))

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? OpenArtSource token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (get-token-uri (token-id uint))
;;  (ok (some "ipfs://ipfs/QmPAg1mjxcEQPPtqsLoEcauVedaeMH81WXDPvPx3VC5zUz"))
  (ok (map-get? tokens-meta-uri token-id))
)

;; error handling
(define-constant nft-not-owned-err (err u401)) ;; unauthorized
(define-constant not-approved-spender-err (err u403)) ;; forbidden
(define-constant not-admin-err (err u403)) ;; forbidden
(define-constant no-admin-err (err u403)) ;; forbidden
(define-constant nft-not-found-err (err u404)) ;; not found
(define-constant sender-equals-recipient-err (err u405)) ;; method not allowed
(define-constant nft-exists-err (err u409)) ;; conflict

(define-map err-strings (response uint uint) (string-ascii 32))
(map-insert err-strings nft-not-owned-err "nft-not-owned")
(map-insert err-strings not-approved-spender-err "not-approaved-spender")
(map-insert err-strings not-admin-err "not-admin")
(map-insert err-strings no-admin-err "no-admin")
(map-insert err-strings nft-not-found-err "nft-not-found")
(map-insert err-strings nft-exists-err "nft-exists")

(define-private (nft-transfer-err (code uint))
  (if (is-eq u1 code)
    nft-not-owned-err
    (if (is-eq u2 code)
      sender-equals-recipient-err
      (if (is-eq u3 code)
        nft-not-found-err
        (err code)))))

(define-private (nft-mint-err (code uint))
  (if (is-eq u1 code)
    nft-exists-err
    (err code)))

(define-read-only (get-errstr (code uint))
  (unwrap! (map-get? err-strings (err code)) "unknown-error"))

;; Initialize the contract
(begin
  (map-set admins tx-sender true)
  (var-set admin-count u1)
;;  (try! (mint tx-sender "https://www.google.com"))
;;  (try! (claim "https://www.google.com"))
  )

