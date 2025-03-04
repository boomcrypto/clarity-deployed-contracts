;; Mainnet ft trait implementation
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait) ;;

;; sip-010 function implementation
(define-private (transfer-ft (token-contract <sip-010-trait>) (quantity uint) (sender principal) (recipient principal))
    (contract-call? token-contract transfer quantity sender recipient none)
)

(define-private (get-balance-ft (token-contract <sip-010-trait>) (address principal) )
    (contract-call? token-contract get-balance address)
)

;; errors
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_ALREADY_SUBSCRIBED (err u101))
(define-constant ERR_NOT_SUBSCRIBED (err u102))
(define-constant ERR_ALREADY_ADDED (err u103))
(define-constant ERR_NO_MEME (err u104))
(define-constant ERR_TOO_EARLY (err u105))
(define-constant ERR_NOTHING (err u106))
(define-constant ERR_NOT_ALLOWED (err u107))
(define-constant ERR_TOO_MUCH (err u108))
(define-constant ERR_MAX_LEN (err u109))
(define-constant ERR_NOT_ZERO (err u110))
(define-constant ERR_WRONG_BONUS (err u111))
(define-constant ERR_PAUSED (err u112))

;; contract authorization management
(define-data-var OWNER principal tx-sender) ;; 
(define-map MANAGERS principal bool) ;; manager can run some operations on behalft of the owner
(define-data-var OGadded bool false)

(define-public (change-ownership (address principal))
    (begin
        (asserts! (is-eq contract-caller (var-get OWNER)) ERR_OWNER_ONLY)
        (var-set OWNER address)
        (ok true)
    )
)

;; owner can add managers to update users multipliers
(define-public (add-manager (address principal))
    (begin
        (asserts! (is-eq contract-caller (var-get OWNER)) ERR_OWNER_ONLY)
        (map-set MANAGERS address true)
        (ok true)
    )
)

(define-public (remove-manager (address principal))
    (begin
        (asserts! (is-eq contract-caller (var-get OWNER)) ERR_OWNER_ONLY)
        (map-set MANAGERS address false)
        (ok true)
    )
)

;; add ogs address to contract - only one time action!!
;; special multiplier for ogs
(define-public (add-ogs (addresses (list 500 principal)))
    (begin
        (asserts! (is-eq contract-caller (var-get OWNER)) ERR_OWNER_ONLY)
        (asserts! (not (var-get OGadded)) ERR_ALREADY_ADDED)
        (try! (fold check-err (map add-single-og addresses) (ok true)))
        (ok true)
    )
)

(define-private (add-single-og (address principal))
    (let (
            (datas (get-datas address))
            ) 
        (map-set SUBSCRIBERS address {
            active: (get active datas),
            og: true,
            role: (get role datas),
            registered: (get registered datas),
            registered_epoch: (get registered_epoch datas),
            initial_meme_balance: (get initial_meme_balance datas),
            highest_meme_balance: (get highest_meme_balance datas),
            lowest_meme_balance: (get lowest_meme_balance datas),
            last_meme_balance: (get last_meme_balance datas),
            highest_salt_balance: (get highest_salt_balance datas),
            lowest_salt_balance: (get lowest_salt_balance datas),
            last_salt_balance: (get last_salt_balance datas),
            salt_earned: (get salt_earned datas),
            salt_claimed: (get salt_claimed datas),
            last_claim: (get last_claim datas),
        })
        (print {wallet: address, a: "add-og"} )
        (ok true)
    )
)

(define-public (no-more-ogs)
    (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) ERR_OWNER_ONLY)
        (var-set OGadded true)
    (ok true)
))

;; map for blacklisting address
(define-map BLACKLIST principal bool) ;; blacklisted bots

(define-public (add-blacklisted (addresses (list 500 principal)))
    (begin
        (asserts! (is-eq contract-caller (var-get OWNER)) ERR_OWNER_ONLY)
        (try! (fold check-err (map add-single-blacklist addresses) (ok true)))
        (ok true)
    )
)

(define-private (add-single-blacklist (address principal))
    (begin   
        (map-set BLACKLIST address true)
        (print {a: "add-to-blacklist", wallet: address})
        (ok true)
    )
)

(define-public (remove-blacklisted (addresses (list 500 principal)))
    (begin
        (asserts! (is-eq contract-caller (var-get OWNER)) ERR_OWNER_ONLY)
        (try! (fold check-err (map remove-single-blacklist addresses) (ok true)))
        (ok true)
    )
)

(define-private (remove-single-blacklist (address principal))
    (begin   
        (map-set BLACKLIST address false)
        (print {a: "remove-from-blacklist", wallet: address})
        (ok true)
    )
)

;; pause the subscriptions. rewards claim cannot be paused
(define-public (toggle-pause)
    (begin 
    (asserts! (is-eq contract-caller (var-get OWNER)) ERR_OWNER_ONLY)
        (var-set PAUSED (not (var-get PAUSED)))
    (ok true)
))

;; Managers functions

;; managers can add a special multiplier for every epoch based on offchain calcultation
(define-public (add-many-wallet-reward (addresses (list 500 {address: principal, reward: uint, epoch: uint})))
        (fold check-err (map add-single-wallet-reward addresses) (ok true))
)

(define-private (add-single-wallet-reward (wallet {address: principal, reward: uint, epoch: uint}))
        (add-wallet-reward (get address wallet) (get reward wallet) (get epoch wallet) )
)

(define-public (add-wallet-reward (address principal) (reward uint) (epoch uint) )
    (begin
        (asserts! (or (is-eq contract-caller (var-get OWNER)) (is-manager contract-caller)) ERR_NOT_ALLOWED)
        (let (
            (datas (get-datas address))
            (current-reward (get salt_earned datas))
            (total-earned (+ reward current-reward))
            )
        (map-set SUBSCRIBERS address {
            active: (get active datas),
            og: (get og datas),
            role: (get role datas),
            registered: (get registered datas),
            registered_epoch: (get registered_epoch datas),
            initial_meme_balance: (get initial_meme_balance datas),
            highest_meme_balance: (get highest_meme_balance datas),
            lowest_meme_balance: (get lowest_meme_balance datas),
            last_meme_balance: (get last_meme_balance datas),
            highest_salt_balance: (get highest_salt_balance datas),
            lowest_salt_balance: (get lowest_salt_balance datas),
            last_salt_balance: (get last_salt_balance datas),
            salt_earned: total-earned,
            salt_claimed: (get salt_claimed datas),
            last_claim: (get last_claim datas),
        })
        (print {wallet: address, epoch: epoch, earned: reward, total_earned: total-earned, a: "add-reward"} )
        (if (get active datas)
            (begin 
                (var-set TOTAL_SALT_EARNED (+ (var-get TOTAL_SALT_EARNED) reward))
                (ok true)
            )
            (ok true)

        )
        )
))

(define-public (add-many-wallet-role (addresses (list 500 {address: principal, role: (string-ascii 12)})))
        (fold check-err (map add-single-wallet-role addresses) (ok true))
)

(define-private (add-single-wallet-role (wallet {address: principal, role: (string-ascii 12)}))
        (add-wallet-role (get address wallet) (get role wallet) )
)

(define-public (add-wallet-role (address principal) (role (string-ascii 12)) )
    (begin
        (asserts! (or (is-eq contract-caller (var-get OWNER)) (is-manager contract-caller)) ERR_NOT_ALLOWED)
        (let (
            (datas (get-datas address))
            )
        (map-set SUBSCRIBERS address {
            active: (get active datas),
            og: (get og datas),
            role: role,
            registered: (get registered datas),
            registered_epoch: (get registered_epoch datas),
            initial_meme_balance: (get initial_meme_balance datas),
            highest_meme_balance: (get highest_meme_balance datas),
            lowest_meme_balance: (get lowest_meme_balance datas),
            last_meme_balance: (get last_meme_balance datas),
            highest_salt_balance: (get highest_salt_balance datas),
            lowest_salt_balance: (get lowest_salt_balance datas),
            last_salt_balance: (get last_salt_balance datas),
            salt_earned: (get salt_earned datas),
            salt_claimed: (get salt_claimed datas),
            last_claim: (get last_claim datas),
        })
        (print {wallet: address, role: role, a: "add-role"} )
        (ok true))
))

;; token contracts
(define-constant MEME 'SP3HNEXSXJK2RYNG5P6YSEE53FREX645JPJJ5FBFA.meme-stxcity) ;; 
(define-constant SALT 'SP3HNEXSXJK2RYNG5P6YSEE53FREX645JPJJ5FBFA.salt) ;;

;; parameter for epoch and halving
(define-constant EPOCH_START (+ burn-block-height u880880)) ;; u880880 approx 25 jan 25
(define-constant EPOCH_DURATION u1008) ;; u1008 aprox. 1 week at a rate of 144 btc blocks per day
(define-constant HALVING_DURATION (* u1008 u13)) ;; u13104 aprox. 3 months at a rate of 144 btc blocks per day / 13 epochs

;; pause the contract function to subscribe
(define-data-var PAUSED bool false) ;;
;; $SALT trackers
(define-data-var TOTAL_SALT_EARNED uint u0) ;;
(define-data-var TOTAL_SALT_CLAIMED uint u0) ;;
;; subscriber count
(define-data-var TOTAL_SUBSCRIBERS uint u0) ;;
;; basic wallet information
(define-map SUBSCRIBERS principal {
    active: bool,
    og: bool,
    role: (string-ascii 12),
    registered: uint,
    registered_epoch: uint,
    initial_meme_balance: uint,
    highest_meme_balance: uint,
    lowest_meme_balance: uint,
    last_meme_balance: uint,
    highest_salt_balance: uint,
    lowest_salt_balance: uint,
    last_salt_balance: uint,
    salt_earned: uint,
    salt_claimed: uint,
    last_claim: uint,
    })

;; subscribe to the contract to be allowed to mint Salt

(define-public (subscribe)
    (let (
        (meme-balance (unwrap-panic (get-balance-ft MEME contract-caller)))
        (salt-balance (unwrap-panic (get-balance-ft SALT contract-caller)))
        (datas (get-datas contract-caller))
        (current-block burn-block-height)
        (current-epoch (get-current-epoch))
    )
    (asserts! (not (get active datas)) ERR_ALREADY_SUBSCRIBED)
    (asserts! (not (var-get PAUSED)) ERR_PAUSED)
    (asserts!  (> meme-balance u0) ERR_NO_MEME)
    (asserts! (not (is-blacklisted contract-caller)) ERR_NOT_ALLOWED)
    (begin
        (map-set SUBSCRIBERS contract-caller {
            active: true,
            og: (get og datas),
            role: "base",
            registered: current-block,
            registered_epoch: (if (<= current-block EPOCH_START) u0 current-epoch),
            initial_meme_balance: meme-balance,
            highest_meme_balance: meme-balance,
            lowest_meme_balance: meme-balance,
            last_meme_balance: meme-balance,
            highest_salt_balance: salt-balance,
            lowest_salt_balance: salt-balance,
            last_salt_balance: salt-balance,
            salt_earned: u0,
            salt_claimed: u0,
            last_claim: u0,
        })
        (var-set TOTAL_SUBSCRIBERS (+ (var-get TOTAL_SUBSCRIBERS) u1))
        (print {
            a: "subscribe",
            address: contract-caller,
            active: true,
            og: (get og datas),
            role: "base",
            registered: burn-block-height,
            registered_epoch: (if (<= current-block EPOCH_START) u0 current-epoch),
            initial_meme_balance: meme-balance,
            highest_meme_balance: meme-balance,
            lowest_meme_balance: meme-balance,
            last_meme_balance: meme-balance,
            highest_salt_balance: salt-balance,
            lowest_salt_balance: salt-balance,
            last_salt_balance: salt-balance,
            salt_earned: u0,
            salt_claimed: u0,
            last_claim: u0,
        })
        (ok true))
    )
)

;; based on multipliers an user can redeem on epoch basis his reward
(define-public (get-salted (amount uint))
    (let (
        (datas (get-datas contract-caller))
        (meme-balance (unwrap-panic (get-balance-ft MEME contract-caller)))
        (salt-balance (unwrap-panic (get-balance-ft SALT contract-caller)))
        (sender contract-caller)
    )
        (asserts! (get active datas) ERR_NOT_SUBSCRIBED)
        (asserts! (> amount u0) ERR_NOT_ZERO)
        (asserts! (not (is-blacklisted contract-caller)) ERR_NOT_ALLOWED)
        (let (       
            ;; start the calculation
            (available-amount (unwrap-panic (calculate-amount contract-caller )))
        )
        (asserts! (> available-amount u0) ERR_NOTHING)
        (asserts! (<= amount available-amount ) ERR_TOO_MUCH)
        (map-set SUBSCRIBERS contract-caller {
            active: (get active datas),
            og: (get og datas),
            role: (get role datas),
            registered: (get registered datas),
            registered_epoch: (get registered_epoch datas),
            initial_meme_balance: (get initial_meme_balance datas),
            highest_meme_balance: (if (> meme-balance (get highest_meme_balance datas)) meme-balance (get highest_meme_balance datas)),
            lowest_meme_balance: (if (< meme-balance (get lowest_meme_balance datas)) meme-balance (get lowest_meme_balance datas)),
            last_meme_balance: meme-balance,
            highest_salt_balance: (if (> salt-balance (get highest_salt_balance datas)) salt-balance (get highest_salt_balance datas)),
            lowest_salt_balance: (if (< salt-balance (get lowest_salt_balance datas)) salt-balance (get lowest_salt_balance datas)),
            last_salt_balance: salt-balance,
            salt_earned: (get salt_earned datas),
            salt_claimed: (+ (get salt_claimed datas) amount),
            last_claim: burn-block-height,
        })
        (print {
            a: "get-salted",
            amount: amount,
            address: contract-caller,
            active: (get active datas),
            og: (get og datas),
            role: (get role datas),
            registered: (get registered datas),
            registered_epoch: (get registered_epoch datas),
            initial_meme_balance: (get initial_meme_balance datas),
            highest_meme_balance: (if (> meme-balance (get highest_meme_balance datas)) meme-balance (get highest_meme_balance datas)),
            lowest_meme_balance: (if (< meme-balance (get lowest_meme_balance datas)) meme-balance (get lowest_meme_balance datas)),
            last_meme_balance: meme-balance,
            highest_salt_balance: (if (> salt-balance (get highest_salt_balance datas)) salt-balance (get highest_salt_balance datas)),
            lowest_salt_balance: (if (< salt-balance (get lowest_salt_balance datas)) salt-balance (get lowest_salt_balance datas)),
            last_salt_balance: salt-balance,
            salt_earned: (get salt_earned datas),
            salt_claimed: (+ (get salt_claimed datas) amount),
            last_claim: burn-block-height,
        })
        (try! (as-contract (transfer-ft SALT amount tx-sender sender  )))
        (if (get active datas)
            (begin 
                (var-set TOTAL_SALT_CLAIMED (+ (var-get TOTAL_SALT_CLAIMED) amount))
                (ok true)
            )
            (ok true)
        )
        )
    )
)

;; simple helper to read current available amount to withdraw
(define-read-only (calculate-amount 
                (address principal) 
                )
    (let (
        (datas (get-datas address))
        (earned-reward (get salt_earned datas))
        (claimed-reward (get salt_claimed datas))
        )
        (if (or (is-eq earned-reward u0) (is-eq claimed-reward earned-reward) )
            (ok u0) ;; if wallet-bonus is u0 returns u0
            (let (
                (amount-salted (- earned-reward claimed-reward))
                )
                (ok amount-salted)
            )
        )
    )
)

;; read-only call to get wallet datas
(define-read-only (get-datas (address principal))
    (default-to {
        active: false,
        og: false,
        role: "none",
        registered: u0,
        registered_epoch: u0,
        initial_meme_balance: u0,
        highest_meme_balance: u0,
        lowest_meme_balance: u0,
        last_meme_balance: u0,
        highest_salt_balance: u0,
        lowest_salt_balance: u0,
        last_salt_balance: u0,
        salt_earned: u0,
        salt_claimed: u0,
        last_claim: u0
    } (map-get? SUBSCRIBERS address))
)

;; single contract statistics
(define-read-only (get-total-earned)
    (var-get TOTAL_SALT_EARNED)
)
(define-read-only (get-total-claimed)
    (var-get TOTAL_SALT_CLAIMED)
)
(define-read-only (get-total-subscribers)
    (var-get TOTAL_SUBSCRIBERS)
)

;; main contract statistics
(define-read-only (get-stats)
    (ok {
        total_subscribers: (get-total-subscribers),
        total_salt_earned: (get-total-earned),
        total_salt_claimed: (get-total-claimed),
        current_epoch: (get-current-epoch),
        current_halving: (get-current-halving),
        next_epoch_start: (if (< burn-block-height EPOCH_START) 
                                EPOCH_START 
                                (get-epoch-start (+ (get-current-epoch) u1))
                                ),
        next_halving_start: (if (< burn-block-height EPOCH_START) 
                                (get-epoch-start u13) 
                                (get-epoch-start (* (+ (get-current-halving) u1) u13))),
        })
)

;; authorizations helpers
(define-private (is-manager (address principal))
    (default-to false (map-get? MANAGERS address))
)

(define-private (is-blacklisted (address principal))
    (default-to false (map-get? BLACKLIST address))
)

;; helpers
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

;; epoch and halving helpers
(define-read-only (get-current-epoch)
    (if (>= burn-block-height EPOCH_START)
        (/ (- burn-block-height EPOCH_START) EPOCH_DURATION)
        u0)
)

(define-read-only (get-current-halving)
    (if (>= burn-block-height EPOCH_START)
        (/ (- burn-block-height EPOCH_START) HALVING_DURATION)
        u0)
)

(define-private (get-epoch-start (epoch uint))
    (if (is-eq epoch u0)
    EPOCH_START
    (+ EPOCH_START (* EPOCH_DURATION epoch))
    )
)

(define-read-only (get-epoch-halving (epoch uint))
    (if (>= epoch u13)
        (/ (* epoch EPOCH_DURATION) HALVING_DURATION)
        u0)
)


