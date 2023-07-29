;; Crash Punk NFT(s) -> $SNOW Staking Contract
;; This contract is in charge of handling all staking within the Crash Punks ecosystem.
;; Written by StrataLabs


;; $SNOW FT Unique Properties
;; 1. Minting is only allowed by the staking contract

(use-trait nft-trait .nft-trait.nft-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;
;; Vars/Cons ;;
;;;;;;;;;;;;;;;

;; @desc - Uint that represents the *max* possible stake reward per block
(define-constant max-payout-per-block u69444)

;; (temporary) Helper Variable to stake and unstake custodial
(define-data-var function-caller-helper-to-unstake principal tx-sender)

;; @desc - List of principals that represents all whitelisted, actively-staking collections
(define-data-var whitelist-collections (list 100 principal) 
  (list 
    'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2
    'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS.crash-punks-animated-series
    'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G.crash-punks-animated-punks
    'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G.crash-punks-animated-series-ep-1
    'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes
    'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-vip-pass
    'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD.crash-punks-termination-shock
    'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G.crashpunks-punkettes
    'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.brandx
    'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.the-smiley-collection
    'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xlove
    'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens
    'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.narcotix
    'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft
    'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles
    'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles
    'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106.giraffe-mafia
    'SP3M05ETW09E98NNFMFHT1WND3ZRX9DV31TFC6DFW.hooch-haus---booze-brains
    'SP3M05ETW09E98NNFMFHT1WND3ZRX9DV31TFC6DFW.hooch-haus-creature-feature
    'SP3252T1HMQHZTA9S22WZ2HZMKC4CVH965SHSERTH.the-guests-woymuls
    'SP3252T1HMQHZTA9S22WZ2HZMKC4CVH965SHSERTH.misfit-chimp-society
    'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.the-guests
    'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d
    'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-parrots
    'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents
    'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa
    'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.project-indigo-act1
    'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft
    'SP2W12MNM4SPV37VZHN4GCDG35G9ACG3FDKK7WF04.MetaBoy
    'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.sol-townsfolk-nft
    'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2
    'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild
    'SP2ESPYE74G94D2HD9X470426W1R6C2P22B4Z1Q5.skullcoin-souls-nft
    'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft
    'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys
  )
)
(define-data-var custodial-whitelist-collections (list 100 principal)
  (list 
    'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2
    'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS.crash-punks-animated-series
    'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G.crash-punks-animated-punks
    'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G.crash-punks-animated-series-ep-1
    'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes
    'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-vip-pass
    'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD.crash-punks-termination-shock
    'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G.crashpunks-punkettes
    'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.brandx
    'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.the-smiley-collection
    'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xlove
    'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens
    'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.narcotix
    'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft
    'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles
    'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles
    'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106.giraffe-mafia
    'SP3M05ETW09E98NNFMFHT1WND3ZRX9DV31TFC6DFW.hooch-haus---booze-brains
    'SP3M05ETW09E98NNFMFHT1WND3ZRX9DV31TFC6DFW.hooch-haus-creature-feature
    'SP3252T1HMQHZTA9S22WZ2HZMKC4CVH965SHSERTH.the-guests-woymuls
    'SP3252T1HMQHZTA9S22WZ2HZMKC4CVH965SHSERTH.misfit-chimp-society
    'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.the-guests
    'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d
    'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-parrots
    'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents
    'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa
    'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.project-indigo-act1
    'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft
    'SP2W12MNM4SPV37VZHN4GCDG35G9ACG3FDKK7WF04.MetaBoy
    'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.sol-townsfolk-nft
    'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2
    'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild
    'SP2ESPYE74G94D2HD9X470426W1R6C2P22B4Z1Q5.skullcoin-souls-nft
    'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft
    'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys
  )
)
(define-data-var non-custodial-whitelist-collections (list 100 principal) (list))

;; @desc - (temporary) Uint that's used to aggregate when calling "get-unclaimed-balance"
(define-data-var helper-total-unclaimed-balance uint u0)

;; @desc - (temporary) Principal that's used to temporarily hold a collection principal
(define-data-var helper-collection-principal principal tx-sender)

;; @desc - (temporary) List of uints that's used to temporarily hold the output of a map resulting in a list of height differences (aka blocks staked)
(define-data-var helper-height-difference-list (list 10000 uint) (list))

;; @desc - (temporary) Uint that needs to be removed when unstaking
(define-data-var id-being-removed uint u0)

;; @desc - Map that keeps track of whitelisted principal (key) & corresponding multiplier (value)
(define-map collection-multiplier principal uint)
;; CrashPunks Collections
(map-set collection-multiplier 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 u10)
(map-set collection-multiplier 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS.crash-punks-animated-series u8)
(map-set collection-multiplier 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G.crash-punks-animated-punks u6)
(map-set collection-multiplier 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G.crash-punks-animated-series-ep-1 u5)
(map-set collection-multiplier 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-boxes u5)
(map-set collection-multiplier 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.crash-punks-vip-pass u3)
(map-set collection-multiplier 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD.crash-punks-termination-shock u2)
(map-set collection-multiplier 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G.crashpunks-punkettes u2)
;; Collaborations
(map-set collection-multiplier 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.brandx u1)
(map-set collection-multiplier 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.the-smiley-collection u1)
(map-set collection-multiplier 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.xlove u1)
(map-set collection-multiplier 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.cx-tokens u1)
(map-set collection-multiplier 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3.narcotix u1)
(map-set collection-multiplier 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.hback-whales-nft u1)
(map-set collection-multiplier 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.monster-satoshibles u1)
(map-set collection-multiplier 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.satoshibles u1)
(map-set collection-multiplier 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106.giraffe-mafia u1)
(map-set collection-multiplier 'SP3M05ETW09E98NNFMFHT1WND3ZRX9DV31TFC6DFW.hooch-haus---booze-brains u1)
(map-set collection-multiplier 'SP3M05ETW09E98NNFMFHT1WND3ZRX9DV31TFC6DFW.hooch-haus-creature-feature u1)
(map-set collection-multiplier 'SP3252T1HMQHZTA9S22WZ2HZMKC4CVH965SHSERTH.the-guests-woymuls u1)
(map-set collection-multiplier 'SP3252T1HMQHZTA9S22WZ2HZMKC4CVH965SHSERTH.misfit-chimp-society u1)
(map-set collection-multiplier 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.the-guests u1)
(map-set collection-multiplier 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.stacks-parrots-3d u1)
(map-set collection-multiplier 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-parrots u1)
(map-set collection-multiplier 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents u1)
(map-set collection-multiplier 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.steady-lads-msa u1)
(map-set collection-multiplier 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.project-indigo-act1 u1)
(map-set collection-multiplier 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-nft u1)
(map-set collection-multiplier 'SP2W12MNM4SPV37VZHN4GCDG35G9ACG3FDKK7WF04.MetaBoy u1)
(map-set collection-multiplier 'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.sol-townsfolk-nft u1)
(map-set collection-multiplier 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 u1)
(map-set collection-multiplier 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.the-explorer-guild u1)
(map-set collection-multiplier 'SP2ESPYE74G94D2HD9X470426W1R6C2P22B4Z1Q5.skullcoin-souls-nft u1)
(map-set collection-multiplier 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft u1)
(map-set collection-multiplier 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys u1)

;; @desc - List of principals that are whitelisted/have admin privileges
(define-data-var whitelist-admins (list 100 principal) (list tx-sender))

;; @desc - Map that tracks a staked item details (value) by collection & ID (key)
(define-map staked-item {collection: principal, id: uint}
  {
    staker: principal,
    status: bool,
    last-staked-or-claimed: uint
  }
)

;; @desc - Map that tracks all staked IDs (value) by collection principal (key)
(define-map all-stakes-in-collection principal (list 10000 uint))

;; @desc - Map that tracks all staked IDs in a collection (value) by user & collection & ID (key)
(define-map user-stakes-by-collection {user: principal, collection: principal}
  (list 10000 uint)
)

;;;;;;;;;;;;;;;;
;; Error Cons ;;
;;;;;;;;;;;;;;;;

(define-constant ERR-NOT-AUTH (err u101))
(define-constant ERR-NOT-STAKED (err u102))
(define-constant ERR-STAKED-OR-NONE (err u103))
(define-constant ERR-NOT-WHITELISTED (err u104))
(define-constant ERR-UNWRAP (err u105))
(define-constant ERR-NOT-OWNER (err u106))
(define-constant ERR-MIN-STAKE-HEIGHT (err u107))
(define-constant ERR-ALREADY-WHITELISTED (err u108))
(define-constant ERR-MULTIPLIER (err u109))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Read Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (active-admins)
  (var-get whitelist-admins)
)

(define-read-only (active-collections)
  (var-get whitelist-collections)
)

(define-read-only (custodial-active-collections)
  (var-get custodial-whitelist-collections)
)

(define-read-only (non-custodial-active-collections)
  (var-get non-custodial-whitelist-collections)
)

;; @desc - Read only to get how many snow per day a collection is generating
(define-read-only (get-generation-rate-of-a-collection (collection principal)) 
  (map-get? collection-multiplier collection)
)

;; @desc - Read function that returns the current generation rate for tx-sender across all actively staked collective assets
(define-read-only (get-total-generation-rate-through-all-collections)
  (let
    (
      (list-of-collections-with-active-user-stakes (filter filter-out-collections-with-no-stakes (var-get whitelist-collections)))
      (list-of-generation-per-collection (map map-from-list-staked-to-generation-per-collection list-of-collections-with-active-user-stakes))
    )
    (print list-of-collections-with-active-user-stakes)
    (ok (fold + list-of-generation-per-collection u0))
  )
)

;; @desc - Filter function used which takes in all (list principal) stakeable/whitelist principals & outputs a (list principal) of actively-staked (by tx-sender) principals
(define-private (filter-out-collections-with-no-stakes (collection principal))
  (let
    (
      (collection-staked-by-user-list (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: collection})))
      (collection-staked-by-user-count (len collection-staked-by-user-list))
    )
    (if (>= collection-staked-by-user-count u0)
      true
      false
    )
  )
)

;; @desc - Map function which takes in a list of actively-staked principals & returns a list of current generation rate per collection
(define-private (map-from-list-staked-to-generation-per-collection (collection principal))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier collection)))
      (collection-staked-by-user-list (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: collection})))
      (collection-staked-by-user-count (len collection-staked-by-user-list))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier max-payout-per-block) u10))
    )
    (* this-collection-multiplier-normalized collection-staked-by-user-count)
  )
)

;; @desc - function that gets the unclaimed balance by item and collection
(define-read-only (get-unclaimed-balance-by-collection-and-item (collection <nft-trait>) (item uint))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier (contract-of collection))))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier max-payout-per-block) u10))
      (item-info (get-item-stake-details (contract-of collection) item))
      (get-time-from-staking-or-claiming (unwrap! (get last-staked-or-claimed item-info) ERR-UNWRAP))
      (time-passed (- block-height get-time-from-staking-or-claiming))
    ) 
    ;; check collection is existing whitelist collection
    (asserts! (> this-collection-multiplier u0) ERR-NOT-WHITELISTED)
    ;; check if item is staked
    (asserts! (is-eq true (unwrap! (get status item-info) ERR-UNWRAP)) ERR-NOT-STAKED)
    (ok (* this-collection-multiplier-normalized time-passed))
  )
)

;; @desc - function that gets the unclaimed balance by a list of items and a specific collection
(define-read-only (get-unclaimed-balance-by-collection-and-items (collection <nft-trait>) (items (list 10 (optional uint))))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier (contract-of collection))))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier max-payout-per-block) u10))
      (item-info-1 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u0) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-1 (unwrap! (get last-staked-or-claimed item-info-1) ERR-UNWRAP))
      (time-passed-1 (- block-height get-time-from-staking-or-claiming-1))
      (item-info-2 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u1) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-2 (unwrap! (get last-staked-or-claimed item-info-2) ERR-UNWRAP))
      (time-passed-2 (- block-height get-time-from-staking-or-claiming-2))
      (item-info-3 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u2) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-3 (unwrap! (get last-staked-or-claimed item-info-3) ERR-UNWRAP))
      (time-passed-3 (- block-height get-time-from-staking-or-claiming-3))
      (item-info-4 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u3) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-4 (unwrap! (get last-staked-or-claimed item-info-4) ERR-UNWRAP))
      (time-passed-4 (- block-height get-time-from-staking-or-claiming-4))
      (item-info-5 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u4) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-5 (unwrap! (get last-staked-or-claimed item-info-5) ERR-UNWRAP))
      (time-passed-5 (- block-height get-time-from-staking-or-claiming-5))
      (item-info-6 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u5) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-6 (unwrap! (get last-staked-or-claimed item-info-6) ERR-UNWRAP))
      (time-passed-6 (- block-height get-time-from-staking-or-claiming-6))
      (item-info-7 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u6) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-7 (unwrap! (get last-staked-or-claimed item-info-7) ERR-UNWRAP))
      (time-passed-7 (- block-height get-time-from-staking-or-claiming-7))
      (item-info-8 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u7) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-8 (unwrap! (get last-staked-or-claimed item-info-8) ERR-UNWRAP))
      (time-passed-8 (- block-height get-time-from-staking-or-claiming-8))
      (item-info-9 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u8) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-9 (unwrap! (get last-staked-or-claimed item-info-9) ERR-UNWRAP))
      (time-passed-9 (- block-height get-time-from-staking-or-claiming-9))
      (item-info-10 (get-item-stake-details (contract-of collection) (unwrap! (unwrap! (element-at items u9) ERR-UNWRAP) ERR-UNWRAP)))
      (get-time-from-staking-or-claiming-10 (unwrap! (get last-staked-or-claimed item-info-10) ERR-UNWRAP))
      (time-passed-10 (- block-height get-time-from-staking-or-claiming-10))
    )
    ;; check collection is existing whitelist collection
    (asserts! (> this-collection-multiplier u0) ERR-NOT-WHITELISTED)
    ;; check if item is staked
    (asserts! (is-eq true (unwrap! (get status item-info-1) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-2) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-3) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-4) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-5) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-6) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-7) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-8) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-9) ERR-UNWRAP)) ERR-NOT-STAKED)
    (asserts! (is-eq true (unwrap! (get status item-info-10) ERR-UNWRAP)) ERR-NOT-STAKED)
    ;; Return a list of balance per each nft on the list
    (ok
      (list
        (* this-collection-multiplier-normalized time-passed-1)
        (* this-collection-multiplier-normalized time-passed-2)
        (* this-collection-multiplier-normalized time-passed-3)
        (* this-collection-multiplier-normalized time-passed-4)
        (* this-collection-multiplier-normalized time-passed-5)
        (* this-collection-multiplier-normalized time-passed-6)
        (* this-collection-multiplier-normalized time-passed-7)
        (* this-collection-multiplier-normalized time-passed-8)
        (* this-collection-multiplier-normalized time-passed-9)
        (* this-collection-multiplier-normalized time-passed-10)
      )
    )
  )
)

;; @desc - Read function that returns a (list uint) of all actively-staked IDs in a collection by user
(define-read-only (get-items-staked-by-collection-and-user (collection <nft-trait>) (user principal))
  (ok (default-to (list) (map-get? user-stakes-by-collection {user: user, collection: (contract-of collection)})))
)

;; @desc - Read function that returns stake details (staker, status, last-staked-or-claimed) in a specific collection & id
(define-read-only (get-item-stake-details (collection principal) (item-id uint))
      (map-get? staked-item {collection: collection, id: item-id})
)

;; @desc - Read function that returns the tx-sender's total unclaimed balance across all whitelisted collections
(define-public (get-unclaimed-balance)
  (let
    (
      ;; Filter from (list principal) of all whitelist principals/NFTs to (list principal) of all whitelist principals/NFTs where user has > 0 stakes
      (this-collection-stakes-by-user (filter filter-out-collections-with-no-stakes (var-get whitelist-collections)))
      (list-of-height-differences (list))
    )
    ;; 1. Filter from whitelisted to active staked
    ;; 2. Map from a list of principals to a list of uints
    ;; clear temporary unclaimed balance uint
    (var-set helper-total-unclaimed-balance u0)
    ;; map through this-collection-stakes-by-user, don't care about output list, care about appending to list-of-height-differences
    (map map-to-append-to-list-of-height-differences this-collection-stakes-by-user)
    ;; return unclaimed balance from tx-sender
    (ok (var-get helper-total-unclaimed-balance))
  )
)

;; @desc - looping through all the collections that a user *does* have active stakes, goal of this function is to append the unclaimed balance from each collection to a new list (helper-height-difference)
(define-private (map-to-append-to-list-of-height-differences (collection principal))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier collection)))
      (this-collection-stakes-by-user (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: collection})))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier max-payout-per-block) u10))
    )
    ;; set helper list to empty
    (var-set helper-height-difference-list (list))
    ;; Set collection helper var for folding through height differences
    (var-set helper-collection-principal collection)
    ;; Use map as a loop to append helper list with get-unclaimed-balance-by-collection
    (map append-helper-list-from-id-staked-to-height-difference this-collection-stakes-by-user)
    ;; Total unclaimed balance in collection
    (var-set helper-total-unclaimed-balance
      (+
        (var-get helper-total-unclaimed-balance)
        (* this-collection-multiplier-normalized (fold + (var-get helper-height-difference-list) u0))
      )
    )
    tx-sender
  )
)

;; @desc - function to append the height-difference
(define-private (append-helper-list-from-id-staked-to-height-difference (staked-id uint))
  (let
    (
      (staked-or-claimed-height (get last-staked-or-claimed (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (var-get helper-collection-principal), id: staked-id}))))
      (height-difference (- block-height staked-or-claimed-height))
    )
    (var-set helper-height-difference-list
      (unwrap! (as-max-len? (append (var-get helper-height-difference-list) height-difference) u1000) u0)
    )
    u1
  )
)

;; @desc - Read function that outputs a tx-sender total unclaimed balance from a specific collection
(define-public (get-unclaimed-balance-by-collection (collection <nft-trait>))
  (let
    (
      (this-collection-multiplier (unwrap! (map-get? collection-multiplier (contract-of collection)) (err u0)))
      (this-collection-stakes-by-user (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)})))
      (list-of-staked-height-differences (map map-from-id-staked-to-height-difference this-collection-stakes-by-user))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier max-payout-per-block) u10))
    )
      ;; Assert at least one stake exists
      (asserts! (and (> (len this-collection-stakes-by-user) u0) (> (len list-of-staked-height-differences) u0)) (err u0))
      ;; Var-set helper-collection-principal for use in map-from-id-staked-to-height-difference
      (var-set helper-collection-principal (contract-of collection))
      ;; Unclaimed $SNOW balance by user in this collection
      ;; Fold to aggregate total blocks staked across all IDs, then multiply collection multiplier
      (ok (* this-collection-multiplier-normalized (fold + list-of-staked-height-differences u0)))
  )
)

;; @desc - Helper function used to map from a list of uint of staked ids to a list of uint of height-differences
(define-private (map-from-id-staked-to-height-difference (staked-id uint))
  (let
    (
      (staked-or-claimed-height (get last-staked-or-claimed (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (var-get helper-collection-principal), id: staked-id}))))
    )
    (print (- block-height staked-or-claimed-height))
    (- block-height staked-or-claimed-height)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Stake Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (stake (collection <nft-trait>) (id uint))
  (let
    (
      (current-all-staked-in-collection-list (default-to (list) (map-get? all-stakes-in-collection (contract-of collection))))
      (is-unstaked-in-all-staked-ids-list (index-of current-all-staked-in-collection-list id))
      (is-unstaked-in-staked-by-user-list (index-of (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)})) id))
      (is-unstaked-in-stake-details-map (get status (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (var-get helper-collection-principal), id: id}))))
      (current-nft-owner (unwrap! (contract-call? collection get-owner id) ERR-UNWRAP))
      (custodial-list (var-get custodial-whitelist-collections))
      (transaction-sender tx-sender)
    )
    ;; Assert collection is whitelisted
    (asserts! (is-some (index-of (var-get whitelist-collections) (contract-of collection))) ERR-NOT-WHITELISTED)
    ;; Asserts item is unstaked across all necessary storage
    (asserts! (and (is-none is-unstaked-in-all-staked-ids-list) (is-none is-unstaked-in-staked-by-user-list) (not is-unstaked-in-stake-details-map)) ERR-STAKED-OR-NONE)
    ;; Assert caller is current owner of NFT
    (asserts! (is-eq (some tx-sender) current-nft-owner) ERR-NOT-OWNER)
    ;; manual staking for custodial
    (if
      (is-some (index-of custodial-list (contract-of collection))) 
        (unwrap! (contract-call? collection transfer id tx-sender .cp-staking) (err u401))
    false
    )
    ;; Var set all staked ids list
    (map-set all-stakes-in-collection (contract-of collection)
      (unwrap! (as-max-len? (append (default-to (list) (map-get? all-stakes-in-collection (contract-of collection))) id) u10000) ERR-UNWRAP)
    )
    ;; Map set user staked in collection list
    (map-set user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)}
        (unwrap! (as-max-len? (append (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)})) id) u10000) ERR-UNWRAP)
    )
    ;; Map set staked-item details
    (ok (map-set staked-item {collection: (contract-of collection), id: id}
      {
        staker: tx-sender,
        status: true,
        last-staked-or-claimed: block-height
      }
    ))
  )
)

(define-public (stake-many (collection <nft-trait>) (nfts (list 10 uint)))
  (let 
    (
      (nft-1 (element-at nfts u0))
      (nft-2 (element-at nfts u1))
      (nft-3 (element-at nfts u2))
      (nft-4 (element-at nfts u3))
      (nft-5 (element-at nfts u4))
      (nft-6 (element-at nfts u5))
      (nft-7 (element-at nfts u6))
      (nft-8 (element-at nfts u7))
      (nft-9 (element-at nfts u8))
      (nft-10 (element-at nfts u9))
      (staking-list (list nft-1 nft-2 nft-3 nft-4 nft-5 nft-6 nft-7 nft-8 nft-9 nft-10))
      (stake-1 (if (is-some nft-1) (some (stake collection (unwrap! nft-1 ERR-UNWRAP))) none))
      (stake-2 (if (is-some nft-2) (some (stake collection (unwrap! nft-2 ERR-UNWRAP))) none))
      (stake-3 (if (is-some nft-3) (some (stake collection (unwrap! nft-3 ERR-UNWRAP))) none))
      (stake-4 (if (is-some nft-4) (some (stake collection (unwrap! nft-4 ERR-UNWRAP))) none))
      (stake-5 (if (is-some nft-5) (some (stake collection (unwrap! nft-5 ERR-UNWRAP))) none))
      (stake-6 (if (is-some nft-6) (some (stake collection (unwrap! nft-6 ERR-UNWRAP))) none))
      (stake-7 (if (is-some nft-7) (some (stake collection (unwrap! nft-7 ERR-UNWRAP))) none))
      (stake-8 (if (is-some nft-8) (some (stake collection (unwrap! nft-8 ERR-UNWRAP))) none))
      (stake-9 (if (is-some nft-9) (some (stake collection (unwrap! nft-9 ERR-UNWRAP))) none))
      (stake-10 (if (is-some nft-10) (some (stake collection (unwrap! nft-10 ERR-UNWRAP))) none))
      (final-list (list stake-1 stake-2 stake-3 stake-4 stake-5 stake-6 stake-7 stake-8 stake-9 stake-10))
    )
    (ok final-list)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Claim Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc - Function that a user calls to claim any generated stake rewards for a specific collection & specific id
(define-public (claim-item-stake (collection-collective <nft-trait>) (staked-id uint))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier (contract-of collection-collective))))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier max-payout-per-block) u10))
      (current-staker (get staker (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection-collective), id: staked-id}))))
      (stake-status (get status (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection-collective), id: staked-id}))))
      (last-claimed-or-staked-height (get last-staked-or-claimed (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection-collective), id: staked-id}))))
      (current-nft-owner (unwrap! (contract-call? collection-collective get-owner staked-id) ERR-NOT-AUTH))
      (blocks-staked (- block-height last-claimed-or-staked-height))
    )
    ;; assert collection-collective is active/whitelisted
    (asserts! (is-some (index-of (var-get whitelist-collections) (contract-of collection-collective))) ERR-NOT-WHITELISTED)                                     
    ;; asserts is staked
    (asserts! stake-status ERR-NOT-STAKED)
    ;; asserts tx-sender is owner && asserts tx-sender is staker
    (asserts! (is-eq tx-sender current-staker) ERR-NOT-OWNER)
    ;; asserts height-difference > 0
    (asserts! (> blocks-staked u0) ERR-MIN-STAKE-HEIGHT)
    ;; contract call to mint for X amount
    (unwrap! (contract-call? .snow-token mint (* this-collection-multiplier-normalized blocks-staked) tx-sender) ERR-UNWRAP)
    ;; update last-staked-or-claimed height
    (ok (map-set staked-item {collection: (contract-of collection-collective), id: staked-id}
      {
        status: true,
        last-staked-or-claimed: block-height,
        staker: tx-sender
      }
    ))
  )
)

;; @desc -Function that a user calls to stake any current or future SGC asset for $SNOW
;; @param - Collection (principal or collection?), ID (uint) -> bool?
(define-public (claim-all-stake)
  (let
    (
      (list-of-collections-with-active-user-stakes (filter filter-out-collections-with-no-stakes (var-get whitelist-collections)))
      (unclaimed-balance-total (unwrap! (get-unclaimed-balance) ERR-UNWRAP))
    )
    ;; contract call to mint for X amount
    (unwrap! (contract-call? .snow-token mint unclaimed-balance-total tx-sender) ERR-UNWRAP)
    ;; loop through collections, then through IDs, reset last-staked-or-claimed value for each staked ID in each collection by user
    (ok (map map-to-loop-through-active-collection list-of-collections-with-active-user-stakes))
  )
)

(define-private (map-to-loop-through-active-collection (collection principal))
  (let
    (
      (collection-staked-by-user-list (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: collection})))
    )
      (map map-to-set-reset-last-claimed-or-staked-height collection-staked-by-user-list)
      tx-sender
  )
)

(define-private (map-to-set-reset-last-claimed-or-staked-height (staked-id uint))
  (begin
    (map-set staked-item {collection: (var-get helper-collection-principal), id: staked-id}
      (merge
        (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (var-get helper-collection-principal), id: staked-id}))
        {last-staked-or-claimed: block-height}
      )
    )
    u0
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Unstake Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (unstake-item (collection <nft-trait>) (staked-id uint))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier (contract-of collection))))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier max-payout-per-block) u10))
      (current-staker (get staker (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (stake-status (get status (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (last-claimed-or-staked-height (get last-staked-or-claimed (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (current-nft-owner (unwrap! (contract-call? collection get-owner staked-id) ERR-NOT-AUTH))
      (blocks-staked (- block-height last-claimed-or-staked-height))
      (current-all-staked-in-collection-list (default-to (list) (map-get? all-stakes-in-collection (contract-of collection))))
      (current-user-staked-by-collection-list (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)})))
      (custodial-list (var-get custodial-whitelist-collections))
    )
    ;; asserts is staked
    (asserts! stake-status ERR-NOT-STAKED)
    ;; asserts tx-sender is owner staker
    (asserts! (is-eq tx-sender current-staker) ERR-NOT-OWNER)
    ;; check if blocks-staked > 0 to see if there's any unclaimed $SNOW to claim
    (if (> blocks-staked u0)
      ;; if there is, need to claim snow balance
      (unwrap! (contract-call? .snow-token mint (* this-collection-multiplier-normalized blocks-staked) tx-sender) ERR-UNWRAP)
      ;; if not, proceed
      true
    )
    ;; set function caller to tx-sender to send from contract
    (var-set function-caller-helper-to-unstake tx-sender)
    ;;manual unstake of custodial
    (if
        (is-some (index-of custodial-list (contract-of collection)))
        
        (as-contract (unwrap! (contract-call? collection transfer staked-id .cp-staking (var-get function-caller-helper-to-unstake)) (err u401)))

        true
    )
    ;; Set helper id for removal in filters below
    (var-set id-being-removed staked-id)
    ;; filter/remove staked-id from all-stakes-in-collection
    (map-set all-stakes-in-collection (contract-of collection) (filter is-not-id current-all-staked-in-collection-list))
    ;; filter/remove staked-id from user-stakes-by-collection
    (map-set user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)} (filter is-not-id current-user-staked-by-collection-list))
    ;; update last-staked-or-claimed height
    (ok (map-set staked-item {collection: (contract-of collection), id: staked-id}
      {
        status: false,
        last-staked-or-claimed: block-height,
        staker: tx-sender
      }
    ))
  )
)

(define-private (is-not-id (list-id uint))
  (not (is-eq list-id (var-get id-being-removed)))
)

(define-public (unstake-many (collection <nft-trait>) (nfts (list 10 uint)))
  (let 
    (
      (nft-1 (element-at nfts u0))
      (nft-2 (element-at nfts u1))
      (nft-3 (element-at nfts u2))
      (nft-4 (element-at nfts u3))
      (nft-5 (element-at nfts u4))
      (nft-6 (element-at nfts u5))
      (nft-7 (element-at nfts u6))
      (nft-8 (element-at nfts u7))
      (nft-9 (element-at nfts u8))
      (nft-10 (element-at nfts u9))
      (staking-list (list nft-1 nft-2 nft-3 nft-4 nft-5 nft-6 nft-7 nft-8 nft-9 nft-10))
      (stake-1 (if (is-some nft-1) (some (unstake-item collection (unwrap! nft-1 ERR-UNWRAP))) none))
      (stake-2 (if (is-some nft-2) (some (unstake-item collection (unwrap! nft-2 ERR-UNWRAP))) none))
      (stake-3 (if (is-some nft-3) (some (unstake-item collection (unwrap! nft-3 ERR-UNWRAP))) none))
      (stake-4 (if (is-some nft-4) (some (unstake-item collection (unwrap! nft-4 ERR-UNWRAP))) none))
      (stake-5 (if (is-some nft-5) (some (unstake-item collection (unwrap! nft-5 ERR-UNWRAP))) none))
      (stake-6 (if (is-some nft-6) (some (unstake-item collection (unwrap! nft-6 ERR-UNWRAP))) none))
      (stake-7 (if (is-some nft-7) (some (unstake-item collection (unwrap! nft-7 ERR-UNWRAP))) none))
      (stake-8 (if (is-some nft-8) (some (unstake-item collection (unwrap! nft-8 ERR-UNWRAP))) none))
      (stake-9 (if (is-some nft-9) (some (unstake-item collection (unwrap! nft-9 ERR-UNWRAP))) none))
      (stake-10 (if (is-some nft-10) (some (unstake-item collection (unwrap! nft-10 ERR-UNWRAP))) none))
      (final-list (list stake-1 stake-2 stake-3 stake-4 stake-5 stake-6 stake-7 stake-8 stake-9 stake-10))
    )
    (ok final-list)
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Admin Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc - Function that only an admin user can call to add a new SGC collection for staking
;; @param - Collection (principal or collection?), Collection-Multiple (uint)
(define-public (admin-add-new-custodial-collection (collection <nft-trait>) (collection-multiple uint))
  (let
    (
      (active-whitelist (var-get custodial-whitelist-collections))
      (all-whitelist (var-get whitelist-collections))
    )
    ;; assert the tx-sender is admin
    (asserts! (is-some (index-of (var-get whitelist-admins) tx-sender)) ERR-NOT-AUTH)
    ;; assert collection not already added
    (asserts! (is-none (index-of all-whitelist (contract-of collection))) ERR-ALREADY-WHITELISTED)
    ;; assert multiple < 10
    (asserts! (and (< collection-multiple u11) (> collection-multiple u0)) ERR-MULTIPLIER)
    ;; update collection-multiplier map
    (map-set collection-multiplier (contract-of collection) collection-multiple)
    ;; add new principle to whitelist
   (ok 
      (begin
        (var-set custodial-whitelist-collections (unwrap! (as-max-len? (append active-whitelist (contract-of collection)) u100) ERR-UNWRAP))
        (var-set whitelist-collections (unwrap! (as-max-len? (append all-whitelist (contract-of collection)) u100) ERR-UNWRAP))
      )
    )
  )
)

(define-public (admin-remove-custodial-collection (collection <nft-trait>))
  (let
    (
      (active-whitelist (var-get custodial-whitelist-collections))
      (all-whitelist (var-get whitelist-collections))
      (removeable-principal-position-in-custodial-whitelist (index-of active-whitelist (contract-of collection)))
      (removeable-principal-position-in-all-whitelist (index-of all-whitelist (contract-of collection)))
    )
    ;; assert the tx-sender is admin
    (asserts! (is-some (index-of (var-get whitelist-admins) tx-sender)) ERR-NOT-AUTH)
    ;; assert collection is already added in custodial
    (asserts! (is-some (index-of active-whitelist (contract-of collection))) ERR-NOT-WHITELISTED)
    ;; assert collection is already added
    (asserts! (is-some (index-of all-whitelist (contract-of collection))) ERR-NOT-WHITELISTED)
    ;; update collection-multiplier map
    (map-set collection-multiplier (contract-of collection) u0)
    ;; temporary var set to help remove param principal
    (var-set helper-collection-principal (contract-of collection))
    ;; add new principal to whitelist
    (ok 
      (begin
        (var-set whitelist-collections (filter is-not-removeable-collection active-whitelist))
        (var-set custodial-whitelist-collections (filter is-not-removeable-collection all-whitelist))
      )
    )
  )
)

(define-public (admin-add-new-non-custodial-collection (collection <nft-trait>) (collection-multiple uint))
  (let
    (
      (active-whitelist (var-get non-custodial-whitelist-collections))
      (all-whitelist (var-get whitelist-collections))
    )
    ;; assert the tx-sender is admin
    (asserts! (is-some (index-of (var-get whitelist-admins) tx-sender)) ERR-NOT-AUTH)
    ;; assert collection not already added
    (asserts! (is-none (index-of all-whitelist (contract-of collection))) ERR-ALREADY-WHITELISTED)
    ;; assert multiple < 10
    (asserts! (and (< collection-multiple u11) (> collection-multiple u0)) ERR-MULTIPLIER)
    ;; update collection-multiplier map
    (map-set collection-multiplier (contract-of collection) collection-multiple)
    ;; add new principal to whitelist
    (ok 
      (begin
        (var-set non-custodial-whitelist-collections (unwrap! (as-max-len? (append active-whitelist (contract-of collection)) u100) ERR-UNWRAP))
        (var-set whitelist-collections (unwrap! (as-max-len? (append all-whitelist (contract-of collection)) u100) ERR-UNWRAP))
      )
    )
  )
)

(define-public (admin-remove-non-custodial-collection (collection <nft-trait>))
  (let
    (
      (active-whitelist (var-get non-custodial-whitelist-collections))
      (all-whitelist (var-get whitelist-collections))
      (removeable-principal-position-in-non-custodial-whitelist (index-of active-whitelist (contract-of collection)))
      (removeable-principal-position-in-all-whitelist (index-of all-whitelist (contract-of collection)))
    )
    ;; assert the tx-sender is admin
    (asserts! (is-some (index-of (var-get whitelist-admins) tx-sender)) ERR-NOT-AUTH)
    ;; assert collection is already added in non custodial
    (asserts! (is-some (index-of active-whitelist (contract-of collection))) ERR-NOT-WHITELISTED)
    ;; assert collection is already added
    (asserts! (is-some (index-of all-whitelist (contract-of collection))) ERR-NOT-WHITELISTED)
    ;; update collection-multiplier map
    (map-set collection-multiplier (contract-of collection) u0)
    ;; temporary var set to help remove param principal
    (var-set helper-collection-principal (contract-of collection))
    ;; add new principal to whitelist
    (ok 
      (begin
        (var-set whitelist-collections (filter is-not-removeable-collection active-whitelist))
        (var-set non-custodial-whitelist-collections (filter is-not-removeable-collection all-whitelist))
      )
    )
  )
)

;; @desc - Helper function for removing a specific collection from the whitelist
(define-private (is-not-removeable-collection (whitelist-collection principal))
  (not (is-eq whitelist-collection (var-get helper-collection-principal)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add Admin Address For Whitelisting ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc - Function for add principals that have explicit permission to add current or future stakeable collections
;; @param - Principal that we're adding as whitelist
(define-public (add-admin-address-for-whitelisting (new-whitelist principal))
  (let
    (
      (current-admin-list (var-get whitelist-admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (param-principal-position-in-list (index-of current-admin-list new-whitelist))
    )
    ;; asserts tx-sender is an existing whitelist address
    (asserts! (is-some caller-principal-position-in-list) ERR-NOT-AUTH)
    ;; asserts param principal (new whitelist) doesn't already exist
    (asserts! (is-none param-principal-position-in-list) ERR-ALREADY-WHITELISTED)
    ;; append new whitelist address
    (ok (var-set whitelist-admins (unwrap! (as-max-len? (append (var-get whitelist-admins) new-whitelist) u100) ERR-UNWRAP)))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remove Admin Address For Whitelisting ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc - Function for removing principals that have explicit permission to add current or future stakeable collections
;; @param - Principal that we're adding removing as white
(define-public (remove-admin-address-for-whitelisting (remove-whitelist principal))
  (let
    (
      (current-admin-list (var-get whitelist-admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (removeable-principal-position-in-list (index-of current-admin-list remove-whitelist))
    )
    ;; assert the tx-sender is admin
    (asserts! (is-some (index-of (var-get whitelist-admins) tx-sender)) ERR-NOT-AUTH)
    ;; asserts param principal (removeable whitelist) already exist
    (asserts! (is-eq removeable-principal-position-in-list) ERR-NOT-WHITELISTED)
    ;; temporary var set to help remove param principal
    (var-set helper-collection-principal remove-whitelist)
    ;; filter existing whitelist address
    (ok 
      (var-set whitelist-admins (filter is-not-removeable current-admin-list))
    )
  )
)

;; @desc - Helper function for removing a specific admin from the admin whitelist
(define-private (is-not-removeable (admin-principal principal))
  (not (is-eq admin-principal (var-get helper-collection-principal)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Admin Manual Unstake ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc - Function for emergency un-staking all manually custodied assets (Stacculents or Spookies)
;; @param - Principal of collection we're removing, ID of item we're manually unstaking & returning to user

(define-public (admin-emergency-unstake (collection <nft-trait>) (staked-id uint) (original-owner principal))
  (let
    (
      (this-collection-multiplier (default-to u0 (map-get? collection-multiplier (contract-of collection))))
      (this-collection-multiplier-normalized (/ (* this-collection-multiplier max-payout-per-block) u10))
      (current-staker (get staker (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (stake-status (get status (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (last-claimed-or-staked-height (get last-staked-or-claimed (default-to {status: false, last-staked-or-claimed: block-height, staker: tx-sender} (map-get? staked-item {collection: (contract-of collection), id: staked-id}))))
      (current-nft-owner (unwrap! (contract-call? collection get-owner staked-id) ERR-NOT-AUTH))
      (blocks-staked (- block-height last-claimed-or-staked-height))
      (current-all-staked-in-collection-list (default-to (list) (map-get? all-stakes-in-collection (contract-of collection))))
      (current-user-staked-by-collection-list (default-to (list) (map-get? user-stakes-by-collection {user: tx-sender, collection: (contract-of collection)})))
      (custodial-list (var-get custodial-whitelist-collections))
      (admins (var-get whitelist-admins))
    )
    ;; asserts is staked
    (asserts! stake-status ERR-NOT-STAKED)
    ;; asserts original-owner is staker
    (asserts! (is-eq original-owner current-staker) ERR-NOT-OWNER)
    ;; asserts that tx-sender is admin
    (asserts! (is-some (index-of admins tx-sender)) ERR-NOT-AUTH)
    ;; check if blocks-staked > 0 to see if there's any unclaimed $SNOW to claim
    (if (> blocks-staked u0)
      ;; if there is, need to claim unstaked
      (unwrap! (contract-call? .snow-token mint (* this-collection-multiplier-normalized blocks-staked) original-owner) ERR-UNWRAP)
      ;; if not, proceed
      true
    )
    ;;manual unstake of custodial
    (if
        (is-some (index-of custodial-list (contract-of collection)))   
        (as-contract (unwrap! (contract-call? collection transfer staked-id .cp-staking original-owner) (err u401))) 
        true
    )
    ;; Set helper id for removal in filters below
    (var-set id-being-removed staked-id)
    ;; filter/remove staked-id from all-stakes-in-collection
    (map-set all-stakes-in-collection (contract-of collection) (filter is-not-id current-all-staked-in-collection-list))
    ;; filter/remove staked-id from user-stakes-by-collection
    (map-set user-stakes-by-collection {user: original-owner, collection: (contract-of collection)} (filter is-not-id current-user-staked-by-collection-list))
    ;; update last-staked-or-claimed height
    (ok (map-set staked-item {collection: (contract-of collection), id: staked-id}
      {
        status: false,
        last-staked-or-claimed: block-height,
        staker: original-owner
      }
    ))
  )
)

;; Function to change a collection multiplier (amount of SNOW generated per day)
(define-public (change-collection-multiplier (collection principal) (new-multiplier uint))
  (let
    (
      (admins (var-get whitelist-admins))
    )
    (asserts! (is-some (index-of admins tx-sender)) ERR-NOT-AUTH)
    (ok (map-set collection-multiplier collection new-multiplier))
  )
)
