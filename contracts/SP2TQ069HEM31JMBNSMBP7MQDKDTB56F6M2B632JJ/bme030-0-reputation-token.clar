;; Title: BME030 Reputation Token
;; Synopsis:
;; Wraps reputation scheme within a non-transferable soulbound semi fungible token (see sip-013).
;; Description:
;; The reputation token is a SIP-013 compliant token that is controlled by active DAO extensions.
;; It facilitates hierarchical reputation and rewards based on engagements across a number of
;; BigMarket DAO features and use cases. 

(impl-trait 'SPDBEG5X8XD50SPM1JJH0E5CTXGDV5NJTKAKKR5V.sip013-semi-fungible-token-trait.sip013-semi-fungible-token-trait)
(impl-trait 'SPDBEG5X8XD50SPM1JJH0E5CTXGDV5NJTKAKKR5V.sip013-transfer-many-trait.sip013-transfer-many-trait)

(define-constant err-unauthorised (err u30001))
(define-constant err-already-minted (err u30002))
(define-constant err-soulbound (err u30003))
(define-constant err-insufficient-balance (err u30004))
(define-constant err-zero-amount (err u30005))
(define-constant err-claims-old-epoch (err u30006))
(define-constant err-claims-zero-rep (err u30007))
(define-constant err-claims-zero-total (err u30008))
(define-constant err-invalid-tier (err u30009))
(define-constant err-too-high (err u30010))

(define-constant max-tier u20)
(define-constant epoch-duration u1000)

(define-fungible-token bigr-token)
(define-non-fungible-token bigr-id { token-id: uint, owner: principal })

(define-map balances { token-id: uint, owner: principal } uint)
(define-map supplies uint uint)
(define-map last-claimed-epoch { who: principal } uint)
(define-map tier-weights uint uint)

(define-data-var reward-per-epoch uint u10000000000) ;; 10,000 BIG per epoch (in micro units)
(define-data-var overall-supply uint u0)
(define-data-var token-name (string-ascii 32) "BigMarket Reputation Token")
(define-data-var token-symbol (string-ascii 10) "BIGR")
(define-data-var launch-height uint u0)

;; ------------------------
;; DAO Control Check
;; ------------------------
(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .bigmarket-dao) (contract-call? .bigmarket-dao is-extension contract-caller)) err-unauthorised))
)

(define-read-only (get-epoch)
	 (/ burn-block-height epoch-duration)
)

(define-read-only (get-last-claimed-epoch (user principal))
  (default-to u0 (map-get? last-claimed-epoch { who: user }))
)

;; ------------------------
;; Trait Implementations
;; ------------------------
(define-read-only (get-balance (token-id uint) (who principal))
  (ok (default-to u0 (map-get? balances { token-id: token-id, owner: who })))
)

(define-public (set-launch-height)
  (begin
    (try! (is-dao-or-extension))
    (asserts! (is-eq (var-get launch-height) u0) err-unauthorised)
    (var-set launch-height burn-block-height)
    (ok (var-get launch-height))
  )
)

(define-read-only (get-symbol)
	(ok (var-get token-symbol))
)

(define-read-only (get-name)
	(ok (var-get token-name))
)

(define-read-only (get-overall-balance (who principal))
  (ok (ft-get-balance bigr-token who))
)

(define-read-only (get-total-supply (token-id uint))
  (ok (default-to u0 (map-get? supplies token-id)))
)

(define-read-only (get-overall-supply)
  (ok (var-get overall-supply))
)

(define-read-only (get-decimals (token-id uint)) (ok u0))

(define-read-only (get-token-uri (token-id uint))
  (ok none)
)

(define-public (set-reward-per-epoch (new-reward uint))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (<= new-reward u100000000000) err-too-high) ;; cap at 100k BIG
    (var-set reward-per-epoch new-reward)
    (print { event: "set-reward-per-epoch", new-reward: new-reward })
    (ok true)
  )
)
(define-public (set-tier-weight (token-id uint) (weight uint))
  (begin
    (try! (is-dao-or-extension))
    (map-set tier-weights token-id weight)
    (print { event: "set-tier-weight", token-id: token-id, weight: weight })
    (ok true)
  )
)

;; ------------------------
;; Mint / Burn
;; ------------------------
(define-public (mint (recipient principal) (token-id uint) (amount uint))
  (let (
    (base-amount
      (if (not is-in-mainnet)
          (* amount u2) ;; testnet: 2x
          (if (< burn-block-height (+ (var-get launch-height) u12000))
              (/ (* amount u3) u2) ;; 1.5x on early mainnet
              amount))) ;; no early adopter bonus
  )
    (begin
      (try! (is-dao-or-extension))
      (asserts! (> base-amount u0) err-zero-amount)
      (asserts! (and (> token-id u0) (<= token-id max-tier)) err-invalid-tier)
      (try! (ft-mint? bigr-token base-amount recipient))
      (try! (tag-nft { token-id: token-id, owner: recipient }))
      (map-set balances { token-id: token-id, owner: recipient }
        (+ base-amount (default-to u0 (map-get? balances { token-id: token-id, owner: recipient }))))
      (map-set supplies token-id (+ base-amount (default-to u0 (map-get? supplies token-id))))
      (var-set overall-supply (+ (var-get overall-supply) base-amount))
      (print { event: "sft_mint", token-id: token-id, amount: base-amount, recipient: recipient })
      (ok true)
    )
  )
)

(define-public (burn (owner principal) (token-id uint) (amount uint))
  (begin
    (try! (is-dao-or-extension))
    (let ((current (default-to u0 (map-get? balances { token-id: token-id, owner: owner }))))
      (asserts! (>= current amount) err-insufficient-balance)
      (try! (ft-burn? bigr-token amount owner))
      (map-set balances { token-id: token-id, owner: owner } (- current amount))
      (map-set supplies token-id (- (unwrap-panic (get-total-supply token-id)) amount))
      (var-set overall-supply (- (var-get overall-supply) amount))
      (try! (nft-burn? bigr-id { token-id: token-id, owner: owner } owner))
      (print { event: "sft_burn", token-id: token-id, amount: amount, sender: owner })
      (ok true)
    )
  )
)

;; ------------------------
;; Transfer (DAO-only)
;; ------------------------
(define-public (transfer (token-id uint) (amount uint) (sender principal) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (> amount u0) err-zero-amount)
    (let ((sender-balance (default-to u0 (map-get? balances { token-id: token-id, owner: sender }))))
      (asserts! (>= sender-balance amount) err-insufficient-balance)
      (try! (ft-transfer? bigr-token amount sender recipient))
      (try! (tag-nft { token-id: token-id, owner: sender }))
      (try! (tag-nft { token-id: token-id, owner: recipient }))
      (map-set balances { token-id: token-id, owner: sender } (- sender-balance amount))
      (map-set balances { token-id: token-id, owner: recipient }
        (+ amount (default-to u0 (map-get? balances { token-id: token-id, owner: recipient }))))
      (print { event: "sft_transfer", token-id: token-id, amount: amount, sender: sender, recipient: recipient })
      (ok true)
    )
  )
)

(define-public (transfer-memo (token-id uint) (amount uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin
    (try! (transfer token-id amount sender recipient))
    (print memo)
    (ok true)
  )
)

(define-public (transfer-many (transfers (list 200 { token-id: uint, amount: uint, sender: principal, recipient: principal })))
  (fold transfer-many-iter transfers (ok true))
)

(define-public (transfer-many-memo (transfers (list 200 { token-id: uint, amount: uint, sender: principal, recipient: principal, memo: (buff 34) })))
  (fold transfer-many-memo-iter transfers (ok true))
)

;; -------------------------
;; Claims for big from bigr
;; individual and batch supported..
;; -------------------------

(define-public (claim-big-reward)
  (claim-big-reward-for-user tx-sender)
)

(define-public (claim-big-reward-batch (users (list 100 principal)))
  (fold claim-big-reward-batch-iter users (ok u0))
)

(define-private (claim-big-reward-batch-iter (user principal) (acc (response uint uint)))
  (let (
        (a (unwrap! acc err-claims-zero-total))
        (b (unwrap! (claim-big-reward-for-user user) err-claims-zero-total))
      )
    (ok (+ a b))
  )
)

(define-private (claim-big-reward-for-user (user principal)) ;; returns share or u0
  (let (
        (epoch (/ burn-block-height epoch-duration))
        (last (default-to u0 (map-get? last-claimed-epoch { who: user })))
      )
    (if (< last epoch)
      (let (
            (rep (unwrap! (get-weighted-rep user) err-claims-zero-rep))
            (total (unwrap! (get-weighted-supply) err-claims-zero-total))
          )
        (if (and (> rep u0) (> total u0))
          (let ((share (/ (* rep (var-get reward-per-epoch)) total)))
            (map-set last-claimed-epoch { who: user } epoch)
            (try! (contract-call? .bme006-0-treasury sip010-transfer share user none .bme000-0-governance-token))
            (print { event: "big-claim", user: user, epoch: epoch, amount: share, reward-per-epoch: (var-get reward-per-epoch) })
            (ok share)
          )
          (ok u0)
        )
      )
      (ok u0)
    )
  )
)

;; ------------------------
;; Helpers
;; ------------------------
(define-private (tag-nft (nft-token-id { token-id: uint, owner: principal }))
  (begin
    (if (is-some (nft-get-owner? bigr-id nft-token-id))
      (try! (nft-burn? bigr-id nft-token-id (get owner nft-token-id)))
      true)
    (nft-mint? bigr-id nft-token-id (get owner nft-token-id))
  )
)

(define-private (transfer-many-iter (item { token-id: uint, amount: uint, sender: principal, recipient: principal }) (prev (response bool uint)))
  (match prev ok-prev (transfer (get token-id item) (get amount item) (get sender item) (get recipient item)) err-prev prev)
)

(define-private (transfer-many-memo-iter (item { token-id: uint, amount: uint, sender: principal, recipient: principal, memo: (buff 34) }) (prev (response bool uint)))
  (match prev ok-prev (transfer-memo (get token-id item) (get amount item) (get sender item) (get recipient item) (get memo item)) err-prev prev)
)

;; dynamic weighted totals for user
(define-read-only (get-weighted-rep (user principal))
  (let (
    (tiers (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20))
        (result (fold add-weighted-rep-for-user tiers (tuple (acc u0) (user user))))
  )
    (ok (get acc result))
  )
)

(define-private (add-weighted-rep-for-user (token-id uint) (state (tuple (acc uint) (user principal))))
  (let (
    (acc (get acc state))
    (user (get user state))
    (bal-at-tier (default-to u0 (map-get? balances {token-id: token-id, owner: user})))
    (weight-at-tier (default-to u1 (map-get? tier-weights token-id)))
  )
    (tuple (acc (+ acc (* bal-at-tier weight-at-tier))) (user user))
  )
)

;; dynamic weighted totals for overall supply pool
(define-read-only (get-weighted-supply)
  (let (
    (tiers (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20))
    (result (fold add-weighted-supply-for-tier tiers u0))
  )
    (ok result)
  )
)

(define-private (add-weighted-supply-for-tier (token-id uint) (acc uint))
  (let (
    (tier-supply (default-to u0 (map-get? supplies token-id)))
    (weight (default-to u1 (map-get? tier-weights token-id)))
  )
    (+ acc (* tier-supply weight))
  )
)