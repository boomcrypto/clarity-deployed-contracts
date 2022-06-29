;;     _____________  _______ _________  ___  ___  ____  ____
;;     / __/_  __/ _ |/ ___/ //_/ __/ _ \/ _ \/ _ |/ __ \/ __/
;;     _\ \  / / / __ / /__/ ,< / _// , _/ // / __ / /_/ /\ \  
;;    /___/ /_/ /_/ |_\___/_/|_/___/_/|_/____/_/ |_\____/___/  
;;                                                          
;;     _____  _____________  ______________  _  __           
;;    / __/ |/_/_  __/ __/ |/ / __/  _/ __ \/ |/ /           
;;   / _/_>  <  / / / _//    /\ \_/ // /_/ /    /            
;;  /___/_/|_| /_/ /___/_/|_/___/___/\____/_/|_/             

(use-trait nft-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.sip009-nft-trait.sip009-nft-trait)
(use-trait ft-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.sip010-ft-trait.sip010-ft-trait)

(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.extension-trait.extension-trait)

(define-constant ERR_UNAUTHORIZED (err u3200))
(define-constant ERR_ASSET_NOT_WHITELISTED (err u3201))
(define-constant ERR_FAILED_TO_TRANSFER_STX (err u3202))
(define-constant ERR_FAILED_TO_TRANSFER_FT (err u3203))
(define-constant ERR_FAILED_TO_TRANSFER_NFT (err u3204))

(define-constant CONTRACT_ADDRESS (as-contract tx-sender))

(define-map WhitelistedAssets principal bool)

;; --- Authorization check

(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .mega-dao) (contract-call? .mega-dao is-extension contract-caller)) ERR_UNAUTHORIZED))
)

;; --- Internal DAO functions

(define-public (set-whitelist (token principal) (enabled bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (map-set WhitelistedAssets token enabled))
  )
)

(define-private (set-whitelist-iter (item {token: principal, enabled: bool}))
  (begin
    (print {event: "whitelist", token: (get token item), enabled: (get enabled item)})
    (map-set WhitelistedAssets (get token item) (get enabled item))
  )
)

(define-public (set-whitelists (whitelist (list 100 {token: principal, enabled: bool})))
  (begin
    (try! (is-dao-or-extension))
    (ok (map set-whitelist-iter whitelist))
  )
)

;; --- Public functions

(define-public (deposit (amount uint))
  (begin
    (unwrap! (stx-transfer? amount tx-sender CONTRACT_ADDRESS) ERR_FAILED_TO_TRANSFER_STX)
    (print {event: "deposit", amount: amount, caller: tx-sender})
    (ok true)
  )
)

(define-public (deposit-ft (ft <ft-trait>) (amount uint))
  (begin
    (asserts! (is-whitelisted (contract-of ft)) ERR_ASSET_NOT_WHITELISTED)
    (unwrap! (contract-call? ft transfer amount tx-sender CONTRACT_ADDRESS (some 0x11)) ERR_FAILED_TO_TRANSFER_FT)
    (print {event: "deposit-ft", amount: amount, assetContract: (contract-of ft), caller: tx-sender})
    (ok true)
  )
)

(define-public (deposit-nft (nft <nft-trait>) (id uint))
  (begin
    (asserts! (is-whitelisted (contract-of nft)) ERR_ASSET_NOT_WHITELISTED)
    (unwrap! (contract-call? nft transfer id tx-sender CONTRACT_ADDRESS) ERR_FAILED_TO_TRANSFER_NFT)
    (print {event: "deposit-nft", assetContract: (contract-of nft), tokenId: id, caller: tx-sender})
    (ok true)
  )
)

(define-public (transfer (amount uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (unwrap! (as-contract (stx-transfer? amount CONTRACT_ADDRESS recipient)) ERR_FAILED_TO_TRANSFER_STX)
    (print {event: "transfer", amount: amount, caller: tx-sender, recipient: recipient})
    (ok true)
  )
)

(define-public (transfer-ft (ft <ft-trait>) (amount uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (is-whitelisted (contract-of ft)) ERR_ASSET_NOT_WHITELISTED)
    (unwrap! (as-contract (contract-call? ft transfer amount CONTRACT_ADDRESS recipient (some 0x11))) ERR_FAILED_TO_TRANSFER_FT)
    (print {event: "transfer-ft", assetContract: (contract-of ft), caller: tx-sender, recipient: recipient})
    (ok true)
  )
)

(define-public (transfer-nft (nft <nft-trait>) (id uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (is-whitelisted (contract-of nft)) ERR_ASSET_NOT_WHITELISTED)
    (unwrap! (as-contract (contract-call? nft transfer id CONTRACT_ADDRESS recipient)) ERR_FAILED_TO_TRANSFER_NFT)
    (print {event: "transfer-nft", assetContract: (contract-of nft), tokenId: id, caller: tx-sender, recipient: recipient})
    (ok true)
  )
)

;; --- Read only functions

(define-read-only (is-whitelisted (assetContract principal))
  (default-to false (get-whitelisted-asset assetContract))
)

(define-read-only (get-whitelisted-asset (assetContract principal))
  (map-get? WhitelistedAssets assetContract)
)

(define-read-only (get-balance)
  (stx-get-balance CONTRACT_ADDRESS)
)

(define-public (get-balance-of (assetContract <ft-trait>))
  (contract-call? assetContract get-balance CONTRACT_ADDRESS)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)