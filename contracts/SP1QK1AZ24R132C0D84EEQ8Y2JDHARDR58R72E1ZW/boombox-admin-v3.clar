(use-trait bb-trait .boombox-trait.boombox-trait)

(define-constant dplyr tx-sender)
(define-constant accnt (as-contract tx-sender))
;; M blocks before the prepare phase starts of length N
(define-constant blocks-before-rewards u200)

(define-data-var last-id uint u0)
(define-map total-stacked uint uint)
(define-map boombox uint
  {fq-contract: principal,
    cycle: uint,
    locking-period: uint,
    minimum-amount: uint,
    pox-addr: {version: (buff 1), hashbytes: (buff 20)},
    owner: principal,
    active: bool})

(define-map meta {id: uint, nft-id: uint}
  {stacker: principal,
    amount-ustx: uint,
    stacked-ustx: (optional uint),
    reward: (optional uint)})

(define-map boombox-by-contract {fq-contract: principal, cycle: uint} uint)

;; @desc adds a boombox contract to the list of boomboxes
;; @param nft-contract; The NFT contract for this boombox
;; @param cycle; PoX reward cycle
;; @param minimum-amount; minimum stacking amount for this boombox
;; @param owner; owner/admin of this boombox
;; @param pox-addr; reward pool address
(define-public (add-boombox (nft-contract <bb-trait>) (cycle uint) (locking-period uint) (minimum-amount uint) (pox-addr {version: (buff 1), hashbytes: (buff 20)}) (owner principal))
  (let ((fq-contract (contract-of nft-contract))
        (id (+ u1 (var-get last-id))))
    (asserts! (> cycle (current-cycle)) err-too-late)
    (map-insert boombox id
      {fq-contract: fq-contract, cycle: cycle, locking-period: locking-period,
      minimum-amount: minimum-amount, pox-addr: pox-addr, owner: owner,
      active: true })
    (asserts! (map-insert boombox-by-contract {fq-contract: fq-contract, cycle: cycle} id) err-entry-exists)
    (try! (contract-call? nft-contract set-boombox-id id))
    (var-set last-id id)
    (ok id)))

;; @desc stops minting of a boombox
;; @param id; the boombox id
(define-public (halt-boombox (id uint))
  (let ((details (unwrap! (map-get? boombox id) err-not-found)))
    (asserts! (is-eq contract-caller (get owner details)) err-not-authorized)
    (map-set boombox id (merge details {active: false}))
    (ok true)))

;; @desc lookup a boombox by id
;; @param id; the boombox id
(define-read-only (get-boombox-by-id (id uint))
  (map-get? boombox id))

(define-read-only (get-boombox-by-contract (fq-contract <bb-trait>) (cycle uint))
  (map-get? boombox-by-contract {fq-contract: (contract-of fq-contract), cycle: cycle}))

;; (define-private (get-boombox-by-owner (owner principal)) body)
;; (define-private (get-boombox-by-owner-and-cycle (owner principal) (cycle uint)) body)
;; (define-private get-boombox-by-owner-and-cycle-and-id (owner principal) (cycle uint)  body)
;; (define-private get-boombox-by-minimum-amount body)
;; (define-private boombox-unique body)
;; (define-private get-stackers-by-id body)

(define-private (get-total-stacked (id uint))
  (map-get? total-stacked id))

(define-private (pox-delegate-stx-and-stack (amount-ustx uint) (pox-addr {version: (buff 1), hashbytes: (buff 20)}) (locking-period uint))
  (let ((ignore-result-revoke (contract-call? 'SP000000000000000000002Q6VF78.pox revoke-delegate-stx))
        (start-block-ht (+ burn-block-height u1))
        (stacker tx-sender))
      (match (contract-call? 'SP000000000000000000002Q6VF78.pox delegate-stx amount-ustx accnt none none)
        success
            (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox delegate-stack-stx stacker amount-ustx pox-addr start-block-ht locking-period))
              stack-success (ok stack-success)
              stack-error (print (err (to-uint stack-error))))
        error (err (to-uint error)))))

(define-private (delegatedly-stack (id uint) (nft-id uint) (stacker principal) (amount-ustx uint) (pox-addr {version: (buff 1), hashbytes: (buff 20)}) (locking-period uint))
  (match (pox-delegate-stx-and-stack amount-ustx pox-addr locking-period)
    success-pox
            (begin
              (asserts! (map-insert meta {id: id, nft-id: nft-id}
                  {stacker: stacker, amount-ustx: amount-ustx, stacked-ustx: (some (get lock-amount success-pox)), reward: none})
                  err-map-function-failed)
              (ok {id: id, nft-id: nft-id, pox: success-pox}))
    error-pox (err error-pox)))

;; delegate and lock stacks token
;; @id boombox id
;; @fq-contract: fully qualified contract of that boombox
;; @amount-ustx: amount to lock, tx-sender must have at least this amount
(define-public (delegate-stx (id uint) (fq-contract <bb-trait>) (amount-ustx uint))
  (let ((details (unwrap! (map-get? boombox id) err-not-found))
      (pox-addr (get pox-addr details))
      (locking-period (get locking-period details)))
    (asserts! (get active details) err-not-authorized)
    (asserts! (>= amount-ustx (get minimum-amount details)) err-delegate-below-minimum)
    (asserts! (< (+ burn-block-height blocks-before-rewards) (reward-cycle-to-burn-height (get cycle details))) err-delegate-too-late)
    (asserts! (>= (stx-get-balance tx-sender) amount-ustx) err-not-enough-funds)
    (asserts! (is-eq (contract-of fq-contract) (get fq-contract details)) err-invalid-boombox)
    (map-set total-stacked id (+ (default-to u0 (map-get? total-stacked id)) amount-ustx))
    (match (contract-call? fq-contract mint id tx-sender amount-ustx pox-addr locking-period)
      nft-id (delegatedly-stack id nft-id tx-sender amount-ustx pox-addr locking-period)
      error-minting (err error-minting))))

;; function for pool admins
(define-public (stack-aggregation-commit (pox-addr {version: (buff 1), hashbytes: (buff 20)}) (reward-cycle uint))
  (begin
    (asserts! (>= (+ burn-block-height blocks-before-rewards) (reward-cycle-to-burn-height reward-cycle)) err-too-early)
    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox stack-aggregation-commit pox-addr reward-cycle))
      success (ok success)
      error (err (to-uint error)))))

(define-public (nft-details (id uint) (fq-contract <bb-trait>) (nft-id uint))
  (ok {stacked-ustx: (unwrap! (unwrap! (get stacked-ustx (map-get? meta {id: id, nft-id: nft-id})) err-invalid-asset-id) err-invalid-asset-id),
        owner: (unwrap! (contract-call? fq-contract get-owner nft-id) err-no-asset-owner)}))

(define-public (nft-details-at-block (id uint) (fq-contract <bb-trait>) (nft-id uint) (stacks-tip uint))
  (ok {stacked-ustx: (unwrap! (unwrap! (get stacked-ustx (map-get? meta {id: id, nft-id: nft-id})) err-invalid-asset-id) err-invalid-asset-id),
        owner: (unwrap! (contract-call? fq-contract get-owner-at-block nft-id stacks-tip) err-no-asset-owner)}))

(define-data-var ctx-boombox-id uint u0)
(define-private (sum-stacked-ustx (nft-id uint) (ctx {id: uint, total: uint}))
  (match (map-get? meta {id: (get id ctx), nft-id: nft-id})
    entry (match (get stacked-ustx entry)
            amount {id: (get id ctx), total: (+ (get total ctx) amount)}
            ctx)
    ctx))

(define-private (get-total-stacked-ustx (id uint) (nfts (list 750 uint)))
    (fold sum-stacked-ustx nfts {id: id, total: u0}))

(define-public (get-total-stacked-ustx-at-block (id uint) (nfts (list 750 uint)) (stacks-tip uint))
  (match (get-block-info? id-header-hash stacks-tip)
    ihh (at-block ihh (ok (get-total-stacked-ustx id nfts)))
    err-invalid-stacks-tip))

(define-public (allow-contract-caller (this-contract principal))
  (begin
    (asserts! (is-eq tx-sender dplyr) err-not-authorized)
    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox allow-contract-caller this-contract none))
      success (ok true)
      error (err (to-uint error)))))


;; What's the reward cycle number of the burnchain block height?
;; Will runtime-abort if height is less than the first burnchain block (this is intentional)
(define-read-only (burn-height-to-reward-cycle (height uint))
    (let ((pox-info (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.pox get-pox-info) u0)))
     (/ (- height (get first-burnchain-block-height pox-info)) (get reward-cycle-length pox-info))))

;; What's the block height at the start of a given reward cycle?
(define-read-only (reward-cycle-to-burn-height (cycle uint))
    (let ((pox-info (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.pox get-pox-info) u0)))
     (+ (get first-burnchain-block-height pox-info) (* cycle (get reward-cycle-length pox-info)))))

;; What's the current PoX reward cycle?
(define-read-only (current-cycle)
    (burn-height-to-reward-cycle burn-block-height))



;; error handling
(define-constant err-nft-not-owned (err u401)) ;; unauthorized
(define-constant err-not-authorized (err u403)) ;; forbidden
(define-constant err-not-found (err u404)) ;; not found
(define-constant err-sender-equals-recipient (err u405)) ;; method not allowed
(define-constant err-nft-exists (err u409)) ;; conflict
(define-constant err-not-enough-funds (err u4021)) ;; payment required
(define-constant err-amount-not-positive (err u4022)) ;; payment required

(define-constant err-map-function-failed (err u601))
(define-constant err-invalid-asset-id (err u602))
(define-constant err-no-asset-owner (err u603))
(define-constant err-delegate-below-minimum (err u604))
(define-constant err-delegate-invalid-stacker (err u605))
(define-constant err-delegate-too-late (err u606))
(define-constant err-too-early (err u607))
(define-constant err-invalid-stacks-tip (err u608))
(define-constant err-too-late (err u609))
(define-constant err-pox-addr-mismatch (err u610))
(define-constant err-entry-exists (err u611))
(define-constant err-cycle-full (err u612))
(define-constant err-not-deleted (err u613))
(define-constant err-invalid-boombox (err u614))
