;; Implement the `ft-trait` trait defined in the `ft-trait` contract - SIP 10
;; This can use sugared syntax in real deployment (unit tests do not allow)
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)

;; vSTSW_TOKEN ERRORS 4270~4289
(define-constant ERR_PERMISSION_DENIED u4270)
(define-constant ERR_STSW_TRANSFER u4272)
(define-constant ERR_MONTH_TOO_LARGE u4273)
(define-constant ERR_NO_DATA u4275)
(define-constant ERR_BLOCK_HEIGHT_NOT_REACHED u4276)
(define-constant ERR_ALREADY_RETURNED u4277)
(define-constant ERR_COOLDOWN_ALREADY_SET u4278)
(define-constant ERR_COOLDOWN_NOT_SET u4279)
(define-constant ERR_COOLDOWN_NOT_REACHED u4280)

(define-constant COOLDOWN_CYCLE u1008)  ;;u1008
(define-constant STAKING_CYCLE u4320)  ;;u4320

;; Data variables specific to the deployed token contract
(define-data-var token-name (string-ascii 32) "vSTACKSWAP")
(define-data-var token-symbol (string-ascii 32) "vSTSW")
(define-data-var token-decimals uint u6)

;; Track who deployed the token and whether it has been initialized
(define-data-var deployer-principal principal 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275)
(define-data-var is-initialized bool false)

;; Meta Read Only Functions for reading details about the contract - conforms to SIP 10
;; --------------------------------------------------------------------------

;; Defines built in support functions for tokens used in this contract
;; A second optional parameter can be added here to set an upper limit on max total-supply
(define-fungible-token vstsw)

;; Get the token balance of the specified owner in base units
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance vstsw owner)))

;; Returns the token name
(define-read-only (get-name)
  (ok (var-get token-name)))

;; Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

;; Returns the number of decimals used
(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

;; Returns the total number of tokens that currently exist
(define-read-only (get-total-supply)
  (ok (ft-get-supply vstsw)))


;; Write function to transfer tokens between accounts - conforms to SIP 10
;; --------------------------------------------------------------------------

;; Transfers tokens to a recipient
;; The originator of the transaction (tx-sender) must be the 'sender' principal
;; Smart contracts can move tokens from their own address by calling transfer with the 'as-contract' modifier to override the tx-sender.

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (let (
      (governance (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5e get-qualified-name-by-name "governance")))
    )
    (asserts! (is-eq from tx-sender) (err ERR_PERMISSION_DENIED))
    (try! (ft-transfer? vstsw amount from to))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

;; Token URI
;; --------------------------------------------------------------------------

;; Variable for URI storage
(define-data-var uri (string-utf8 256) u"https://app.stackswap.org/token/vstsw.json")

;; Public getter for the URI
(define-read-only (get-token-uri)
  (ok (some (var-get uri))))

;; Setter for the URI - only the owner can set it
(define-public (set-token-uri (updated-uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get deployer-principal)) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-uri", updated-uri: updated-uri })
    (ok (var-set uri updated-uri))))


;; At a given user:
;; - how many staking
(define-map UserStakingCount
  principal ;; user
  {
    idx: uint, ;;staking  count
    stakedSTX: uint
  }
)

;; returns the total staked tokens and committed uSTX for a given reward cycle
(define-read-only (get-user-count (user principal))
  (map-get? UserStakingCount user)
)

;; returns the total staked tokens and committed uSTX for a given reward cycle
;; or, an empty structure
(define-read-only (get-user-count-or-default (user principal))
  (default-to   {
                  idx: u0, 
                  stakedSTX: u0
                }
    (map-get? UserStakingCount user))
)

;; At a given reward user ID and idx:
;; - ?
;; - ?
(define-map UserStakingInfos
  {
    user: principal,
    idx: uint
  }
  {
    amountSTSW: uint,
    amountvSTSW: uint,
    endBlock: uint,
    cooldownBlock: uint,
    returned: bool
  }
)

(define-read-only (get-user-info (user principal) (idx uint))
  (map-get? UserStakingInfos { user: user, idx: idx })
)

(define-read-only (get-user-info-or-default  (user principal) (idx uint))
  (default-to { amountSTSW: u0, amountvSTSW: u0, endBlock: u0, returned: false}
    (map-get? UserStakingInfos { user: user, idx: idx }))
)
  
(define-constant POW_LIST (list u1000	u1059	u1122	u1189	u1260	u1335	u1414	u1498	u1587	u1682	u1782	u1888	u2000	u2119	u2245	u2378	u2520	u2670	u2828	u2997	u3175	u3364	u3564	u3775	u4000	u4238	u4490	u4757	u5040	u5339	u5657	u5993	u6350	u6727	u7127	u7551	u8000))

(define-read-only (get-amount (amount uint) (month uint))
  (/ (* amount (unwrap-panic (element-at POW_LIST month))) u1000)
)

(define-public (stake-tokens (amount uint) (month uint))
  (let (
      (need-block (* month STAKING_CYCLE))
      (end-block (+ need-block block-height))
      (check-month (asserts! (< month u37) (err ERR_MONTH_TOO_LARGE)))
      (amount-vstsw (get-amount amount month))
      (user tx-sender)
      (userinfo (get-user-count-or-default user))
      (user-idx (+ (get idx userinfo) u1))
    )
    (map-set UserStakingCount
      user 
      {
        idx: user-idx,
        stakedSTX: (+ (get stakedSTX userinfo) amount)
      }
    )
    (map-set UserStakingInfos
      {
        user: user,
        idx: user-idx
      }
      {
        amountSTSW: amount,
        amountvSTSW: amount-vstsw,
        endBlock: end-block,
        cooldownBlock: u999999999999999999,
        returned: false
      }
    )
    (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a transfer amount user (as-contract tx-sender) none) (err ERR_STSW_TRANSFER))
    (try! (ft-mint? vstsw amount-vstsw user))
    (ok {amount-vSTSW: amount-vstsw, end-block: end-block, user-idx: user-idx})
  )
)

(define-public (cool-down-tokens (idx uint))
  (let (
      (user tx-sender)
      (user-data-cap (map-get? UserStakingInfos {user: user, idx: idx}))
    )
    (match user-data-cap user-data
      ;;some
      (begin
        (asserts! (>= block-height (get endBlock user-data)) (err ERR_BLOCK_HEIGHT_NOT_REACHED))
        (asserts! (not (get returned user-data)) (err ERR_ALREADY_RETURNED))
        (asserts! (is-eq (get cooldownBlock user-data) u999999999999999999) (err ERR_COOLDOWN_ALREADY_SET))
        (map-set UserStakingInfos {user: user, idx: idx} (merge user-data {cooldownBlock: (+ block-height COOLDOWN_CYCLE)}))
        (ok true)
      )
      ;;none
      (err ERR_NO_DATA)
    )
  )
)

(define-public (unstake-tokens (idx uint) (user principal))
  (let (
      (user-data-cap (map-get? UserStakingInfos {user: user, idx: idx}))
      (userinfo (get-user-count-or-default user))
    )
    (match user-data-cap user-data
      ;;some
      (begin
        (asserts! (>= block-height (get endBlock user-data)) (err ERR_BLOCK_HEIGHT_NOT_REACHED))
        (asserts! (not (get returned user-data)) (err ERR_ALREADY_RETURNED))
        (asserts! (not (is-eq (get cooldownBlock user-data) u999999999999999999)) (err ERR_COOLDOWN_NOT_SET))
        (asserts! (not (>= (get cooldownBlock user-data) block-height)) (err ERR_COOLDOWN_NOT_REACHED))
        (try! (ft-burn? vstsw (get amountvSTSW user-data) user))
        (unwrap! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a transfer (get amountSTSW user-data) tx-sender user none)) (err ERR_STSW_TRANSFER))
        (map-set UserStakingCount
          user 
          (merge userinfo { stakedSTX: (- (get stakedSTX userinfo) (get amountSTSW user-data))})
          
        )
        (map-set UserStakingInfos {user: user, idx: idx} (merge user-data {returned: true}))
        (ok true)
      )
      ;;none
      (err ERR_NO_DATA)
    )
  )
)