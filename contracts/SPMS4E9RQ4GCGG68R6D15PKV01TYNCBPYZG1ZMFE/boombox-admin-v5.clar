;; @contract Boombox Admin
;; @version 5

;; Boombox Admin is a non-custodial stacking pool providing
;; liquidity of the future rewards through a Boombox NFT.
;; Each Boombox NFT can be minted during a particular cycle.
;; Minters of the NFT stack their Stacks for 1 cycle and
;; can continuously extend the stacking for 1 cycle.
;; Rewards are distributed to the owner of the NFT
;; at the end of each cycle according to the distribution rules.

(use-trait bb-trait 'SPMS4E9RQ4GCGG68R6D15PKV01TYNCBPYZG1ZMFE.boombox-trait-v2.boombox-trait)

(define-trait distribution-trait
  (
    ;; @param nft-id; owner of the id
    ;; @param amount; reward amount in ustx to distribute
    ;; @param stacks-tip; stacks block height used for NFT ownership
    (distribute (uint uint uint) (response uint uint))

    ;; @param nfts; list of nft ids and corresponding amounts to distribute
    ;; @param stacks-tip; stacks block height used for NFT ownership
    (distribute-many ((list 200 uint) (list 200 uint) uint) (response (list 200 (response uint uint)) uint))
  )
)

(define-constant dplyr tx-sender)
(define-constant accnt (as-contract tx-sender))
(define-constant stx-buffer u1000000) ;; Always keep 1 STX unlocked

(define-data-var last-id uint u0)
(define-map total-stacked uint uint)

(define-map meta {id: uint, nft-id: uint}
  {stacker: principal,
    amount-ustx: uint,
    stacked-ustx: (optional uint),
    reward: (optional uint)})

(define-map boombox-by-contract {fq-contract: principal, cycle: uint} uint)

;; Map of reward cycle to pox reward set index.
;; Reward set index gives access to the total locked stx of the pool.
(define-map pox-addr-indices {pox-addr: {hashbytes: (buff 32), version: (buff 1)}, reward-cycle: uint} uint)
;; Map of reward cyle to block height of last commit
(define-map last-aggregation {pox-addr: {hashbytes: (buff 32), version: (buff 1)}, reward-cycle: uint} uint)

(define-data-var boombox-list (list 100 {id: uint,
    fq-contract: principal,
    cycle: uint,
    locking-period: uint,
    minimum-amount: uint,
    pox-addr: {hashbytes: (buff 32), version: (buff 1)},
    owner: principal,
    distribution-rules: principal,
    active: bool}) (list))

;; Allowed contract-callers handling a user's boombox stacking activity.
(define-map allowance-contract-callers
  { sender: principal, contract-caller: principal}
  { until-burn-ht: (optional uint)})

;; Half cycle lenght is 1050 for mainnet
(define-constant half-cycle-length (/ (get reward-cycle-length (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-2 get-pox-info))) u2))

;;
;; error handling
;;
(define-constant err-unauthorized (err u401)) ;; unauthorized
(define-constant err-forbidden (err u403)) ;; forbidden
(define-constant err-not-found (err u404)) ;; not found
(define-constant err-sender-equals-recipient (err u405)) ;; method not allowed
(define-constant err-nft-exists (err u409)) ;; conflict
(define-constant err-not-enough-funds (err u4021)) ;; payment required
(define-constant err-amount-not-positive (err u4022)) ;; payment required

(define-constant err-decrease-forbidden (err u503))

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
(define-constant err-invalid-boombox (err u614))
;; Error code 9 is used by pox-2 contract
(define-constant err-stacking-permission-denied (err u709))

;; @desc adds a boombox contract to the list of boomboxes
;; @param nft-contract; The NFT contract for this boombox
;; @param cycle; PoX reward cycle
;; @param minimum-amount; minimum stacking amount for this boombox
;; @param owner; owner/admin of this boombox
;; @param pox-addr; reward pool address
(define-public (add-boombox (nft-contract <bb-trait>) (cycle uint) (locking-period uint)
                    (minimum-amount uint) (pox-addr {version: (buff 1), hashbytes: (buff 32)})
                    (owner principal) (distribution-rules <distribution-trait>))
  (let ((fq-contract (contract-of nft-contract))
        (current-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-2 current-pox-reward-cycle))
        (id (+ u1 (var-get last-id))))
    (asserts! (>= cycle current-cycle) err-too-late)
    (asserts! (map-insert boombox-by-contract {fq-contract: fq-contract, cycle: cycle} id) err-entry-exists)
    (append-to-boombox-list {id: id, fq-contract: fq-contract, cycle: cycle, locking-period: locking-period,
      minimum-amount: minimum-amount, pox-addr: pox-addr, owner: owner,
      distribution-rules: (contract-of distribution-rules),
      active: true })
    (try! (contract-call? nft-contract set-boombox-id id))
    (var-set last-id id)
    (ok id)))

;; @desc stops minting of a boombox
;; @param id; the boombox id
(define-public (halt-boombox (id uint))
  (let ((bb-list (var-get boombox-list))
        (element (unwrap! (element-at? bb-list (- id u1)) err-not-found))
        (new-list (unwrap! (replace-at? bb-list (- id u1) (merge element {active: false})) err-not-found)))
    (var-set boombox-list new-list)
    (ok new-list)))


;; @desc lookup a boombox by id
;; @param id; the boombox id
(define-read-only (get-boombox-by-id (id uint))
  (element-at (var-get boombox-list) (- id u1)))

(define-read-only (get-boombox-by-contract (fq-contract <bb-trait>) (cycle uint))
  (map-get? boombox-by-contract {fq-contract: (contract-of fq-contract), cycle: cycle}))

(define-read-only (get-all-boomboxes)
  (var-get boombox-list))

(define-private (pox-delegate-stx-and-stack (amount-ustx uint) (pox-addr {version: (buff 1), hashbytes: (buff 32)}) (locking-period uint))
  (let ((user tx-sender)
        (current-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-2 current-pox-reward-cycle)))
      (asserts! (check-caller-allowed) err-stacking-permission-denied)
      ;; Do 1. and 2.
      (try! (delegate-stx-inner amount-ustx (as-contract tx-sender) none))
      ;; Do 3.
      (match (as-contract (lock-delegated-stx user pox-addr locking-period))
        success-lock
          ;; Do 4.
          (ok (merge success-lock
                {aggregate: (maybe-stack-aggregation-commit pox-addr current-cycle)}))
        error-lock (err error-lock))))

;; Revokes and delegates stx
(define-private (delegate-stx-inner (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint)))
  (let ((result-revoke
            ;; Calls revoke and ignores result
          (contract-call? 'SP000000000000000000002Q6VF78.pox-2 revoke-delegate-stx)))
    ;; Calls delegate-stx, converts any error to uint
    (match (contract-call? 'SP000000000000000000002Q6VF78.pox-2 delegate-stx amount-ustx delegate-to until-burn-ht none)
      success (ok success)
      error (err (* u1000 (to-uint error))))))

;; Tries to lock delegated stx (delegate-stack-stx).
;; If user already stacked then extend and increase
(define-private (lock-delegated-stx (user principal) (pox-addr {hashbytes: (buff 32), version: (buff 1)}) (locking-period uint))
  (let ((start-burn-ht (+ burn-block-height u1))
        (user-account (stx-account user))
        (allowed-amount (min (get-delegated-amount user) (+ (get locked user-account) (get unlocked user-account))))
        (amount-ustx (if (> allowed-amount stx-buffer) (- allowed-amount stx-buffer) allowed-amount)))
    (match (contract-call? 'SP000000000000000000002Q6VF78.pox-2 delegate-stack-stx
             user amount-ustx
             pox-addr start-burn-ht locking-period)
      stacker-details  (ok stacker-details)
      error (if (is-eq error 3) ;; check whether user is already stacked
              (delegate-stack-extend-increase user amount-ustx pox-addr start-burn-ht)
              (err (* u1000 (to-uint error)))))))



;; Calls pox-2 delegate-stack-extend and delegate-stack-increase.
;; parameter amount-ustx must be lower or equal the stx balance and the delegated amount
(define-private (delegate-stack-extend-increase (user principal)
                  (amount-ustx uint)
                  (pox-address {hashbytes: (buff 32), version: (buff 1)})
                  (start-burn-ht uint))
  (let ((status (stx-account user)))
    (asserts! (>= amount-ustx (get locked status)) err-decrease-forbidden)
    (match (contract-call? 'SP000000000000000000002Q6VF78.pox-2 delegate-stack-extend
             user pox-address u1)
      success (if (> amount-ustx (get locked status))
                (match (contract-call? 'SP000000000000000000002Q6VF78.pox-2 delegate-stack-increase
                         user pox-address (- amount-ustx (get locked status)))
                  success-increase (ok {lock-amount: (get total-locked success-increase),
                                        stacker: user,
                                        unlock-burn-height: (get unlock-burn-height success)})
                  error-increase (err (* u1000000000 (to-uint error-increase))))
                (ok {lock-amount: (get locked status),
                     stacker: user,
                     unlock-burn-height: (get unlock-burn-height success)}))
      error (err (* u1000000 (to-uint error))))))

;; Tries to calls stack aggregation commit. If the minimum is met,
;; subsequent calls increase the total amount using
;; the index of the first successful call.
;; This index gives access to the internal map of the pox-2 contract
;; that handles the reward addresses.
(define-private (maybe-stack-aggregation-commit (pox-addr {hashbytes: (buff 32), version: (buff 1)}) (current-cycle uint))
  (let ((reward-cycle (+ u1 current-cycle)))
    (match (map-get? pox-addr-indices {pox-addr: pox-addr, reward-cycle: reward-cycle})
            ;; Total stacked already reached minimum.
            ;; Call stack-aggregate-increase.
            ;; It might fail because called in the same cycle twice.
      index (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-2 stack-aggregation-increase pox-addr reward-cycle index))
              success (map-set last-aggregation {pox-addr: pox-addr, reward-cycle: reward-cycle} block-height)
              error (begin (print {err-increase-ignored: error}) false))
            ;; Total stacked is still below minimum.
            ;; Just try to commit, it might fail because minimum not yet met
      (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-2 stack-aggregation-commit-indexed pox-addr reward-cycle))
        index (begin
                (map-set pox-addr-indices {pox-addr: pox-addr, reward-cycle: reward-cycle} index)
                (map-set last-aggregation {pox-addr: pox-addr, reward-cycle: reward-cycle} block-height))
        error (begin (print {err-commit-ignored: error}) false))))) ;; ignore errors


(define-private (delegatedly-stack (id uint) (nft-id uint) (stacker principal) (amount-ustx uint) (pox-addr {version: (buff 1), hashbytes: (buff 32)}) (locking-period uint))
  (match (pox-delegate-stx-and-stack amount-ustx pox-addr locking-period)
    success-pox
            (begin
              (asserts! (map-insert meta {id: id, nft-id: nft-id}
                  {stacker: stacker, amount-ustx: amount-ustx, stacked-ustx: (some (get lock-amount success-pox)), reward: none})
                  err-map-function-failed)
              (ok {id: id, nft-id: nft-id, pox: success-pox}))
    error-pox (err error-pox)))

;;
;; Public functions
;;

;; delegate and lock stacks token
;; @id boombox id
;; @fq-contract: fully qualified contract of that boombox
;; @amount-ustx: amount to lock, tx-sender must have at least this amount
(define-public (delegate-stx (id uint) (fq-contract <bb-trait>) (amount-ustx uint))
  (let ((details (unwrap! (get-boombox-by-id id) err-not-found))
      (pox-addr (get pox-addr details))
      (locking-period (get locking-period details)))
    (asserts! (get active details) err-forbidden)
    (asserts! (>= amount-ustx (get minimum-amount details)) err-delegate-below-minimum)
    (asserts! (< burn-block-height (reward-cycle-to-burn-height (get cycle details))) err-delegate-too-late)
    (asserts! (>= (stx-get-balance tx-sender) amount-ustx) err-not-enough-funds)
    (asserts! (is-eq (contract-of fq-contract) (get fq-contract details)) err-invalid-boombox)
    ;; TODO fix total stacked
    (map-set total-stacked id (+ (default-to u0 (map-get? total-stacked id)) amount-ustx))
    (match (contract-call? fq-contract mint id tx-sender amount-ustx pox-addr locking-period)
      nft-id (delegatedly-stack id nft-id tx-sender amount-ustx pox-addr locking-period)
      error-minting (err error-minting))))

;; only stacker can increase
(define-public (increase-stacked-stx (id uint) (nft-id uint) (fq-contract <bb-trait>) (amount-increase uint))
  (let ((details (unwrap! (map-get? meta {id: id, nft-id: nft-id}) err-not-found))
    (stacker (get stacker details))
    (pox-addr (get pox-addr (unwrap! (element-at? (var-get boombox-list) (- id u1)) err-not-found))))
      (asserts! (check-caller-allowed) err-stacking-permission-denied)
      (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-2 delegate-stack-increase stacker pox-addr amount-increase))
      success (ok success)
      error (err (to-uint error)))))

;; any user can extend after half of the cycle
(define-public (extend-stacking (id uint) (nft-id uint) (fq-contract <bb-trait>) (lock-period uint))
  (let ((details (unwrap! (map-get? meta {id: id, nft-id: nft-id}) err-not-found))
          (stacker (get stacker details))
          (current-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-2 current-pox-reward-cycle))
          (pox-addr (get pox-addr (unwrap! (element-at? (var-get boombox-list) (- id u1)) err-not-found))))
      (asserts! (can-extend-now current-cycle) err-too-early)
      (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-2 delegate-stack-extend stacker pox-addr lock-period))
      success (ok success)
      error (err (to-uint error)))))

(define-public (extend-and-increase-stacked-stx (id uint) (nft-id uint) (fq-contract <bb-trait>) (lock-period uint) (amount-increase uint))
  (begin
    (try! (extend-stacking id nft-id fq-contract lock-period))
    (increase-stacked-stx id nft-id fq-contract amount-increase)))

;; Public Admin functions
(define-public (stack-aggregation-commit (pox-addr {version: (buff 1), hashbytes: (buff 32)}) (reward-cycle uint))
  (ok (maybe-stack-aggregation-commit pox-addr (- reward-cycle u1))))

(define-public (nft-details (id uint) (fq-contract <bb-trait>) (nft-id uint))
  (ok {stacked-ustx: (unwrap! (unwrap! (get stacked-ustx (map-get? meta {id: id, nft-id: nft-id})) err-invalid-asset-id) err-invalid-asset-id),
        owner: (unwrap! (contract-call? fq-contract get-owner nft-id) err-no-asset-owner)}))

(define-public (nft-details-at-block (id uint) (fq-contract <bb-trait>) (nft-id uint) (stacks-tip uint))
  (ok {stacked-ustx: (unwrap! (unwrap! (get stacked-ustx (map-get? meta {id: id, nft-id: nft-id})) err-invalid-asset-id) err-invalid-asset-id),
        owner: (unwrap! (contract-call? fq-contract get-owner-at-block nft-id stacks-tip) err-no-asset-owner)}))

(define-private (sum-stacked-ustx (nft-id uint) (ctx {id: uint, total: uint}))
  (match (map-get? meta {id: (get id ctx), nft-id: nft-id})
    entry (match (get stacked-ustx entry)
            amount {id: (get id ctx), total: (+ (get total ctx) amount)}
            ctx)
    ctx))


(define-read-only (get-delegated-amount (user principal))
  (default-to u0 (get amount-ustx (contract-call? 'SP000000000000000000002Q6VF78.pox-2 get-delegation-info user))))

(define-read-only (get-total-stacked (id uint))
  (map-get? total-stacked id))

(define-private (get-total-stacked-ustx (id uint) (nfts (list 750 uint)))
    (fold sum-stacked-ustx nfts {id: id, total: u0}))

(define-read-only (get-total-stacked-ustx-at-block (id uint) (nfts (list 750 uint)) (stacks-tip uint))
  (match (get-block-info? id-header-hash stacks-tip)
    ihh (at-block ihh (ok (get-total-stacked-ustx id nfts)))
    err-invalid-stacks-tip))

(define-read-only (can-extend-now (cycle uint))
  (> burn-block-height (+ (contract-call? 'SP000000000000000000002Q6VF78.pox-2 reward-cycle-to-burn-height cycle) half-cycle-length)))

;; What's the reward cycle number of the burnchain block height?
;; Will runtime-abort if height is less than the first burnchain block (this is intentional)
(define-read-only (burn-height-to-reward-cycle (height uint))
    (contract-call? 'SP000000000000000000002Q6VF78.pox-2 burn-height-to-reward-cycle height))

;; What's the block height at the start of a given reward cycle?
(define-read-only (reward-cycle-to-burn-height (cycle uint))
  (contract-call? 'SP000000000000000000002Q6VF78.pox-2 reward-cycle-to-burn-height cycle))

(define-private (append-to-boombox-list (details {id: uint, fq-contract: principal,
    cycle: uint,
    locking-period: uint,
    minimum-amount: uint,
    pox-addr: {version: (buff 1), hashbytes: (buff 32)},
    owner: principal,
    distribution-rules: principal,
    active: bool}))
  (var-set boombox-list
    (unwrap-panic (as-max-len? (append (var-get boombox-list) details) u100))))

;; Returns minimum
(define-private (min (amount-1 uint) (amount-2 uint))
  (if (< amount-1 amount-2)
    amount-1
    amount-2))

;;
;; Functions about allowance of delegation/stacking contract calls
;;

;; Give a contract-caller authorization to call stacking methods
;;  normally, stacking methods may only be invoked by _direct_ transactions
;;   (i.e., the tx-sender issues a direct contract-call to the stacking methods)
;;  by issuing an allowance, the tx-sender may call through the allowed contract
(define-public (allow-contract-caller (caller principal) (until-burn-ht (optional uint)))
  (begin
    (asserts! (is-eq tx-sender contract-caller) err-stacking-permission-denied)
    (ok (map-set allowance-contract-callers
          { sender: tx-sender, contract-caller: caller}
          { until-burn-ht: until-burn-ht}))))

;; Revoke contract-caller authorization to call stacking methods
(define-public (disallow-contract-caller (caller principal))
  (begin
    (asserts! (is-eq tx-sender contract-caller) err-stacking-permission-denied)
    (ok (map-delete allowance-contract-callers { sender: tx-sender, contract-caller: caller}))))

(define-read-only (check-caller-allowed)
  (or (is-eq tx-sender contract-caller)
    (let ((caller-allowed
                 ;; if not in the caller map, return false
            (unwrap! (map-get? allowance-contract-callers
                       { sender: tx-sender, contract-caller: contract-caller})
              false))
          (expires-at
                ;; if until-burn-ht not set, then return true (because no expiry)
            (unwrap! (get until-burn-ht caller-allowed) true)))
          ;; is the caller allowance still valid
      (< burn-block-height expires-at))))

;; Returns the burn height at which a particular contract is allowed to stack for a particular principal.
;; The result is (some (some X)) if X is the burn height at which the allowance terminates.
;; The result is (some none) if the caller is allowed indefinitely.
;; The result is none if there is no allowance record.
(define-read-only (get-allowance-contract-callers (sender principal) (calling-contract principal))
  (map-get? allowance-contract-callers { sender: sender, contract-caller: calling-contract}))