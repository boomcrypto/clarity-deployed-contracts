
;; domain-registering
;; <contract for registering domains>

;; constants/errors
(define-constant ERR_MINT_FAILED (err u200))
(define-constant ERR_AUTH_FAILED (err u201))

;; data maps and vars
(define-map domain-data 
  {name: (string-ascii 128)}
  {routed: bool, route: (optional (string-ascii 128))}
)

;; defining non-fungible token for Amortize
(define-non-fungible-token AMORTIZE-DOMAIN (string-ascii 128))

;; private functions

;; Registering the domain
(define-private (register-domain (owner principal) (name (string-ascii 128)))
  (unwrap! (nft-mint? AMORTIZE-DOMAIN name owner) false)
)

;; Check Owner
(define-private (is-owner (name (string-ascii 128)))
  (is-eq tx-sender
    (unwrap! (nft-get-owner? AMORTIZE-DOMAIN name) false)
  )
)

(define-private (register-many-domains (name (string-ascii 128)))
  (begin
    (asserts! (is-eq (nft-mint? AMORTIZE-DOMAIN name tx-sender) (ok true)) ERR_MINT_FAILED)
    (ok 
      (map-set domain-data
        {name: name}
        {routed: false, route: none}
      )
    )
  )
)

;; public functions

;; minting the domain as nft on blockchain
(define-public (mint-domain
  (owner principal)
  (name (string-ascii 128))
  )
  (begin
    (asserts! (register-domain owner name) ERR_MINT_FAILED)
    (ok 
      (map-set domain-data
        {name: name}
        {routed: false, route: none}
      )
    )
  )
)

(define-public (mint-many-domains
    (names (list 10 (string-ascii 128)))
  )
  (begin
    (map register-many-domains names)
    (ok true)
  )
)

(define-public (transfer-ownership (new-owner principal) (name (string-ascii 128)))
  (begin
    (asserts! (is-owner name) ERR_AUTH_FAILED)
    (map-set domain-data
      {name: name}
      {routed: false, route: none}
    )
    (nft-transfer? AMORTIZE-DOMAIN name tx-sender new-owner)
  )
)

(define-public (set-route (name (string-ascii 128)) (new-route (optional (string-ascii 128))))
  (begin
    (asserts! (is-owner name) ERR_AUTH_FAILED)
    (ok     
      (map-set domain-data
        {name: name}
        {routed: true, route: new-route}
      )
    )
  )
)

(define-public (disable-route (name (string-ascii 128)))
  (begin
    (asserts! (is-owner name) ERR_AUTH_FAILED)
    (ok     
      (map-set domain-data
        {name: name}
        {routed: false, route: none}
      )
    )
  )
)

;; burning the domain
(define-public (burn (name (string-ascii 128)))
  (begin
    (asserts! (is-owner name) ERR_AUTH_FAILED)
    (map-delete domain-data {name: name})
    (nft-burn? AMORTIZE-DOMAIN name tx-sender) 
  )
)

(define-read-only (is-available (name (string-ascii 128)))
  (is-none (map-get? domain-data {name: name}))
)

(define-read-only (is-routed (name (string-ascii 128)))
  (get routed (unwrap! (map-get? domain-data {name: name}) false))
)

(define-read-only (get-route (name (string-ascii 128)))
  (get route (unwrap! (map-get? domain-data {name: name}) none ))
)

(define-read-only (get-domain-data (name (string-ascii 128)))
  (map-get? domain-data {name: name})
)

