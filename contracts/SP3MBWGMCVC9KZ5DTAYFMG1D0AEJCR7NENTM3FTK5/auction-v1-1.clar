;; @contract Auction
;; @version 1.1

(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u3403001)

(define-constant ERR-WRONG-TOKEN u3402001)

(define-constant ERR-NO-CLAIMABLE-TOKENS u3400001)
(define-constant ERR-AUCTION-NOT-OPEN u3400002)
(define-constant ERR-AUCTION-NOT-ENDED u3400003)
(define-constant ERR-AUCTION-SUCCESSFUL u3400004)
(define-constant ERR-START-BLOCK u3400005)
(define-constant ERR-END-BLOCK u3400006)
(define-constant ERR-TOTAL-TOKENS u3400007)
(define-constant ERR-MIN-PRICE u3400008)
(define-constant ERR-START-PRICE u3400009)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var auction-counter uint u0)

;; ------------------------------------------
;; Maps
;; ------------------------------------------

(define-map auction-info
  { auction-id: uint }
  {
    ;; Info
    payment-token: principal,     ;; token to accept as payment
    start-block: uint,            ;; auction start block
    end-block: uint,              ;; auction end block
    total-tokens: uint,           ;; total number of tokens to sell in auction
    start-price: uint,            ;; start price auction
    min-price: uint,              ;; min price auction

    ;; Status
    total-committed: uint,        ;; total committed tokens
  }
)

(define-map commitments
  { 
    user: principal,
    auction-id: uint 
  }
  {
    committed: uint,
    claimed: uint,
  }
)

(define-read-only (get-auction-info (auction-id uint))
  (map-get? auction-info { auction-id: auction-id })
)

(define-read-only (get-commitments (user principal) (auction-id uint))
  (default-to
    {
      committed: u0,
      claimed: u0,
    }
    (map-get? commitments { user: user, auction-id: auction-id })
  )
)

;; ------------------------------------------
;; Var & Map Helpers
;; ------------------------------------------

(define-read-only (get-auction-counter)
  (var-get auction-counter)
)

;; ------------------------------------------
;; Price
;; ------------------------------------------

;; total-committed / total-tokens
(define-read-only (token-price (auction-id uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
    (total-committed (get total-committed auction))
    (total-tokens (get total-tokens auction))
  )
    (/ (* total-committed u1000000) total-tokens)
  )
)

;; current-price if auction open
(define-read-only (price-function (auction-id uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
  )
    (if (<= block-height (get start-block auction))
      (get start-price auction)
      (if (>= block-height (get end-block auction))
        (get min-price auction)
        (current-price auction-id)
      )
    )
  )
)

;; from start-price at start-block, to min-price at end-block
(define-read-only (current-price (auction-id uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
    (start-block (get start-block auction))
    (end-block (get end-block auction))
    (start-price (get start-price auction))
    (min-price (get min-price auction))

    (price-diff-nominator (* (- block-height start-block) (- start-price min-price)))
    (price-diff-denominator (- end-block start-block))
    (price-diff (/ price-diff-nominator price-diff-denominator))
  )
    (- start-price price-diff)
  )
)

;; max of token price or current-price
(define-read-only (clearing-price (auction-id uint))
  (let (
    (current-token-price (token-price auction-id))
    (price (price-function auction-id))
  )
    (if (> current-token-price price)
      current-token-price
      price
    )
  )
)

;; ------------------------------------------
;; Auction end
;; ------------------------------------------

(define-read-only (auction-successful (auction-id uint))
  (let (
    (clearing (clearing-price auction-id))
    (token (token-price auction-id))
  )
    (if (>= token clearing)
      true
      false
    )
  )
)

(define-read-only (auction-ended (auction-id uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
  )
    (if (> block-height (get end-block auction))
      true
      false
    )
  )
)

(define-read-only (auction-open (auction-id uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
  )
    (if (and (>= block-height (get start-block auction)) (<= block-height (get end-block auction)))
      true
      false
    )
  )
)

;; ------------------------------------------
;; Commit
;; ------------------------------------------

(define-public (commit-tokens (token <ft-trait>) (auction-id uint) (amount uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
    (tokens-to-transfer (calculate-commitment auction-id amount))
  )
    (asserts! (auction-open auction-id) (err ERR-AUCTION-NOT-OPEN))
    (asserts! (is-eq (contract-of token) (get payment-token auction)) (err ERR-WRONG-TOKEN))

    (if (> tokens-to-transfer u0)
      (begin
        ;; Transfer from user
        (try! (contract-call? token transfer tokens-to-transfer tx-sender (as-contract tx-sender) none))

        ;; Add commitment
        (add-commitment auction-id tx-sender tokens-to-transfer)
      )
      (ok u0)
    )
  )
)

(define-private (add-commitment (auction-id uint) (user principal) (commitment uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
    (current-total (get total-committed auction))

    (user-committed (get-commitments user auction-id))
    (current-committed (get committed user-committed))
  )
    ;; Update auction
    (map-set auction-info
      { auction-id: auction-id }
      (merge auction { total-committed: (+ current-total commitment) })
    )

    ;; Update user
    (map-set commitments
      { user: user, auction-id: auction-id }
      (merge user-committed { committed: (+ current-committed commitment) })
    )
  
    (ok commitment)
  )
)

(define-read-only (calculate-commitment (auction-id uint) (commitment uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
    (max-commitment (/ (* (get total-tokens auction) (clearing-price auction-id)) u1000000))
    (new-commitment (+ commitment (get total-committed auction)))
  )
    (if (> new-commitment max-commitment)
      (- max-commitment (get total-committed auction))
      commitment
    )
  )
)

;; ------------------------------------------
;; Claim
;; ------------------------------------------


(define-public (withdraw-tokens (auction-id uint))
  (let (
    (user tx-sender)
    (claimable (tokens-claimable auction-id user))

    (user-committed (get-commitments user auction-id))
    (current-claimed (get claimed user-committed))
  )
    (asserts! (> claimable u0) (err ERR-NO-CLAIMABLE-TOKENS))

    (map-set commitments
      { user: user, auction-id: auction-id }
      (merge user-committed { claimed: claimable })
    )
  
    (try! (as-contract (contract-call? .lydian-token transfer claimable (as-contract tx-sender) user none)))

    (ok claimable)
  )
)

(define-read-only (tokens-claimable (auction-id uint) (user principal))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
    (user-committed (get committed (get-commitments user auction-id)))
    (user-claimed (get claimed (get-commitments user auction-id)))

    (total-committed (get total-committed auction))
  )
    (if (is-eq total-committed u0)
      u0
      (let (
        (total-claimable (/ (* user-committed (get total-tokens auction)) total-committed))
        (claimable (- total-claimable user-claimed))
      )
        (if (and (auction-ended auction-id) (auction-successful auction-id))
          claimable
          u0
        )  
      )
    )
  )
)

(define-public (withdraw-committed (token <ft-trait>) (auction-id uint))
  (let (
    (user tx-sender)
    (auction (unwrap-panic (get-auction-info auction-id)))

    (user-committed (get-commitments user auction-id))
    (current-committed (get committed user-committed))
    (current-claimed (get claimed user-committed))
    (claimable (- current-committed current-claimed))
  )
    (asserts! (is-eq (contract-of token) (get payment-token auction)) (err ERR-WRONG-TOKEN))
    (asserts! (auction-ended auction-id) (err ERR-AUCTION-NOT-ENDED))
    (asserts! (not (auction-successful auction-id)) (err ERR-AUCTION-SUCCESSFUL))
    (asserts! (> claimable u0) (err ERR-NO-CLAIMABLE-TOKENS))

    (map-set commitments
      { user: user, auction-id: auction-id }
      (merge user-committed { claimed: claimable })
    )
  
    (try! (as-contract (contract-call? token transfer claimable (as-contract tx-sender) user none)))

    (ok claimable)
  )
)

;; ---------------------------------------------------------
;; DAO
;; ---------------------------------------------------------

(define-public (cancel-auction (auction-id uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))

    ;; Set total-tokens so auction is not successful
    (map-set auction-info
      { auction-id: auction-id }
      (merge auction { end-block: block-height, total-tokens: (get total-committed auction) })
    )

    (ok true)
  )
)

(define-public (transfer-tokens (token <ft-trait>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err  ERR-NOT-AUTHORIZED))
    (try! (as-contract (contract-call? token transfer amount (as-contract tx-sender) recipient none)))
    (ok true)
  )
)

(define-public (add-auction 
    (payment-token principal) 
    (start-block uint)
    (end-block uint)
    (total-tokens uint)
    (start-price uint)
    (min-price uint)
  )
  (let (
    (auction-id (var-get auction-counter))
  )
    (asserts! (is-eq tx-sender .lydian-dao) (err ERR-NOT-AUTHORIZED))
    (asserts! (> start-block block-height) (err ERR-START-BLOCK))
    (asserts! (> end-block start-block) (err ERR-END-BLOCK))
    (asserts! (> total-tokens u0) (err ERR-TOTAL-TOKENS))
    (asserts! (> min-price u0) (err ERR-MIN-PRICE))
    (asserts! (> start-price min-price) (err ERR-START-PRICE))

    (map-set auction-info 
      { auction-id: auction-id } 
      { 
        payment-token: payment-token,
        start-block: start-block,
        end-block: end-block,
        total-tokens: total-tokens,
        start-price: start-price,
        min-price: min-price,

        total-committed: u0,
      }
    )
    (var-set auction-counter (+ auction-id u1))
    (ok auction-id)
  )
)
