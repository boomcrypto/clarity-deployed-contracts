---
title: "Trait stacks-invaders-v1"
draft: true
---
```
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stacks-invaders-v1 uint)

;; Constants
(define-constant DEPLOYER tx-sender )
;;deployer: 'SPV8C2N59MA417HYQNG6372GCV0SEQE01EV4Z1RQ)

(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERR-NOT-ENOUGH-PASSES u101)
(define-constant ERR-PUBLIC-SALE-DISABLED u102)
(define-constant ERR-CONTRACT-INITIALIZED u103)
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-PAUSED u109)
(define-constant ERR-MINT-LIMIT u110)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-AIRDROP-CALLED u112)
(define-constant ERR-NO-MORE-MINTS u113)
(define-constant ERR-INVALID-PERCENTAGE u114)
(define-constant ERR-BLOCK-ALREADY-MINTED u115)


;; Internal variables
(define-data-var mint-limit uint u4995) ;; 5 batches of 999 
(define-data-var last-id uint u0)
(define-data-var total-price uint u1000000) ;;Either free or 1 STX
(define-data-var artist-address principal 'SP30MSY8NECE4SJJRQ5NVFZA58HF9Y93XX6E15WMG)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/temporaryURL/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u10) ;; Max 10 per wallet

(define-map mints-per-user principal uint)
(define-map free-mints-per-user
    {user-wallet:  principal}
    {available-mints: uint}
)

;; map to save the colour per number preferences.
(define-map colour-code
    {colour-id:  (string-ascii 40)}
    {colour-hexa: (string-ascii 7)}
)
;; map to save the base model per number preferences.
(define-map base-model
    {model-id: (string-ascii 40)}
    {model-hexa: (string-ascii 1024), model-hexa-2: (string-ascii 1024), model-hexa-3: (string-ascii 1024)}
)
(define-map base-model-special
    {model-id: (string-ascii 40)}
    {model-hexa: (string-ascii 1024)}
)
;; maps to save generated token vs block. (access via token or block)
(define-map generated-dmt
    {token-id: uint}
    {block-id: uint, miner: principal}
)
(define-map blocks-gen
    {block-id: uint}
    {token-id: uint, miner: principal}
)

;; set the base models for DMT
(define-public (model-set (model-id-input uint) (model-hexa-input (string-ascii 1024)) (model-hexa-input-2 (string-ascii 1024)) (model-hexa-input-3 (string-ascii 1024)) )
  (let
  (
      (model-ascii (int-to-ascii model-id-input))
  )
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (map-set base-model { model-id: model-ascii } { model-hexa: model-hexa-input , model-hexa-2: model-hexa-input-2 , model-hexa-3: model-hexa-input-3 })
    (ok "Post successful")
  )
  )
)

;; set whitelist
(define-public (whitelist-user (wallet-input principal) )
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (map-set free-mints-per-user { user-wallet: wallet-input } { available-mints: u1 })
    (ok "Post successful")
  )
)


;; set the base models for DMT
(define-public (model-special-set (model-id-input uint) (model-hexa-input (string-ascii 1024)) )
  (let
  (
      (model-ascii (int-to-ascii model-id-input))
  )
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (map-set base-model-special { model-id: model-ascii } { model-hexa: model-hexa-input })
    (ok "Post successful")
  )
  )
)

;; set the base colours for DMT
(define-public (colour-set (colour-id-input uint) (colour-hexa-input (string-ascii 7)) )
  (let
  (
      (colour-ascii (int-to-ascii colour-id-input))
  )
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (map-set colour-code { colour-id: colour-ascii } { colour-hexa: colour-hexa-input })
    (ok "Post successful")
  )
  )
)

(define-read-only (get-block-height-design (block-id uint)) 
  (let 
    (
      ;; split block numbers
      (block-ascii (int-to-ascii block-id))
      (block-digit-1 (default-to "0" (slice? block-ascii u5 u6)))
      (block-digit-2 (default-to "0" (slice? block-ascii u4 u5)))
      (block-digit-3 (default-to "0" (slice? block-ascii u2 u4)))
      ;; unpack into colours and patterns
      (colour-1 (default-to "#000000" (get colour-hexa (map-get? colour-code (tuple ( colour-id block-digit-1 )))))) 
      (colour-2 (default-to "#000000" (get colour-hexa (map-get? colour-code (tuple ( colour-id block-digit-2 )))))) 
      (base-mod (default-to "<div>" (get model-hexa (map-get? base-model  (tuple ( model-id block-digit-3 )))))) 
      (base-mod-2 (default-to "<div>" (get model-hexa-2 (map-get? base-model  (tuple ( model-id block-digit-3 )))))) 
      (base-mod-3 (default-to "<div>" (get model-hexa-3 (map-get? base-model  (tuple ( model-id block-digit-3 )))))) 
      (base-mod-special (default-to "none" (get model-hexa (map-get? base-model-special  (tuple ( model-id block-ascii )))))) 
      (colour-3     (if (is-eq colour-1 colour-2) "#9000CE" colour-2 ) )
      ;;(conc-return (concat block-digit-1 (concat colour-1 (concat block-digit-2 (concat colour-2 (concat block-digit-3 base-mod))))))
      (conc-return (if (is-eq base-mod-special "none" ) (concat base-mod (concat colour-1 (concat base-mod-2 (concat colour-3 base-mod-3)))) base-mod-special ))
    )
  (ok conc-return) 
  )
)

(define-read-only (get-current-block-height-design) 
  (let
  (
    (block-design (get-block-height-design block-height))
  )
  (ok block-design)
  )
)
(define-read-only (get-dmt-for-block-height (block-input uint)) 
  (let
  (
    (block-design (get-block-height-design block-input))
  )
  (ok block-design)
  )
)

;; TODO: Export full block vs Token list
;; TODO: execute contract calls to put inital data

(define-public (claim) 
  (mint (list true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))


(define-private (mint-many (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id));; mint command
      (price (var-get total-price) )
     ;; (price (* (var-get total-price) (- id-reached last-nft-id)))
      (current-balance (get-balance tx-sender))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
      (free-mints (default-to u0 (get available-mints (map-get? free-mints-per-user (tuple ( user-wallet tx-sender )))))) 
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ (len orders) user-mints))) (err ERR-NO-MORE-MINTS))
    ;; add function to check block height from map
    (asserts! (is-eq none (get token-id (map-get? blocks-gen  (tuple ( block-id block-height ))))) (err ERR-BLOCK-ALREADY-MINTED))
    (map-set mints-per-user tx-sender (+ (len orders) user-mints))
    (var-set last-id id-reached)
    (map-set blocks-gen { block-id: block-height } { token-id: id-reached , miner: tx-sender })
    (map-set generated-dmt { token-id: id-reached } { block-id: block-height , miner: tx-sender })
    ;; get whitelist
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER) (is-eq free-mints u1) (is-eq (var-get total-price) u0000000))
      (begin
        (map-set free-mints-per-user { user-wallet: tx-sender } { available-mints: u0 })
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin       
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (stx-transfer? price tx-sender (var-get artist-address)))
      )    
    )
    (ok id-reached)
    )
)

;; public function to return token SVG per token ID:
(define-read-only (get-token-svg (token-id uint))
  (let
  (
    (block-id (default-to u100 (get block-id (map-get? generated-dmt  (tuple ( token-id token-id ))))))
    (block-design (get-block-height-design block-id))
  )
  (ok block-design)
  )
)


(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? stacks-invaders-v1 next-id tx-sender) next-id)
      ;; function to save: tokenID + BlockHeight + 1stPrincipal
      (+ next-id u1)    
    )
    next-id))


(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (set-price (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price price))))

(define-public (toggle-pause)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market token-id)) (err ERR-LISTING))
    (nft-burn? stacks-invaders-v1 token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stacks-invaders-v1 token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (print { notification: "token-metadata-update", payload: { token-class: "nft", contract-id: (as-contract tx-sender) }})
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stacks-invaders-v1 token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))


(define-read-only (get-token-uri (token-id uint))
(let
  ( 
    (block-id (int-to-ascii (default-to u100 (get block-id (map-get? generated-dmt  (tuple ( token-id token-id ))))))) 
  )
;; get token block, replace on the ID below
  (ok (some (concat (concat (var-get ipfs-root) block-id) ".json")))
)
)

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/5")
(define-data-var license-name (string-ascii 40) "PERSONAL-NO-HATE")

(define-read-only (get-license-uri)
  (ok (var-get license-uri)))
  
(define-read-only (get-license-name)
  (ok (var-get license-name)))

;; updating license details  
(define-public (set-license-uri (uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-uri uri))))
    
(define-public (set-license-name (name (string-ascii 40)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-name name))))

;; Non-custodial marketplace extras
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? stacks-invaders-v1 id sender recipient)
    success
      (let
        ((sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
          (map-set token-count
            sender
            (- sender-balance u1))
          (map-set token-count
            recipient
            (+ recipient-balance u1))
          (ok success))
    error (err error)))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? stacks-invaders-v1 id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? stacks-invaders-v1 id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price royalty))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))
    
(define-data-var royalty-percent uint u5000) ;; 5%

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))

(define-private (pay-royalty (price uint) (royalty uint))
  (let (
    (royalty-amount (/ (* price royalty) u10000))
  )
  (if (and (> royalty-amount u0) (not (is-eq tx-sender (var-get artist-address))))
    (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))
```
