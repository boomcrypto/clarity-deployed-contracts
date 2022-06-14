(use-trait product-trait .nft-trait.nft-trait)

;; USER ROLES
(define-constant ROLE_PRODUCER "PRODUCER")
(define-constant ROLE_PUBLISHER "PUBLISHER")

;; REQUEST STATUS
(define-constant STATUS_PENDING "PENDING")
(define-constant STATUS_REJECTED "REJECTED")
(define-constant STATUS_EXPIRED "EXPIRED")
(define-constant STATUS_CANCELED "CANCELED")
(define-constant STATUS_ACCEPTED "ACCEPTED")

;; ERRORS
(define-constant ERR_PRODUCER_ONLY (err u100))

(define-constant ERR_PUBLISHER_ONLY (err u200))
(define-constant ERR_PUBLISHER_ID_NOT_FOUND (err u201))
(define-constant ERR_PUBLISHER_ALREADY_ASSIGNED (err u202))
(define-constant ERR_PUBLISHER_OWNED_PRODUCT_ONLY (err u203))

(define-constant ERR_PRODUCT_EXISTS (err u300))
(define-constant ERR_PRODUCT_NOT_FOUND (err u301))

(define-constant ERR_REQUEST_COST_LOW (err u400))
(define-constant ERR_REQUEST_COMMISSION_HIGH (err u401))
(define-constant ERR_REQUEST_NOT_FOUND (err u402))
(define-constant ERR_REQUEST_NOT_ENOUGH_SUPPLY (err u403))
(define-constant ERR_REQUEST_ESCROW_LOW (err u404))
(define-constant ERR_REQUEST_SENDER_ONLY (err u405))
(define-constant ERR_REQUEST_NOT_PENDING (err u406))
(define-constant ERR_REQUEST_EXPIRY_LOW (err u407))

(define-constant ERR_INVALID_URI (err u500))
(define-constant ERR_INVALID_SUPPLY_COUNT (err u501))
(define-constant ERR_INVALID_PRODUCT_PRICE (err u502))
(define-constant ERR_INVALID_NFT_CONTRACT (err u503))
(define-constant ERR_INVALID_PUBLISHER_ID (err u504))

(define-constant ERR_CONTRACT_OWNER_ONLY (err u600))

(define-data-var requestID uint u0)
(define-data-var chainID uint u0)

;; Trusted Contracts
(define-constant CONTRACT_OWNER tx-sender)

(define-map TrustedContracts principal bool)

(define-public (trust-contract (nft principal) (trusted bool))
  (begin 
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_CONTRACT_OWNER_ONLY)
    (ok (map-set TrustedContracts nft trusted))
   )
)
;; Purchase ------------------------------------------
(define-map HoldingID
   {
      nft: principal,
      id: uint
   }
  uint
)

(define-map Holdings
  {
    product: {
      nft: principal,
      id: uint
    },
    user: principal,
    number: uint
  }
  {
    delivered: bool
  }
)

(define-read-only
  (get-user-holding
    (product
      {
        nft: principal,
        id: uint
      }
    )
    (number uint)
    (user principal)
  )
  (map-get? Holdings {product: product, number: number, user: user})
)
;; ---------------------------------------------------

;; Users ---------------------------------------------
(define-map Users 
  {
    id: principal,
    role: (string-ascii 16)
  } 
  {
    uri: (string-ascii 256)
  }
)

(define-read-only 
  (get-user-uri 
    (user 
      {
        id: principal,
        role: (string-ascii 16)
      }
    )
  )
  (get uri (map-get? Users user))
)
;; ---------------------------------------------------

;; Requests ------------------------------------------
(define-map Requests 
  uint
  {
    sender: principal,
    publisherID: uint,
    product: {
      nft: principal,
      id: uint
    },
    price: uint,
    commission: uint,
    count: uint,
    escrow: uint,
    expiry: uint,
    status: (string-ascii 16)
  }
)

(define-read-only (get-request (id uint))
  (map-get? Requests id)
)

(define-public 
  (request-product
    (publisher principal)
    (publisherURI (string-ascii 256))
    (product
      {
        nft: principal,
        id: uint
      }
    )
    (from uint)
    (price uint)
    (commission uint)
    (expiry uint)
    (count uint)
    (escrow uint)
  )
  (let 
    (
      (newRequestID (+ (var-get requestID) u1))
      (productInfo (unwrap! (map-get? Products product) ERR_PRODUCT_NOT_FOUND))
      (productChainInfo (unwrap! (map-get? ProductChain product) ERR_PRODUCT_NOT_FOUND))
      (sourceInfo (unwrap! (map-get? PublisherChain {product: product, id: from}) ERR_PRODUCT_NOT_FOUND))
      (requestInfo (unwrap! (map-get? Requests (get requestID sourceInfo)) ERR_REQUEST_NOT_FOUND))
    )
    (asserts! (<= from (get nonce productChainInfo)) ERR_INVALID_PUBLISHER_ID)
    (asserts! (is-eq publisher tx-sender) ERR_PUBLISHER_ONLY)
    (asserts! (not (is-eq publisherURI "")) ERR_INVALID_URI)
    (asserts! (> price (get price requestInfo)) ERR_REQUEST_COST_LOW)
    (asserts! (< commission (get commission requestInfo)) ERR_REQUEST_COMMISSION_HIGH)
    (asserts! (not (is-eq count u0)) ERR_REQUEST_NOT_ENOUGH_SUPPLY)
    (asserts! (>= escrow u0) ERR_REQUEST_ESCROW_LOW)
    (asserts! (> expiry u0) ERR_REQUEST_EXPIRY_LOW)
    (try! (stx-transfer? escrow publisher (as-contract tx-sender)))
    (map-insert Users
      {
        id: publisher,
        role: ROLE_PUBLISHER
      }
      {
        uri: publisherURI
      }
    )
    (map-insert Requests newRequestID 
      {
        sender: publisher,
        publisherID: from,
        product: product,
        price: price,
        commission: commission,
        count: count,
        escrow: escrow,
        expiry: expiry,
        status: STATUS_PENDING
      }
    )
    (var-set requestID newRequestID)
    (ok newRequestID)
  )
)

(define-public 
  (cancel-request
    (publisher principal)
    (id uint)
  )
  (let 
    (
      (request (unwrap! (map-get? Requests id) ERR_REQUEST_NOT_FOUND))
      (sender (get sender request))
      (status (get status request))
      (escrow (get escrow request))
    )
    (asserts! (is-eq publisher tx-sender) ERR_PUBLISHER_ONLY)
    (asserts! (is-eq publisher sender) ERR_REQUEST_SENDER_ONLY)
    (asserts! (is-eq status STATUS_PENDING) ERR_REQUEST_NOT_PENDING)
    (try! (as-contract (stx-transfer? escrow tx-sender publisher)))
    (ok (map-set Requests id (merge request {status: STATUS_CANCELED})))
  )
)

(define-public 
  (accept-request
    (publisher uint)
    (id uint)
  )
  (let 
    (
      (request (unwrap! (map-get? Requests id) ERR_REQUEST_NOT_FOUND))
      (product (get product request))
      (count (get count request))
      (productChain (unwrap! (map-get? ProductChain product) ERR_PRODUCT_NOT_FOUND))
      (publisherInfo (unwrap! (map-get? PublisherChain {product: product, id: publisher}) ERR_PRODUCT_NOT_FOUND))
      (remaining (get remaining publisherInfo))
      (newChainID (+ (get nonce productChain) u1))
    )
    (asserts! (is-eq (get userID publisherInfo) tx-sender) ERR_PUBLISHER_ONLY)
    (asserts! (<= count remaining) ERR_REQUEST_NOT_ENOUGH_SUPPLY)
    (asserts! (is-none (get next publisherInfo)) ERR_PUBLISHER_ALREADY_ASSIGNED)
    (map-set Requests id (merge request {expiry: (+ (get expiry request) block-height)}))
    (map-set ProductChain product (merge productChain {nonce: newChainID}))
    (map-set PublisherChain 
      {
        product: product,
        id: publisher
      } 
      (merge publisherInfo {remaining: (- remaining count)})
    )
    (map-insert PublisherChain 
      {
        product: product,
        id: newChainID
      } 
      {
        userID: (get sender request),
        previous: (some publisher),
        next: none,
        depth: (+ (get depth publisherInfo) u1),
        count: (get count request),
        remaining: (get count request),
        requestID: id
      }
    )
    (ok newChainID)
  )
)
;; ---------------------------------------------------

;; Products ------------------------------------------
(define-map Products 
  {
    nft: principal,
    id: uint
  }
  {
    producer: principal,
  }
)

(define-map ProductChain 
  {
    nft: principal,
    id: uint
  }
  {
    chainID: uint,
    nonce: uint
  }
)

(define-map PublisherChain 
  {
    product: {
      nft: principal,
      id: uint
    },
    id: uint,
  }
  {
    userID: principal,
    previous: (optional uint),
    next: (optional uint),
    depth: uint,
    count: uint,
    remaining: uint,
    requestID: uint
  }
)

(define-read-only 
  (get-product
    (product
      {
        nft: principal,
        id: uint
      }
    )
  )
  (map-get? Products product)
)

(define-read-only 
  (get-product-chain
    (product
      {
        nft: principal,
        id: uint
      }
    )
  )
  (map-get? ProductChain product)
)

(define-read-only 
  (get-publisher-chain 
    (product 
      {
        nft: principal,
        id: uint
      }
    )
    (id uint)
  )
  (map-get? PublisherChain {product: product, id: id})
)

(define-public 
  (add-product
    (producer principal)
    (producerURI (string-ascii 256))
    (nft <product-trait>)
    (nftID uint)
    (productURI (string-ascii 256))
    (price uint)
    (supply uint)
  )
  (let 
    (
      (nftContract (contract-of nft))
      (product {nft: nftContract, id: nftID})
      (newRequestID (+ (var-get requestID) u1))
      (newChainID (+ (var-get chainID) u1))
    )
    (asserts! (is-eq tx-sender producer) ERR_PRODUCER_ONLY)
    (asserts! (default-to false (map-get? TrustedContracts nftContract)) ERR_INVALID_NFT_CONTRACT)
    (asserts! (is-none (map-get? Products product)) ERR_PRODUCT_EXISTS)
    (asserts! (> price u0) ERR_INVALID_PRODUCT_PRICE)
    (asserts! (> supply u0) ERR_INVALID_SUPPLY_COUNT)
    (asserts! (not (is-eq producerURI "")) ERR_INVALID_URI)
    (asserts! (not (is-eq productURI "")) ERR_INVALID_URI)
    (try! (contract-call? nft transfer nftID producer (as-contract tx-sender)))
    (map-insert Products 
      product 
      {
        producer: producer,
      }
    )
    (map-insert Requests newRequestID 
      {
        sender: producer,
        publisherID: newChainID,
        product: {nft: nftContract, id: nftID},
        count: supply,
        escrow: u0,
        commission: u100,
        price: price,
        expiry: u0,
        status: STATUS_ACCEPTED
      }
    )
    (map-insert ProductChain 
      product
      {
        chainID: newChainID,
        nonce: u1,
      }
    )
    (map-insert Users
      {id: producer, role: ROLE_PRODUCER}
      {uri: producerURI}
    )
    (map-insert PublisherChain 
      {
        product: product,
        id: u1
      }
      {
        userID: producer,
        previous: none,
        next: none,
        depth: u1,
        count: supply,
        remaining: supply,
        requestID: newRequestID
      }
    )
    (var-set requestID newRequestID)
    (var-set chainID newChainID)
    (ok 
      {
        productID: nftID,
        chainID: newChainID
      }
    )
  ) 
)

;; #[allow(unchecked_data)]
(define-public 
  (purchase-product
    (user principal)
    (product 
     {
       nft: principal,
       id: uint
     }
    )
    (publisher uint)
  )
  (let 
    (
      (publisherInfo (unwrap! (map-get? PublisherChain {product: product, id: publisher}) ERR_PRODUCT_NOT_FOUND))
      (request (unwrap! (map-get? Requests (get requestID publisherInfo)) ERR_REQUEST_NOT_FOUND))
      (requestProduct (get product request))
      (holdingID (default-to u0 (map-get? HoldingID product)))
      (newHoldingID (+ holdingID u1))
    )
    (asserts! (is-eq product requestProduct) ERR_PUBLISHER_OWNED_PRODUCT_ONLY)
    (asserts! (>= (get remaining publisherInfo) u1) ERR_REQUEST_NOT_ENOUGH_SUPPLY)
    (try! (stx-transfer? (get price request) user (get userID publisherInfo)))
    (map-set PublisherChain {product: product, id: publisher} (merge publisherInfo {remaining: (- (get remaining publisherInfo) u1)}))
    (map-set HoldingID product newHoldingID)
    (map-insert Holdings {product: product, number: newHoldingID, user: user} {delivered: false})
    (ok newHoldingID)
  )
)
;; ---------------------------------------------------

;; Range ---------------------------------------------
(define-private (range10 (l uint) (h uint))
  (let ((diff (- h l)))
    (asserts! (> diff u0) (list l))
    (asserts! (> diff u1) (list l h))
    (asserts! (> diff u2) (list l (+ l u1) h))
    (asserts! (> diff u3) (list l (+ l u1) (+ l u2) h))
    (asserts! (> diff u4) (list l (+ l u1) (+ l u2) (+ l u3) h))
    (asserts! (> diff u5) (list l (+ l u1) (+ l u2) (+ l u3) (+ l u4) h))
    (asserts! (> diff u6) (list l (+ l u1) (+ l u2) (+ l u3) (+ l u4) (+ l u5) h))
    (asserts! (> diff u7) (list l (+ l u1) (+ l u2) (+ l u3) (+ l u4) (+ l u5) (+ l u6) h))
    (asserts! (> diff u8) (list l (+ l u1) (+ l u2) (+ l u3) (+ l u4) (+ l u5) (+ l u6) (+ l u7) h))
    (list l (+ l u1) (+ l u2) (+ l u3) (+ l u4) (+ l u5) (+ l u6) (+ l u7) (+ l u8) (+ l u9))
  )
)
;; ---------------------------------------------------