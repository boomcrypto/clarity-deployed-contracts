;; use the SIP009 interface (testnet)
;; trait deployed by deployer address from ./settings/Devnet.toml
;; (impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait.nft-trait)

;; define a new NFT. Make sure to replace stx-claim-support-2
(define-non-fungible-token claim-5 uint)

;; Store the last issues token ID
(define-data-var compaign-id (list 1000 (string-ascii 256)) (list))
(define-data-var platform-fee-percent uint u10)
(define-map user-compaigns { account : principal}  {compaigns : (list 1000 (string-ascii 256)) })
(define-map compaigns-claimed { compaign-id : (string-ascii 256)}  {accounts : (list 1000 principal) })
(define-map compaigns-claimed-count { compaign-id : (string-ascii 256)}  {count : int})
(define-map compaigns-meta  { id : (string-ascii 256)} { title: (string-ascii 256), description: (string-ascii 256), copies: int,amount: uint , type: (string-ascii 256)} )
(define-map mint-active { account: principal } { status: bool } )
(define-map user-delete-item { account : principal}  {c-id :  (string-ascii 256) })

(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-ALREADY_CLAIMED (err u402))
(define-constant MAX_CLAIMED (err u403))
(define-constant CAMPAIGN-EXISTS (err u404))
(define-constant MAX_LIMIT_EXCEEDED (err u405))
(define-constant CAMPAIGN-DOES-NOT-EXISTS (err u406))
(define-constant CONTRACT-OWNER tx-sender)

;; Claim a new NFT
(define-public (set-minting-state-per-account (account principal) (bool bool))
 (begin
   (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
   (map-insert mint-active { account: account} { status: bool } )
   (ok true)))

;; Create a support
(define-public (create-link (title (string-ascii 256)) (description (string-ascii 256)) (copies int) (amount uint) (type (string-ascii 256)) (c-id (string-ascii 256)))
 (begin
   (let 
    (
      (current-ids (var-get compaign-id))
      (current-user-ids (default-to (list) (get compaigns (map-get? user-compaigns  {account : tx-sender }))))
    )
   (asserts! (is-none (index-of  current-ids c-id)) CAMPAIGN-EXISTS)
   (var-set  compaign-id (unwrap-panic (as-max-len? (append current-ids c-id) u1000 )))
   (map-set user-compaigns { account: tx-sender } {compaigns : (unwrap-panic (as-max-len? (append current-user-ids c-id) u1000 )) })
   (map-insert compaigns-meta { id: c-id} { title: title, description: description, type: type, copies: copies , amount: amount })
   (try! (stx-transfer?  amount tx-sender (as-contract tx-sender)))
   )
   (ok true)
 )
)


;; Claim link
(define-public (claim-link (c-id (string-ascii 256)))
 (begin
 (let 
        (
           (current-id-count (default-to 0 (get count (map-get? compaigns-claimed-count   { compaign-id : c-id }))))
           (current-meta (map-get? compaigns-meta   { id : c-id }))
           (max_count (default-to 1 (get copies current-meta)))
           (amount (unwrap-panic (get amount current-meta)))
          ;;  (account tx-sender)
           (user-address tx-sender)
           (contract-address (as-contract tx-sender))
           (current-id (var-get compaign-id))
           (current-user-ids (default-to (list c-id) (get compaigns (map-get? user-compaigns  {account : tx-sender }))))
           (compaigns-claimed-accounts (default-to (list) (get accounts (map-get? compaigns-claimed  {compaign-id: c-id }))))

        )
        (asserts! (< current-id-count max_count) MAX_CLAIMED)
        (asserts! (not (is-some (index-of compaigns-claimed-accounts tx-sender))) ERR-ALREADY_CLAIMED)
        (map-set compaigns-claimed-count { compaign-id: c-id }  { count: (+ 1 current-id-count)  })
        (map-set compaigns-claimed { compaign-id: c-id } {accounts : (unwrap-panic (as-max-len? (append compaigns-claimed-accounts tx-sender) u10 )) })
        (try! (as-contract (stx-transfer? (/ amount (to-uint max_count)) contract-address user-address)))
        (ok true)
 )
  )
)
;; Filter
(define-private (filtered-list (c-id (string-ascii 256)))
(let 
    (
      (delete-item (unwrap-panic (get c-id (map-get? user-delete-item  {account : tx-sender }))))
    )
   (not (is-eq c-id delete-item))
)
)

;; delete a campaign
(define-public ( delete-campaign (c-id (string-ascii 256)))
 (begin
   (let 
    (
      (current-ids (var-get compaign-id))
      (current-user-ids (default-to (list) (get compaigns (map-get? user-compaigns  {account : tx-sender }))))
      (current-meta (map-get? compaigns-meta   { id : c-id }))
      (max_count (default-to 1 (get copies current-meta)))
      (amount (unwrap-panic (get amount current-meta)))
      (current-id-count (default-to 0 (get count (map-get? compaigns-claimed-count   { compaign-id : c-id }))))
      (user-address tx-sender)
      (contract-address (as-contract tx-sender))
    )
   (asserts! (is-some (index-of  current-user-ids c-id)) CAMPAIGN-DOES-NOT-EXISTS)
   (map-set user-delete-item {account : tx-sender} {c-id : c-id})
   (try! (as-contract (stx-transfer?  (/ (* (to-uint (/ (* (- max_count current-id-count) 1000000) max_count)) amount) u1000000) contract-address user-address )))
   (map-set user-compaigns { account: tx-sender } { compaigns : (filter filtered-list current-user-ids) })
   (map-set user-delete-item {account : tx-sender} {c-id : ""})
   )

   (ok true)
 )
)

;; (define-read-only (get-last-compaign-id)
;;   (ok (var-get compaign-id)))

(define-read-only (get-user-compaigns (account principal))
  (ok (map-get? user-compaigns {account : account})))

  (define-read-only (get-compaigns-user (c-id (string-ascii 256)))
  (ok (map-get? compaigns-claimed {compaign-id : c-id})))
