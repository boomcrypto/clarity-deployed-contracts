(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait) 

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait) 

;; sip-010 implementation

(define-private (transfer-ft (token-contract <sip-010-trait>) (amount uint) (sender principal) (recipient principal))
  (contract-call? token-contract transfer amount sender recipient none)
)

;; sip-009 implementation

(define-private (transfer-nft (token-contract <nft-trait>) (token-id uint) (sender principal) (recipient principal))
  (contract-call? token-contract transfer token-id sender recipient)
)

(define-private (get-owner-id (token-contract <nft-trait>) (id uint))
  (contract-call? token-contract get-owner id)
)

;; custom BNS-V2 integration
;; 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2

;; get the name expiry

(define-private (get-name-expiry (id uint)) 
  (let 
    (
      (buffer (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-bns-from-id id))
      (name (unwrap-panic (get name buffer)))
      (namespace (unwrap-panic (get namespace buffer)))
      (info (unwrap-panic (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-bns-info name namespace)))
    )
    (get renewal-height info)
  )
)

;; return the owner address

(define-private (get-owner-address (id uint))
  (begin
    (match (get-owner-id 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id) 
      address (if (is-some address)
                  (unwrap-panic address)
                  'SP000000000000000000002Q6VF78
      )  
      err 'SP000000000000000000002Q6VF78)
  ) 
)
;; errors

(define-constant NOT_THE_OWNER (err u1000))
(define-constant NOT_IN_THE_VAULT (err u1001))
(define-constant EXPIRED (err u1002))
(define-constant NOT_ACTIVE (err u1003))
(define-constant NOT_ENOUGH (err u1004))
(define-constant TOO_SHORT (err u1005))
(define-constant NOT_IN_THE_PAST (err u1006))
(define-constant STILL_ACTIVE (err u1007))
(define-constant TOO_LOW (err u1008))
(define-constant ONLY_STX (err u1009))
(define-constant NOT_WHITELISTED (err u1010))
(define-constant NOT_THE_TOKEN (err u1011)) 
(define-constant SELLER_NOT_ALLOWED (err u1012))
(define-constant TOO_EARLY (err u1013))
(define-constant ALREADY_STARTED (err u1014))
(define-constant NAME_EXPIRES (err u1015))
(define-constant NOT_IN_THE_RANGE (err u1016))
(define-constant ONLY_USER (err u1017))
(define-constant ONLY_TOKEN (err u1018))
(define-constant PAUSED (err u1019))
(define-constant NOT_PENDING (err u1020)) 

;; admin variables and functions

(define-map WHITELISTED principal uint) ;; whitelisted tokens only allowed
(define-data-var OWNER principal tx-sender)
(define-data-var VAULT principal 'SM18RN48GX7E3ED23M03BY4QD8EA2DG2R4VX4CDYJ) ;; BNS One treasury
(define-data-var PAUSE bool false)
(define-data-var COMMISSION uint u500) ;; BNS One commission
(define-data-var STEP uint u1000000) ;; Bid basic step
(define-data-var STEP_ONE uint u5 )
(define-data-var STEP_TWO uint u10 )
(define-data-var STEP_THREE uint u50 )

;; main mapping for Auctions

(define-map AUCTION uint {
    auction: uint,
    seller: principal,
    taker: principal,
    token: (optional principal),
    startBid: uint,
    reservePrice: uint,
    buyNowPrice: uint,
    currentBid: uint,
    totalBids: uint,
    expiration: uint,
    newExpiration: uint,
    start: uint,
    status: (string-ascii 12),
})

(define-data-var CURRENT uint u14) ;; continues the V1 auctions index

;; pause the contract

(define-public (pause) 
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER)
    (var-set PAUSE (not (var-get PAUSE)))
    (ok true)
  )
)

;; change the contract owner

(define-public (transfer-ownership (address principal)) 
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER)
    (var-set OWNER address)
    (ok true)
  )
)

;; change the commission treasury

(define-public (change-vault (address principal)) 
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER)
    (var-set VAULT address)
    (ok true)
  )
)

;; add and remove whitelisted token with step

(define-public (add-token (ft <sip-010-trait>) (step uint)) 
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER)
    (asserts! (> step u0) TOO_LOW)
    (map-set WHITELISTED (contract-of ft) step)
    (ok true)
  )
)

(define-public (remove-token (ft <sip-010-trait>)) 
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER)
    (map-set WHITELISTED (contract-of ft) u0)
    (ok true)
  )
)

;; configure commission

(define-public (change-commission (commission uint)) 
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER)
    (asserts! (and (>= commission u100) (<= commission u1000)) NOT_IN_THE_RANGE) ;; min 1% max 10%
    (var-set COMMISSION commission)
    (ok true)
  )
)

;; configure bid steps

(define-public (change-step (step uint)) 
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER)
    (asserts! (>= step u100000) TOO_LOW)
    (var-set STEP step)
    (ok true)
  )
)

(define-public (change-steps-multipier (one uint) (two uint) (three uint)) 
  (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) NOT_THE_OWNER)
    (asserts! (> one u1) TOO_LOW)
    (asserts! (and (> three two) (> two one)) TOO_LOW)
    (var-set STEP_ONE one)
    (var-set STEP_TWO two)
    (var-set STEP_THREE three)
    (print {STEP_ONE: one, STEP_TWO: two, STEP_THREE: three})
    (ok true)
  )
)

;; seller can create an auction with stx or whitelisted tokens
;; contract checks if caller is the owner of the name and if name 
;; will not expire before the auction ends.

(define-public (create-auction (id uint) (startBid uint) (reservePrice uint) (buyNowPrice uint) (start uint) (expiration uint)  )
   (let (
    (block burn-block-height)
    (next (+ u1 (var-get CURRENT)))
   )
   
   (asserts! (not (var-get PAUSE)) PAUSED)
   (asserts! (is-eq contract-caller (get-owner-address id)) NOT_THE_OWNER)
   (asserts! (not (is-expired-at (get-name-expiry id) expiration)) NAME_EXPIRES)
   (asserts! (>= start block ) NOT_IN_THE_PAST)
   (asserts! (and (> expiration start ) (>= (- expiration start) u144)) TOO_SHORT)
   (asserts! (>= startBid (var-get STEP)) NOT_ENOUGH)
   (asserts! (verify-price startBid reservePrice buyNowPrice) TOO_LOW)
   (var-set CURRENT next)
    (map-set AUCTION id {
        auction: next,
        seller: contract-caller,
        taker: contract-caller,
        token: none,
        startBid: startBid,
        reservePrice: reservePrice,
        buyNowPrice: buyNowPrice,
        currentBid: u0,
        totalBids: u0,
        expiration: expiration,
        newExpiration: expiration,
        start: start,
        status: "Pending"
    })
    (print {
        auction: next,
        id: id,
        block: block,
        seller: contract-caller,
        taker: contract-caller,
        token: none,
        startBid: startBid,
        reservePrice: reservePrice,
        buyNowPrice: buyNowPrice,
        currentBid: u0,
        totalBids: u0,
        expiration: expiration,
        start: start,
        status: "Pending"
    })
    (ok id)
   )
)

(define-public (create-auction-ft (id uint) (startBid uint) (reservePrice uint) (buyNowPrice uint) (start uint) (expiration uint) (token <sip-010-trait>) )
   (let (
    (block burn-block-height)
    (next (+ u1 (var-get CURRENT)))
    (step (get-token (contract-of token)))
   )
   
   (asserts! (not (var-get PAUSE)) PAUSED)
   (asserts! (is-eq contract-caller (get-owner-address id)) NOT_THE_OWNER)
   (asserts! (not (is-expired-at (get-name-expiry id) expiration)) NAME_EXPIRES)
   (asserts! (verify-price startBid reservePrice buyNowPrice) TOO_LOW)
   (asserts! (> step u0) NOT_WHITELISTED)
   (asserts! (>= start block ) NOT_IN_THE_PAST)
   (asserts! (and (> expiration start ) (>= (- expiration start) u144)) TOO_SHORT)
   (var-set CURRENT next)
    (map-set AUCTION id {
        auction: next,
        seller: contract-caller,
        taker: contract-caller,
        token: (some (contract-of token)),
        startBid: startBid,
        reservePrice: reservePrice,
        buyNowPrice: buyNowPrice,
        currentBid: u0,
        totalBids: u0,
        expiration: expiration,
        newExpiration: expiration,
        start: start,
        status: "Pending"
    })
    (print {
        auction: next,
        id: id,
        block: block,
        seller: contract-caller,
        taker: contract-caller,
        token: (contract-of token),
        startBid: startBid,
        reservePrice: reservePrice,
        buyNowPrice: buyNowPrice,
        currentBid: u0,
        totalBids: u0,
        expiration: expiration,
        start: start,
        status: "Pending"
    })
    (ok id)
   )
)

;; seller need first to transfer the name to the contract then validate the auction before it can start

(define-public (validate-auction (id uint) ) 
   (let (
    (vault (as-contract tx-sender) )
    (auction (get-auction id))
    (seller (get seller auction) )
    (status (get status auction))
    (start (get start auction) )
    (expiration (get expiration auction))
    (block burn-block-height)
    (current (get auction auction))
   )
   (asserts! (is-eq contract-caller seller) NOT_THE_OWNER)
   (asserts! (is-eq status "Pending") NOT_ACTIVE)
   (asserts! (<= block start) EXPIRED)
   (asserts! (is-eq vault (get-owner-address id)) NOT_IN_THE_VAULT) ;; Names must be in the Vault before starting the auction
    (map-set AUCTION id {
        auction: current,
        seller: (get seller auction),
        taker: (get taker auction),
        token: (get token auction),
        startBid: (get startBid auction),
        reservePrice: (get reservePrice auction),
        buyNowPrice: (get buyNowPrice auction),
        currentBid: (get currentBid auction),
        totalBids: (get totalBids auction),
        expiration: expiration,
        newExpiration: expiration,
        start: start,
        status: "Active"
    })
    (print {
        auction: current,
        id: id,
        block: block,
        status: "Active"
    })
    (ok id)
   )
)

;; Seller can delete auctions only if no bids was confirmed

(define-public (delete-auction (id uint))
   (let (
    (vault (as-contract tx-sender) )
    (auction (get-auction id))
    (seller (get seller auction) )
    (taker (get taker auction) )
    (token (get token auction))
    (status (get status auction))
    (currentBid (get currentBid auction) )
    (current (get auction auction))
   )
   (asserts! (is-eq contract-caller seller) NOT_THE_OWNER)
   (asserts! (not (is-eq status "None")) NOT_ACTIVE)
   (asserts! (is-none token) ONLY_STX)
   (asserts! (is-eq currentBid u0) ALREADY_STARTED)
   (asserts! (is-eq vault (get-owner-address id)) NOT_IN_THE_VAULT) ;; Names must be in the Vault before starting the auction
   (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender seller)))
  
    (map-delete AUCTION id )
    (print {
        auction: current,
        id: id,
        status: "Deleted"
    })
    (ok id)
   )
)

(define-public (delete-auction-ft (id uint) (ft <sip-010-trait>))
   (let (
    (vault (as-contract tx-sender) )
    (auction (get-auction id))
    (seller (get seller auction) )
    (taker (get taker auction) )
    (token (get token auction))
    (status (get status auction))
    (currentBid (get currentBid auction) )
    (current (get auction auction))
   )
   (asserts! (is-eq contract-caller seller) NOT_THE_OWNER)
   (asserts! (not (is-eq status "None")) NOT_ACTIVE)
   (asserts! (is-eq currentBid u0) ALREADY_STARTED)
   (asserts! (is-eq vault (get-owner-address id)) NOT_IN_THE_VAULT) ;; Names must be in the Vault before starting the auction
   (asserts! (not (is-none token)) ONLY_TOKEN)
   (asserts! (is-eq (unwrap-panic token) (contract-of ft)) NOT_THE_TOKEN)
   (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender seller)))
    (map-delete AUCTION id )
    (print {
        auction: current,
        id: id,
        status: "Deleted"
    })
    (ok id)
   )
)

;; Sellers can delete pending auctions // fix to prevent names locked in the contract

(define-public (delete-pending-auction (id uint))
   (let (
    (vault (as-contract tx-sender) )
    (auction (get-auction id))
    (seller (get seller auction) )
    (status (get status auction))
    (currentBid (get currentBid auction) )
    (current (get auction auction))
   )
   (asserts! (is-eq contract-caller seller) NOT_THE_OWNER)
   (asserts! (is-eq status "Pending") NOT_PENDING)
   (asserts! (is-eq currentBid u0) ALREADY_STARTED)

   (if (is-eq vault (get-owner-address id))
      (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender seller)))
      true
   )
     
    (map-delete AUCTION id )
    (print {
        auction: current,
        id: id,
        status: "Deleted"
    })
    (ok id)
   )
)

;; users will transfer the amount to the contract and will be sent back if someone else outbids the amount

(define-public (bid (id uint) (amount uint))
  (let (
    (vault (as-contract tx-sender))
    (block burn-block-height)
    (auction (get-auction id))
    (status (get status auction))
    (expiration (get expiration auction))
    (newExpiration  (get newExpiration auction))
    (currentExpiration (if (> newExpiration expiration) newExpiration expiration))
    (nextExpiry (get-new-expiration expiration newExpiration block))
    (currentBid (get currentBid auction))
    (taker (get taker auction))
    (seller (get seller auction))
    (token (get token auction))
    (startBid (get startBid auction))
    (start (get start auction))
    (current (get auction auction))
    (minBid (calculate-min-bid currentBid))
  )
  (asserts! (is-eq status "Active") NOT_ACTIVE)
  (asserts! (> id u0) TOO_LOW)
  (asserts! (>= block start) TOO_EARLY)
  (asserts! (<= block currentExpiration) EXPIRED)
  
  (asserts! (not (is-eq contract-caller seller)) SELLER_NOT_ALLOWED)
  (asserts! (is-none token) ONLY_STX)
  (asserts! (>= amount minBid) TOO_LOW)
  (asserts! (and (> amount currentBid) (>= amount startBid) ) NOT_ENOUGH)
  (if (> currentBid u0)
      (try! (as-contract (stx-transfer? currentBid tx-sender taker)))
      true
  )
  (try! (stx-transfer? amount contract-caller vault))
  
  (map-set AUCTION id {
        auction: current,
        seller: seller,
        taker: contract-caller,
        token: token,
        startBid: startBid,
        reservePrice: (get reservePrice auction),
        buyNowPrice: (get buyNowPrice auction),
        currentBid: amount,
        totalBids: (+ u1 (get totalBids auction)),
        expiration: expiration,
        newExpiration: nextExpiry,
        start: start,
        status: "Active"
    })
  (print {
    auction: current,
    id: id,
    block: block,
    taker: contract-caller,
    amount: amount,
    newExpiration: nextExpiry,
  })
  (ok id)
  )
)

(define-public (bid-ft (id uint) (amount uint) (ft <sip-010-trait>))
  (let (
    (vault (as-contract tx-sender))
    (block burn-block-height)
    (auction (get-auction id))
    (status (get status auction))
    (expiration (get expiration auction))
    (newExpiration  (get newExpiration auction))
    (currentExpiration (if (> newExpiration expiration) newExpiration expiration))
    (nextExpiry (get-new-expiration expiration newExpiration block))
    (currentBid (get currentBid auction))
    (taker (get taker auction))
    (seller (get seller auction))
    (token (get token auction))
    (startBid (get startBid auction))
    (start (get start auction))
    (current (get auction auction))
    (step (get-token (contract-of ft)))
    (minBid (calculate-min-bid-ft currentBid step))
  )
  (asserts! (is-eq status "Active") NOT_ACTIVE)
  (asserts! (> id u0) TOO_LOW)
  (asserts! (>= block start) TOO_EARLY)
  (asserts! (<= block currentExpiration) EXPIRED)
  
  (asserts! (not (is-eq contract-caller seller)) SELLER_NOT_ALLOWED)
  (asserts! (not (is-none token)) ONLY_TOKEN)
  (asserts! (is-eq (unwrap-panic token) (contract-of ft)) NOT_THE_TOKEN)
  (asserts! (>= amount minBid) TOO_LOW)
  (asserts! (and (> amount currentBid) (>= amount startBid) ) NOT_ENOUGH)
  (if (> currentBid u0)
      (try! (as-contract (transfer-ft ft currentBid tx-sender taker)))
      true
  )
  (try! (transfer-ft ft amount contract-caller vault))
  (map-set AUCTION id {
        auction: current,
        seller: seller,
        taker: contract-caller,
        token: token,
        startBid: startBid,
        reservePrice: (get reservePrice auction),
        buyNowPrice: (get buyNowPrice auction),
        currentBid: amount,
        totalBids: (+ u1 (get totalBids auction)),
        expiration: expiration,
        newExpiration: nextExpiry,
        start: start,
        status: "Active"
    })
  (print {
    auction: current,
    id: id,
    block: block,
    taker: contract-caller,
    amount: amount,
    expiration: nextExpiry,
  })
  (ok id)
  )
)

;; seller can set a Buy Now price for the auction to be ended by a buyer

(define-public (buy-now (id uint))
   (let (
    (vault (as-contract tx-sender))
    (buyer contract-caller)
    (auction (get-auction id))
    (seller (get seller auction) )
    (taker (get taker auction) )
    (currentExpiration  (get newExpiration auction))
    (token (get token auction) )
    (status (get status auction) )
    (currentBid (get currentBid auction))
    (buyNowPrice (get buyNowPrice auction))
    (current (get auction auction))
    (block burn-block-height)
   )
   (asserts! (is-eq status "Active") NOT_ACTIVE)
   (asserts! (is-none token) ONLY_STX)
   (asserts! (<= block currentExpiration) EXPIRED)
   (asserts! (is-eq vault (get-owner-address id)) NOT_IN_THE_VAULT) ;; Names must be in the Vault before starting the auction
   (asserts! (> buyNowPrice currentBid) TOO_LOW)
    (try! (stx-transfer? buyNowPrice contract-caller vault))
    (try! (pay buyNowPrice seller)) 
    (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender buyer)))
    (if (> currentBid u0)
        (try! (as-contract (stx-transfer? currentBid tx-sender taker)))
        true
    )
    
    (map-delete AUCTION id )
    (print {
        auction: current,
        id: id,
        block: block,
        seller: (get seller auction),
        taker: buyer,
        token: (get token auction),
        startBid: (get startBid auction),
        reservePrice: (get reservePrice auction),
        buyNowPrice: buyNowPrice,
        currentBid: buyNowPrice,
        totalBids: (get totalBids auction),
        status: "Purchased"
    })
    (ok id)
   )
)

(define-public (buy-now-ft (id uint) (ft <sip-010-trait>))

   (let (
    (vault (as-contract tx-sender))
    (buyer contract-caller)
    (auction (get-auction id))
    (seller (get seller auction) )
    (taker (get taker auction) )
    (currentExpiration  (get newExpiration auction))
    (token (get token auction) )
    (status (get status auction) )
    (currentBid (get currentBid auction))
    (buyNowPrice (get buyNowPrice auction))
    (current (get auction auction))
    (block burn-block-height)
   )
   (asserts! (is-eq status "Active") NOT_ACTIVE)
   (asserts! (not (is-none token)) ONLY_TOKEN)
   (asserts! (is-eq (unwrap-panic token) (contract-of ft)) NOT_THE_TOKEN)
   (asserts! (<= block currentExpiration) EXPIRED)
   (asserts! (is-eq vault (get-owner-address id)) NOT_IN_THE_VAULT) ;; Names must be in the Vault before starting the auction
   (asserts! (> buyNowPrice currentBid) TOO_LOW)
    (try! (transfer-ft ft buyNowPrice contract-caller vault))
    (try! (pay-ft buyNowPrice seller ft)) 
    (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender buyer)))
    (if (> currentBid u0)
        (try! (as-contract (transfer-ft ft currentBid tx-sender taker)))
        true
    )
    
    (map-delete AUCTION id )
    (print {
        auction: current,
        id: id,
        block: block,
        seller: (get seller auction),
        taker: buyer,
        token: (get token auction),
        startBid: (get startBid auction),
        reservePrice: (get reservePrice auction),
        buyNowPrice: buyNowPrice,
        currentBid: buyNowPrice,
        totalBids: (get totalBids auction),
        status: "Purchased"
    })
    (ok id)
   )
)

;; the seller close the auction and can opt to receive the amount even if no reserve price was reached

(define-public (close-auction (id uint) (accept-without-reserve bool))
  ;; accept without reserve: true => accept any bid; false => accept bid only if gte of reserve bid;
   (let (
    (vault (as-contract tx-sender))
    (auction (get-auction id))
    (seller (get seller auction) )
    (taker (get taker auction) )
    (currentExpiration  (get newExpiration auction))
    (token (get token auction) )
    (status (get status auction) )
    (currentBid (get currentBid auction))
    (reservePrice (get reservePrice auction))
    (current (get auction auction))
    (is-reserve-met (>= currentBid reservePrice))
    (block burn-block-height)
   )
   (asserts! (is-eq status "Active") NOT_ACTIVE)
   (asserts! (is-eq contract-caller seller) NOT_THE_OWNER)
   (asserts! (is-none token) ONLY_STX)
   (asserts! (> block currentExpiration) STILL_ACTIVE)
   (asserts! (is-eq vault (get-owner-address id)) NOT_IN_THE_VAULT) ;; Names must be in the Vault before starting the auction
    (if (or is-reserve-met accept-without-reserve)
        (begin
          (try! (pay currentBid seller)) 
          (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender taker)))
        )
        (begin
          (try! (as-contract (stx-transfer? currentBid tx-sender taker))) 
          (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender seller)))
        )
    )
    (map-delete AUCTION id )
    (print {
        auction: current,
        id: id,
        seller: (get seller auction),
        taker: (get taker auction),
        token: (get token auction),
        startBid: (get startBid auction),
        reservePrice: (get reservePrice auction),
        buyNowPrice: (get buyNowPrice auction),
        currentBid: (get currentBid auction),
        totalBids: (get totalBids auction),
        status: (if (or is-reserve-met accept-without-reserve) "Closed" "Reserve not met")
    })
    (ok id)
   )
)

(define-public (close-auction-ft (id uint) (accept-without-reserve bool) (ft <sip-010-trait>))
  ;; accept without reserve: true => accept any bid; false => accept bid only if gte of reserve bid;
   (let (
    (vault (as-contract tx-sender))
    (auction (get-auction id))
    (seller (get seller auction) )
    (taker (get taker auction) )
    (currentExpiration  (get newExpiration auction))
    (token (get token auction) )
    (status (get status auction) )
    (currentBid (get currentBid auction))
    (reservePrice (get reservePrice auction))
    (current (get auction auction))
    (is-reserve-met (>= currentBid reservePrice))
    (block burn-block-height)
   )
   (asserts! (is-eq status "Active") NOT_ACTIVE)
   (asserts! (not (is-none token)) ONLY_TOKEN)
   (asserts! (is-eq (unwrap-panic token) (contract-of ft)) NOT_THE_TOKEN)
   (asserts! (is-eq contract-caller seller) NOT_THE_OWNER)
   (asserts! (> block currentExpiration) STILL_ACTIVE)
   (asserts! (is-eq vault (get-owner-address id)) NOT_IN_THE_VAULT) ;; Names must be in the Vault before starting the auction
    (if (or is-reserve-met accept-without-reserve)
        (begin
          (try! (pay-ft currentBid seller ft)) 
          (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender taker)))
        )
        (begin
          (try! (as-contract (transfer-ft ft currentBid tx-sender taker))) 
          (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender seller)))
        )
    )
    (map-delete AUCTION id )
    (print {
        auction: current,
        id: id,
        seller: (get seller auction),
        taker: (get taker auction),
        token: (get token auction),
        startBid: (get startBid auction),
        reservePrice: (get reservePrice auction),
        buyNowPrice: (get buyNowPrice auction),
        currentBid: (get currentBid auction),
        totalBids: (get totalBids auction),
        status: (if (or is-reserve-met accept-without-reserve) "Closed" "Reserve not met")
    })
    (ok id)
   )
)

;; this is a safe function to allow everyone to close an open auction with the default settings

(define-public (close-auction-public (id uint) )
   (let (
    (vault (as-contract tx-sender))
    (auction (get-auction id))
    (seller (get seller auction) )
    (taker (get taker auction) )
    (currentExpiration  (get newExpiration auction))
    (status (get status auction) )
    (currentBid (get currentBid auction))
    (reservePrice (get reservePrice auction))
    (current (get auction auction))
    (is-reserve-met (>= currentBid reservePrice))
    (block burn-block-height)
   )
   (asserts! (is-eq status "Active") NOT_ACTIVE)
   (asserts! (> block (+ currentExpiration u432)) STILL_ACTIVE) ;; after 3 days everyone can close the auction
   (asserts! (is-eq vault (get-owner-address id)) NOT_IN_THE_VAULT) ;; Names must be in the Vault before starting the auction
    (if is-reserve-met 
      (begin
        (try! (pay currentBid seller)) 
        (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender taker)))
      )
      (begin
        (try! (as-contract (stx-transfer? currentBid tx-sender taker))) 
        (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender seller)))
      )
    )
    (map-delete AUCTION id )
    (print {
        auction: current,
        id: id,
        seller: (get seller auction),
        taker: (get taker auction),
        token: (get token auction),
        startBid: (get startBid auction),
        reservePrice: (get reservePrice auction),
        buyNowPrice: (get buyNowPrice auction),
        currentBid: (get currentBid auction),
        totalBids: (get totalBids auction),
        status: (if is-reserve-met  "Closed" "Reserve not met")
    })
    (ok id)
   )
)

(define-public (close-auction-public-ft (id uint) (ft <sip-010-trait>))
   (let (
    (vault (as-contract tx-sender))
    (auction (get-auction id))
    (seller (get seller auction) )
    (taker (get taker auction) )
    (currentExpiration (get newExpiration auction) )
    (token (get token auction) )
    (status (get status auction) )
    (currentBid (get currentBid auction))
    (reservePrice (get reservePrice auction))
    (current (get auction auction))
    (is-reserve-met (>= currentBid reservePrice))
    (block burn-block-height)
   )
   (asserts! (is-eq status "Active") NOT_ACTIVE)
   (asserts! (not (is-none token)) ONLY_TOKEN)
   (asserts! (is-eq (unwrap-panic token) (contract-of ft)) NOT_THE_TOKEN)
   (asserts! (> block (+ currentExpiration u432)) STILL_ACTIVE) ;; after 3 days everyone can close the auction
   (asserts! (is-eq vault (get-owner-address id)) NOT_IN_THE_VAULT) ;; Names must be in the Vault before starting the auction
    (if is-reserve-met 
      (begin
        (try! (pay-ft currentBid seller ft)) 
        (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender taker)))
      )
      (begin
        (try! (as-contract (transfer-ft ft currentBid tx-sender taker))) 
        (try! (as-contract (transfer-nft 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 id tx-sender seller)))
      )
    )
    (map-delete AUCTION id )
    (print {
        auction: current,
        id: id,
        seller: (get seller auction),
        taker: (get taker auction),
        token: (get token auction),
        startBid: (get startBid auction),
        reservePrice: (get reservePrice auction),
        buyNowPrice: (get buyNowPrice auction),
        currentBid: (get currentBid auction),
        totalBids: (get totalBids auction),
        status: (if is-reserve-met  "Closed" "Reserve not met")
    })
    (ok id)
   )
)

;; private function to send commission

(define-private (pay (amount uint) (recipient principal) )
  (let (
    (commission (/ (* amount (var-get COMMISSION)) u10000))
  )
  (try! (as-contract (stx-transfer? commission tx-sender (var-get VAULT))))
  (as-contract (stx-transfer? (- amount commission) tx-sender recipient))
  )
)

(define-private (pay-ft (amount uint) (recipient principal) (token <sip-010-trait>))
  (let (
    (commission (/ (* amount (var-get COMMISSION)) u10000))
  )
  (try! (as-contract (transfer-ft token commission tx-sender (var-get VAULT))))
  (as-contract (transfer-ft token (- amount commission) tx-sender recipient))
  )
)

;; check if name doesn't expire during the auction

(define-private (is-expired-at (name-expiry uint) (auction-expiry uint)) 
  (if (is-eq name-expiry u0)
    false ;; if name-expiry is u0 will always return false
    (< name-expiry auction-expiry)
  )
)

;; validate auction price

(define-private (verify-price (startBid uint) (reservePrice uint) (buyNowPrice uint))
  (if (is-eq reservePrice u0)
    (if (is-eq buyNowPrice u0)
      true
      (>= buyNowPrice startBid)
    )
    (if (is-eq buyNowPrice u0)
      (>= reservePrice startBid)
      (and (>= reservePrice startBid) (>= buyNowPrice reservePrice))
    )
  )
)

;; calculate minimum bid based on steps

(define-private (calculate-min-bid (currentBid uint))
    
    (if (< currentBid (* u100 (var-get STEP)))
        (+ (var-get STEP) currentBid)
        (if (< currentBid (* u1000 (var-get STEP))) 
            (+ (* (var-get STEP) (var-get STEP_ONE) ) currentBid)
            (if (< currentBid (* u10000 (var-get STEP))) 
              (+ (* (var-get STEP) (var-get STEP_TWO) ) currentBid)
              (+ (* (var-get STEP) (var-get STEP_THREE)) currentBid)
        )
        )
    )
)

(define-private (calculate-min-bid-ft (currentBid uint) (step uint))
  ( if (> step u0)
    (if (< currentBid (* step u100))
        (+ step currentBid)
        (if (< currentBid (* step u1000)) 
            (+ (* step (var-get STEP_ONE)) currentBid)
            (if (< currentBid (* step u10000)) 
              (+ (* step (var-get STEP_TWO)) currentBid)
              (+ (* step (var-get STEP_THREE)) currentBid)
          )
        )
    )
    u0
  )
)

;; auction can be extend for max 144 btc blocks (approx. 1 day)

(define-private (get-new-expiration (expiration uint) (new-expiration uint) (block uint))
  (if (> block new-expiration)
      new-expiration
      (if (< (- new-expiration block) u2)
          
          (if (is-eq (- new-expiration expiration) u144) 
              new-expiration ;; capped at 144 blocks
              (if (is-eq (- new-expiration expiration) u143)
                (+ new-expiration u1)
                (+ block u2)
              )
          )
          new-expiration
      )
  )
)

;; get the auction information

(define-read-only (get-auction (id uint))
    (default-to {
        auction: u0,
        seller: 'SP000000000000000000002Q6VF78,
        taker: 'SP000000000000000000002Q6VF78,
        token: none,
        startBid: u0,
        reservePrice: u0,
        buyNowPrice: u0,
        currentBid: u0,
        totalBids: u0,
        expiration: u0,
        newExpiration: u0,
        start: u0,
        status: "None"
    } (map-get? AUCTION id))
)
(define-read-only (get-current-auction)
    (var-get CURRENT)
)

;; check if a token is whitelisted

(define-read-only (get-token (token principal)) 
  (default-to u0 (map-get? WHITELISTED token))
)